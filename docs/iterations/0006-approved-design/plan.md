# Iteration 0006: Approved design implementation

Status: active

## Source and scope

On 2026-09-07 the user-authorized Trae → ChatGPT review loop accepted r02. Source ZIP: `FlowBreak-design-20260906-2358-r02.zip`, SHA-256 `797b1bd8b1290b401f17e1e38eb5a58f413f6296355d57038914c3e27c5a38d0`. Private exports and review receipts remain in ignored local workspaces. No third-party runtime code is copied into the application.

Requirements: FB-001 through FB-011. Preserve native macOS 14+ arm64, bilingual UI, offline operation and deterministic core. Implement the approved blue/green card hierarchy, compact menu dashboard, conditional Agent/power controls, sidebar settings, nonactivating reminders and active-rest surfaces. Match visual intent with native semantic colors, not the exporter's fixed dark-theme workaround.

## Behavioral reconciliation

[ADR-0004](../../decisions/0004-approved-design.md) supersedes conflicting old runtime rules: waiting for strong movement never silences eyes; explicitly skipping movement restarts only its cycle even in the soft window; unknown app downtime is not evidence of rest; weak eye reminders do not periodically repeat without a new user action. Hover/expanded controls must prevent reminder dismissal.

## Acceptance

Run make check. Use Computer Use against the built application, covering light/dark dashboard, settings navigation and persistence, active eye/movement rest, Agent start/takeover/stop, reminder actions and unclipped expanded controls. Record observed results separately from build/core tests; OS sleep/Space/multiple physical display checks remain pending if not observed.
