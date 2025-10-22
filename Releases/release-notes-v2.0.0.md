First release of this independently maintained NoMAD fork with macOS 26 compatibility, Swift 5.10 modernization, comprehensive documentation, and complete localization support for 8 languages.

## What's New

### Major Version Jump to 2.0.0

This release corrects the version numbering after discovering Jamf's v1.3.0 (January 2022) incorrectly showed "1.0.5" in Info.plist. This fork starts at v2.0.0 to reflect the major modernization efforts.

### macOS 26 Compatibility

- **Fixed menu bar handling** - Updated from deprecated `statusItem.menu` to `popUpMenu()` for macOS 26 support
- **Resolved UI threading issues** - Fixed authentication hangs and CPU spin issues
- **Async OpenDirectory operations** - Eliminated UI freezing during sign-in

### Critical Stability Fixes

- **Fixed app launch crash** - Added missing PKINITMenuItem IBOutlet connection
- **Fixed smartcard sign-in** - Corrected `@IBAction` signature for menu actions
- **Fixed translation crash** - Restored NoMADMenuController-Connected with proper dictionary structure
- **Fixed CPU spin** - Resolved race condition in menu click auto-login

### Complete Localization

- **8 languages fully supported**: English, French, German, Swedish, Danish, Dutch, Polish, Spanish
- **Fixed missing translations** in MainMenu for German, Danish, and French
- **Standardized all localization files** - Migrated from Localizable.strings to structured Languages.plist
- **Cleaned up Xcode project** - Removed duplicate InfoPlist.strings and obsolete localization files

### Comprehensive Documentation

- **70+ preference keys documented** - New PREFERENCES.md with detailed explanations
- **22 wiki pages preserved** - All original GitLab wiki content migrated to docs/ folder
- **Version history clarified** - Documented the v1.0-v1.3.0-v2.0.0 timeline
- **Deployment guides** - Admin guides for setup, triggers, and troubleshooting

### Enhanced Preferences UI

- **Added Help Configuration** options (Help URLs, support options)
- **Added Local Password Sync** options for better password management
- **Improved layout and positioning** in Preferences window

### Swift Modernization

- **Swift 5.0/5.10 compatibility** - Reduced build warnings by 37%
- **Normalized keyboard shortcuts** - Case-insensitive redo shortcut handling
- **Improved threading model** - Better main thread handling for UI operations
- **Code quality improvements** - Standardized localization key naming conventions

### Easter Egg Update

- **HistoryAndThanks.swift** - Added `lifeAfterJamf()` function documenting community continuation
- **Community tribute** - Preserves NoMAD's history while honoring the fork's beginning

## System Requirements

- **macOS**: 13.5 (Ventura) or later
- **Build**: 704 (auto-generated from git commit count)

## Installation

Download the **NoMAD-2.0.0.dmg** from the assets below and drag the app to your Applications folder. Configuration can be done via the Preferences UI or configuration profiles.

## Notes

- SmartCard/PKINIT support requires bundling with PKINITer.app (separate download)
- This is an independently maintained fork of Jamf's archived NoMAD project (archived 2024)
- Jamf's last release was v1.3.0 (January 2022)
- Build number reflects the total git commit count including upstream Jamf commits

## Documentation

- [Preferences Guide](https://github.com/arnemoor/NoMAD/blob/main/PREFERENCES.md) - All 70+ preference keys explained
- [Documentation Wiki](https://github.com/arnemoor/NoMAD/tree/main/docs) - 22 pages covering setup, deployment, and troubleshooting
- [Version History](https://github.com/arnemoor/NoMAD/blob/main/docs/preferences-evolution.md) - Complete timeline from v1.0 to v2.0.0
- [Release Process](https://github.com/arnemoor/NoMAD/blob/main/RELEASE.md) - Automated build, archive, and notarization workflow

## Acknowledgments

NoMAD wouldn't exist without the original work by Joel Rennich and the team at Jamf. This fork honors that legacy while ensuring NoMAD remains available and maintained for organizations that depend on it.

This fork is maintained by Arne Moor, a grateful NoMAD user giving back to keep the project alive.

---

**Full Changelog**: https://github.com/arnemoor/NoMAD/compare/v1.0.4...v2.0.0
