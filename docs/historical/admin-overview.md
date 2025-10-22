***NoMAD Admin Guide***
v. 1.0

***Overview***

NoMAD is designed to relieve your users of the burden of being bound to a directory service, Active Directory, while giving those users all of the advantages of being bound and more. While the original intent was not for NoMAD to be used in an environment where the client machines would be bound, there are valid use cases for NoMAD in these environments as well.

NoMAD is first and foremost a password management tool allowing users to integrate into a Kerberos single sign on environment, keep track of when their directory password expires and then allow the user to change it. From this foundation NoMAD can leverage the single sign on environment to provide a number of other functions that use the user's Kerberos ticket and NoMAD's knowledge about their network account.

***Basic Operation***

On launch NoMAD looks to see if an AD domain has been set in the NoMAD preferences, if this has not been set the user will be prompted to configure the domain. NoMAD then uses that domain to query DNS for SRV records related to that domain. You can simulate this with ```dig -t SRV _ldap._tcp.nomad.test``` replacing "nomad.test" with your AD domain. Note that NoMAD uses the built-in DNS resolver APIs and not the POSIX APIs used by dig, nslookup and other tools. This ensures that NoMAD can operate with SSL VPNs and other more complicated network setups requiring the user of the built-in DNS resolver.

If NoMAD can resolve the SRV records it changes it's state to "connected" and allows for the user to sign in to the domain. The sign in process is handled by the system's Kerberos APIs which will do a DNS lookup for _kdc._tcp. records and then use those KDCs to authenticate the user.

On a successful login, NoMAD will change to a state of "logged in" and offer further functionality to the user since the user has now been authenticated into a single sign on environment. Once logged in, NoMAD will pull the user's record from AD using a Kerberos-authenticated LDAP connection. NoMAD then calculates the user's password expiration times, home share, display name and other attributes from the user record.

NoMAD will re-check it's environment on three conditions:
- Every 15 minutes.
- Each time the menu item is clicked. Note that much of NoMAD's directory lookups and other activities happen in the background, so clicking the menu starts off the lookup process but any changes may not be immediately displayed.
- Whenever a network interface changes.

NoMAD does throttle it's lookups so as to reduce unnecessary network traffic as much as possible. Additionally the network lookups that NoMAD does are fairly lightweight and mostly limited to DNS SRV record lookups and pulling the user's account information over LDAP.

On sign out NoMAD will remove the users Kerberos tickets using ```kdestroy``` and then go back to a "connected" state.

***AD Sites***

NoMAD is site aware and will use domain controllers (DCs) within the site for all operations. On initial sign in NoMAD will look up the DCs using just the AD domain. It will then iterate through the list of returned DCs querying them with LDAP pings. When a DC replies it will inform NoMAD as to what site it should be using and other telemetry about the domain. If the replying DC is not part of the site NoMAD should be using, NoMAD will then do a DNS query for the site-specific DCs it should be using. NoMAD will then iterate through the list of DCs for the site it should be a part of and check them all for connectivity. Once it has successfully found a working DC it will maintain that DC until a network change occurs and the process starts all over again.

Since NoMAD is not using it's own Kerberos library and Kerberos on it's own is not site-aware, it's possible that the client system may be using different DCs for LDAP and Kerberos. For most operations this will not present a problem, as each system is used for different purposes. This is especially true because once a user has been authenticated, NoMAD has no need to query the Kerberos KDC until the Kerberos ticket needs to be renewed.

 However, when a user changes their password it's important that the operation happens on the same DC that NoMAD is using for LDAP queries as it is for the kpasswd operation. Otherwise, in situations where replication between DCs may not be instantaneous, there may be a discrepancy between the password expiration that NoMAD shows and what the new expiration date is.

To facilitate this when changing passwords NoMAD will attempt to create a com.apple.Kerberos.plist specifying the DC currently in use by NoMAD for LDAP queries. The system Kerberos APIs will then use this DC for changing the password via Kerberos. NoMAD removes this file after the password has been changed, so as to not impede future Kerberos operations.

Note that you can prevent site lookups by specifying a list of specific DCs you'd like to use. This is done via the ```LDAPServerList``` preference key. Keep in mind that by doing this, NoMAD will only use those DCs and not fall back to any others.

***Password Expiration Calculations***

Where possible NoMAD will use ```msDS-UserPasswordExpiryTimeComputed``` which, similar to the LDAP ping, has the DC compute the user's password expiration time and then tells NoMAD. This method supports fine-grained password policies, however, it's only available in Windows 2008 domains and higher. On older domains, NoMAD will fall back to looking up the global password expiration policy and then computing the user's last password set date against that global policy. NoMAD is aware of user's that have been exempted from password expirations and will display that information accordingly.

For expiration notifications, NoMAD will start, by default, at 15 days out. This can be configured with the ```PasswordExpireAlertTime``` key in the NoMAD preferences. Once the initial threshold has been crossed NoMAD will alert the user based on the time to expiration.
- Between the threshold and 4 days - NoMAD will alert once a day
- Between 4 days and 1 day - NoMAD will alert twice per day
- Less than 1 day - NoMAD will alert every hour


