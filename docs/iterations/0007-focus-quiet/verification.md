# Verification

2026-09-07 用户明确接受一次系统配置，采用 ADR 0005。

## 自动验证

`make check` 成功：56 项 Swift 测试通过，文档及双语检查通过，arm64 Debug BUILD SUCCEEDED。新增覆盖 Focus 静默下继续累计、最后静默来源退出后缓冲恢复、手动与 Focus 叠加、保留明确稍后提醒、正常长空闲返回后自然重置。首次新增测试误将自然重置预期写为离开期间立即发生，依据既有“返回时重置”规则修正，未修改该产品行为。

## 原生 Computer Use

隔离运行：`workspaces/focus-quiet/20260907/session-focus-20260907`；用例与截图留在同轮工作区，不提交运行日志。

- PASS：应用设置显示联动开关、过滤条件未生效或未配置状态、一次配置指引；“打开专注模式设置”打开正确系统页面。
- PASS：系统勿扰 → 添加过滤条件列出 FlowBreak / Quiet break reminders，参数 Silence reminders 可开启，标题正确本地化。
- BLOCKED_SIGNING：点击 Add 后持续等待，配置未保存。系统 linkd 明确记录 `Unable to get teamId from org.flowbreak.app` 和 `Rejecting invalid client due to requiresValidatedBundle`；`security find-identity -v -p codesigning` 返回 0 valid identities。当前为临时签名，不绕过系统身份校验。
- 已取消未完成配置，回读确认 No Focus filters。最初系统为 Sleep On；本轮未切换任何 Focus，未改变原有专注模式。
- 勿扰开启/关闭、应用重启、手动静默叠加的真实系统链路未验收，不标记 PASS。开发身份配置完成后再执行。Owner：用户准备 Apple ID/开发签名，Codex 继续构建和验收。

证据：`test_result/filter-discovered.png`、`test_result/filter-save-blocked.png`。待配置开发签名这一条件变化后恢复验收；不反复重试当前身份。

2026-09-07 阻塞复核：连续三轮仍无有效代码签名身份，当前回读仍为 0 valid identities。此前两轮已提交实现和不依赖签名的普通回归证据；剩余系统联动无法在当前身份下推进。迭代标记 blocked，等待用户配置开发签名后恢复，不重复尝试系统保存。纯悬停仍保留为独立未证实项，不因签名阻塞而标记完成。


2026-09-07 11:14 resumed with user-supplied Apple Development identity. Leaf certificate and key existed but valid-identity lookup initially returned zero. Validated and installed Apple's WWDR G3 intermediate from https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer; no trust override. Identity now valid; deep development signing and strict verification succeeded. Actual CU System Settings → Do Not Disturb → Add Filter → FlowBreak → Add succeeded immediately, and the saved filter appears as Quiet break reminders, On. Screenshot: workspaces/focus-quiet/20260907-01/test_result/filter-saved.png. Initial system Focus list showed no active mode. Control Center cannot currently be located through CU; requested user to enable DND for activation/restart/overlap tests. Filter save PASS does not yet prove on/off behavior.


Signed native acceptance completed: CU read System Settings Do Not Disturb, On and app Focus quiet is active; restart while active retained quiet. With isolated eye/movement thresholds 0.1/0.2/0.3 minutes, counters exceeded thresholds without reminder events. Enabled manual quiet, then user disabled DND. CU confirmed system DND no longer On, current filter inactive, manual quiet still checked. After disabling manual quiet, one strongReminder event was recorded 64.426 seconds later, never before the 20-second recovery buffer. Separate public input-duration read was ~0.006 seconds during observation, so additional delay is consistent with the required two-second input grace. Do not describe the measured delay as exactly 20 seconds. The automatic presenter records strongReminder only after show succeeds; the CU screenshot at that time selected the dashboard popover rather than the independent reminder, so no independent post-buffer panel screenshot is claimed.

Screenshots in workspaces/focus-quiet/20260907-01/test_result: filter-saved.png, system-dnd-on.png, focus-active-after-restart.png, overdue-suppressed.png, manual-remains-after-dnd-off.png. User confirmed system DND off. Restored shortened test parameters via Reset and read back 20/40/60 minutes, idle120 seconds/natural5 minutes. Quit isolated app and restarted with normal user storage. Kept the one-time system filter configured as requested. No actual audible sound or macOS14 retest; those remain user-deferred. Unknown-query fault injection and filter-removal variants have no new native evidence.

make check passed with 56 tests, and ./scripts/sign.sh selected the unique development identity and passed codesign --verify --deep --strict. No certificate, private key, Team ID configuration or raw runtime log committed.
