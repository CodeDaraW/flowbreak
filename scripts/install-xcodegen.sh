#!/bin/bash
# Install the pinned generator into ignored .tools/, without Homebrew drift.
set -euo pipefail
cd "$(dirname "$0")/.."
version=2.45.4
sha256=090ec29491aad50aec10631bf6e62253fed733c50f3aab0f5ffc86bc170bdbef
mkdir -p .tools
download_dir=$(mktemp -d "$PWD/.tools/xcodegen-download.XXXXXX")
trap 'rm -rf "$download_dir"' EXIT
curl --fail --location --retry 3 --silent --show-error \
  "https://github.com/yonaskolb/XcodeGen/releases/download/$version/xcodegen.zip" \
  -o "$download_dir/xcodegen.zip"
printf '%s  %s\n' "$sha256" "$download_dir/xcodegen.zip" | shasum -a 256 -c -
unzip -q "$download_dir/xcodegen.zip" -d "$download_dir"
mkdir -p .tools/bin .tools/share
cp "$download_dir/xcodegen/bin/xcodegen" .tools/bin/xcodegen
rm -rf .tools/share/xcodegen
cp -R "$download_dir/xcodegen/share/xcodegen" .tools/share/xcodegen
cp "$download_dir/xcodegen/LICENSE" .tools/share/xcodegen/LICENSE
chmod +x .tools/bin/xcodegen
.tools/bin/xcodegen --version
