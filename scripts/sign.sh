#!/bin/bash
# Sign a local build. Optional FLOWBREAK_SIGNING_IDENTITY selects a specific identity.
# A unique valid development identity is preferred; no key material is exported.
set -euo pipefail
cd "$(dirname "$0")/.."
app="${1:-.build/DerivedData/Build/Products/Debug/FlowBreak.app}"
identity="${FLOWBREAK_SIGNING_IDENTITY:-}"
if [[ -z "$identity" ]]; then
  identities=$(security find-identity -v -p codesigning | sed -nE '/"Apple Development:|"Mac Developer:/s/^[[:space:]]*[0-9]+\) ([A-F0-9]+) .*/\1/p')
  count=$(printf '%s\n' "$identities" | sed '/^$/d' | wc -l | tr -d ' ')
  if [[ "$count" == 1 ]]; then
    identity="$identities"
  elif [[ "$count" == 0 ]]; then
    identity="-"
    echo "No development identity: using ad-hoc signing; Focus filter setup may be unavailable." >&2
  else
    echo "Multiple development identities: set FLOWBREAK_SIGNING_IDENTITY explicitly." >&2
    exit 1
  fi
fi
codesign --force --deep --sign "$identity" "$app"
codesign --verify --deep --strict "$app"
