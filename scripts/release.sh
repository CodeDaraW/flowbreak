#!/bin/bash
# Build/package only. Never pushes a tag or contacts the GitHub Releases API.
# Optional tag: vX.Y.Z[-alpha.N|-beta.N|-rc.N]. No tag creates a dev artifact.
set -euo pipefail
cd "$(dirname "$0")/.."
tag="${1:-}"
build_number="${GITHUB_RUN_NUMBER:-1}"
if [[ $# -gt 1 || ( -n "$tag" && ! "$tag" =~ ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-(alpha|beta|rc)\.[1-9][0-9]*)?$ ) ]]; then
  echo "Usage: $0 [vX.Y.Z[-alpha.N|-beta.N|-rc.N]]" >&2
  exit 2
fi
if [[ ! "$build_number" =~ ^[1-9][0-9]*$ ]]; then
  echo "GITHUB_RUN_NUMBER must be a positive integer." >&2
  exit 2
fi
version_args=("CURRENT_PROJECT_VERSION=$build_number")
if [[ -n "$tag" ]]; then
  version="${tag#v}"
  version="${version%%-*}"
  version_args+=("MARKETING_VERSION=$version")
  label="$tag"
else
  label="dev-$(git rev-parse --short=12 HEAD)"
fi
if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 ]]; then
  echo "Release packaging requires an Apple Silicon Mac." >&2
  exit 1
fi
xcodebuild -version
make generate
xcodebuild -project FlowBreak.xcodeproj -scheme FlowBreak -configuration Release \
  -destination 'platform=macOS,arch=arm64' -derivedDataPath .build/release/DerivedData \
  CODE_SIGNING_ALLOWED=NO "${version_args[@]}" build

app="$PWD/.build/release/DerivedData/Build/Products/Release/FlowBreak.app"
plist="$app/Contents/Info.plist"
binary="$app/Contents/MacOS/FlowBreak"
require_equal() {
  if [[ "$1" != "$2" ]]; then
    echo "$3: expected '$2', got '$1'." >&2
    exit 1
  fi
}
require_equal "$(lipo -archs "$binary")" arm64 Architecture
require_equal "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$plist")" org.flowbreak.app BundleID
require_equal "$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$plist")" 14.0 MinimumSystem
require_equal "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$plist")" "$build_number" BuildNumber
if [[ -n "$tag" ]]; then
  require_equal "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")" "$version" AppVersion
fi
# Explicit ad-hoc identity: never select or export a developer's certificate.
codesign --force --deep --sign - "$app"
codesign --verify --deep --strict "$app"

dist="$PWD/.build/release/dist"
rm -rf "$dist"
mkdir -p "$dist"
archive="FlowBreak-$label-macos-arm64.dmg"
./scripts/package-dmg.sh "$app" "$dist/$archive"
cp docs/release-notes.md "$dist/RELEASE-NOTES.md"
(
  cd "$dist"
  shasum -a 256 "$archive" > "$archive.sha256"
  shasum -a 256 -c "$archive.sha256"
)
echo "Release package: $dist/$archive"
