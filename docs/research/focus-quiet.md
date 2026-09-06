# 勿扰联动接口研究

2026-09-07。此文是证据与方案边界，不是实现完成证明。

- Apple [INFocusStatusCenter](https://developer.apple.com/documentation/intents/infocusstatuscenter)：Focus 状态及访问授权；本机 SDK 标注 macOS 12+。
- 本机 SDK 的 INFocusStatus 只暴露可空 isFocused，不暴露 Focus 标识或名称；因此单靠该 API 不能断言是勿扰而非工作/睡眠等其他模式。未知不能解释为确定关闭。
- Apple [Focus](https://developer.apple.com/documentation/appintents/focus) / [SetFocusFilterIntent](https://developer.apple.com/documentation/appintents/setfocusfilterintent)：本机 SDK 标注 macOS 13+，允许应用适配用户选择的 Focus。
- Apple [示例说明](https://developer.apple.com/documentation/appintents/defining-your-app-s-focus-filter)：用户在 Settings → Focus → Do Not Disturb → Add Filter 添加应用；开启时系统调用 perform 并提供配置参数，关闭时提供默认参数。样例用扩展及 App Groups 处理后台执行；本项目本地临时签名与宿主内实现的可用性需要实际验证，不能直接承诺零配置。
- 已查阅 sindresorhus/do-not-disturb 项目说明：其请求 Apple 提供正式控制 API，并声明不适用 sandbox。没有复制或执行该项目代码；不能据此认定在本项目支持的所有 macOS 版本可靠。

待用户确认一次配置是否符合预期，再决定具体后端；私有 API 仍需新明确决策。
