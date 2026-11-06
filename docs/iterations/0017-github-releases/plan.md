# Iteration 0017：GitHub 自动构建与 Release 产物

Status: active

当前进度：配置与文档已完成；本地测试及打包 fixture 通过，完整 Xcode 构建、GitHub 执行与下载版系统验收待完成。

来源：用户 2026-11-06 要求配置 GitHub 自动构建，并将产物放到 Releases。关联 FB-001、FB-012；决策见 [ADR-0010](../../decisions/0010-github-releases.md)。

| 范围 | 验收 |
|---|---|
| 自动检查 | main / PR / 版本标签 / 手动触发，执行 make check |
| 构建环境 | arm64 macOS、固定 Xcode 与 XcodeGen，Actions 固定 commit |
| 应用产物 | Release 配置、版本与标签一致、临时签名验证、ZIP 与 SHA-256 |
| 发布 | 仅标签 push 写入 Releases，预发布标签正确标记；构建失败不发布 |
| 使用说明 | 中英 README 说明触发、下载、安装和未公证限制 |
| 验证边界 | 本地静态与测试检查；GitHub 真正执行和下载版系统验收单列 pending |

非目标：修改应用 UI / 计时规则、Intel 支持、Developer ID / 公证、自动更新、推送或创建本次 Release。
