//
//  AppDelegate.swift
//  NoMAD
//
//  Created by Joel Rennich on 7/8/16.
//  Copyright © 2016 Trusource Labs. All rights reserved.
//

import Cocoa
import SystemConfiguration

/// `Notification` to alert app of changes in system state.
///
/// Listen for this notification if you need to refresh data on network changes.
let updateNotification = Notification(name: Notification.Name(rawValue: "updateNow"))

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    var refreshTimer: Timer?
    var refreshActivity: NSBackgroundActivityScheduler?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        myLogger.logit(.base, message:"---NoMAD Initialized---")
        let version = String(describing: Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)
        let build = String(describing: Bundle.main.infoDictionary!["CFBundleVersion"]!)
        myLogger.logit(.base, message:"NoMAD version: " + version)
        myLogger.logit(.base, message:"NoMAD build: " + build)
        myLogger.logit(.debug, message: "Current app preferences: \(defaults.dictionaryRepresentation())")

        let changed: SCDynamicStoreCallBack = { dynamicStore, _, _ in
            myLogger.logit(.base, message: "State change, checking things.")
            NotificationQueue.default.enqueue(updateNotification, postingStyle: .now)

            Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {_ in
                myLogger.logit(.base, message: "State change, checking things again.")
                NotificationQueue.default.enqueue(updateNotification, postingStyle: .now)
            })

            if (defaults.string(forKey: Preferences.stateChangeAction) != "" ) {
                myLogger.logit(.base, message: "Firing State Change Action")
                _ = cliTask(defaults.string(forKey: Preferences.stateChangeAction)! + " &")
            }
        }

        var dynamicContext = SCDynamicStoreContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let dcAddress = withUnsafeMutablePointer(to: &dynamicContext, {UnsafeMutablePointer<SCDynamicStoreContext>($0)})

        if let dynamicStore = SCDynamicStoreCreate(kCFAllocatorDefault, "com.trusourcelabs.networknotification" as CFString, changed, dcAddress) {
            let keysArray = ["State:/Network/Global/IPv4" as CFString, "State:/Network/Global/IPv6"] as CFArray
            SCDynamicStoreSetNotificationKeys(dynamicStore, nil, keysArray)
            let loop = SCDynamicStoreCreateRunLoopSource(kCFAllocatorDefault, dynamicStore, 0)
            CFRunLoopAddSource(CFRunLoopGetMain(), loop, .commonModes)
        }

        scheduleTimer()
        awakeFromNib()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        defaults.synchronize()
        refreshActivity?.invalidate()
        refreshTimer?.invalidate()
    }

    @objc func sendUpdateMessage() {
        myLogger.logit(.base, message: "It's been a while, checking things.")
        NotificationQueue.default.enqueue(updateNotification, postingStyle: .now)
    }

    /// Schedule our update notification to fire every 15 minutes or so.
    func scheduleTimer() {
        refreshActivity = NSBackgroundActivityScheduler(identifier: "com.trusourcelabs.updatecheck")
        refreshActivity?.repeats = true
        refreshActivity?.interval = 15 * 60
        refreshActivity?.tolerance = 1.5 * 60

        refreshActivity?.schedule() { (completionHandler) in
            self.sendUpdateMessage()
            completionHandler(NSBackgroundActivityScheduler.Result.finished)
        }
    }
}

