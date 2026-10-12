# Iteration 0015: Countdown and rest polish

Status: completed

Source: user request and three UI screenshots, 2026-10-12. Requirements: FB-001, FB-005, FB-008, FB-009, FB-011.

| Change | Acceptance |
|---|---|
| Keep-awake extensions | +30 / +60 minutes add 1800 / 3600 seconds, including Agent sessions |
| Rest presentation | Close the menu-bar dashboard before showing eye or movement rest; reopening remains available |
| Menu-bar countdown | At least 60 seconds: ceil(remaining / 60) minutes; below 60 seconds: ceil(remaining) seconds; monospaced digits |
| Weak reminder default | First launch and reset use 30 seconds; existing saved values remain intact |

Use the existing AppKit presentation ownership from ADR-0006 and nonactivating rest panel. The model emits a synchronous presentation event consumed by the menu-bar controller. No scheduler, power-assertion or focus semantics change; no new architecture decision is needed.

Validation: deterministic countdown boundaries and settings persistence; make check; native presentation check on available macOS 26.6.2 arm64. macOS 14 and physical multi-display/Space acceptance remain pending if unavailable. Do not publish or configure remotes.
