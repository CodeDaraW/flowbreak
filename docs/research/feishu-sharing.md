# 飞书共享检测研究

日期：2026-09-05。范围：公开文档/GitHub 只读检索；未连接飞书、未检查聊天或用户会议。

## 已核验参考

[Nudge commit a0bdd7ba2c770b29060e812c5ad345335397e44f](https://github.com/macadmins/nudge/commit/a0bdd7ba2c770b29060e812c5ad345335397e44f) 的 `Nudge/Utilities/UILogic.swift` 加载 `/System/Library/PrivateFrameworks/DoNotDisturbServer.framework`，使用 `DNDSAuxiliaryStateMonitor` / `isScreenShared` 判断共享。该提交也移除了从系统日志读取 `isScreenShared=1/0` 的旧路径。证据通过 GitHub commit API 读取 diff；仅参考思路，没有复制代码。

这证明业界有参考实现，但它是历史私有 API 方案，不证明 macOS 14+ 飞书当前可用。它利用系统辅助状态，不等于读取用户设置的 Focus 模式；不过兼容性、授权边界和长期维护仍需验证。

[Apple ScreenCaptureKit](https://developer.apple.com/documentation/screencapturekit) 描述本应用进行屏幕采集的能力，没有因此建立观察其他应用共享的保证。

## 未核验与排除

本轮公开搜索未找到可验证的飞书专用 macOS 检测实现。飞书进程存在只能证明客户端运行；会议进行不代表共享。截图、录屏与共享也不能直接等同。Linux/Wayland 飞书共享 issue 不适用于本项目。

## 后续验证方案

如后续重新启动本功能：记录 macOS 与飞书版本，覆盖无共享、入会未共享、窗口共享、整屏共享、停止共享、退出/崩溃、截图、无权限、中英客户端、多显示器。验证输入信号、启停延迟、误报、漏报和资源开销。不要先申请屏幕录制权限再假定能解决检测问题。

当前结果：FB-007 deferred，采用 [ADR-0002](../decisions/0002-defer-sharing-detection.md)。
