# Tasks

- [x] D1 Archive r02 and explicit ChatGPT design approval (FB-001, FB-011).
- [x] D2 Reconcile core scheduling with approved semantics and regression tests (FB-002–FB-010).
- [x] D3 Implement native visual system, dashboard and conditional power controls (FB-001, FB-008, FB-011).
- [x] D4 Implement sidebar settings, reminders and active-rest panels (FB-005, FB-006, FB-009, FB-011).
- [ ] D5 Run make check and Computer Use acceptance; archive screenshots and update requirement evidence.

- [ ] D6 Complete remaining ordinary GUI regression: hover-only dismissal pause. Strong-repeat and merged snooze/clear/undo/restart combinations gained native evidence in the 2026-09-07 continuation. Deliberate input, expanded dismissal pause, end edit, full-screen rest and settings restart have evidence; platform tests are handled by D9.

- [x] D7 Audit all 13 r02 pages; reconcile per-cycle snooze persistence, 2-minute extension, specific undo labels, deadline/next-reminder information and pre-start power configuration. See design-audit.md; 50 tests/build passed.

- [x] D8 Unlocked CU run: independent panels, deliberate-input interruption, eye/movement completion, rest extension/early end, deadline editing, power combinations, idle return, manual correction/undo, sharing recovery. Fixed adaptive/fullscreen panel sizing and sharing rearm; 52 tests/build passed.
- [x] D9 Record user disposition: physical display/unplug, cross-Space nonactivation, audible sound and macOS 14 runtime are DEFERRED_USER_FEEDBACK (currently impractical to test). User accepts daily-use feedback; not a delivery blocker and not PASS.
