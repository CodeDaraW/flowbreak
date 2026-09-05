# FlowBreak

[English](README.en.md) · MIT · macOS 14+ · Apple Silicon

一个尊重工作节奏的 macOS 休息提醒工具：护眼、起身提醒，以及可独立控制的保持唤醒与 Agent 暂停模式。

**当前状态：工程初始化，尚不是完整休息提醒产品。** 已有双语菜单栏、设置保存、计时核心和规则测试；自动提醒、系统空闲检测、电源控制、恢复和统计尚未接入。菜单栏不会启动真实计时或阻止系统休眠。

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

## AI 与贡献者入口

先读 [AGENTS.md](AGENTS.md)，再读 [文档工作流](docs/README.md) 和 [当前迭代](docs/iterations/0001-bootstrap/plan.md)。所有行为变更必须先关联规格，再记录实现与验证；重要决策进入 ADR。

- `App/`：SwiftUI 菜单栏与设置、macOS 集成入口。
- `Packages/FlowBreakCore/`：确定性规则，不含 UI、IOKit 和真实时钟。
- `docs/specs/`：当前认可的产品规则与验收标准。
- `docs/iterations/`：按稳定编号保留每轮变更、任务、结果。
- `docs/decisions/`：不可悄悄覆盖的技术决策历史。
- `docs/research/`：来源、发现、局限与待验证项。

详细实现边界见 [需求追踪](docs/specs/requirements.json) 与 [路线图](docs/roadmap.md)。

## 开源

[MIT](LICENSE)。欢迎贡献，流程见 [CONTRIBUTING.md](CONTRIBUTING.md)。Git 仅在本地初始化，尚未配置远程仓库、CI 托管或正式发布身份。不要提交个人账号、证书、用户运行日志或原始聊天导出。
