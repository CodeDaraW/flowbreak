# Verification

2026-11-06，FB-001、FB-012。环境：macOS 27.2 (26B123)、arm64、Command Line Tools Swift 6.4.2；未安装完整 Xcode。

| 检查 / 命令 | 实际结果 | 状态 |
|---|---|---|
| `python3 scripts/check_docs.py` | 12 requirements、18 iterations、199 bilingual keys | PASS |
| `.tools/bin/actionlint .github/workflows/build.yml` | actionlint 1.7.12，0 errors；未包含外部 shellcheck / pyflakes 检查 | PASS（静态） |
| `bash -n scripts/package-dmg.sh scripts/release.sh` | Exit 0 | PASS |
| `python3 .build/verification/test_dmg_release.py` | 正式标签、rc 标签、dev 均完成真实 DMG 创建、镜像校验、挂载与卸载；Applications 符号链接正确，许可及中英说明一致；从挂载卷复制出的应用签名、可执行权限、版本与构建号正确；写入只读卷失败；SHA-256 能发现镜像篡改 | PASS（最小应用 fixture） |
| 参数 / 版本失败路径 | 7 个非法标签、非法构建号被拒绝；注入错误应用版本阻止生成产物 | PASS（fixture） |
| 挂载后失败清理 | 注入内容比较失败，脚本卸载镜像、删除临时目录，不生成最终 DMG | PASS（fixture） |
| `make check` | 文档检查、6 项 macOS 适配测试、50 项核心测试和工程生成通过；xcodebuild 报 requires Xcode，整体 Exit 2 | 未通过：缺少完整 Xcode |
| `git diff --check` | Exit 0 | PASS |

## 证据边界

- 忽略目录中的 `.build/verification/test_dmg_release.py` 在临时仓库生成最小 arm64 Mach-O 应用，替代 `make` 与 `xcodebuild`；实际执行仓库 release.sh 和 package-dmg.sh，并实际运行 hdiutil、codesign、ditto 与 shasum。
- 测试把应用复制到临时安装目录，不写入用户的 Applications，也不启动 fixture。以上结果证明 DMG 打包和复制过程，不代表 FlowBreak 本体已构建或可正常启动；没有声称通过 Finder 视觉与拖拽人工验收。
- 日志保存于忽略目录 `.build/verification/dmg-fixture.log` 和 `make-check-dmg.log`，不提交。macOS 27 的 hdiutil 发出弃用提示，命令仍正常工作；CI 目标仍为 macOS 15。
- 本次未推送代码、创建标签或发布 Release。

## 待完成

| 环境 | 待验收 |
|---|---|
| 完整 Xcode | make check、FlowBreak 本体 Release 构建与 DMG |
| GitHub | main / PR / 手动构建、artifact 下载、标签触发的 Release / prerelease 上传 |
| macOS 14 与实际下载环境 | Finder 打开、拖拽安装、推出后启动；Gatekeeper、Focus Filter、登录启动 |

迭代保持 active，FB-012 保持 partial；不以 fixture 代替平台或云端验收。

## 后续真实云端与下载验收（2026-11-06）

[迭代 0019](../0019-release-acceptance/verification.md) 已完成真实 macOS 15 / Xcode 16.4 的 make check、FlowBreak Release 构建、DMG 生成、GitHub prerelease 上传、公开 HTTP 下载和本机 Finder 镜像打开。此前的“云端待验证”是本轮最初记录，后续证据以 0019 为准；Chrome 下载拦截、Gatekeeper 拒绝及应用启动 / macOS 14 等边界仍须保留。
