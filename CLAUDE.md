# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NoMAD (No More Active Directory) is a macOS menu bar application that provides Active Directory functionality without requiring domain binding. It manages Kerberos tickets, LDAP connections, password synchronization, and certificate enrollment.

**Key Capabilities:**
- Automatic Kerberos ticket renewal
- AD site-aware LDAP server discovery
- Local/AD password synchronization
- Windows CA certificate enrollment
- Password expiration warnings
- SmartCard/PKINIT support

## Build Commands

```bash
# Build from command line
xcodebuild -project NoMAD.xcodeproj -scheme NoMAD -configuration Release build

# Run tests
xcodebuild test -project NoMAD.xcodeproj -scheme NoMAD

# Clean build
xcodebuild -project NoMAD.xcodeproj -scheme NoMAD clean

# Open in Xcode for development
open NoMAD.xcodeproj
```

## Architecture

### Core Components

**NoMADMenuController.swift (1,462 lines)**
- Central controller managing all menu bar interactions
- Coordinates between LDAP, Kerberos, and user management subsystems
- Handles notifications, menu validation, and user actions
- Recent fix: Changed from `statusItem.menu` to `popUpMenu()` for macOS 26 compatibility

**NoMADUser.swift (712 lines)**
- Manages all user account operations
- Password verification against local account, AD, and keychain
- Password changes with AD/local/keychain synchronization
- FileVault password sync support

**LDAPUtil.swift (764 lines)**
- LDAP server discovery via DNS SRV records
- AD site detection using LDAP Ping protocol
- Automatic failover between domain controllers
- User attribute retrieval from AD

### Supporting Systems

**Kerberos Management**
- `KerbUtil.[h,m]` - Objective-C bridge for Kerberos operations
- `KlistUtil.swift` - Parses `klist --json` output for ticket info
- Automatic renewal based on `RenewTickets` preference

**Certificate Management**
- `WindowsCATools.swift` - Windows CA integration
- `CSRGen.swift` - Certificate signing request generation
- Automatic renewal before expiration

**Network Monitoring**
- `AppDelegate.swift` - SystemConfiguration callbacks for network changes
- `ADLDAPPing.swift` - AD site discovery protocol implementation
- Automatic LDAP server revalidation on network changes

### Key Architectural Patterns

1. **Preference-Driven Configuration**: All settings in `Preferences.swift` (75+ keys) with defaults in `DefaultPreferences.plist`

2. **Objective-C Bridging**: Critical system operations use Obj-C (`NoMAD-Bridging-Header.h`):
   - KerbUtil for Kerberos
   - DNSResolver for SRV records
   - SecurityPrivateAPI for screen locking

3. **Event-Driven Updates**: Network changes trigger LDAP revalidation, timer-based Kerberos renewal

4. **Multi-Language Support**: 7 localizations using `.lproj` directories

## Testing

```bash
# Run unit tests (minimal coverage - only Network struct tests exist)
xcodebuild test -project NoMAD.xcodeproj -scheme NoMAD

# Manual testing requires:
# - Active Directory environment
# - Kerberos infrastructure
# - Optional: Windows Certificate Authority
```

## Development Configuration

- **Swift Version**: 4.0 (set in build settings)
- **Minimum macOS**: 10.10 (Yosemite)
- **Bundle ID**: com.trusourcelabs.NoMAD
- **Code Signing**: Requires developer certificate for distribution
- **LSUIElement**: true (menu bar app, no dock icon)

### Build Number Versioning

**Important**: The build number (CFBundleVersion) is automatically set to the git commit count via pre-build scripts in both the NoMAD and NoMAD-Release schemes.

- **CURRENT_PROJECT_VERSION** in project.pbxproj is set to `1` (fallback only, not used during normal builds)
- **Pre-build script** runs before each build: `git rev-list HEAD | wc -l`
- **Post-build script** resets Info.plist to "DEVELOPMENT" to avoid git changes
- **Result**: Each build gets the current git commit count as its build number (currently 690)

**Why git commit count?**
- Auto-increments with each commit (no manual updates needed)
- Provides traceability back to source code
- Unique build number for each commit in history
- Standard practice for automated builds

**For releases**: The build number in the packaged .app will match the commit count at build time.

## Common Development Tasks

### Adding New Menu Items
1. Add action method in `NoMADMenuController.swift`
2. Create menu item in `MainMenu.xib`
3. Connect outlet/action in Interface Builder
4. Add validation in `validateMenuItem:` if needed

### Adding New Preferences
1. Add key constant in `Preferences.swift`
2. Add default value in `DefaultPreferences.plist`
3. Access via `defaults.bool(forKey: Preferences.keyName)`

### Debugging LDAP Issues
- Check `LDAPUtil.swift` for server discovery logic
- Verify SRV records: `dig _ldap._tcp.DOMAIN SRV`
- Enable verbose logging via preferences

### Working with Kerberos
- Kerberos operations in `KerbUtil.[h,m]` (Objective-C)
- Ticket parsing in `KlistUtil.swift`
- System commands: `/usr/bin/klist`, `/usr/bin/kinit`, `/usr/bin/kpasswd`

## Important Notes

- **Archived Project**: Originally maintained by Jamf, now community-supported
- **macOS 26 Fix**: Menu handling changed from `statusItem.menu` to `popUpMenu()` (commit 82872ca)
- **System Dependencies**: Requires system binaries (klist, kinit, ldapsearch, etc.)
- **No Package Manager**: Pure Xcode project without CocoaPods/SPM dependencies