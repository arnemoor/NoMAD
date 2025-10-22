# NoMAD Release Process

This document describes the automated release process for NoMAD using the provided scripts.

## Quick Release

For a complete automated release (build, archive, notarize, GitHub release):

```bash
scripts/release.sh
```

For just creating a DMG from the latest archive:

```bash
scripts/create-dmg.sh
```

## Prerequisites

### Required Tools

1. **Xcode** - For building and archiving
2. **Command Line Tools** - `xcode-select --install`
3. **create-dmg** - For creating installer DMGs with proper layout
   ```bash
   brew install create-dmg
   ```

### Optional Tools (for full automation)

4. **GitHub CLI** - For creating releases
   ```bash
   brew install gh
   gh auth login
   ```

5. **Apple Developer Account** - For notarization
   - Active Apple Developer Program membership
   - App-specific password for notarization

## Notarization Setup

### Step 1: Create App-Specific Password

1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in with your Apple ID
3. Navigate to "Sign-In and Security" → "App-Specific Passwords"
4. Click "Generate an app-specific password"
5. Name it "NoMAD Notarization" or similar
6. Copy the generated password (you won't see it again)

### Step 2: Store Credentials in Keychain

```bash
xcrun notarytool store-credentials "notarytool-password" \
    --apple-id "your-apple-id@example.com" \
    --team-id "YOUR_TEAM_ID" \
    --password "xxxx-xxxx-xxxx-xxxx"
```

Replace:
- `your-apple-id@example.com` - Your Apple ID email
- `YOUR_TEAM_ID` - Your 10-character Team ID (from developer.apple.com)
- `xxxx-xxxx-xxxx-xxxx` - The app-specific password you generated

### Step 3: Configure Release Settings

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

Then edit `.env` with your values:

```bash
# Your Apple Developer Team ID (from developer.apple.com)
DEVELOPER_TEAM_ID="YOUR_TEAM_ID"

# Your Apple ID email
APPLE_ID="your-email@example.com"

# Keychain profile name (from step 2)
KEYCHAIN_PROFILE="notarytool-password"
```

**Note:** The `.env` file is gitignored and will not be committed to the repository.

## Release Scripts

### release.sh (Full Automation)

Complete release pipeline including:
1. Clean build folder
2. Build and archive
3. Export for distribution
4. Create DMG
5. Notarize with Apple
6. Verify DMG integrity
7. Create GitHub release

**Usage:**
```bash
./release.sh
```

**Configuration:**
Create a `.env` file from the template (see Notarization Setup above):
```bash
cp .env.example .env
# Edit .env with your credentials
```

The script will automatically load settings from `.env`

### create-dmg.sh (Simple DMG Creation)

Finds the latest Xcode archive and creates a DMG from it.

**Usage:**
```bash
./create-dmg.sh
```

This is useful when you've already archived manually in Xcode and just need to package it.

## Release Checklist

Before running the release script:

- [ ] All code changes committed
- [ ] Version bumped in `project.pbxproj` (MARKETING_VERSION)
- [ ] CHANGELOG or release notes prepared
- [ ] Tests passing
- [ ] Git tag created (`git tag -a v2.0.0 -m "Release v2.0.0"`)
- [ ] Notarization credentials configured (if notarizing)
- [ ] GitHub CLI authenticated (if creating release)

## Manual Release Process

If you prefer manual control:

### 1. Build and Archive in Xcode

```bash
xcodebuild clean archive \
    -project NoMAD.xcodeproj \
    -scheme NoMAD \
    -configuration Release \
    -archivePath ~/Desktop/NoMAD.xcarchive
```

Or use Xcode: Product → Archive

### 2. Export for Distribution

```bash
xcodebuild -exportArchive \
    -archivePath ~/Desktop/NoMAD.xcarchive \
    -exportPath ~/Desktop/Export \
    -exportOptionsPlist ExportOptions.plist
```

### 3. Create DMG

```bash
hdiutil create -volname "NoMAD 2.0.0" \
    -srcfolder ~/Desktop/Export/NoMAD.app \
    -ov -format UDZO \
    ~/Desktop/NoMAD-2.0.0.dmg
```

### 4. Notarize

```bash
# Submit
xcrun notarytool submit ~/Desktop/NoMAD-2.0.0.dmg \
    --keychain-profile "notarytool-password" \
    --wait

# Staple
xcrun stapler staple ~/Desktop/NoMAD-2.0.0.dmg
```

### 5. Verify

```bash
# Verify DMG integrity
hdiutil verify ~/Desktop/NoMAD-2.0.0.dmg

# Check code signature
codesign -vvv --deep --strict ~/Desktop/NoMAD-2.0.0.dmg

# Check notarization
spctl -a -vv -t install ~/Desktop/NoMAD-2.0.0.dmg
```

### 6. Create GitHub Release

```bash
gh release create v2.0.0 \
    --title "NoMAD v2.0.0 - Community Fork" \
    --notes-file release-notes.md \
    ~/Desktop/NoMAD-2.0.0.dmg
```

## Troubleshooting

### Notarization Fails

Check the detailed log:
```bash
xcrun notarytool log <submission-id> \
    --keychain-profile "notarytool-password"
```

Common issues:
- **Hardened Runtime not enabled** - Check signing settings in Xcode
- **Invalid entitlements** - Review entitlements plist
- **Code signing issues** - Ensure valid Developer ID certificate

### GitHub Release Fails

```bash
# Check authentication
gh auth status

# Re-authenticate if needed
gh auth login
```

### Build Fails

```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Clean build folder
xcodebuild clean -project NoMAD.xcodeproj -scheme NoMAD
```

## Version Numbering

- **MARKETING_VERSION** (e.g., 2.0.0) - User-facing version, set manually
- **CURRENT_PROJECT_VERSION** (e.g., 704) - Build number, auto-generated from git commit count

The build number is automatically set by pre-build scripts in the Xcode project.

## Post-Release

After successful release:

1. Push commits and tags to GitHub
   ```bash
   git push origin main
   git push origin v2.0.0
   ```

2. Announce on relevant channels
3. Update documentation website (if applicable)
4. Monitor for issues

## References

- [Apple Notarization Documentation](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
