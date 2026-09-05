# FlowBreak contributor and AI instructions

## Scope

Native macOS 14+, arm64 only. Swift 6, SwiftUI + AppKit. No Windows/Linux abstractions, backend or AI API integration. Test seams exist for deterministic macOS behavior, not cross-platform support.

## Read before editing

1. `docs/README.md`: specification-driven workflow.
2. `docs/specs/product.md` and `docs/specs/requirements.json`: accepted rules vs implementation status.
3. Relevant ADRs and the current `docs/iterations/` entry.

## Workflow

- New work gets a monotonically increasing iteration directory: `docs/iterations/NNNN-slug/` with plan, tasks, verification and manifest. Never reuse a completed iteration.
- Before behavior changes, update the specification and link requirement IDs in the iteration. Unconfirmed behavior stays Proposed; ask only about material unresolved product choices.
- Record architectural tradeoffs in a new ADR. Accepted decisions may be superseded by another ADR, not silently rewritten.
- Update tasks and validation during work. Mark done only with command results or explicitly documented manual evidence. A compile does not prove UI behavior.
- Run `make check` before declaring implementation complete. Platform-only acceptance remains pending until tested on the named macOS versions and scenarios.
- Do not delegate to subagents unless the user asks.

## Architecture

- `App/` owns UI, localization and persistence adapters; UI changes occur on MainActor.
- `FlowBreakCore` owns deterministic value types and rules. No global clock, timers, AppKit, IOKit, UserDefaults or singleton dependencies.
- Do not implement a giant state enum combining every independent system dimension. Keep work accumulation, reminder scheduling and suppression distinct.
- Future system callbacks enter one coordinator, which serializes events. Use monotonic elapsed time and injected event timestamps; do not count timer callbacks as time.
- Eye rest pauses eye accumulation only. Movement rest covers both. Agent human takeover resumes timing and reminders while keeping power assertions alive.
- Sharing detection may be unavailable; never equate unknown with not sharing. No private APIs without a new explicit decision. Do not read Lark/Feishu through browser or bypass CLI permissions.

## Commands and quality

Use `make generate`, `make build`, `make test`, `make check`, `make run`; see README for setup and sandbox failures. `project.yml` is authoritative; never hand-edit generated `.xcodeproj`. Keep XcodeGen pinned for reproducibility.

Test behavioral transitions using deterministic elapsed time, not real 20-minute waits. Every visible string must exist in both `en.lproj` and `zh-Hans.lproj`. Do not ship functioning-looking buttons for unimplemented behavior. Keep preview limitations visible.

No credentials, certificates, private chat exports, runtime logs or generated binaries in Git. Do not configure remotes, push or publish unless asked. MIT applies to original code; review licensing before copying third-party code.
