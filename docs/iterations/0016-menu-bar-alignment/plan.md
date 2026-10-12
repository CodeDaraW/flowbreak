# Iteration 0016: Menu-bar vertical alignment

Status: completed

Source: user screenshot and reported vertical misalignment after iteration 0015, 2026-10-12. Requirements: FB-001, FB-011.

| Scope | Acceptance |
|---|---|
| Icon and countdown | Center visible symbol and localized countdown vertically within one template image |
| Width | Retain equal-width digits and minute/second formatter; use typographic advance for text width |
| Native interaction | Retain NSStatusBarButton left/right-click and popover behavior; expose countdown in accessibility label |
| Delivery | make check, inspect rendered image examples, sign/install/relaunch after validation |

App-only Core Text rendering, described in ADR-0009. No scheduler, persisted-settings or timing changes. Render only when symbol/countdown changes. Verify Chinese/English, minute/second and varied symbols on available macOS 26.6.2 arm64. macOS 14, external displays and live system-menu appearance remain limited to evidence actually captured.
