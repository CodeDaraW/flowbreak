# FlowBreak

[简体中文](README.md) · MIT · macOS 14+ · Apple Silicon

A native menu bar break reminder designed to respect your workflow: eye breaks, movement breaks, and independent keep-awake and Agent timing controls.

**Status: runnable development build.** Includes bilingual live timers, gentle/strong reminders, merging, snooze/skip, manual breaks and undo, native idle detection, keep-awake, Agent timing control, sleep events, snapshots and recent activity. Timers start at launch; power assertions require an explicit action.

Automatic Feishu sharing detection is deferred. Enable manual sharing quiet mode before sharing. Focus behavior, full-screen Spaces, lock/multiple-display behavior and macOS 14 runtime compatibility still require hands-on acceptance.

## Develop

Requires an Apple Silicon Mac, macOS 14+, Xcode 16+ with Swift 6, Python 3 and [XcodeGen 2.45.4](https://github.com/yonaskolb/XcodeGen/releases/tag/2.45.4). Verified toolchain: Xcode 26.6 / Swift 6.3.3. Runtime compatibility on macOS 14 still needs testing.

Install XcodeGen in PATH or set `XCODEGEN=/absolute/path/to/xcodegen`. A local `.tools/bin/xcodegen` is also recognized and is not committed. No third-party runtime dependencies, server or credentials are required.

```sh
make generate
make test
make build
make check
make run
open FlowBreak.xcodeproj
```

The app is built at `.build/DerivedData/Build/Products/Debug/FlowBreak.app`. `make run` applies an ad-hoc local signature and opens it. Find the leaf icon in the menu bar; there is no Dock icon. Select Chinese, English or the system language in Settings. Durations are seconds; valid changes save automatically. `project.yml` is the source of truth; generated projects are ignored.

If SwiftPM reports `sandbox_apply: Operation not permitted`, run from a normal local terminal or request execution permission; do not disable the package sandbox. Check `xcode-select -p` if Xcode is unavailable. Distribution signing and notarization are not configured.

## Behavior and data

Eye breaks reset only eye time; movement breaks reset both. Snooze suppresses every reminder until its deadline. Dismissing a panel is not skipping a break. Agent mode pauses timing and keeps the Mac awake; resuming timing leaves keep-awake active.

Snapshots and up to 1,000 events stay in `~/Library/Application Support/FlowBreak/`. Settings use local UserDefaults. Damaged or newer-format data is preserved and surfaced as an error. Snapshots save every 15 seconds and on actions; a crash can lose the last 15 seconds. Relaunch restores counters and snooze, not power assertions or paused mode. Quit an already-running build before `make run` to load new code.

## Contribute

Start with [AGENTS.md](AGENTS.md), the [documentation workflow](docs/README.md) and the [current iteration](docs/iterations/0004-reminder-app/plan.md). Behavioral changes require linked specifications, decision records and validation evidence. Engineering documentation currently uses Chinese; both product languages are maintained together.

The repository is local, with no remote configured. See [CONTRIBUTING.md](CONTRIBUTING.md) and [MIT license](LICENSE). Never commit personal accounts, certificates, runtime logs or raw chat exports.
