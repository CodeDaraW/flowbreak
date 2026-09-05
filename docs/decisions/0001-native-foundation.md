# ADR-0001：原生工程与可测试核心

- Status: Accepted
- Date: 2026-09-05
- Requirements: FB-001, FB-002, FB-008, FB-011, FB-012
- Iteration: [0001](../iterations/0001-bootstrap/plan.md)

## 背景

仅支持 macOS，用户要求低资源开销、非阻断提醒、AI 友好与完整迭代决策历史。

## 决定

Swift 6 + SwiftUI + AppKit；最低 macOS 14，arm64。Swift Package 承载确定性规则，应用 target 承载 macOS 集成；不构建跨平台层。Swift Testing 验证行为。XcodeGen 2.45.4 + project.yml 作为文本工程来源，生成工程忽略。当前应用无运行时第三方依赖。

菜单栏骨架使用 MenuBarExtra；未来自动提醒另用非激活 NSPanel，必要时用 NSStatusItem 提供更精确控制。UI 主线程更新；一个协调器串行接受系统事件。设置采用版本化 Codable 数据存入 UserDefaults。运行快照与事件日志留待专门迭代。

本地应用构建不需要开发者账号，运行时 ad-hoc 签名；开启 Hardened Runtime，App Sandbox 暂不启用，不添加权限 entitlement。bundle ID `org.flowbreak.app` 仅本地占位，公开发布前确认归属。无远端、无发布流水线。

## 替代方案

Electron/Tauri 增加 web runtime 或桥接边界，本项目没有跨平台收益。纯 SwiftUI 对自动浮层的显示器、焦点和 Space 控制需 AppKit 补充。只用 Xcode 项目手工配置不利于 AI 审阅工程变更。大型第三方状态框架在初始化阶段增加依赖，暂不引入。

## 后果

需要安装固定版本 XcodeGen；通过统一脚本屏蔽日常生成细节。macOS 14 部署目标不等于已完成 14 真机验收。未来新增权限、持久化迁移或分发方式应另写 ADR。
