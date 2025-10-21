Basic and then less-basic usage instructions for NoMAD

***Basic***

1. Launch NoMAD
2. You may be presented with a preferences window allowing you to fill out basic information about your environment. Only the top item is required. This is your active directory domain. If you're bound to AD, NoMAD will do the rest.

***Advanced***

- If you are already bound to AD, NoMAD will look for this at startup and use your AD domain to do it's configuration.

- If you want to make things simple you can push out NoMAD preferences via a profile, pushing preferences from some form of management server, or by creating a NoMAD preference file in ```/Library/Preferences/com.trusourcelabs.NoMAD.plist``` with the keys you want to manage.

***Logging***

- You can get additional logs from NoMAD by setting the ```Verbose``` key in the preferences to true as a boolean or 1 as an integer.
```defaults write com.trusourcelabs.NoMAD Verbose -bool true```

- Also, when the app is running you can hold down control-option which will give change the Preferences menu option to Spew Logs. This will dump the entire state of the app, the currently logged in user's record in AD, and a list of any Kerberos tickets the user has to the console logs.