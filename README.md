# NoMAD - Community Maintained Fork

A community-maintained fork of NoMAD with modern macOS support and Swift modernization.

## About This Fork

This fork continues development of NoMAD with focus on:
- **macOS 26 compatibility** - Updated menu bar handling and API compatibility
- **Swift 5.0/5.10 modernization** - Modern Swift syntax and reduced build warnings
- **Enhanced localization** - Support for 8 languages (English, French, German, Swedish, Danish, Dutch, Polish, Spanish)
- **Performance improvements** - Resolved UI threading issues and improved responsiveness
- **Active maintenance** - Bug fixes and compatibility updates for current macOS versions

The original NoMAD project was archived by Jamf in 2024 and is available at [github.com/jamf/NoMAD](https://github.com/jamf/NoMAD).

## What is NoMAD?

NoMAD allows macOS systems to integrate with Active Directory without traditional AD binding, providing:

- **Kerberos SSO** - Automatic credential management for Windows Authentication
- **Password synchronization** - Keep AD, local account, and FileVault passwords in sync
- **Certificate management** - Obtain X509 identities from Windows CA
- **AD site awareness** - Automatic LDAP server discovery and failover
- **Password expiration warnings** - Proactive notification of upcoming password changes
- **SmartCard/PKINIT support** - Alternative authentication methods

## System Requirements

- **macOS**: 10.10 (Yosemite) and later, tested through macOS 26
- **Swift**: 5.0+
- **Active Directory**: Any modern AD environment

## Installation

Download the latest release from the [Releases](https://github.com/arnemoor/NoMAD/releases) page.

## Building from Source

```bash
# Clone the repository
git clone https://github.com/arnemoor/NoMAD.git
cd NoMAD

# Build with Xcode command line tools
xcodebuild -project NoMAD.xcodeproj -scheme NoMAD -configuration Release build

# Or open in Xcode
open NoMAD.xcodeproj
```

The build number is automatically set to the git commit count.

## Configuration

NoMAD can be configured via:
- Preferences GUI in the application
- Configuration profiles
- Command-line defaults

See the [configuration documentation](CLAUDE.md#common-development-tasks) for details.

## Community & Support

- **Issues**: Report bugs and feature requests in [GitHub Issues](https://github.com/arnemoor/NoMAD/issues)
- **Discussions**: Join the [MacAdmins Slack](https://macadmins.slack.com) #nomad channel
- **Original Project**: [Jamf's archived NoMAD](https://github.com/jamf/NoMAD)

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with clear description of changes

## License

MIT License - see LICENSE file for details.

Original code copyright Jamf, community fork maintained by contributors.

## Credits

- Original NoMAD development team at Jamf
- MacAdmins community for continued support
- All contributors to this fork
