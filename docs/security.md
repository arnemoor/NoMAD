***Security in NoMAD***

As an application dealing with passwords and certificates, NoMAD takes security very seriously. While you're more than welcome to peruse the code, here's some notes to give you a better understanding of what NoMAD does with your secrets.

***General Thoughts***

NoMAD itself doesn't do any of the heavy lifting as far as logging into and getting you SSO access. The interaction with Active Directory is all done via Kerberos and LDAP, Heimdal Kerberos and OpenLDAP to be specific.  

***Passwords***

While most of NoMAD is written in Swift, as of Swift 2.2 there was no easy way to directly interact with the Heimdal Kerberos APIs on OS X 10.11. Because of that an Objective-C bridging header is used to mix the two languages. Whenever you are asked for a password it's done via a secure text field and never written out anywhere. The password is then used with the Heimdal APIs and Objective-C to do  ```gss_aapl_initial_cred()``` and get a TGT for the user. When changing passwords the same process is followed using the Heimdal APIs to do ```gss_aapl_change_password()```. 

The password is never piped to kinit or other Kerberos tools.

***Keychain Usage***

NoMAD, if the preference is set, will put the user's password into the local Keychain. This is done through the use of ```SecKeychainAddGenericPassword()``` and other ```SecKeychain``` methods. The password is stored in the default keychain and will be removed if the user selects "Log Out" from the menu. 

If a password is present in the Keychain, NoMAD will use that password on launch to get Kerberos tickets.

***Certificates***

Similar to passwords, NoMAD does not send a private key across the wire. In fact the private key used for generating your CSR never leaves the Keychain. The process is done entirely within NoMAD using the ```SecKeychain``` and ```SecCertificate``` APIs.

By default the private keys are marked as non-exportable. However, you can use a preference to change this.

When sending the CSR to the Windows CA, Kerberos authentication is used and then the CSR is sent via SSL. Even though nothing in the CSR is sensitive, good data-in-motion hygiene is respected. The resulting signed public key is retrieved using Kerberos and SSL as well and then matched up with the private key in the Keychain.

***SSL***

The project in the repository has been set to Allow Arbitrary Loads for App Transport Security. You can change this in the Info tab of the project in Xcode. 

This setting allows for self-signed, but specifically trusted, certificates to be used. The reason for this is that many Windows CAs use a self-signed certificate root that all machines in the organization trust. In that situation, NoMAD would not be able to get a x509 identity, even if the root certificate was explicitly trusted in the user's Keychain.

You're more than welcome to remove this flag before compiling, just keep in mind that if you're not using a publicly trusted certificate you'll most likely have issues.

***Sandboxing***

Currently NoMAD is unable to be sandboxed on OS X/macOS due to a few features.

1.  The function being used to sleep the screen is not allowed inside a sandbox. 
2. If you want to sync the AD password with the local password, NoMAD needs to be able to change the local Keychain password. It does this using a private API ```SecKeychainChangePassword()```. If/when a public API becomes available that fulfills the same function, we'll move to that.
3. The aforementioned App Transport Security flag.

The bulk of NoMAD's functionality will work unimpeded if you do need sandboxing. Plus it would be allowed on the Mac App Store, which could be interesting.