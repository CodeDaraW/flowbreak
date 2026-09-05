# FlowBreak

[English](README.en.md) · MIT · macOS 14+ · Apple Silicon

一个尊重工作节奏的 macOS 休息提醒工具：护眼、起身提醒，以及可独立控制的保持唤醒与 Agent 暂停模式。

**当前状态：可运行的开发版。** 已接入双语菜单栏、双计时、非阻断提醒、合并/延迟/跳过、主动/补记休息与撤销、原生空闲检测、保持唤醒与 Agent 模式、睡眠事件、快照和最近事件记录。启动后即开始计时；保持唤醒仅在主动开启后生效。

飞书共享自动检测仍延期，共享前需手动开启“共享静默”。窗口焦点、全屏 Space、锁屏/多屏和 macOS 14 真机体验仍待实测，详见当前迭代的验证记录。

## 本地开发

准备：Apple Silicon Mac、macOS 14+、Xcode 16+（Swift 6）、Python 3、XcodeGen 2.45.4。当前验证环境为 Xcode 26.6 / Swift 6.3.3；macOS 14 真机兼容性仍待验证。

安装固定版本 [XcodeGen](https://github.com/yonaskolb/XcodeGen/releases/tag/2.45.4)，放进 PATH，或设置 `XCODEGEN=/absolute/path/to/xcodegen`。本次工作区已缓存 `.tools/bin/xcodegen`；此目录不提交。无运行时第三方依赖，无服务端、账号或 API Key。

```sh
make generate # 从 project.yml 生成 Xcode 工程
make test     # 不启动 GUI，运行核心测试
make build    # 构建 arm64 .app，不需要开发者证书
make check    # 文档关联检查 + 测试 + 构建
make run      # 构建、临时本地签名并打开菜单栏应用
open FlowBreak.xcodeproj
```

构建输出在 `.build/DerivedData/Build/Products/Debug/FlowBreak.app`。应用不显示 Dock 图标，从菜单栏叶子图标打开。设置支持简体中文 / English / 跟随系统，参数单位为秒，有效值自动保存。生成工程不提交，`project.yml` 是工程配置唯一来源。

SwiftPM 报 `sandbox_apply: Operation not permitted` 表示运行环境限制，应在正常本机终端运行或请求执行权限；不要通过禁用沙箱改写项目。Xcode 未选中时检查 `xcode-select -p`。XcodeGen 缺失按上述方式安装；签名发布与公证尚未配置。

## 使用与本地数据

- 菜单栏查看工作累计；护眼只重置护眼，起身休息完成同时重置两者。
- 延迟作用于所有提醒；关闭面板不算跳过；柔性起身可以等到强提醒再提示。
- Agent 模式同时暂停计时与保持唤醒；“恢复计时”不会停止保持唤醒。可单独停止电源保持或结束 Agent 模式。
- 设置中选择鼠标所在屏幕、主屏或固定屏幕；显示器断开时回退主屏。
- `~/Library/Application Support/FlowBreak/` 保存版本化快照和最近 1000 条事件。设置存于本机 UserDefaults。损坏/未知版本数据会显示错误并停止覆盖，保留原文件供排查。
- 重启恢复工作累计和剩余静默；电源断言与暂停不自动恢复。快照每 15 秒与用户动作保存，崩溃最多可能丢失最近 15 秒累计。
- 已有应用运行时请先从菜单栏退出，再 `make run`，确保加载新构建。

## AI 与贡献者入口

先读 [AGENTS.md](AGENTS.md)，再读 [文档工作流](docs/README.md) 和 [当前迭代](docs/iterations/0004-reminder-app/plan.md)。所有行为变更必须先关联规格，再记录实现与验证；重要决策进入 ADR。

- `App/`：SwiftUI 菜单栏与设置、macOS 集成入口。
- `Packages/FlowBreakCore/`：确定性规则，不含 UI、IOKit 和真实时钟。
- `docs/specs/`：当前认可的产品规则与验收标准。
- `docs/iterations/`：按稳定编号保留每轮变更、任务、结果。
- `docs/decisions/`：不可悄悄覆盖的技术决策历史。
- `docs/research/`：来源、发现、局限与待验证项。

详细实现边界见 [需求追踪](docs/specs/requirements.json) 与 [路线图](docs/roadmap.md)。

## 开源

[MIT](LICENSE)。欢迎贡献，流程见 [CONTRIBUTING.md](CONTRIBUTING.md)。Git 仅在本地初始化，尚未配置远程仓库、CI 托管或正式发布身份。不要提交个人账号、证书、用户运行日志或原始聊天导出。
