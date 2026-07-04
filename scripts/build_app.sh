#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="Uygulama Silici"
EXECUTABLE_NAME="UygulamaSilici"
CONFIGURATION="${1:-debug}"

cd "$ROOT_DIR"
swift build -c "$CONFIGURATION" >&2
"$ROOT_DIR/scripts/build_icon.sh" >/dev/null

BUILD_DIR="$(swift build -c "$CONFIGURATION" --show-bin-path 2>/dev/null)"
APP_BUNDLE="$ROOT_DIR/dist/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
rm -rf "$CONTENTS_DIR/_CodeSignature"

cp "$BUILD_DIR/$EXECUTABLE_NAME" "$MACOS_DIR/$EXECUTABLE_NAME"
chmod +x "$MACOS_DIR/$EXECUTABLE_NAME"

cp "$ROOT_DIR/BundleResources/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/BundleResources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
printf "APPL????" > "$CONTENTS_DIR/PkgInfo"

if command -v xattr >/dev/null 2>&1; then
    xattr -cr "$APP_BUNDLE" >/dev/null 2>&1 || true
fi
rm -rf "$CONTENTS_DIR/_CodeSignature"

echo "$APP_BUNDLE"
