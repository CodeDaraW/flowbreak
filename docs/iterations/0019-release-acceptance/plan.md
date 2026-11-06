# Iteration 0019：GitHub 构建与 Release 下载验收

Status: active

来源：用户 2026-11-06 明确授权将配置推送到 GitHub，并测试构建和 Release 下载。关联 FB-001、FB-012。延续 [0017](../0017-github-releases/plan.md) 与 [0018](../0018-dmg-distribution/plan.md)，本轮授权提交、推送和发布测试预发布版本。

| 范围 | 验收 |
|---|---|
| 推送 | 提交现有构建、DMG 配置及文档，推送 main |
| 云端检查 | 跟踪 main 的 make check 与真实应用 DMG 构建，失败则修复并重跑 |
| 发布 | 推送尚未使用的 v0.1.0-rc.N 标签，验证自动创建 prerelease 与 DMG / SHA-256 上传 |
| 下载 | 从实际 Release 下载 DMG 与校验文件，检查镜像、快捷入口、版本、架构、签名与复制后权限 |
| 人工界面 | 如使用 browser/computer use，必须由 GPT-6.1 Terra 子代理执行 |

不覆盖已存在的 Release / 标签，不更改全局安全设置；不将未公证包等同于可直接通过 Gatekeeper。macOS 14 与 Focus Filter 等系统验收按实际证据保留边界。
