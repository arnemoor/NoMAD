#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}NoMAD DMG Creator${NC}"
echo "================================"

# Find the latest archive
ARCHIVES_DIR="$HOME/Library/Developer/Xcode/Archives"
LATEST_ARCHIVE=$(find "$ARCHIVES_DIR" -name "*.xcarchive" -type d -print0 | xargs -0 ls -dt | head -n 1)

if [ -z "$LATEST_ARCHIVE" ]; then
    echo -e "${RED}Error: No Xcode archives found in $ARCHIVES_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}Found latest archive:${NC}"
echo "  $(basename "$LATEST_ARCHIVE")"
echo ""

# Extract the app from the archive
APP_PATH="$LATEST_ARCHIVE/Products/Applications/NoMAD.app"

if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}Error: NoMAD.app not found in archive${NC}"
    echo "  Expected: $APP_PATH"
    exit 1
fi

# Get version info from the app
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist")
BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$APP_PATH/Contents/Info.plist")

echo -e "${GREEN}App version:${NC} $VERSION (Build $BUILD)"
echo ""

# Create DMG filename
DMG_NAME="NoMAD-${VERSION}.dmg"
OUTPUT_DIR="$(pwd)/Releases"
DMG_PATH="$OUTPUT_DIR/$DMG_NAME"

# Create Releases directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Remove existing DMG if it exists
if [ -f "$DMG_PATH" ]; then
    echo -e "${BLUE}Removing existing DMG...${NC}"
    rm "$DMG_PATH"
fi

# Create the DMG using create-dmg tool
echo -e "${BLUE}Creating DMG with create-dmg...${NC}"

# create-dmg will add the Applications link automatically
create-dmg \
    --volname "NoMAD $VERSION" \
    --window-pos 200 120 \
    --window-size 500 300 \
    --icon-size 128 \
    --icon "NoMAD.app" 125 150 \
    --app-drop-link 375 150 \
    --no-internet-enable \
    "$DMG_PATH" \
    "$APP_PATH"

echo ""
echo -e "${GREEN}✓ DMG created successfully!${NC}"
echo ""
echo "  File: $DMG_NAME"
echo "  Size: $(du -h "$DMG_PATH" | cut -f1)"
echo "  Location: $OUTPUT_DIR"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Notarize the DMG (if you have Apple Developer account)"
echo "  2. Upload to GitHub release"
