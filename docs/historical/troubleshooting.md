***How to troubleshoot NoMAD***

So, you kinda sorta got it working, but it's not doing what you want... or it's just flat out failing. Here's how to replicate what's going on manually to find out where things have gone awry.

***1. SRV Records***

The first thing NoMAD does is attempt to look up your AD Domain Controllers via a DNS lookup for any LDAP SRV records. For the following examples we'll be using "company.com" as your AD domain and "server.company.com" as your AD Domain Controller. If you're playing along at home, swap your real information in for these examples.

```dig +short -t SRV _ldap._tcp.company.com```

Will query DNS for any LDAP SRV records. If you don't get any results this means you're a) not able to reach your corporate AD domain, at which point it's probably a VPN issue or general network issue, b) you can't get any DNS resolution for your domain. Make sure you're using the expected DNS servers, or that you can actually reach your internal network.

***2. Kerberos Login***

Once you've gotten some results of the SRV lookup, the next step is to attempt to get a Kerberos ticket with an AD username and password.

```kinit user@COMPANY.COM```

No news is good new here, but you can test to ensure it worked by using the ```klist``` command which should show you having a Kerberos TGT for your domain.

If this doesn't work it's most likely that you again can't reach any of the AD Domain Controllers.

***3. LDAP Queries***

If you were able to login via Kerberos, you can try looking up information via LDAP.

Use any of the servers that you find via the ```dig``` command in the first step and attempt to do an LDAP query against it.

```ldapsearch -LLL -Q -H ldap://server.company.com -s base defaultNamingContext```

This should return a chunk of text with a defaultNamingContext attribute in it. This lets you know that you can in fact use that username and password to lookup information via LDAP.

If this doesn't work a) you're most likely not on the internal network, b) you may have some funky access rights in AD that will cause further issues.

***4. Windows CA Troubleshooting***

A few top tips for working with Windows Certificate Authorities (CA). Much like the rest of NoMAD there isn't any real magic to this as well. NoMAD will leverage your AD credentials to request a certificate from the CA's web portal. In order to regress any issues you can manually attempt this process by just using Safari.

     - Use NoMAD to ensure you are logged in with your AD user and that you have a valid Kerberos TGT
     - Use Safari, as it's Kerberos-aware by default, to connect to the CA web portal. This typically be in the style of ```https://x509.domain.com/certsrv```
     - You should be automatically logged in. If you are presented with a security dialog about trusting the CA's SSL cert, this may be where things are going wrong. Please import that CA's root cert into your local keychain and trust it. NoMAD won't connect if the web server is untrusted. If you're not automatically logged in, the web portal is most likely not set to use "Windows Authentication" which is just a checkbox in the Microsoft IIS settings. Without this set, the web portal will be asking for a password and not a Kerberos ticket.
     - If all of that works, you should be able to request a certificate through the web portal. Note that some earlier versions, i.e. pre-Windows 2008, of the portal leveraged ActiveX in the web page and may not work on a Mac. When you go through this process, you should be able to specify a certificate template to use. You should use that same template name in NoMAD.