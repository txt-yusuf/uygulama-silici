#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="Uygulama Silici"
ZIP_NAME="Uygulama-Silici-macOS.zip"
CONFIGURATION="${1:-release}"

cd "$ROOT_DIR"

APP_BUNDLE="$("$ROOT_DIR/scripts/build_app.sh" "$CONFIGURATION")"
DMG_PATH="$("$ROOT_DIR/scripts/build_dmg.sh" "$CONFIGURATION")"
ZIP_PATH="$ROOT_DIR/dist/$ZIP_NAME"

rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_BUNDLE" "$ZIP_PATH"

echo "Release files created:"
echo "$ZIP_PATH"
echo "$DMG_PATH"
