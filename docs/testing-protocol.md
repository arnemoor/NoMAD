***Testing Protocols for NoMAD***
Current version - PB8

***Short Test***

This is ensure basic functionality before releasing a minor update.

***Short Test - Preparation***

1. Remove any existing preference files from ~/Library/Preferences/com.trusourcelabs.NoMAD.plist
```defaults delete com.trusourcelabs.NoMAD```
2. Remove any previous version of NoMAD, and ensure that they're not running.
```killall NoMAD```
3. Remove any keychain items. Ideally it's best to have a NoMAD testing only keychain that you enable as the default prior to testing, and then set the login keychain back to the default when done.

***Short Test - Basic Functionality***
1. Launch NoMAD and enter in an AD Domain.
2. Close Preferences window.
-- Test to ensure that the Domain can be contacted by ensuring that your test system has basic connectivity to the Domain.
3. Log In
-- Use the "Log In" menu to login to the domain using an existing AD domain user.
```klist``` should show a valid ticket for the AD Domain
-- If successful use the "Log Out" menu item.
```klist``` should not show a valid ticket for the AD Domain.