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

The app is built at `.build/DerivedData/Build/Products/Debug/FlowBreak.app`. `make run` applies an ad-hoc local signature and opens it. Find the leaf icon in the menu bar; there is no Dock icon. Select Chinese, English or the system language in Settings. Durations use minutes or seconds as labeled; valid changes save automatically. `project.yml` is the source of truth; generated projects are ignored.

If SwiftPM reports `sandbox_apply: Operation not permitted`, run from a normal local terminal or request execution permission; do not disable the package sandbox. Check `xcode-select -p` if Xcode is unavailable. Distribution signing and notarization are not configured.

## Automated builds and downloads

The [GitHub Actions workflow](https://github.com/CodeDaraW/flowbreak/actions/workflows/build.yml) is defined in [build.yml](.github/workflows/build.yml). Download versioned apps from [Releases](https://github.com/CodeDaraW/flowbreak/releases). The first hosted run after pushing this configuration still needs verification.

| Trigger | Work | Download |
|---|---|---|
| Push to main or open/update a PR | `make check`, then build and package the Release configuration | `FlowBreak-macos-arm64` artifact on the Actions run page, retained for 14 days |
| Actions → Build and Release → Run workflow | Check and package without publishing | Same artifact |
| Push `v1.2.3` | Check, package and create the matching GitHub Release | Release DMG and `.sha256` assets |
| Push `v1.2.3-rc.1` | Same, marked as a prerelease | Releases; alpha / beta / rc supported, starting at 1 |

Builds use an arm64 `macos-15` runner, Xcode 16.4 and SHA-256-verified XcodeGen 2.45.4. Only the built-in `GITHUB_TOKEN` is needed, with no PAT or certificate secrets. The app version comes from the tag's `1.2.3`; the build number uses the Actions run number. Existing Releases are never overwritten. Rerunning an already published tag fails at Release creation; use a new version for fixes.

After committing and pushing the configuration and release code to main, publish by pushing a version tag, for example:

```sh
git tag -a v0.1.0 -m "FlowBreak v0.1.0"
git push origin v0.1.0
```

Only tag pushes publish automatically; creating a Release in the web UI does not trigger this workflow. GitHub Actions must be enabled, and repository/organization policies must allow the release job's `contents: write` permission. With full Xcode installed, run `./scripts/install-xcodegen.sh`, `make check`, then `./scripts/release.sh v0.1.0` to check packaging locally. Outputs go to `.build/release/dist/`; the script itself never publishes.

**Downloads are development builds with ad-hoc signing and no Apple notarization.** They require macOS 14+ and Apple Silicon; macOS 14 runtime acceptance remains pending. Download both the DMG and its `.sha256`, then run `shasum -a 256 -c FlowBreak-v0.1.0-macos-arm64.dmg.sha256` using the actual version. Quit the old app, open the DMG and drag FlowBreak.app onto its Applications shortcut. Eject the image, then launch the app from Applications. macOS may block it; consult [Apple's guidance](https://support.apple.com/en-us/102445) before allowing it to open. Focus Filter setup may be unavailable; manual quiet mode is available. Downloaded-build system integration, including login items, still needs testing. See [release notes](docs/release-notes.md) and [ADR-0011](docs/decisions/0011-dmg-distribution.md).

## Behavior and data

Eye breaks reset only eye time; movement breaks reset both. Snooze suppresses every reminder until its deadline. Dismissing a panel is not skipping a break. Agent mode pauses timing and keeps the Mac awake; resuming timing leaves keep-awake active.

Snapshots and up to 1,000 events stay in `~/Library/Application Support/FlowBreak/`. Settings use local UserDefaults. Damaged or newer-format data is preserved and surfaced as an error. Snapshots save every 15 seconds and on actions; a crash can lose the last 15 seconds. Relaunch restores counters and snooze, not power assertions or paused mode. Quit an already-running build before `make run` to load new code.

## Engineering documentation

Start with [AGENTS.md](AGENTS.md), the [documentation workflow](docs/README.md) and its iteration index. Behavioral changes require linked specifications, decision records and validation evidence. Engineering documentation currently uses Chinese; both product languages are maintained together.

## Open source and contribution policy

This project was built entirely through **Vibe Coding**: AI generated and iterated on the code under the author’s prompts and feedback.

FlowBreak is open source under the [MIT License](LICENSE). **External contributions, including pull requests, are not accepted.** See the [contribution policy](CONTRIBUTING.md). You are welcome to use, fork and modify it under the MIT license.

Never commit personal accounts, certificates, runtime logs or raw chat exports.
