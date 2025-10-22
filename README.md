# NoMAD - Independently Maintained Fork

An independently maintained fork of NoMAD with modern macOS support and Swift modernization.

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
- **Enhanced preferences UI** - Improved configuration interface for all NoMAD settings
- **SmartCard/PKINIT support** - When bundled with PKINITer.app (separate download required)

## System Requirements

- **macOS**: 13.5 (Ventura) or later, tested through macOS 26
- **Swift**: 5.0+
- **Active Directory**: Any modern AD environment

## Installation

### Pre-built Releases

Download the latest build from the [Releases](https://github.com/arnemoor/NoMAD/releases) page.

### Creating a Release

**Automated Release (Recommended)**

The repository includes automated release scripts for building, notarizing, and publishing releases:

```bash
# One-time setup: Configure notarization credentials
cp .env.example .env
# Edit .env with your Apple Developer credentials

# Create a complete release (builds, notarizes, creates GitHub release)
# Note: Run from project root directory
scripts/release.sh
```

See [docs/RELEASE.md](docs/RELEASE.md) for detailed instructions on:
- Setting up notarization with Apple
- Configuring release credentials
- Manual release process
- Troubleshooting

**Manual Release**

If you prefer manual control:

1. Update version in `NoMAD.xcodeproj` (MARKETING_VERSION)
2. Commit changes and create git tag: `git tag -a v2.0.0 -m "Release v2.0.0"`
3. Push commits and tag: `git push origin main && git push origin v2.0.0`
4. Run automated script: `scripts/release.sh`

The script will:
- Clean and build with Xcode
- Create archive and export for distribution
- Generate notarized DMG in `Releases/`
- Create GitHub release with release notes

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
- **Preferences GUI** - Built-in preferences window in the application
- **Configuration profiles** - MDM deployment with `com.trusourcelabs.NoMAD` domain
- **Command-line** - `defaults write com.trusourcelabs.NoMAD <key> <value>`

### Documentation

- **[Complete Preferences Reference](docs/PREFERENCES.md)** - All 89 configuration options with examples
- **[Menu Visibility Guide](docs/PREFERENCES.md#menu-item-visibility-conditions)** - What controls each menu item
- **[Configuration Examples](docs/PREFERENCES.md#configuration-examples)** - Common deployment scenarios
- **[Troubleshooting](docs/PREFERENCES.md#troubleshooting)** - Debug logging and diagnostics

### Quick Start

```bash
# Set your AD domain
defaults write com.trusourcelabs.NoMAD ADDomain "corp.example.com"

# Enable password sync
defaults write com.trusourcelabs.NoMAD LocalPasswordSync -bool true

# Set expiration warning to 14 days
defaults write com.trusourcelabs.NoMAD PasswordExpireAlertTime -int 14
```

See [docs/PREFERENCES.md](docs/PREFERENCES.md) for complete documentation.

## Support

- **Issues**: Report bugs and feature requests in [GitHub Issues](https://github.com/arnemoor/NoMAD/issues)
- **Original Project**: [Jamf's archived NoMAD](https://github.com/jamf/NoMAD)

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with clear description of changes

## License

MIT License - see LICENSE file for details.

Original code copyright Jamf. This fork is maintained independently by Arne Moor.

## Credits

- Joel Rennich - Original creator at Trusource Labs (2016)
- Ben Toms, Phillip Boushy, Peter Bukowinski, Francois Levaux-Tiffreau, Owen Pragel, Michael Lynn, Kyle Crawshaw, and the #secretgroup community
- Jamf - Maintained the project after acquiring Trusource Labs
- All contributors to the original project
