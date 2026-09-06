# 路线图与当前进度

| 阶段 | 状态 | 记录 |
|---|---|---|
| 工程初始化 | 代码已提交；历史 GUI 阻塞保留 | [0001](iterations/0001-bootstrap/verification.md) |
| 确定性调度 | 核心测试通过并提交 | [0002](iterations/0002-scheduler/verification.md) |
| macOS 适配 | 原生空闲、电源、存储联测通过并提交 | [0003](iterations/0003-macos-runtime/verification.md) |
| 应用接线与提醒 | 开发版已实现，完整 GUI/系统体验待验收 | [0004](iterations/0004-reminder-app/verification.md) |

r02 设计已落地，主要原生链路已验收并修复（见 [0006](iterations/0006-approved-design/verification.md)）。外接屏、macOS 14、声音及跨 Space 项目经用户确认标记为当前不便测试，等待日常使用反馈，不作为交付阻塞。其余重复提醒、纯悬停和延迟组合保留为普通 GUI 回归覆盖项。飞书自动共享检测继续可选延期，当前需要手动共享静默。

公开发布阶段另行确认：远端由用户配置，正式签名、公证、图标、安装包及自动更新尚未实施。本地关键阶段持续 Git commit，不自动 push。
