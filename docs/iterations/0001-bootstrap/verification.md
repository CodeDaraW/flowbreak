# Verification

日期：2026-09-05。环境：macOS 26.6.2，Apple Silicon，Xcode 26.6 / Swift 6.3.3，XcodeGen 2.45.4。

| 检查 | 结果 | 证据 / 范围 |
|---|---|---|
| `make check` | PASS | 文档检查、核心测试及应用构建整体退出 0；使用正常本机执行权限 |
| `python3 scripts/check_docs.py` | PASS | 12 个需求、1 个迭代、23 个双语键关联有效 |
| `make test` | PASS | Swift Testing 7/7；不是 XCTest 摘要中的 0 tests |
| `make build` | PASS | Xcode `BUILD SUCCEEDED`；arm64，deployment target 14.0 |
| 本地签名与启动请求 | PASS | codesign ad-hoc 签名及 open 命令退出 0；不等于界面交互验收 |
| 菜单栏、设置打开、语言切换、重启后设置保存 | BLOCKED_TOOL | Computer Use getApp 长时间未返回后报 timeoutReached；无可用 UI 证据，未标 PASS |
| Git | PASS | `git init -b main` 成功；`git remote -v` 为空；无提交、无远端 |
| 忽略项 | PASS | .tools、.build、.build-cache、生成的 xcodeproj 均被 git check-ignore 命中 |

## 自动测试覆盖

FB-002：护眼后只清除护眼，起身累计包括护眼时段。
FB-003：起身完整完成清除两者；40/60 分钟临界状态。
FB-005：中断护眼保留原累计；真实输入检测未实现。
FB-008：Agent 暂停后人工接管恢复累计，保持唤醒请求继续；实际 IOKit 断言未实现。
其他：非法时间增量被忽略，冲突设置阈值不合法。

## 环境问题与修复记录

- 初次受限环境 SwiftPM 因 `sandbox_apply: Operation not permitted` 失败；获准使用正常本机执行权限后通过，未关闭 SwiftPM 沙箱。
- 最初只复制 XcodeGen 二进制，缺少 share 预设导致空模块名；补齐官方分发包的 bin/share 目录后重新生成并构建通过。
- Git 元数据写入受受限环境阻止；使用获准权限完成初始化。
- GUI 工具超时属于工具故障，不能归为应用缺陷，也不能据此确认 UI 正常。

## 剩余验收

工程代码、规格、文档与命令初始化已交付；本轮完整 GUI 验收尚未关闭。
Owner：后续维护者 / 用户本机验收。工具恢复后执行：

1. `make run`，点击菜单栏叶子图标；确认工程预览说明，打开设置。
2. 选择 English / 简体中文，确认所有文案切换且完整可见。
3. 修改起身时长为 240 秒，退出后重新打开，确认保存；恢复默认值。
4. 输入冲突阈值，确认出现未保存提示且不覆盖最后有效设置。

macOS 14 真机、真实提醒、系统空闲、保持唤醒、飞书共享、多显示器与休眠恢复尚未验证，其中多数尚未实现。
