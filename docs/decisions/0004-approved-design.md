# ADR-0004: Accepted design semantics and native presentation

- Status: Accepted
- Date: 2026-09-07
- Supersedes: conflicting reminder, skip and restart rules in [ADR-0003](0003-runtime-semantics.md)
- Iteration: [0006](../iterations/0006-approved-design/plan.md)
- Requirements: FB-001, FB-005, FB-006, FB-008, FB-009, FB-010, FB-011

## Decision

Use the user-authorized r02 design as the visual and interaction baseline. Keep SwiftUI/AppKit, native colors and SF Symbols; no HTML runtime or external design dependencies. Dashboard presents two compact timer cards, proactive rest actions, conditional power/Agent controls and secondary manual corrections. Settings use one sidebar. Reminder and rest panels stay nonactivating, on the selected display. Expanded options/hover pause automatic dismissal and all content must remain visible.

“Wait until strong movement” only suppresses the soft movement suggestion. Eye reminders continue; only 3/5-minute snooze suppresses every automatic reminder. Explicit movement skip restarts movement alone, including in the soft window. Weak eye reminders stay due after closing but do not repeat periodically; snooze expiry may show again. App downtime of unknown activity preserves accumulated work rather than inventing natural rest. Known idle/lock/Agent absence still follows the natural-rest threshold.

## Consequences

Update old tests that encoded superseded behavior and add distinguishing cases. Design-only controls cannot look functional before their implementation exists. Feishu automatic detection remains deferred: expose honest manual quiet mode. Runtime OS acceptance remains separate from design approval.
