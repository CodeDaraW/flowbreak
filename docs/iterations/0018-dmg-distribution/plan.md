# Iteration 0018：DMG 拖拽安装包

Status: active

当前进度：DMG 脚本、发布配置和说明已更新；静态检查与真实 DMG fixture 通过。完整 Xcode 构建、GitHub 执行和实际下载版系统验收待完成。

来源：用户 2026-11-06 明确要求“换成 dmg 方案”。关联 FB-001、FB-012；取代迭代 0017 的 ZIP 产物格式，其他 CI 约定保留。见 [ADR-0011](../../decisions/0011-dmg-distribution.md)。

| 范围 | 验收 |
|---|---|
| 打包 | 只读压缩 DMG，含 FlowBreak.app、Applications 入口、中英说明和 MIT 许可 |
| 校验 | 镜像验证、挂载后签名/可执行权限/包内容一致性、卸载和 SHA-256 |
| 发布 | Actions 产物和 Release 上传使用 DMG 与对应校验文件 |
| 文档 | 产品规格、需求索引、中英 README、发布说明更新 |
| 验证边界 | 执行 make check；最小应用的真实 DMG 测试；完整 Xcode、GitHub 与下载版系统验收单列待完成 |

非目标：签名公证、安装器脚本、自定义 Finder 布局、推送或发布。
