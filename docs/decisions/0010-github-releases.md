# ADR-0010：GitHub 自动构建与开发版分发

- Status: Accepted
- Date: 2026-11-06
- Requirements: FB-001, FB-012
- Iteration: [0017](../iterations/0017-github-releases/plan.md)
- Supersedes: ADR-0001 中“无远端、无发布流水线”的初始约定；其他决定保留

## 背景

用户要求 GitHub 自动构建，并将应用产物放到 Releases。仓库已有 GitHub 远端、`make check` 和无证书构建入口；没有 Developer ID、公证或分发凭证。应用仍仅面向 macOS 14+ arm64。

## 决定

| 环节 | 约定 |
|---|---|
| 检查 | main 推送、PR、版本标签推送及手动运行都执行 `make check` |
| 工具 | `macos-15` 的 arm64 标准 runner，显式选择 Xcode 16.4；XcodeGen 2.45.4 下载并验证固定 SHA-256；Actions 固定 commit |
| 打包 | 独立 Release 配置构建、显式 ad-hoc 签名、验证签名及 arm64 架构；`ditto` ZIP 保留应用包元数据；生成 SHA-256 文件 |
| 版本 | 标签为 `vX.Y.Z` 或 `vX.Y.Z-alpha.N/beta.N/rc.N`；应用版本取 X.Y.Z，构建号取 Actions run number；非标签构建以 dev + commit 命名 |
| 分发 | 所有构建保存 Actions artifact 14 天；仅版本标签的 push 创建 GitHub Release，预发布标签标记为 prerelease |
| 权限 | 构建 job 只读；独立发布 job 获得 contents:write 和 actions:read，通过内置 GITHUB_TOKEN 下载本次 artifact 并发布；不需要 PAT 或证书 secrets |
| 重跑 | 不覆盖已有 Release。发布成功后重新构建同一标签会在创建 Release 时失败，避免悄悄替换已经下载的产物 |

发布说明包含中英文安装、安全检查和 Focus Filter 限制。下载版未经过 Developer ID 签名和 Apple 公证，不能承诺直接双击打开或 Focus Filter 配置成功；不提供绕过安全检查的脚本。不调用会自动选取本机开发证书的 `sign.sh`。

## 替代方案与后果

- 每次 main 提交都发布：会产生大量无版本边界的 Release，采用显式标签发布。
- 上传签名证书及公证凭证：需要用户提供与管理 Apple 分发身份，后续单独决策。
- Intel runner 交叉构建：无法原生运行 arm64 macOS 测试，选择 arm64 runner。runner 标签的系统镜像会更新；固定 Xcode 路径不存在时明确失败。
- 本次只准备本地配置，不推送代码、不创建标签、不实际发布。GitHub 首次运行、下载后 Gatekeeper 行为、macOS 14 及 Focus 系统集成仍需各自环境验收。

## 依据

- [GitHub 标准 runner](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)：macos-15 的 arm64 标签与资源。
- [macOS 15 arm64 镜像工具清单](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-arm64-Readme.md)：Xcode 16.4 路径。
- [GitHub CLI release create](https://cli.github.com/manual/gh_release_create)：`--verify-tag`、预发布及资产上传。
