***Deployment***

NoMAD was designed to be as simple as possible to deploy into any organization regardless of size. As such, and to accommodate a variety of different organizational needs, you can deploy NoMAD in a number of ways. No way is any more "correct" than others.

***Stand Alone Application***

At the most base level, you can deploy NoMAD as a stand-alone application to your users. It does not need admin authorization to run, nor does it need to be in any particular location on the user's Mac. The only required preference to set is the AD Domain. If the machine is bound to an AD domain, the user won't even be prompted for the domain as it will be pulled from the ```dsconfigad``` settings instead.

For many smaller environments this may be all that's required for a deployment. Although to make NoMAD more useful it should be set to a Login Item in the user's System Preferences or via a Launch Agent most likely supplied by an admin.

For the more adventurous admins you could edit the DefaultPreferences.plist within the NoMAD application bundle as many preferences will default to values contained in that plist. However, this will break the application's signature and will require it to be re-signed. While this isn't a complicated process it does require a developer account with Apple.

***Package Installer***

The next step up from just handing out the .app is to put the application into a package installer. There is one on the NoMAD web page that will install NoMAD into the /Applications folder, however, keep in mind that this will require admin privileges.

It's imminently feasible to create your own package installer that could either a) lay down a default preferences file in /Library/Preferences/com.trusourcelabs.NoMAD.plist or in the user's Preferences folder. Additionally you could use a post-install script to use the ```defaults``` command to write out individual keys.

Note that NoMAD will pull from a preferences file in /Library/Preferences and then combine that with user-defined preferences.

If you are installing NoMAD in the /Applications folder, you can also install a Launch Agent for the users that will launch NoMAD on user log in. In addition you could install a configuration profile at the same time.

***Configuration Profile***

NoMAD will respect preference keys from a configuration profile. You can create one of these by hand, although not advised, or via a number of tools such as Apple's Profile Manager application, part of Apple's Server application on the Mac App Store, or 3rd party MDM solutions. A configuration profile will typically be in a binary format and signed to ensure it's validity.

Here's an example plaintext payload:

```<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ADDomain</key>
    <string>nomad.test</string>
    <key>KerberosRealm</key>
    <string>NOMAD.TEST</string>
    <key>RenewTickets</key>
    <string>1</string>
    <key>SecondsToRenew</key>
    <string>7200</string>
    <key>ShowHome</key>
    <string>0</string>
    <key>Template</key>
    <string>User Auth</string>
    <key>UseKeychain</key>
    <string>0</string>
    <key>Verbose</key>
    <string>0</string>
    <key>x509CA</key>
    <string>dc1.nomad.test</string>
</dict>
</plist>```

***Managed Preferences***

If you have an existing management solution you can easily push both the NoMAD package and the preferences from most management solutions. This is probably the easiest deployment method for larger organizations.

Within the management system you can specify a preferences domain to control. In this case NoMAD's preference domain is ```com.trusourcelabs.NoMAD```. Then add keys and values that you want to manage.