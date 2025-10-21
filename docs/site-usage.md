***AD Site Awareness***

NoMAD is AD site-aware and will use them when determining what AD Domain Controller (DC) to use.

***1. What Is a "Site"?***

Before site awareness means much to you, it would probably be helpful to understand what a site is. Active Directory uses sites to best determine what is the closest DC to your system. Within AD sites are listed by their CIDR network address, e.g. 192.168.128.0/23. Within each of these subnet objects AD specifies the name of a site to be used. The site name corresponds to a site object that than lists DCs that should be used within that site.

***2. How NoMAD Works With Sites*** 

When first discovering what DCs exist for a network, NoMAD does a DNS SRV record lookup for that domain.

```dig +short -t SRV _ldap._tcp.domain.com```

This will return a list of DCs that are authoritative for that AD Domain. NoMAD will then take the highest ranked server and perform an [ LDAP Ping](https://msdn.microsoft.com/en-us/library/cc223811.aspx) to that server. The reply to this "ping" contains a number of telematics about the AD environment including what site the client should be in, based upon how that client is reaching the DC.

If a site is found, NoMAD will re-query for SRV records specific to the DNS site.

```dig +short -t SRV _ldap._tcp.site._sites.domain.com```

NoMAD will then check the results of the lookup for TCP and LDAP connectivity.

Having found a DC that works, NoMAD will continue to use that until a network change happens. At which point the process will start all over again. If at any time that server stops responding, NoMAD will go to the next server, by weight, from the DNS lookup results and attempt to use that one.

***3. Notes***

At this time NoMAD is not IPv6 aware for site detection. If you are interested in this functionality please let us know as we would be interested in working with you on this.

In general we're of two minds with site support. While NoMAD is not network-intensive there's no point in using a slow WAN link to access a DC for those lookups. On the other hand, most environments we've looked at have very poor, if any at all, site organization. Also with the large use of RFC1597 addresses both inside institutional networks and at home, it's quite possible to have the false detection of a site that the user isn't on. We believe that the current methodology is the best balance of these needs, however, we'd love any feedback on how to improve. 