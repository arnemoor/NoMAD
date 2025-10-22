# NoMAD Preferences Evolution

This document tracks the evolution of NoMAD preferences from the original 2017 documentation to the current implementation.

## 2017 Original Documentation (February 2017)

The original preferences documentation at nomad.menu contained **26 total keys**:
- **23 active preferences**
- **3 removed preferences** (ExpeditedLookups, InternalSite, InternalSiteIP)

**Source:** [Internet Archive](https://web.archive.org/web/20170204180512/https://www.nomad.menu/help-center/preferences-and-what-they-do/)

## Current Implementation (2025)

The current NoMAD codebase contains **89 total preference keys** defined in code (Preferences.swift), with **70 user-facing preferences** documented for configuration. This represents significant expansion of functionality since the February 2017 documentation.

**Release History:**
- v1.0.x series: January 2017 - July 2017
- v1.1.0 - v1.1.3: October 2017 - February 2018
- v1.2.0: Planned but **never released** (jumped to v1.3.0)
- v1.3.0: January 2022 (last official Jamf release)
  - **Note:** Jamf tagged as "1.3.0" but never updated Info.plist, which still showed "1.0.5"
- v2.0.0: October 2025 (independent fork release by Arne Moor)
  - Major refactoring and tech stack upgrade
  - Swift 5.10 modernization
  - macOS 26 compatibility
  - Complete localization and documentation

## Missing from 2017 Documentation

The following 7 preferences existed in the code but were **not documented** in the 2017 web documentation:

| Preference | Type | Default | Description |
|------------|------|---------|-------------|
| AutoConfigure | String | "" | Keyword to enable pre-configured settings (e.g., "JODA", "TSL") |
| ExportableKey | Bool | false | Whether private keys from generated certificates can be exported |
| LoginItem | String | "" | If set, creates LaunchAgent to auto-start NoMAD at login |
| SecondsToRenew | Int | 7200 | Threshold (in seconds) for when to renew Kerberos tickets |
| SelfServicePath | String | "" | Custom path to self-service application (overrides auto-detection) |
| StateChangeAction | String | "" | Script/command to run on network state changes |
| Verbose | Bool | false | Enable verbose logging for debugging |

**Note:** These preferences were present in DefaultPreferences.plist and Preferences.swift but omitted from the user-facing documentation.

## Features Added After 2017 Documentation

### v1.1.x Series (October 2017 - February 2018)

Released versions: v1.1.0, v1.1.2, v1.1.3

Major features added:
- **Shares Menu** - Multiple file share preferences
- **Keychain Sync** - Keychain item synchronization
- **802.1x TLS** - Wireless profile certificate association
- **Welcome Window** - First-run customization
- **Recursive Groups** - Nested group lookup
- **Anonymous LDAP** - Non-AD LDAP support
- **Open Directory** - OD-specific settings
- **Sign In Window Control** - Advanced UI behavior

See [v-1-1.md](v-1-1.md) for complete release notes.

### v1.2 (Planned, Never Released)

Version v1.2.0 was planned for March 2018 but never released. Development jumped from v1.1.3 to v1.3.0. Planned features included:
- **Custom Actions** - UserCommand preferences for custom menu items
- DFS share resolution support
- Actions menu for custom workflows

See [v-1-2.md](v-1-2.md) for original plans.

### v1.3.0 (January 2022)

Last official Jamf release before project archival in 2024.

### Community Fork (2024+)

- **macOS 26 Compatibility** - Menu handling updates
- **Swift 5.10 Modernization** - Reduced build warnings
- **Localization Improvements** - Complete translations
- **Documentation Enhancement** - Comprehensive preferences reference

### Examples of New Preferences

- FirstRunDone - Track first-time usage
- RecursiveGroupLookup - Include nested groups
- MessageLocalSync - Customize password sync prompts
- UserCommandName1 / UserCommandTask1 - Custom menu actions
- HideLockScreen - Hide lock screen menu item
- HideQuit - Prevent users from quitting NoMAD
- MenuChangePassword - Custom text for Change Password menu
- And 50+ more...

## Preferences Removed from Code

The following preferences were documented in 2017 but subsequently removed:

| Preference | Purpose | Removal Reason |
|------------|---------|----------------|
| ExpeditedLookups | Download entire site list for local iteration | Caused problems, removed |
| InternalSite | FQDN of internal network site | Replaced by better detection |
| InternalSiteIP | IP address of InternalSite | Replaced by better detection |

## Default Value Changes

| Preference | 2017 Default | Current Default | Notes |
|------------|--------------|-----------------|-------|
| PasswordExpireAlertTime | 1,296,000 (15 days) | 1,296,000 | No change |
| SecondsToRenew | Not documented | 7200 (2 hours) | Now documented |
| RenewTickets | false | true | Changed to auto-renew by default |

## Variable Substitution

The 2017 documentation mentioned the following variable substitutions for ChangePasswordOptions and GetHelpOptions:

- `<<serial>>` - Mac serial number
- `<<fullname>>` - User's full name
- `<<shortname>>` - User's short name
- `<<domain>>` - AD domain name

These substitutions remain supported in the current version.

## Documentation Completeness

| Version | Documented Prefs | Code Keys | Coverage |
|---------|------------------|-----------|----------|
| 2017    | 23               | ~30       | ~77%     |
| 2025    | 70               | 89        | 100% of user-facing prefs |

**Note:** The 89 code keys include internal state keys not meant for user configuration. The 70 documented preferences represent all user-configurable settings.

## See Also

- [PREFERENCES.md](../PREFERENCES.md) - Complete current preferences reference
- [Archived 2017 HTML](archived-preferences-2017.html) - Original preserved documentation
- [v-1-1.md](v-1-1.md) - Version 1.1 release notes (October 2017)
- [v-1-2.md](v-1-2.md) - Version 1.2 planned features (March 2018)
