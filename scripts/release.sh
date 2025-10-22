#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Load configuration from .env file if it exists
# Look for .env in project root (parent directory of scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

if [ -f "$ENV_FILE" ]; then
    echo -e "${BLUE}Loading configuration from .env${NC}"
    # Export variables from .env, ignoring comments and empty lines
    export $(grep -v '^#' "$ENV_FILE" | grep -v '^$' | xargs)
else
    echo -e "${YELLOW}No .env file found. Copy .env.example to .env and configure it.${NC}"
    echo -e "${YELLOW}Expected location: $PROJECT_ROOT/.env${NC}"
fi

# Configuration - Loaded from .env or environment variables
DEVELOPER_TEAM_ID="${DEVELOPER_TEAM_ID:-""}"
APPLE_ID="${APPLE_ID:-""}"
KEYCHAIN_PROFILE="${KEYCHAIN_PROFILE:-notarytool-password}"
BUNDLE_ID="${BUNDLE_ID:-com.trusourcelabs.NoMAD}"

# Project settings
PROJECT_NAME="NoMAD"
SCHEME="NoMAD"
CONFIGURATION="Release"
WORKSPACE_DIR="$(pwd)"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   NoMAD Release Automation Script     ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo ""

# Function to print step headers
print_step() {
    echo ""
    echo -e "${BLUE}▶ $1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function to check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites"

    # Check for xcodebuild
    if ! command -v xcodebuild &> /dev/null; then
        echo -e "${RED}Error: xcodebuild not found. Please install Xcode.${NC}"
        exit 1
    fi

    # Check for create-dmg
    if ! command -v create-dmg &> /dev/null; then
        echo -e "${RED}Error: create-dmg not found. Please install it:${NC}"
        echo -e "${RED}  brew install create-dmg${NC}"
        exit 1
    fi

    # Check for gh (GitHub CLI)
    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}Warning: GitHub CLI (gh) not found. Install with: brew install gh${NC}"
        echo -e "${YELLOW}GitHub release creation will be skipped.${NC}"
        GH_AVAILABLE=false
    else
        GH_AVAILABLE=true
    fi

    # Check for notarytool
    if ! xcrun notarytool --help &> /dev/null; then
        echo -e "${YELLOW}Warning: notarytool not available. Notarization will be skipped.${NC}"
        NOTARIZE_AVAILABLE=false
    else
        NOTARIZE_AVAILABLE=true
    fi

    echo -e "${GREEN}✓ Prerequisites checked${NC}"
}

# Step 1: Clean build folder
clean_build() {
    print_step "Step 1: Cleaning build folder"

    xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        clean

    echo -e "${GREEN}✓ Build folder cleaned${NC}"
}

# Step 2: Build and Archive
build_and_archive() {
    print_step "Step 2: Building and archiving"

    ARCHIVE_PATH="$HOME/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)/${PROJECT_NAME}.xcarchive"

    xcodebuild archive \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -archivePath "$ARCHIVE_PATH"

    echo -e "${GREEN}✓ Archive created at: $ARCHIVE_PATH${NC}"

    # Get version info
    APP_PATH="$ARCHIVE_PATH/Products/Applications/${PROJECT_NAME}.app"
    VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist")
    BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$APP_PATH/Contents/Info.plist")

    echo -e "${GREEN}Version: $VERSION (Build $BUILD)${NC}"
}

# Step 3: Export Archive
export_archive() {
    print_step "Step 3: Exporting archive"

    EXPORT_DIR="$WORKSPACE_DIR/build/Release"
    mkdir -p "$EXPORT_DIR"

    # Create export options plist
    EXPORT_OPTIONS_PLIST="$WORKSPACE_DIR/ExportOptions.plist"
    cat > "$EXPORT_OPTIONS_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>$DEVELOPER_TEAM_ID</string>
</dict>
</plist>
EOF

    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_DIR" \
        -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"

    # Clean up export options
    rm "$EXPORT_OPTIONS_PLIST"

    EXPORTED_APP="$EXPORT_DIR/${PROJECT_NAME}.app"
    echo -e "${GREEN}✓ App exported to: $EXPORTED_APP${NC}"
}

