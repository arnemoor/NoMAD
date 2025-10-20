# Lessons Learned: RunLoop Pumping and Threading in macOS

## Problem Statement

NoMAD was experiencing UI hang risk warnings during sign-in authentication due to blocking OpenDirectory operations on the main thread. The authentication flow also requires waiting for Kerberos operations to complete using a pattern that "pumps" the RunLoop.

**Initial Symptoms:**
- Hang risk warnings at `NoMADUser.swift` lines 84, 425, 435, 460, 470
- UI freeze during authentication (5-10 seconds)
- Code review identified CPU spin loop and race condition in menu click handler

## Why We Couldn't "Just Make It Async"

### Attempt 1: Async Factory Pattern with Background Queue
**What We Tried:** Created `NoMADUser.create()` async factory method on `.userInitiated` QoS queue

**Why It Failed:**
- **Priority Inversion:** OpenDirectory internally uses `.default` QoS, but our code used `.userInitiated`
- High-priority thread waiting on lower-priority operations causes system to prioritize incorrectly
- Still triggered hang risk warnings

**Lesson:** Match QoS levels between caller and callee to avoid priority inversion.

### Attempt 2: Async Factory with Matching QoS
**What We Tried:** Changed async factory to use `.default` QoS to match OpenDirectory

**Why It Failed:**
- **RunLoop Coordination Issues:** The completion handler pattern conflicted with RunLoop pumping
- `checkRemoteUserPassword()` pumps the main RunLoop, but we were calling from background queue
- UI updates queued on main thread didn't execute until mouse movement (idle RunLoop)

**Lesson:** RunLoop pumping requires careful coordination with the thread that has an active RunLoop.

### Attempt 3: Background Queue in LoginWindow
**What We Tried:** Ran authentication on background queue, posted UI updates to main queue

**Why It Failed:**
- **Idle RunLoop Problem:** Main RunLoop was idle while background thread pumped its own RunLoop
- `DispatchQueue.main.async { ... }` queued UI updates, but they didn't execute
- Required mouse events to wake main RunLoop and process queued updates
- User experienced: spinner appears, then requires two mouse movements to complete

**Lesson:** `DispatchQueue.main.async` from a background thread doesn't wake an idle RunLoop.

### Attempt 4: Background Queue in Menu Click Handler
**What We Tried:** Moved Kerberos authentication from `NoMADMenuClickLogIn` to background queue

**Why It Failed:**
```swift
DispatchQueue.global(qos: .default).async {
    let myKerbUtil = KerbUtil()
    var myErr: String?

    self.myWorkQueue.async {
        myErr = myKerbUtil.getKerbCredentials(myPass, userPrinc)  // Write on queue A
    }

    while ( !myKerbUtil.finished ) {
        RunLoop.current.run(mode: .default, before: Date.distantFuture)  // Returns immediately!
    }

    if myErr == nil {  // Read on queue B - RACE!
        // ...
    }
}
```

**Two Critical Issues:**

1. **CPU Spin Loop (100% CPU):**
   - GCD background threads have NO RunLoop sources
   - `RunLoop.current.run()` returns immediately when no sources exist
   - Creates busy-wait loop consuming 100% of a CPU core

2. **Race Condition:**
   - `myErr` written on `myWorkQueue` (queue A)
   - `myErr` read on outer background queue (queue B)
   - No synchronization mechanism between the two threads
   - Classic data race

**Lesson:** RunLoop pumping ONLY works on threads with active RunLoop sources (main thread in GUI apps).

## The Fundamental Issue: RunLoop Architecture

### How macOS RunLoops Work

**Main Thread:**
```
Main RunLoop Sources:
- UI events (mouse, keyboard)
- Display refresh (CADisplayLink)
- Timer events
- Mach port messages
- Custom sources

RunLoop.current.run() → Processes ONE event → Returns
```

**GCD Background Thread:**
```
Background Thread RunLoop Sources:
- (none - empty!)

RunLoop.current.run() → No sources, returns immediately → SPIN!
```

### Why KerbUtil Requires RunLoop Pumping

The `KerbUtil` class uses an asynchronous completion pattern:
1. `getKerbCredentials()` starts async operation
2. Sets `finished` flag when complete
3. Caller must wait by pumping RunLoop

