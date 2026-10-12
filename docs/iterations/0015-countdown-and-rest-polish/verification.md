# Verification

Date: 2026-10-12. Environment: macOS 26.6.2 (25G83), arm64. Requirements: FB-001, FB-005, FB-008, FB-009, FB-011.

## Results

| Check | Expected and actual | Verdict |
|---|---|---|
| `make check` | Exit 0; 12 requirements, 15 iterations, 199 bilingual keys; 50 core + 6 macOS adapter tests pass; Xcode Debug build succeeds | PASS |
| Wake button wiring | Source review: +30 invokes `extendWake(seconds: 1800)`; +60 invokes `extendWake(seconds: 3600)`; shared controls cover wake and Agent | PASS (source/build) |
| Countdown boundaries | Isolated harness executes actual formatter and bundled English/Chinese resources: 1800 and 1799 → 30 minutes; 60.01 → 2 minutes; 60 → 1 minute; 59.99 → 60 seconds; 59 → 59 seconds; 1 and 0.1 → 1 second; 0 → 0 seconds | PASS (18 cases) |
| Digit width | Measure actual localized strings for 10...59 seconds with the assigned AppKit monospaced digit font; maximum width difference <0.01 pt in both languages | PASS |
| Settings persistence | Empty isolated UserDefaults → 30; save 8 and reload → 8; reset and reload → 30; strong remains 15 | PASS |
| Native rest handoff | Open the controller's real NSPopover on a native test-window anchor; invoke model eye/movement actions; subscriber confirms the popover is already closed before rest presentation; actual rest NSPanel is visible, non-key/non-main at popUpMenu level | PASS |
| Reopening during rest | Reopen the same popover on the test anchor; cancel rest; dashboard stays open | PASS |
| Final docs/diff | `python3 scripts/check_docs.py` and `git diff --check` | PASS |

## Method and limitations

Temporary harness: ignored `workspaces/countdown-and-rest-polish/20261012/AppCheck.swift`, linked with production App sources (excluding the application entry point) and Xcode-built FlowBreakCore/FlowBreakMac objects. Resources copied from the app. Compile with `xcrun swiftc -swift-version 6 -D DEBUG -parse-as-library`, importing `.build/DerivedData/Build/Products/Debug`; run its AppCheck executable with `--e2e-workspace` pointing to an ignored isolated directory. It uses real AppKit windows and presentation subscriptions; it does not replace the runtime model or presenter. All assertions passed, exit 0. Defaults use only a disposable test suite; production state is untouched.

Two harness setup attempts failed before the rest handoff assertions: SwiftPM cache modules were built by Swift 6.3.3 while xcrun uses 6.4, then the command-line test application's status item did not show its popover. Linking the matching Xcode build objects resolved the compiler mismatch. A native test-window anchor allowed the actual popover/presenter handoff to be checked. This is not evidence that clicking the installed app's menu-bar item or rest buttons was tested end to end.

Actual status-bar clicks, visual layout on the user's desktop, macOS 14 runtime, physical multi-display/unplug and cross-Space acceptance remain pending. Countdown measurement covers equal digit counts; width can change when crossing a digit-count or minute/second-unit boundary. The formatter uses ceil so a running timer does not show zero early. Main dashboard/rest countdowns retain MM:SS.

Implementation and scoped verification are complete. Build artifact is `.build/DerivedData/Build/Products/Debug/FlowBreak.app`; the installed running app has not been replaced. Runtime logs, binaries and harness remain ignored, with no push or publication.

## Follow-up: install and launch (2026-10-12)

The user explicitly requested loading the new version after implementation. `./scripts/sign.sh` exited 0. Compared installed/new bundle identifiers and signing TeamIdentifier: both match. Sent a native application Quit AppleEvent; confirmed the previous process exited. Staged and verified the new bundle, preserved the previous installed bundle in an ignored workspace backup, and replaced `/Applications/FlowBreak.app`.

Strict `codesign --verify --deep --strict` passed for the installed bundle. SHA-256 of its executable equals the newly built executable. `open /Applications/FlowBreak.app` succeeded; confirmed exactly one process at the installed executable path remained running after startup. No normal settings or session files were modified by the installer. Existing app restart rules apply to timing/power restoration. This confirms loading the new binary, not completion of the pending interaction/platform acceptance above.
