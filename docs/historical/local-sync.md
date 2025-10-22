***Local Password Sync***

Setting the defaults key to force local password synching:

```defaults write com.trusourcelabs.NoMAD LocalPasswordSync true```

Will cause NoMAD to check on Log In to ensure that your AD password is in sync with your local password. The basic flow is as follows:

1. Take the password supplied by the user and attempt to get Kerberos credentials with it.
2. If successful then check the password agains the local user password using the OpenDirectory APIs.
3. If the network password does not match the local password, alert the user and prompt them for their local password.
4. Using the local password, first check to ensure it is the correct local password.
5. If the password is correct then change the local password, the user's local Keychain, from the local password to the network password.

This also needs to be done when the user changes their network password. Assuming the local password was already in sync, NoMAD will use the old and new network passwords submitted by the user to change the local password.

***Note:*** behavior with storing the password in the local Keychain may be problematic, but will be corrected.