# Step 4: Create DMG
create_dmg() {
    print_step "Step 4: Creating DMG"

    # Create Releases directory if it doesn't exist
    RELEASES_DIR="$WORKSPACE_DIR/Releases"
    mkdir -p "$RELEASES_DIR"

    DMG_NAME="${PROJECT_NAME}-${VERSION}.dmg"
    DMG_PATH="$RELEASES_DIR/$DMG_NAME"

    # Remove existing DMG if it exists
    [ -f "$DMG_PATH" ] && rm "$DMG_PATH"

    # Create the DMG using create-dmg tool
    echo "  Creating DMG with create-dmg..."

    # create-dmg will add the Applications link automatically
    create-dmg \
        --volname "${PROJECT_NAME} ${VERSION}" \
        --window-pos 200 120 \
        --window-size 500 300 \
        --icon-size 128 \
        --icon "${PROJECT_NAME}.app" 125 150 \
        --app-drop-link 375 150 \
        --no-internet-enable \
        "$DMG_PATH" \
        "$EXPORTED_APP"

    echo -e "${GREEN}✓ DMG created: $DMG_NAME ($(du -h "$DMG_PATH" | cut -f1))${NC}"
}

# Step 5: Notarize DMG
notarize_dmg() {
    if [ "$NOTARIZE_AVAILABLE" = false ]; then
        echo -e "${YELLOW}⊘ Notarization skipped (notarytool not available)${NC}"
        return
    fi

    if [ -z "$DEVELOPER_TEAM_ID" ] || [ -z "$APPLE_ID" ]; then
        echo -e "${YELLOW}⊘ Notarization skipped (credentials not configured)${NC}"
        echo -e "${YELLOW}  Set APPLE_TEAM_ID and APPLE_ID_EMAIL environment variables${NC}"
        return
    fi

    print_step "Step 5: Notarizing DMG"

    echo "Submitting to Apple notary service..."
    echo "This may take several minutes..."

    # Submit for notarization
    xcrun notarytool submit "$DMG_PATH" \
        --apple-id "$APPLE_ID" \
        --team-id "$DEVELOPER_TEAM_ID" \
        --keychain-profile "$KEYCHAIN_PROFILE" \
        --wait

    # Staple the notarization ticket
    echo "Stapling notarization ticket..."
    xcrun stapler staple "$DMG_PATH"

    echo -e "${GREEN}✓ DMG notarized and stapled${NC}"
}

# Step 6: Verify DMG
verify_dmg() {
    print_step "Step 6: Verifying DMG"

    hdiutil verify "$DMG_PATH"

    # Check code signature
    echo ""
    echo "Checking code signature..."
    codesign -vvv --deep --strict "$DMG_PATH" 2>&1 | head -5

    # Check notarization status
    if [ "$NOTARIZE_AVAILABLE" = true ]; then
        echo ""
        echo "Checking notarization status..."
        spctl -a -vv -t install "$DMG_PATH" 2>&1 | head -3
    fi

    echo -e "${GREEN}✓ DMG verified${NC}"
}

# Step 7: Create GitHub Release
create_github_release() {
    if [ "$GH_AVAILABLE" = false ]; then
        echo -e "${YELLOW}⊘ GitHub release skipped (gh CLI not available)${NC}"
        return
    fi

    print_step "Step 7: Creating GitHub release"

    TAG="v${VERSION}"

    # Check if tag exists
    if git rev-parse "$TAG" >/dev/null 2>&1; then
        echo "Tag $TAG already exists"
    else
        echo -e "${YELLOW}Tag $TAG does not exist. Please create it first.${NC}"
        read -p "Create tag now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git tag -a "$TAG" -m "NoMAD v${VERSION}"
            git push origin "$TAG"
        else
            echo -e "${YELLOW}⊘ GitHub release skipped (tag not created)${NC}"
            return
        fi
    fi

    # Read release notes from file or use default
    RELEASE_NOTES_FILE="$WORKSPACE_DIR/release-notes.md"
    if [ -f "$RELEASE_NOTES_FILE" ]; then
        NOTES=$(cat "$RELEASE_NOTES_FILE")
    else
        NOTES="NoMAD ${VERSION} - See commit history for changes."
    fi

    # Get the correct repository (origin, not upstream)
    REPO=$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')

    # Create release
    gh release create "$TAG" \
        --repo "$REPO" \
        --title "NoMAD v${VERSION}" \
        --notes "$NOTES" \
        "$DMG_PATH"

    echo -e "${GREEN}✓ GitHub release created${NC}"
}

# Main execution
main() {
    check_prerequisites
    clean_build
    build_and_archive
    export_archive
    create_dmg
    notarize_dmg
    verify_dmg
    create_github_release

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Release Process Complete! 🎉        ║${NC}"
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo ""
    echo -e "${BLUE}Release artifacts:${NC}"
    echo "  DMG: $DMG_PATH"
    echo "  Version: $VERSION"
    echo "  Build: $BUILD"
    echo ""
}

# Run main function
main
