#!/bin/bash
# Package an already signed FlowBreak.app. No Finder automation or publishing.
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ $# != 2 || "$2" != *.dmg ]]; then
  echo "Usage: $0 /path/to/FlowBreak.app /path/to/output.dmg" >&2
  exit 2
fi
app="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
mkdir -p "$(dirname "$2")" .build/release
output="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
codesign --verify --deep --strict "$app"
test -x "$app/Contents/MacOS/FlowBreak"

temp_dir=$(mktemp -d "$PWD/.build/release/dmg.XXXXXX")
stage="$temp_dir/stage"
mount_point="$temp_dir/mounted"
image="$temp_dir/FlowBreak.dmg"
attached=false
cleanup() {
  local status=$?
  trap - EXIT
  if [[ "$attached" == true ]]; then
    if ! hdiutil detach "$mount_point"; then
      echo "Could not eject DMG at $mount_point; temporary directory retained." >&2
      exit 1
    fi
  fi
  rm -rf "$temp_dir"
  exit "$status"
}
trap cleanup EXIT
mkdir -p "$stage" "$mount_point"
ditto "$app" "$stage/FlowBreak.app"
ln -s /Applications "$stage/Applications"
cp LICENSE "$stage/LICENSE.txt"
cp docs/release-notes.md "$stage/README.md"
hdiutil create -volname FlowBreak -srcfolder "$stage" -fs HFS+ -format UDZO "$image"
hdiutil verify "$image"
hdiutil attach -readonly -nobrowse -noautoopen -mountpoint "$mount_point" "$image"
attached=true
test "$(readlink "$mount_point/Applications")" = /Applications
test -f "$mount_point/LICENSE.txt"
test -f "$mount_point/README.md"
test -x "$mount_point/FlowBreak.app/Contents/MacOS/FlowBreak"
codesign --verify --deep --strict "$mount_point/FlowBreak.app"
cmp "$app/Contents/Info.plist" "$mount_point/FlowBreak.app/Contents/Info.plist"
cmp "$app/Contents/MacOS/FlowBreak" "$mount_point/FlowBreak.app/Contents/MacOS/FlowBreak"
hdiutil detach "$mount_point"
attached=false
mv -f "$image" "$output"
echo "Verified DMG: $output"
