# Verification

2026-10-12. Environment: macOS 26.6.2 (25G83), arm64. FB-001, FB-011.

| Check | Actual | Result |
|---|---|---|
| Final `make check` | Exit 0; 12 requirements, 16 iterations, 199 bilingual keys; 50 core + 6 macOS tests; Xcode build succeeds | PASS |
| Native rendering | Actual MenuBarLabel rendered at 2x for six symbols and four Chinese/English minute/second strings; alpha >=128 visible vertical bounds measured separately for icon/text; all centers differ by <=1 physical pixel (0.5pt) | PASS, 24 combinations |
| Stable digit widths | Render 10...59 for each of 秒, sec, 分钟, min; each unit yields one image width | PASS, 200 renders |
| Icon-only presentation | Six empty-countdown symbols return template images | PASS |
| Visual fixture inspection | White-background preview of movement icon + 30 分钟, 59 秒, 30 min, 59 sec inspected; no vertical shift apparent | PASS |
| Installed app | Same TeamIdentifier/bundle ID as prior app; strict codesign passes; installed executable SHA-256 matches final build; exactly one installed process | PASS |
| Native interaction | CUA opened updated main panel, navigated wake controls and activated custom wake duration; running state visible, end time 19:00 | PASS |
| Final documents | `python3 scripts/check_docs.py`; `git diff --check` | PASS |

## Evidence and limits

Ignored local harness `workspaces/menu-bar-alignment/20261012/RenderCheck.swift` compiled with `xcrun swiftc -swift-version 6 -parse-as-library App/MenuBarLabel.swift ... -o .../render-check`. Execute with the ignored output directory as argument. Final render-check log and PNG previews stay in that directory; no runtime logs or binaries added to Git.

An initial render centered the full symbol canvas; the clock badge yielded up to 2 pixels center difference at 2x. Centering the native symbol alignment rectangle instead reduced all cases to at most 1 pixel. The final assertion-bearing harness exited 0. This supports the final renderer and does not establish that the prior AppKit misalignment came from one particular font metric. Apple documents SF Symbol configuration and alignment metadata in [Configuring and displaying symbol images](https://developer.apple.com/documentation/uikit/configuring-and-displaying-symbol-images-in-your-ui).

After native Quit, the previous installed bundle was preserved in an ignored backup and the new signed bundle installed. CUA startup lacked a visible window until an application reopen. During navigation, one CUA state read found no window after a successful click; reopening the app preserved the selected page. Subsequent native controls worked. User's active wake session ended at 19:00 before update; because normal application restart does not restore power assertions, the same wake mode was explicitly restarted through the actual custom-duration controls. AX state confirms running, both power switches on, and 19:00 end time. No automatic power-restoration behavior was added.

CUA screenshots capture the app's popover, not the desktop status bar. The live status-bar label has therefore not been screenshot-verified; evidence for alignment is production-renderer output, with native menu access exercised. Dark/light system tint relies on the native template image path; those full desktop appearances were not separately captured. macOS 14 and physical multiple displays remain pending.

## Follow-up reload (2026-10-12)

At the user's further reload request, confirmed the installed executable still matches the corrected build and strict signature verification passes. Native Quit replaced the earlier process; confirmed a new, single installed process. Native controls restored the observed wake session in normal timing mode, with both power switches on and the original 19:00 end time visible. No further code or settings changes.
