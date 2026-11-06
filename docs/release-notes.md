FlowBreak development build / FlowBreak 开发版

- Requires Apple Silicon (arm64), macOS 14 or later. Intel Macs are not supported. macOS 14 runtime acceptance remains pending.
- Download `FlowBreak-…-macos-arm64.dmg` and its `.sha256` file. In the download directory, run `shasum -a 256 -c FlowBreak-…-macos-arm64.dmg.sha256` using the actual filename.
- Quit the old app, open the DMG, and drag `FlowBreak.app` onto the Applications shortcut. Eject the image and launch the app from Applications. Look for the leaf icon in the menu bar. Existing settings and local data stay outside the application bundle.
- This build uses an ad-hoc signature. It has no Developer ID signature or Apple notarization; macOS may block opening it. See [Apple's guidance](https://support.apple.com/en-us/102445) and assess the source before allowing it in Privacy & Security. No security bypass is included.
- Focus Filter setup may be unavailable with this signature. Manual quiet mode remains available. Login-item registration must be configured from the installed app; downloaded-build system integration still needs testing.

- 仅支持 Apple Silicon（arm64）、macOS 14 及以上；不支持 Intel Mac。macOS 14 真机兼容性验收仍待完成。
- 下载 `FlowBreak-…-macos-arm64.dmg` 和同名 `.sha256`，在下载目录用实际文件名运行 `shasum -a 256 -c FlowBreak-…-macos-arm64.dmg.sha256`。
- 先退出旧版，打开 DMG，将 `FlowBreak.app` 拖到其中的 Applications 快捷入口，推出镜像后从 Applications 启动，从菜单栏叶子图标进入。已有设置与本地数据保存在应用包之外。
- 本构建使用临时签名，没有 Developer ID 签名或 Apple 公证，macOS 可能阻止打开。请参考 [Apple 官方说明](https://support.apple.com/zh-cn/102445)，确认来源后再决定是否在“隐私与安全性”中允许打开；不提供绕过系统检查的脚本。
- 此签名下 Focus Filter 配置可能不可用，可使用手动静默。登录启动应在 Applications 安装版中配置；下载版的系统集成仍待验收。
