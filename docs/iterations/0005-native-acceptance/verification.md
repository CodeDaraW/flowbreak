# Verification

2026-09-05，macOS 26.6.2 / arm64。原生 CUA 操作实际界面，Debug 独立数据目录与同一 DashboardView，真实时间和系统电源，无 mock。纯菜单栏 getApp 超时，窗口入口后连接正常。

当前10项用例：7项通过（含输入中断修复后通过），3项部分覆盖。通过护眼完成、输入中断、补记撤销、Agent/真实断言、双语配置、起身完成和重启恢复。延迟/共享调度记录通过；非激活浮层截图、按钮与纯菜单栏入口尚需补证。

确认1个根因：combinedSessionState 没有反映近期输入，实测空闲约3534秒，而 HID 为37秒。修复 SystemActivity 同时读取两张公开表、取有效最小值。随后键盘输入触发 breakInterrupted，保留原累计。make check 36/36 与构建通过。

原始用例、结果和16张截图位于已忽略 workspaces/native-acceptance/20260905/。截图13/14只显示调度历史，不冒充实际浮层截图。未覆盖硬件多屏、锁屏/睡眠、macOS 14 真机。测试电源断言已释放，用户原有 caffeinate 不变。
