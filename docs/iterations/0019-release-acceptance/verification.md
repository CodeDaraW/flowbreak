# Verification

2026-11-06，FB-001、FB-012。初始远端 main 为 79191fbe5a7342a0f1261ba7487e22169710074d，无标签、Release 或 Actions run。仓库公开，现有 Git SSH 读取成功；本轮用户明确授权推送与测试发布。

运行与下载证据执行后追加；不以本地最小应用 fixture 替代云端真实应用构建。

## 首次 main 运行与修复

- 提交 4bf97b502ca6313899e6bb7853b52e655990f299 已推送；[首次运行 42216246332](https://github.com/CodeDaraW/flowbreak/actions/runs/42216246332) 在文档 / 测试 / 构建步骤失败，未生成产物、未发布。
- 实际 runner：macOS 15.8.2 arm64，Xcode 16.4 (16F6)，Swift 6.1.2。工具校验、XcodeGen 安装及文档检查成功。
- Swift 6.1.2 将 BreakEngine.restore 的混合数值表达式数组推断为 `[Any]`，导致 isFinite 校验不能编译。为数组显式标注 `[Double]`；不修改快照、计时或恢复行为。
- 本地 `make check`：56 项测试、文档与工程生成通过，最后仍因没有完整 Xcode 以 Exit 2 结束；云端重新验证完整构建。
