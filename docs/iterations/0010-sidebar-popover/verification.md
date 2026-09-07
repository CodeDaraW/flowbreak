# Verification

User screenshots are the before evidence. Settings used Label's per-symbol width and a selection rectangle inside FlowButtonStyle's additional padding/hover surface. Dashboard always painted FlowStyle.canvas over NSPopover's native material. Native verification pending.


make check passed: 56 Swift tests, SDD/bilingual validation, arm64 BUILD SUCCEEDED. Signed with scripts/sign.sh and strict signature verification passed. Native light popover capture shows one continuous material from triangle into body instead of opaque body against tinted arrow. Light and dark Settings captures show fixed icon/text columns and one selection shape. Evidence lives under ignored workspaces/sidebar-popover/20260907/test_result (popover-light.png, sidebar-light.png, sidebar-dark.png).

Temporarily changed normal app appearance from system to dark for verification. After closing Settings, CU repeatedly returned noWindowsAvailable for menu-only app, including attempts through Finder reopen. Requested user to open menu bar panel for remaining dark-popover capture and restoration. No screenshot or completion claim for those remaining steps yet.


Final cleanup: CU restored Appearance to 跟随系统 with readback before quit/relaunch. Dark Settings rendering passed; dark popover screenshot remains unverified because transient window capture repeatedly failed. User was asked to open the panel, but no explicit answer was needed once live access returned. Appearance assignment is cached by user preference (not continually compared to AppKit-normalized values) so timer updates do not reconfigure popover chrome. Final make check again passed 56 tests/build; development signing and strict verification succeeded. App restarted using normal data, original appearance restored.
