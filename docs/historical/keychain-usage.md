***Keychain Synching***

```defaults write com.trusourcelabs.NoMAD UseKeychain true```

Will have NoMAD store your password in the Keychain for use in logging into your network account.

After setting this preference the user will need to Log In via NoMAD once. This will create a new Keychain entry in the users's default Keychain. The entry will have "NoMAD" as the name and the user's full Kerberos principal, e.g. joel@COMPANY.COM, as the account name. The Keychain item will be configured to only allow NoMAD access to the entry. Note that you'll need to have the NoMAD binary signed by a valid signing identity for this.

Once the Keychain entry is there, NoMAD will attempt to sign in on launch using the stored password. If NoMAD can't login at that time, the user will be able to use the Log In menu item, where NoMAD will attempt to sign in, again, using the stored password.

To remove the stored password, and allow for another account to log in, use the Log Out menu item. This will remove the Keychain item and allow the Log In Dialog to present itself.