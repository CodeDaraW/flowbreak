# r02 implementation audit

Source: approved r02 (SHA-256 in plan). Audit date: 2026-09-07. This table distinguishes implementation from actual runtime acceptance. The original HTML and private review receipts remain ignored. D5/D6 stay open.

| Design page | Implementation | Evidence and remaining work |
|---|---|---|
| 菜单栏面板 | DashboardView, AppModel | Light/dark cards and primary actions CU observed. Upcoming reminder estimate and nearing-due indicator now implemented; native rendering pending. |
| Dark Mode 菜单栏面板 | semantic colors + persisted appearance | CU screenshots 09–10 show native dark settings/dashboard. Panel dark still unverified. |
| Agent 模式与保持唤醒 | PowerControls, WakeController | Start/takeover/stop and real assertions observed. Deadline editing implemented; CU pending. Inactive system/display options and their legal combinations implemented; native verification pending. |
| 设置 | SettingsView, SettingsStore | Controls implemented, reminders layout CU observed. Sound, restart, position/fullscreen behavior pending. Permissions sidebar in design has no detailed page; existing no-permission design must remain honest. |
| 无操作暂停与自然重置 | SystemActivity, BreakEngine | Deterministic idle/return and known sleep tests; real lock/idle transitions pending. |
| 屏幕共享静默 | manual switch, BreakEngine | Manual path and suppression tested at core level. Auto Feishu detection explicitly allowed deferred by user; never claim automatic detection. CU sharing-start/end still pending. |
| 护眼弱提醒 | ReminderPresenter | One-shot soft behavior and snooze core tests. Floating window CU selection/focus/dismissal still pending. |
| 合并提醒 | ReminderPresenter, independent snoozes | Merge/wait/skip scope covered by distinguishing tests. Independent snooze owners persisted with legacy decoding; expanded layout CU pending. |
| 起身强提醒 | ReminderPresenter | Corner-only strong reminder and configurable cadence implemented. Real repeat/hover/position tests pending. |
| 休息进行中 | RestContent, BreakEngine | Extension CU observed for earlier 1-minute implementation. Corrected to design's 2 minutes; movement floating panel height increased for controls, must recapture. |
| 护眼休息 | RestContent, WorkSession | Real eye completion reset only eye in earlier CU run; current input-change regression still needed. |
| 休息被中断 | deliberate input sampler, BreakEngine | Deterministic tests pass. Synthetic CU key did not visibly interrupt before lock; investigate with unlocked app, not yet PASS. |
| 状态矩阵 | BreakEngine, WorkSession | Core dimensions separated. Per-cycle snoozes and scoped clear/undo now implemented. Full scenario audit remains open until native evidence closes gaps. |

## Lock blocker

CU reports Mac locked and cannot unlock. Owner: user. Next: manual unlock, then resume existing isolated session. Do not restart a running instance because observation failed. The code/build workflow remains usable while locked.
