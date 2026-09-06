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
