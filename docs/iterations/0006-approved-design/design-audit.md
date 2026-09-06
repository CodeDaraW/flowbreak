# r02 implementation audit

Source: approved r02 (SHA-256 in plan). Audit date: 2026-09-07. This table distinguishes implementation from actual runtime acceptance. The original HTML and private review receipts remain ignored. D5/D6 stay open.

| Design page | Implementation | Evidence and remaining work |
|---|---|---|
| 菜单栏面板 | DashboardView, AppModel | Light/dark cards and primary actions CU observed. Upcoming estimate and nearing-due indicator observed in native dashboard. |
| Dark Mode 菜单栏面板 | semantic colors + persisted appearance | CU screenshots 09–10 show native dark settings/dashboard. Dark independent rest and merged panels captured in 16/18/20. |
| Agent 模式与保持唤醒 | PowerControls, WakeController | Start/takeover/stop and real assertions observed. Deadline edited 02:11 → 02:12 with correct countdown; inactive options and actual assertion releases verified. |
| 设置 | SettingsView, SettingsStore | Controls implemented, reminders layout CU observed. Restart persisted settings and full-screen behavior verified. Sound and physical position are user-deferred daily-use feedback items. Permissions sidebar in design has no detailed page; existing no-permission design must remain honest. |
| 无操作暂停与自然重置 | SystemActivity, BreakEngine | Deterministic idle/return and known sleep tests; real shortened idle pause/return verified (24/25); physical sleep scenarios remain limited. |
| 屏幕共享静默 | manual switch, BreakEngine | Manual path and suppression tested at core level. Auto Feishu detection explicitly allowed deferred by user; never claim automatic detection. CU sharing-start/end passed; counter growth and a single post-buffer reminder at +20.024675 seconds verified. |
| 护眼弱提醒 | ReminderPresenter | One-shot soft behavior and snooze core tests. Actual floating window and automatic dismissal observed. Cross-app/Space behavior is user-deferred. |
| 合并提醒 | ReminderPresenter, independent snoozes | Merge/wait/skip scope covered by distinguishing tests. Independent snooze owners persisted with legacy decoding; expanded layout CU captured after animation (18). |
| 起身强提醒 | ReminderPresenter | Corner-only strong reminder and configurable cadence implemented. Strong repeat and hover-only GUI checks remain ordinary coverage gaps; physical position is user-deferred. |
| 休息进行中 | RestContent, BreakEngine | 2-minute extension and early end verified in independent floating panel (12/16). Full-screen height bug fixed and regression captured (20). |
| 护眼休息 | RestContent, WorkSession | Real eye completion reset only eye in earlier CU run; current build also completed eye rest while retaining movement (15). |
| 休息被中断 | deliberate input sampler, BreakEngine | Deterministic tests pass. Unlocked CU key produced interruption, resumed counters and the correct notice (13). |
| 状态矩阵 | BreakEngine, WorkSession | Core dimensions separated. Per-cycle snoozes and scoped clear/undo now implemented. Full scenario audit remains open until native evidence closes gaps. |

## Current disposition

The earlier lock blocker was resolved in the unlocked CU run. On 2026-09-07 the user accepted external-display, macOS 14, sound and cross-Space checks as currently impractical, to be revisited through daily-use feedback. They are not delivery blockers and not PASS.

No confirmed unrepaired functional defect is recorded after the native acceptance fixes. Remaining ordinary GUI coverage gaps are strong repeat, hover-only auto-dismiss pause and full snooze/clear combinations; their rules have deterministic tests, but those do not prove every UI combination. Automatic Feishu detection remains explicitly deferred; manual quiet mode is available. Public distribution/signing/updating remains outside this local-use scope.