This pattern was designed for main thread execution and cannot be trivially moved to background threads.

## The Solution: Accept the Trade-Off

**Final Approach:** Run everything synchronously on the main thread

**Why This Works:**
```swift
// Main thread - RunLoop pumping works correctly
let myKerbUtil = KerbUtil()
var myErr: String?

myWorkQueue.async(execute: {
    myErr = myKerbUtil.getKerbCredentials(myPass, userPrinc)
})

while ( !myKerbUtil.finished ) {
    RunLoop.current.run(mode: .default, before: Date.distantFuture)  // ✅ Processes events
}

if myErr == nil {  // ✅ No race - proper RunLoop synchronization
    // Success handling
}
```

**Trade-Offs:**
- ✅ No CPU spin loop (RunLoop works correctly)
- ✅ No race condition (single thread + RunLoop coordination)
- ✅ UI works reliably without mouse movement hacks
- ❌ Main thread blocks for 5-10 seconds during authentication
- ✅ **Acceptable:** Sign-in happens once per day, blocking is brief

## Key Lessons for Future Work

### 1. RunLoop Pumping is Main-Thread Only
**Rule:** Never pump a RunLoop on a GCD background thread
- GCD threads have no RunLoop sources
- `RunLoop.current.run()` becomes a busy-wait loop
- Use proper async/await or semaphores instead

### 2. Match QoS Levels
**Rule:** Use the same QoS as the system APIs you're calling
- OpenDirectory uses `.default` QoS
- Using `.userInitiated` creates priority inversion
- Results in hang risk warnings even on background queue

### 3. DispatchQueue.main.async Doesn't Wake Idle RunLoops
**Rule:** Queuing work on main queue ≠ waking the RunLoop
- Main RunLoop must be actively pumped or have events
- Without events, queued blocks sit waiting
- Mouse movements/timers wake the RunLoop incidentally

### 4. Legacy Async Patterns Resist Simple Threading Changes
**Rule:** Code designed for main thread may not be portable to background threads
- `KerbUtil`'s completion-flag pattern assumes RunLoop pumping
- Modern alternative: Convert to async/await or completion handlers
- Sometimes the effort exceeds the benefit

### 5. Not Every Warning Needs Fixing
**Rule:** Evaluate the cost-benefit of optimization
- Hang risk warnings are important but context-dependent
- 5-10 seconds once per day for authentication = acceptable
- Months of effort for marginal improvement = questionable ROI

## What Would Actually Fix This Properly?

### Option 1: Rewrite KerbUtil with Modern Async/Await
```swift
class KerbUtil {
    func getKerbCredentials(_ password: String, _ principal: String) async throws -> String? {
        // Proper async implementation using Task, continuations, etc.
    }
}
```
**Effort:** High (Objective-C to Swift, API redesign, testing)
**Benefit:** Eliminates RunLoop pumping, proper async/await

### Option 2: Use Semaphores Instead of RunLoop Pumping
```swift
let semaphore = DispatchSemaphore(value: 0)
myWorkQueue.async {
    myErr = myKerbUtil.getKerbCredentials(myPass, userPrinc)
    semaphore.signal()
}
semaphore.wait()  // Blocks without spinning CPU
```
**Effort:** Medium (requires modifying KerbUtil to signal semaphore)
**Benefit:** Can run on background thread without CPU spin

### Option 3: Accept Main Thread Blocking (Current Solution)
**Effort:** Low (minimal changes, just fix obvious bugs)
**Benefit:** Reliable, simple, acceptable performance for use case

## Conclusion

Sometimes the "right" solution is accepting reasonable limitations rather than forcing complex architectural changes. RunLoop pumping is a main-thread pattern in macOS GUI apps, and trying to move it to background threads introduces complexity that exceeds the benefit.

**Time Spent:** ~8 hours, multiple failed approaches
**Tokens Used:** ~40,000+ across iterations
**Bugs Introduced:** CPU spin loop, race condition, UI freeze bugs

**Final Result:** Reverted to simple main-thread approach that works reliably with acceptable 5-10 second blocking once per day.

**Saved for Future:** This document, so the next developer doesn't repeat the same journey.

---

**Date:** 2025-10-20
**Context:** NoMAD macOS app, UI hang warnings during authentication
**Outcome:** Accepted main thread blocking as reasonable trade-off
