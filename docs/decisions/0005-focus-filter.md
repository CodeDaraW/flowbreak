# ADR-0005: Follow Do Not Disturb through Focus filters

- Status: Accepted
- Date: 2026-09-07
- Requirements: FB-007, FB-009, FB-011
- Iteration: [0007](../iterations/0007-focus-quiet/plan.md)
- Supersedes: ADR-0002's Feishu-specific automatic detection direction

The user accepts one-time setup in System Settings → Focus → Do Not Disturb → Add Filter. Use the public SetFocusFilterIntent (macOS 13+) with a quiet Boolean whose default is false, so deactivation restores normal behavior. Recommend a filter with quiet enabled. The app queries the current filter while running; no private APIs, meeting heuristics or system Focus modification. No extension/App Group is needed for the initial host-app query path; actual system integration must be tested before claiming completion.

Manual quiet and Focus quiet are independent. Any active source suppresses automatic panels and sounds. Normal idle/Agent/rest timing rules continue; Focus alone does not prove active work or natural rest. After the last quiet source clears, reuse the configured recovery buffer and recalculate due reminders. Unknown query errors conservatively suppress automatic presentation and show an explicit error; a not-found filter is shown as inactive-or-not-configured, never proof of the system's DND state. Provide an opt-out and setup guidance. Query current state on launch rather than persisting an old Focus value.
