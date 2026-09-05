# FlowBreak

[简体中文](README.md) · MIT · macOS 14+ · Apple Silicon

A native menu bar break reminder designed to respect your workflow: eye breaks, movement breaks, and independent keep-awake and Agent timing controls.

**Status: engineering scaffold, not a complete reminder app.** The bilingual menu bar, persistent settings, deterministic core and rule tests are implemented. Automatic reminders, idle detection, power assertions, recovery and statistics are not connected. Launching the app does not start a timer or prevent sleep.

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

## Contribute

Start with [AGENTS.md](AGENTS.md), the [documentation workflow](docs/README.md) and the [current iteration](docs/iterations/0001-bootstrap/plan.md). Behavioral changes require linked specifications, decision records and validation evidence. Engineering documentation currently uses Chinese; both product languages are maintained together.

The repository is local, with no remote configured. See [CONTRIBUTING.md](CONTRIBUTING.md) and [MIT license](LICENSE). Never commit personal accounts, certificates, runtime logs or raw chat exports.
