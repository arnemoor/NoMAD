# NoMAD Preferences Reference

> **Note:** This documentation incorporates and expands upon content from the [original NoMAD wiki](https://gitlab.com/Mactroll/NoMAD/-/wikis/home). The original NoMAD project by Jamf released versions up to v1.3.0 (January 2022, though Info.plist incorrectly showed "1.0.5") before being archived in 2024. This independently maintained fork v2.0.0 continues development with major refactoring and modernization.
>
> **Historical reference:** The original preferences documentation from nomad.menu (February 2017, 23 preferences) is preserved on the [Internet Archive](https://web.archive.org/web/20170204180512/https://www.nomad.menu/help-center/preferences-and-what-they-do/). This current documentation is more comprehensive with **70 user-configurable preferences**, all extracted directly from the source code. See [docs/preferences-evolution.md](docs/preferences-evolution.md) for detailed version history and comparison.

Complete reference for all NoMAD preferences that can be configured via:
- **Preferences UI** in the application
- **Configuration profiles** (`com.trusourcelabs.NoMAD`)
- **Command-line**: `defaults write com.trusourcelabs.NoMAD <key> <value>`

## Menu Item Visibility Conditions

| Menu Item           | Visibility Condition                                          | Preference Key                    | In Prefs UI |
|---------------------|---------------------------------------------------------------|-----------------------------------|-------------|
| Smartcard Sign In   | PKINITer.app bundled with NoMAD                               | *(automatic detection)*           | No          |
| Sign In             | Always shown (changes to "Renew Tickets" when logged in)      | -                                 | No          |
| Change Password     | Always shown                                                  | -                                 | No          |
| Sign Out            | Never hidden (disabled when not logged in)                    | -                                 | No          |
| Lock Screen         | Hidden if `HideLockScreen=true`                               | `HideLockScreen`                  | Yes         |
| Get Certificate     | Hidden if `X509CA` is empty                                   | `X509CA`                          | Yes         |
| Get Software        | Jamf Self Service or Managed Software Center detected         | *(automatic detection)*           | No          |
| Get Help            | URL configured in `HelpURL`                                   | `HelpURL`                         | Yes         |
| Hidden Item 1       | Custom command configured via `UserCommandName1`              | `UserCommandName1`                | No          |
| Home / Sharepoint   | `ShowHome=1` AND connected AND home directory exists          | `ShowHome`                        | Yes         |
| Preferences         | Hidden if `HidePrefs=true`                                    | `HidePrefs`                       | No          |
| Dump Logs           | Hold Option key (hidden if `HidePrefs=true`)                  | *(Option key + !HidePrefs)*       | No          |
| Quit                | Hidden if `HideQuit=true`                                     | `HideQuit`                        | No          |

## Complete Preferences List

### Authentication & Domain Settings

#### ADDomain
- **Type:** String
- **Default:** None (required)
- **Description:** Active Directory domain (e.g., "example.com")
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD ADDomain "corp.example.com"`

#### AutoConfigure
- **Type:** String
- **Default:** "" (empty)
- **Description:** Keyword to enable pre-configured settings for quick setup. When set to a recognized value (e.g., "JODA", "TSL"), automatically configures multiple preferences. The key is cleared after configuration runs.
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD AutoConfigure "JODA"`
- **Note:** This is a one-time configuration helper. Recognized keywords are typically environment-specific.

#### KerberosRealm
- **Type:** String
- **Default:** Uppercase version of ADDomain
- **Description:** Kerberos realm for authentication
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD KerberosRealm "CORP.EXAMPLE.COM"`

#### LDAPServerList
- **Type:** String
- **Default:** Auto-discovered via DNS SRV
- **Description:** Comma-separated list of LDAP servers to use
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD LDAPServerList "dc1.example.com,dc2.example.com"`

#### LDAPType
- **Type:** String
- **Default:** "AD"
- **Description:** LDAP server type ("AD" or "OD" for Open Directory)
- **In Prefs UI:** Yes

#### LDAPOverSSL
- **Type:** Boolean
- **Default:** false
- **Description:** Use LDAPS (LDAP over SSL) instead of plain LDAP
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD LDAPOverSSL -bool true`

#### LDAPOnly
- **Type:** Boolean
- **Default:** false
- **Description:** Only use LDAP for authentication (no Kerberos)
- **In Prefs UI:** Yes

#### LDAPAnonymous
- **Type:** Boolean
- **Default:** false
- **Description:** Allow anonymous LDAP binds
- **In Prefs UI:** Yes

### Password Management

#### PasswordPolicy
- **Type:** String (URL)
- **Default:** None
- **Description:** URL to password policy documentation
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD PasswordPolicy "https://intranet.example.com/password-policy"`

#### PasswordExpireAlertTime
- **Type:** Integer (days)
- **Default:** 15
- **Description:** Show password expiration warnings X days before expiry
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD PasswordExpireAlertTime -int 30`

#### PasswordExpireCustomAlert
- **Type:** String
- **Default:** None
- **Description:** Custom message for password expiration warnings
- **In Prefs UI:** Yes

#### PasswordExpireCustomWarnTime
- **Type:** Integer (days)
- **Default:** None
- **Description:** Custom warning time override
- **In Prefs UI:** Yes

#### PersistExpiration
- **Type:** Boolean
- **Default:** false
- **Description:** Show expiration info even when not connected to network
- **In Prefs UI:** Yes

#### ChangePasswordCommand
- **Type:** String
- **Default:** None
- **Description:** Custom script/command to run after password change
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD ChangePasswordCommand "/usr/local/bin/sync-password.sh"`

#### ChangePasswordType
- **Type:** String
- **Default:** "Kerberos"
- **Description:** Method for changing passwords ("Kerberos" or other)
- **In Prefs UI:** No

#### ChangePasswordOptions
- **Type:** String
- **Default:** None
- **Description:** Additional options for password change
- **In Prefs UI:** No

### Local Account Sync

#### LocalPasswordSync
- **Type:** Boolean
- **Default:** false
- **Description:** Sync AD password to local Mac account password
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD LocalPasswordSync -bool true`

#### LocalPasswordSyncDontSyncLocalUsers
- **Type:** Array
- **Default:** []
- **Description:** List of local accounts to exclude from password sync
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD LocalPasswordSyncDontSyncLocalUsers -array "admin" "guest"`

#### LocalPasswordSyncOnMatchOnly
- **Type:** Boolean
- **Default:** false
- **Description:** Only sync if local and AD passwords already match
- **In Prefs UI:** Yes

#### MessageLocalSync
- **Type:** String
- **Default:** Standard message
- **Description:** Custom message when prompting for local password sync
- **In Prefs UI:** No

### Kerberos Settings

#### RenewTickets
- **Type:** Boolean
- **Default:** true
- **Description:** Automatically renew Kerberos tickets before expiration
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD RenewTickets -bool true`

#### SecondsToRenew
- **Type:** Integer
- **Default:** 7200 (2 hours)
- **Description:** Threshold in seconds before ticket expiration to trigger automatic renewal. When a Kerberos ticket has less than this many seconds remaining, NoMAD will attempt to renew it.
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD SecondsToRenew -int 3600`
- **Note:** Only applies when `RenewTickets` is enabled. Default of 2 hours provides good balance between security and user experience.

#### GetHelpType
- **Type:** String
- **Default:** "URL"
- **Description:** Type of help action ("URL", "App", etc.)
- **In Prefs UI:** No

#### GetHelpOptions
- **Type:** String
- **Default:** None
- **Description:** Additional options for help action
- **In Prefs UI:** No

#### HideExpiration
- **Type:** Boolean
- **Default:** false
- **Description:** Hide password expiration information from menu
- **In Prefs UI:** Yes

#### HideExpirationMessage
- **Type:** String
- **Default:** None
- **Description:** Custom text when expiration is hidden
- **In Prefs UI:** No

### Certificate Management (X509)

#### X509CA
- **Type:** String (URL)
- **Default:** None
- **Description:** URL to Windows Certificate Authority for certificate enrollment
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD X509CA "https://ca.example.com/certsrv"`

#### X509CommonName
- **Type:** String
- **Default:** User principal name
- **Description:** Common name for certificate requests
- **In Prefs UI:** Yes

#### Template
- **Type:** String
- **Default:** None
- **Description:** Certificate template name to request from Windows CA (e.g., "User Auth", "Computer", "Web Server")
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD Template "User Auth"`
- **Note:** Template name must match an available template on your Windows Certificate Authority

#### ExportableKey
- **Type:** Boolean
- **Default:** false
- **Description:** Whether the private key from generated certificates can be exported from the keychain
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD ExportableKey -bool true`
- **Security Note:** Enabling this reduces security as private keys can be extracted. Only enable if required by your security policy.

### Menu Customization

#### MenuChangePassword
- **Type:** String
- **Default:** "Change Password"
- **Description:** Custom text for "Change Password" menu item
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD MenuChangePassword "Reset AD Password"`

#### MenuRenewTickets
- **Type:** String
- **Default:** "Renew Tickets"
- **Description:** Custom text for "Renew Tickets" menu item
- **In Prefs UI:** No

#### MenuHomeDirectory
- **Type:** String
- **Default:** "Home / Sharepoint"
- **Description:** Custom text for home directory menu item
- **In Prefs UI:** No

#### MenuGetCertificate
- **Type:** String
- **Default:** "Get Certificate"
- **Description:** Custom text for certificate menu item
- **In Prefs UI:** No

#### MenuGetHelp
- **Type:** String
- **Default:** "Get Help"
- **Description:** Custom text for help menu item
- **In Prefs UI:** No

#### MenuGetSoftware
- **Type:** String
- **Default:** "Get Software"
- **Description:** Custom text for software portal menu item
- **In Prefs UI:** No

#### MenuPasswordExpires
- **Type:** String
- **Default:** Auto-generated expiration text
- **Description:** Custom text for password expiration display
- **In Prefs UI:** No

#### MenuUserName
- **Type:** String
- **Default:** User's full name
- **Description:** Custom text for username display
- **In Prefs UI:** No

#### HideLockScreen
- **Type:** Boolean
- **Default:** false
- **Description:** Hide "Lock Screen" menu item
- **In Prefs UI:** Yes

#### HidePrefs
- **Type:** Boolean
- **Default:** false
- **Description:** Hide "Preferences" menu item (disables Dump Logs too)
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD HidePrefs -bool true`

#### HideQuit
- **Type:** Boolean
- **Default:** false
- **Description:** Hide "Quit" menu item
- **In Prefs UI:** No

#### HideRenew
- **Type:** Boolean
- **Default:** false
- **Description:** Disable manual ticket renewal
- **In Prefs UI:** No

#### ShowHome
- **Type:** Integer
- **Default:** 0
- **Description:** Show home directory/sharepoint menu item (0=hide, 1=show)
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD ShowHome -int 1`

### Custom Commands

#### UserCommandTask1
- **Type:** String (path)
- **Default:** None
- **Description:** Path to script/command for custom menu item
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD UserCommandTask1 "/usr/local/bin/custom-action.sh"`

#### UserCommandName1
- **Type:** String
- **Default:** None
- **Description:** Display name for custom menu item
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD UserCommandName1 "Reset Cache"`

#### UserCommandHotKey1
- **Type:** String
- **Default:** None
- **Description:** Keyboard shortcut for custom command (e.g., "r" for Cmd+R)
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD UserCommandHotKey1 "r"`

### Sign-In Behavior

#### SignInWindowOnLaunch
- **Type:** Boolean
- **Default:** false
- **Description:** Show sign-in window automatically at launch if not logged in
- **In Prefs UI:** Yes

#### LoginItem
- **Type:** String
- **Default:** "" (empty)
- **Description:** When set to any non-empty value, creates a LaunchAgent to automatically start NoMAD at user login
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD LoginItem "1"`
- **Note:** The LaunchAgent is created at `~/Library/LaunchAgents/com.trusourcelabs.NoMAD.plist`

#### SignInCommand
- **Type:** String
- **Default:** None
- **Description:** Script/command to run after successful sign-in
- **In Prefs UI:** No

#### SignOutCommand
- **Type:** String
- **Default:** None
- **Description:** Script/command to run after sign-out
- **In Prefs UI:** No

#### StateChangeAction
- **Type:** String
- **Default:** "" (empty)
- **Description:** Script/command to run whenever the network state changes (network interface up/down, connectivity changes)
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD StateChangeAction "/usr/local/bin/network-change-handler.sh"`
- **Note:** Script runs in background with '&' appended automatically. Useful for VPN reconnection or network-dependent tasks.

#### TitleSignIn
- **Type:** String
- **Default:** "NoMAD - Sign In"
- **Description:** Custom title for sign-in window
- **In Prefs UI:** No

### Keychain Integration

#### UseKeychain
- **Type:** Boolean
- **Default:** false
- **Description:** Store AD password in keychain for auto-login
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD UseKeychain -bool true`

#### KeychainItems
- **Type:** Array
- **Default:** []
- **Description:** List of additional keychain items to update with new password
- **In Prefs UI:** No

### User Interface

#### IconOn
- **Type:** String (path)
- **Default:** Built-in icon
- **Description:** Custom menu bar icon when connected
- **In Prefs UI:** No

#### IconOff
- **Type:** String (path)
- **Default:** Built-in icon
- **Description:** Custom menu bar icon when disconnected
- **In Prefs UI:** No

#### IconOnDark
- **Type:** String (path)
- **Default:** Built-in icon
- **Description:** Custom menu bar icon for dark mode (connected)
- **In Prefs UI:** No

#### IconOffDark
- **Type:** String (path)
- **Default:** Built-in icon
- **Description:** Custom menu bar icon for dark mode (disconnected)
- **In Prefs UI:** No

#### CaribouTime
- **Type:** Boolean
- **Default:** false
- **Description:** Use special holiday icons
- **In Prefs UI:** No

#### MessageNotConnected
- **Type:** String
- **Default:** "Not Connected"
- **Description:** Custom status message when not connected to AD
- **In Prefs UI:** No

### URLs

#### HelpURL
- **Type:** String (URL)
- **Default:** None
- **Description:** URL for "Get Help" menu item
- **In Prefs UI:** Yes
- **Example:** `defaults write com.trusourcelabs.NoMAD HelpURL "https://helpdesk.example.com"`

### Internal/Advanced Settings

These preferences are typically not modified by users:

#### Verbose
- **Type:** Boolean
- **Default:** false
- **Description:** Enable verbose logging for debugging purposes. Generates detailed logs about LDAP queries, Kerberos operations, and other internal operations.
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD Verbose -bool true`
- **Note:** Verbose logging can help diagnose connection issues but generates significant log output. Disable after debugging.

#### SelfServicePath
- **Type:** String
- **Default:** "" (empty)
- **Description:** Custom path to self-service application. Overrides automatic detection of Jamf Self Service or Managed Software Center. Set to "None" to force-hide the "Get Software" menu item.
- **In Prefs UI:** No
- **Example:** `defaults write com.trusourcelabs.NoMAD SelfServicePath "/Applications/Company Portal.app"`
- **Note:** If empty, NoMAD auto-detects Jamf Self Service (`/Applications/Self Service.app`) or Munki Managed Software Center (`/Applications/Managed Software Center.app`)

#### LastUser
- **Type:** String
- **Description:** Last logged-in username (auto-managed)

#### UserPrincipal
- **Type:** String
- **Description:** User's Kerberos principal (auto-managed)

#### LastPasswordExpireDate
- **Type:** Date
- **Description:** Last known password expiration date (auto-managed)

#### LastCertificateExpiration
- **Type:** String
- **Description:** Certificate expiration date (auto-managed)

#### DisplayName
- **Type:** String
- **Description:** User's display name from AD (auto-managed)

#### Groups
- **Type:** Array
- **Description:** User's AD group memberships (auto-managed)

#### UserAging
- **Type:** Boolean
- **Description:** Whether password aging is enabled (auto-detected)

## Configuration Examples

### Basic Enterprise Setup

```bash
# Set domain
defaults write com.trusourcelabs.NoMAD ADDomain "corp.example.com"

# Enable password sync
defaults write com.trusourcelabs.NoMAD LocalPasswordSync -bool true

# Set expiration warning
defaults write com.trusourcelabs.NoMAD PasswordExpireAlertTime -int 14

# Add help URL
defaults write com.trusourcelabs.NoMAD HelpURL "https://helpdesk.example.com"

# Show home sharepoint
defaults write com.trusourcelabs.NoMAD ShowHome -int 1
```

### Kiosk/Restricted Setup

```bash
# Hide quit and preferences
defaults write com.trusourcelabs.NoMAD HideQuit -bool true
defaults write com.trusourcelabs.NoMAD HidePrefs -bool true

# Disable manual ticket renewal
defaults write com.trusourcelabs.NoMAD HideRenew -bool true

# Auto-show sign-in
defaults write com.trusourcelabs.NoMAD SignInWindowOnLaunch -bool true
```

### Custom Branding

```bash
# Custom menu labels
defaults write com.trusourcelabs.NoMAD MenuChangePassword "Reset Network Password"
defaults write com.trusourcelabs.NoMAD MenuGetHelp "IT Support"

# Custom icons
defaults write com.trusourcelabs.NoMAD IconOn "/Library/YourOrg/nomad-on.png"
defaults write com.trusourcelabs.NoMAD IconOff "/Library/YourOrg/nomad-off.png"
```

### Certificate Management

```bash
# Configure Windows CA
defaults write com.trusourcelabs.NoMAD X509CA "https://ca.corp.example.com/certsrv"

# Custom cert common name
defaults write com.trusourcelabs.NoMAD X509CommonName "user@corp.example.com"
```

## Configuration Profile Example

Deploy via MDM:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadType</key>
            <string>com.trusourcelabs.NoMAD</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>PayloadIdentifier</key>
            <string>com.example.nomad.settings</string>
            <key>PayloadUUID</key>
            <string>GENERATE-UUID-HERE</string>
            <key>PayloadDisplayName</key>
            <string>NoMAD Settings</string>
            <key>ADDomain</key>
            <string>corp.example.com</string>
            <key>LocalPasswordSync</key>
            <true/>
            <key>PasswordExpireAlertTime</key>
            <integer>14</integer>
            <key>HelpURL</key>
            <string>https://helpdesk.example.com</string>
            <key>ShowHome</key>
            <integer>1</integer>
        </dict>
    </array>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadIdentifier</key>
    <string>com.example.nomad</string>
    <key>PayloadUUID</key>
    <string>GENERATE-UUID-HERE</string>
    <key>PayloadDisplayName</key>
    <string>NoMAD Configuration</string>
</dict>
</plist>
```

## How NoMAD Works

### Basic Operation

1. **Launch:** NoMAD checks if ADDomain is configured, prompts if not
2. **DNS Discovery:** Queries DNS for `_ldap._tcp.DOMAIN` SRV records
3. **Connection:** If SRV records resolve, changes state to "Connected"
4. **Authentication:** User signs in via system Kerberos APIs (`_kdc._tcp` lookup)
5. **LDAP Query:** On successful login, pulls user record via Kerberos-authenticated LDAP
6. **Monitoring:** Re-checks every 15 minutes, on menu click, and on network interface changes

### AD Site Awareness

NoMAD automatically discovers and uses domain controllers in your AD site:

1. Initial lookup uses domain-wide DCs
2. Queries DCs with LDAP pings to determine correct site
3. Switches to site-specific DCs once identified
4. Maintains DC connection until network change

**Override site discovery:**
```bash
# Use specific DCs only (disables automatic site discovery)
defaults write com.trusourcelabs.NoMAD LDAPServerList "dc1.example.com,dc2.example.com"
```

### Password Expiration Calculation

NoMAD uses two methods to calculate expiration:

1. **Modern (Windows 2008+):** `msDS-UserPasswordExpiryTimeComputed` attribute
   - DC computes expiration (supports fine-grained password policies)
2. **Legacy:** Global password policy + user's last password set date

**Notification Schedule:**
- **15+ days out:** Once when threshold crossed
- **15-4 days:** Once per day
- **4-1 days:** Twice per day
- **<1 day:** Every hour

**Configure threshold:**
```bash
defaults write com.trusourcelabs.NoMAD PasswordExpireAlertTime -int 30
```

### Local Password Sync Flow

When `LocalPasswordSync=true`, on sign-in:

1. Attempt Kerberos authentication with supplied password
2. If successful, check against local account password via OpenDirectory
3. If passwords don't match:
   - Prompt user for current local password
   - Verify local password is correct
   - Change local password to match network password
   - Update local keychain with new password

On password change (when already synced):
- Uses old and new network passwords to change local password automatically

## Troubleshooting

### Manual Testing

**1. Test DNS SRV Records:**
```bash
dig +short -t SRV _ldap._tcp.example.com
```
Expected: List of domain controllers with priority/weight

**2. Test Kerberos Authentication:**
```bash
kinit user@EXAMPLE.COM
klist  # Verify TGT obtained
```

**3. Test LDAP Query:**
```bash
ldapsearch -LLL -Q -H ldap://dc.example.com -s base defaultNamingContext
```
Expected: Returns defaultNamingContext attribute

**4. Test Windows CA (if using certificates):**
- Ensure logged in with valid Kerberos TGT
- Open Safari to `https://ca.example.com/certsrv`
- Should auto-login via Kerberos
- If prompted for cert trust: Import CA root cert to keychain
- If prompted for password: Web portal needs "Windows Authentication" enabled in IIS

### Viewing Current Settings

```bash
# Show all NoMAD preferences
defaults read com.trusourcelabs.NoMAD

# Show specific preference
defaults read com.trusourcelabs.NoMAD ADDomain
```

### Resetting Preferences

```bash
# Remove all NoMAD preferences
defaults delete com.trusourcelabs.NoMAD

# Remove specific preference
defaults delete com.trusourcelabs.NoMAD HideQuit
```

### Debug Logging

Hold **Option** while clicking NoMAD menu to access "Dump Logs" - this writes extensive diagnostic information to system logs:

```bash
# View NoMAD logs
log show --predicate 'processImagePath CONTAINS "NoMAD"' --last 1h
```
