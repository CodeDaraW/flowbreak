# Verification

2026-09-07, current macOS native session.

- `make check`: exit 0, 56 tests, 197 bilingual keys, BUILD SUCCEEDED. Initial manifest path corrected; Swift 6.3.3 compiler crashed on a method-reference Binding setter, resolved with an explicit closure.
- Original native vector icon rendered in all 10 macOS asset slots; 1024 px image visually inspected. Installed Info.plist CFBundleIconName is AppIcon.
- `./scripts/sign.sh` and `codesign --verify --deep --strict /Applications/FlowBreak.app` passed.
- Native Quit saved prior session, ditto installed to previously absent /Applications/FlowBreak.app, and process command verified running from that exact installed path.
- Computer Use: Settings → General initially off; enabled, disabled, then re-enabled successfully. Final AX state: 登录时启动 on, no error/approval message.
- Read-only `sfltool dumpbtm`: org.flowbreak.app points to file:///Applications/FlowBreak.app/ with disposition enabled, allowed, notified. No other login items changed.
- Local screenshot: workspaces/app-installation/20260907/test_result/login-enabled.png. A real logout/reboot was not performed; subsequent-login behavior is system registration, not a claimed observed reboot.
