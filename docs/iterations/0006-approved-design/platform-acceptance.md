# 日常使用反馈项（当前不便测试）

2026-09-07 evidence: host `sw_vers -productVersion` is **26.6.2**. Actual Settings → Displays menu exposes only **Built-in Retina Display**, plus current/primary options. These facts do not prove macOS 14 runtime compatibility or external-display behavior.

## 用户确认（2026-09-07）

用户明确接受外接屏、macOS 14、声音和跨 Space 行为当前不便测试，待日常使用体验和反馈。这些项目状态为 **DEFERRED_USER_FEEDBACK**，不再阻塞本轮交付，也不标记为已测试通过。下表保留后续反馈/复测方法。

## 后续反馈与复测证据

| Case | Setup and action | Pass evidence | Current status |
|---|---|---|---|
| Display fallback | Attach external display; select it; show a reminder and a rest panel in separate runs; unplug it | Panel stays visible on primary screen with its timer/expanded state preserved, no duplicate reminder | Needs physical external display. Code now repositions visible panels instead of dismissing reminders. |
| Corner placement | Trigger reminder at each of four configured corners on current/primary/fixed display | Desktop screenshot including screen edges, all controls inside usable bounds | Selection UI implemented; desktop-wide position evidence pending. |
| Focus and Spaces | Type in a disposable document; allow weak/strong reminder; repeat in another Space and a fullscreen app | Same foreground app and caret retain typing; no Space switch; dismiss does not steal input | Panel AX shows non-key dialog; cross-app continuity still needs independent observation. |
| Sound | In an isolated session, enable each sound separately; trigger reminder/completion, then enable sharing | Human or actual audio observation confirms correct audible cue; no automatic cue while sharing | Configuration and gated invocation implemented; no auditory confirmation. Do not change system volume or audio device to manufacture evidence. |
| macOS 14 | Run the arm64 app on macOS 14 with original local signing procedure | Launch, settings, both rest types, wake assertions, idle/return and persistence succeed | Deployment target is 14; actual host is newer. Needs macOS 14 hardware/VM. |

Use the existing ignored test workspace/case.md as the running case source. Do not interpret missing hardware as an application defect or mark an unexecuted assertion PASS. User has accepted daily-use feedback instead of blocking delivery on unavailable platform tests.
