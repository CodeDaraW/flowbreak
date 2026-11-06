# Verification

2026-11-06，FB-001、FB-012。

环境：macOS 27.2 (26B123)、arm64，Command Line Tools Swift 6.4.2；`/Applications` 没有完整 Xcode，`xcode-select -p` 指向 CommandLineTools。没有更改系统工具链选择。

| 检查 / 命令 | 实际结果 | 状态 |
|---|---|---|
| `./scripts/install-xcodegen.sh` | 下载 2.45.4；固定 SHA-256 校验成功，输出 Version: 2.45.4 | PASS |
| `make generate` | 从 project.yml 生成 FlowBreak.xcodeproj | PASS |
| `python3 scripts/check_docs.py` | 12 requirements、17 iterations、199 bilingual keys | PASS |
| `.tools/bin/actionlint .github/workflows/build.yml` | actionlint 1.7.12，0 errors；无 shellcheck / pyflakes，因此不包含这两项外部检查 | PASS（静态检查） |
| `bash -n scripts/install-xcodegen.sh scripts/release.sh` | Exit 0 | PASS |
| `make check` | 文档通过，6 项 macOS 适配 + 50 项核心测试通过，工程生成通过；xcodebuild 报 requires Xcode，整体 Exit 2 | 未通过：缺少完整 Xcode |
| `python3 .build/verification/test_release.py` | 正式标签、rc 标签、dev 均完成真实签名与 ZIP；解压后签名、可执行权限、版本号、构建号、MIT 与说明文件均正确；校验能发现篡改 | PASS（最小应用 fixture） |
| 打包失败路径 | 7 个非法标签和非法构建号 Exit 2；注入错误应用版本阻止产物生成 | PASS（fixture） |
| `git diff --check` | Exit 0 | PASS |

## 打包证据的边界

临时 harness 位于忽略目录 `.build/verification/test_release.py`；日志为同目录 `packaging-fixture.log` 与 `make-check.log`，不提交。harness 在临时独立仓库用 clang 生成真实 arm64 Mach-O 应用 fixture，替代 `make` 与 `xcodebuild`，实际执行仓库 release.sh 的 plist/架构检查、codesign、ditto 和 shasum，并解压复验。它证明打包步骤及拒绝错误版本的行为，不证明 FlowBreak 本体已成功 Release 构建。检查中发现 macOS Bash 3.2 对分支内裸比较的失败退出不可靠，最终改为显式错误与 exit，并重跑全部 fixture 通过。

## 待验收

- 完整 Xcode 下的 `make check` 与 FlowBreak 本体 Release 构建、包内元数据校验。
- GitHub 首次 main / PR / 手动构建，artifact 下载，以及真实标签触发的 Release / prerelease 上传。未推送代码、创建标签或发布。
- 下载版的 Gatekeeper、Focus Filter、登录启动与 macOS 14 真机兼容性；原有 UI / 多屏 / Space 验收边界不变。

本轮保留 active，FB-012 保留 partial。不能将静态配置和 fixture 检查写为云端发布成功。

## 后续格式调整（2026-11-06）

用户随后选择 DMG，见 [迭代 0018](../0018-dmg-distribution/verification.md) 与 [ADR-0011](../../decisions/0011-dmg-distribution.md)。以上 ZIP 记录保留为此前验证证据；当前发布脚本已转为 DMG，不能使用旧 ZIP 记录代替 DMG 验收。完整 Xcode、云端执行和下载版系统验收的待完成项转由迭代 0018 跟进。
