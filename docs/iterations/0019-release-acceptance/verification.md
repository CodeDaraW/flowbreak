# Verification

2026-11-06，FB-001、FB-012。初始远端 main 为 79191fbe5a7342a0f1261ba7487e22169710074d，无标签、Release 或 Actions run。仓库公开，现有 Git SSH 读取成功；本轮用户明确授权推送与测试发布。

运行与下载证据执行后追加；不以本地最小应用 fixture 替代云端真实应用构建。

## 首次 main 运行与修复

- 提交 4bf97b502ca6313899e6bb7853b52e655990f299 已推送；[首次运行 42216246332](https://github.com/CodeDaraW/flowbreak/actions/runs/42216246332) 在文档 / 测试 / 构建步骤失败，未生成产物、未发布。
- 实际 runner：macOS 15.8.2 arm64，Xcode 16.4 (16F6)，Swift 6.1.2。工具校验、XcodeGen 安装及文档检查成功。
- Swift 6.1.2 将 BreakEngine.restore 的混合数值表达式数组推断为 `[Any]`，导致 isFinite 校验不能编译。为数组显式标注 `[Double]`；不修改快照、计时或恢复行为。
- 本地 `make check`：56 项测试、文档与工程生成通过，最后仍因没有完整 Xcode 以 Exit 2 结束；云端重新验证完整构建。

## main 构建通过

- 修复提交：d2a58c24cbc2；[成功运行 42216455431](https://github.com/CodeDaraW/flowbreak/actions/runs/42216455431)。
- 云端 `make check` Exit 0：文档关联通过、56 tests passed、Debug BUILD SUCCEEDED。
- Release BUILD SUCCEEDED；真实应用的 arm64、最低 macOS 14.0、bundle ID 和构建号检查通过；临时签名验证成功。
- DMG 镜像校验 VALID，挂载后的 Applications 入口、签名、可执行文件与 Info.plist 一致性检查通过，卸载成功。
- `FlowBreak-macos-arm64` artifact 上传成功，包含 DMG、SHA-256 与发布说明；[artifact 13501911599](https://github.com/CodeDaraW/flowbreak/actions/runs/42216455431/artifacts/13501911599)，1220360 bytes（外层 archive）。main 的发布 job 按预期 skipped。
- 已推送测试标签 v0.1.0-rc.1，指向 d2a58c24cbc2；标签构建和真实 Release 下载继续验证。

## 标签构建与自动发布通过

| 检查 | 实际证据 | 结果 |
|---|---|---|
| 标签 run | [42216954315](https://github.com/CodeDaraW/flowbreak/actions/runs/42216954315)，run number 3 | success |
| make check | 56 tests passed；Debug BUILD SUCCEEDED | PASS |
| Release 配置 | BUILD SUCCEEDED；DMG 创建、校验、挂载比对与卸载通过 | PASS |
| 发布 job | 下载本次 artifact；SHA-256 校验 OK；gh release create 成功 | PASS |
| Release 元数据 | [v0.1.0-rc.1](https://github.com/CodeDaraW/flowbreak/releases/tag/v0.1.0-rc.1)，prerelease=true、draft=false；标签指向 d2a58c24cbc203b417e61a22bba65f757f429f87 | PASS |
| 资产 | DMG 1217645 bytes、校验文件 104 bytes；均为 uploaded | PASS |

发布资产：

- [FlowBreak-v0.1.0-rc.1-macos-arm64.dmg](https://github.com/CodeDaraW/flowbreak/releases/download/v0.1.0-rc.1/FlowBreak-v0.1.0-rc.1-macos-arm64.dmg)
- [SHA-256 文件](https://github.com/CodeDaraW/flowbreak/releases/download/v0.1.0-rc.1/FlowBreak-v0.1.0-rc.1-macos-arm64.dmg.sha256)

## 真实下载与本机检查

本机 macOS 27.2 arm64，从上述公开 Release URL 使用 `curl --fail --location` 下载；没有使用 Actions artifact 或本地 fixture 代替。

| 检查 | 实际结果 | 状态 |
|---|---|---|
| 公开 HTTP 下载 | 两个资产均成功，DMG 长度 1217645 bytes | PASS |
| SHA-256 | 校验文件和 GitHub 资产 digest 均匹配：`5d5e804179fc2b5f2c08d8dc918e148309b2f8ff75cf7276b0a11615f725db55` | PASS |
| 镜像 | hdiutil verify 为 VALID；只读挂载、Applications → /Applications、MIT 和中英 README 正确 | PASS |
| 应用签名及复制 | 挂载内和 ditto 复制出的应用均通过 codesign --verify --deep --strict；复制后仍可执行 | PASS |
| 元数据 | arm64；bundle ID org.flowbreak.app；版本 0.1.0；构建号 3；最低系统 14.0 | PASS |
| Gatekeeper | `spctl --assess --type execute --verbose=2` Exit 3，rejected | 未公证应用被拒绝，符合现有分发边界；不能声称可直接打开 |

下载及复制产物保存在忽略目录 `.build/verification/release-v0.1.0-rc.1/`，未安装到 Applications、未启动应用，命令行测试挂载已卸载。

## 浏览器与 Finder 实测

按用户要求，由 **GPT-6.1 Terra 子代理**执行全部 browser/computer use，主代理未执行此类工具操作。

- Release 网页正常显示预发布、标签提交和两个资产。
- 在 Chrome 实际点击两个资产后，均跳转到 release-assets.githubusercontent.com 并显示 `ERR_BLOCKED_BY_CLIENT`。浏览器下载未完成，没有浏览器下载路径；不能把 HTTP 下载成功等同于 Chrome 下载通过。未查明客户端拦截原因，未禁用任何扩展或安全设置。CUA 清单没有其他浏览器可供验证。
- 子代理通过 Finder 打开主代理独立 HTTP 下载的 DMG，窗口显示 FlowBreak、Applications、LICENSE.txt、README.md；此证据证明真实镜像可由 Finder 打开，不证明浏览器下载成功。
- 测试镜像已从 Finder 推出。未启动应用、未覆盖 Applications、未更改用户设置或系统安全设置。

## 结论与保留项

本轮构建、测试预发布、公开 HTTP 下载与 DMG 内容验证完成。Chrome 下载存在明确客户端拦截，首次应用启动未验收；Gatekeeper 拒绝已实测记录。macOS 14、Focus Filter、登录启动和其他原生行为仍不在本轮通过范围。

FB-012 的构建与分发配置已有真实验证，标 implemented；FB-001 的平台 / 原生验收继续保持 partial。不能宣称整个下载到启动流程完全通过。
