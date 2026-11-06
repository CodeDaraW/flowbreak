# ADR-0011：以 DMG 分发应用

- Status: Accepted
- Date: 2026-11-06
- Requirements: FB-001, FB-012
- Iteration: [0018](../iterations/0018-dmg-distribution/plan.md)
- Supersedes: [ADR-0010](0010-github-releases.md) 的 ZIP 打包与发布格式；触发、版本、权限和签名规则保留

## 背景

用户明确要求将先前的 ZIP 方案改为 DMG，沿用 macOS 常见的拖拽安装方式。GitHub 构建配置尚未推送，正式应用构建仍待完整 Xcode 环境验证。

## 决定

| 环节 | 约定 |
|---|---|
| 格式 | `FlowBreak-vX.Y.Z-macos-arm64.dmg`，同名 `.dmg.sha256`；不再发布应用 ZIP |
| 内容 | 根目录包含 FlowBreak.app、指向 `/Applications` 的 Applications 快捷入口、MIT 许可和中英安装说明 |
| 制作 | 使用系统 `hdiutil` 创建 HFS+、UDZO 压缩只读镜像；不依赖 Finder 自动化或第三方打包工具 |
| 校验 | 验证镜像、只读挂载，检查快捷入口、应用签名和可执行权限，核对可执行文件及 Info.plist 与源应用一致，再卸载 |
| 发布 | Actions artifact 包含 DMG；Release 上传 `.dmg` 与 `.sha256`；Actions 传输 artifact 的外层压缩格式不属于应用安装格式 |
| 安装 | 打开 DMG，将应用拖到 Applications，推出镜像，从 Applications 启动 |

不加入自定义背景或固定 Finder 图标布局；无需 GUI 会话即可生成可拖拽安装的镜像。应用仍为 ad-hoc 临时签名，DMG 不额外签名、公证；不承诺绕过 Gatekeeper 或 Focus Filter 正常配置。版本标签与 GitHub 权限继续遵循 ADR-0010。

## 替代方案与后果

- 保留 ZIP：用户已选择 DMG，不再同时维护两种应用分发包。
- 通过 Finder AppleScript 排列安装界面：依赖桌面会话与自动化权限，当前采用原生文件视图和快捷入口。
- PKG 安装器：独立应用无需写入多个系统目录或执行安装脚本。
- 本地最小应用测试只能证明 DMG 制作、挂载与复制，不替代 FlowBreak 本体构建、GitHub 发布或 macOS 14 下载验收。

依据：[Apple 的 Mac 软件分发打包说明](https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution)；执行环境的 `hdiutil create/attach/verify -help`。
