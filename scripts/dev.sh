#!/bin/bash
# Input: generate|build|test|check|run. Outputs stay in ignored local directories.
set -euo pipefail
cd "$(dirname "$0")/.."
export CLANG_MODULE_CACHE_PATH="$PWD/.build-cache/clang"
export SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build-cache/swift"
mkdir -p "$CLANG_MODULE_CACHE_PATH" "$SWIFTPM_MODULECACHE_OVERRIDE"
generate() {
  local generator="${XCODEGEN:-xcodegen}"
  if [[ -z "${XCODEGEN:-}" && -x .tools/bin/xcodegen ]]; then generator="$PWD/.tools/bin/xcodegen"; fi
  if ! command -v "$generator" >/dev/null 2>&1; then
    echo "XcodeGen missing. Install 2.45.4 or set XCODEGEN to its executable path." >&2
    exit 1
  fi
  "$generator" generate --spec project.yml
}
build() {
  generate
  xcodebuild -project FlowBreak.xcodeproj -scheme FlowBreak -configuration Debug \
    -destination 'platform=macOS,arch=arm64' -derivedDataPath .build/DerivedData \
    CODE_SIGNING_ALLOWED=NO build
}
case "${1:-check}" in
  generate) generate ;;
  build) build ;;
  test) swift test --package-path Packages/FlowBreakCore --scratch-path "$PWD/.build/core" ;;
  check)
    python3 scripts/check_docs.py
    "$0" test
    build
    ;;
  run)
    build
    ./scripts/sign.sh
    open .build/DerivedData/Build/Products/Debug/FlowBreak.app
    ;;
  *) echo "Usage: $0 generate|build|test|check|run" >&2; exit 2 ;;
esac
