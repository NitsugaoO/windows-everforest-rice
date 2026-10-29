# Windhawk Desktop Icons Double-Click Toggle — F2 重命名修复 + 开机自动隐藏

修复 Windhawk Mod **Desktop Icons Double-Click Toggle**（`desktop-icons-double-click-toggle2`，作者 akumy，v1.1）与桌面 F2 重命名冲突的问题。

## 问题描述

安装该 Mod（双击桌面空白处隐藏/显示桌面图标）后，在桌面上选中文件按 **F2 重命名**，编辑框会自己消失（重命名被取消）。

## 根因

Mod 通过 `WH_MOUSE` 钩子监测桌面线程鼠标消息，用 `WindowFromPoint` + `ListView_HitTest` 判断点击是否在"桌面空白处"：

1. 桌面重命名时，`SysListView32` 会创建重命名编辑框（`Edit` 子窗口），其宽度通常大于文件名标签的可点击区域（短文件名时尤其明显）；
2. 在编辑框内点击（如双击选中文字、点两下定位光标）时，超出标签命中区域的点击点使 `ListView_HitTest` 返回 `-1` → 被误判为"桌面空白点击"；
3. 两次点击满足双击条件（时间 ≤ `GetDoubleClickTime()`，距离 ≤ `SM_CXDOUBLECLK`）→ 触发 `ToggleDesktopIconsLocked()` → `ShowWindow` + 强制重绘桌面 → 重命名被取消。

> 注：F2 本身是键盘事件，不经过鼠标钩子；冲突发生在重命名过程中**使用鼠标点击编辑框**时。

## 修复内容（v1.1 → v1.2）

在 `local@desktop-icons-double-click-toggle2.wh.cpp` 中：

1. 新增 `IsDesktopLabelEditingLocked()`：检测 `SysListView32` 是否存在 `Edit` 子窗口（即处于标签编辑/重命名模式）；
2. `IsEligibleDesktopClickPointLocked()` 开头：重命名模式期间直接返回 `false`（不响应任何点击）；
3. `IsEligibleDesktopClickPointLocked()` 中：点击落在 `SysListView32` 子窗口上时（`hwnd != g_listView && IsChild(...)`）排除，不算桌面空白；
4. `ToggleDesktopIconsLocked()` 开头加同样的重命名保护（二次保险）。

双击桌面空白处隐藏/显示图标的功能不受影响。

## v1.3 开机自动隐藏

新增设置项 `HideIconsOnStartup`（默认开启）：mod 加载后等待桌面窗口就绪，自动隐藏一次图标。
Windhawk 服务为开机自启，explorer 启动时注入，因此效果等同于「登录后自动隐藏」；explorer 重启后也会重新隐藏。

实现位置：

- `Settings` 增加 `hideIconsOnStartup`，`LoadSettings()` 读取 `HideIconsOnStartup`；
- `Wh_ModInit()` 设置一次性标志 `g_startupHidePending`；
- `WorkerThreadProc()` 在 `RefreshDesktopWindowsLocked()` 成功后执行一次 `SetDesktopIconsVisibleLocked(false)`，避免桌面未就绪时误操作，也避免用户双击显示后又被反复隐藏。

卸载 mod 时若 `RestoreInitialStateOnUnload=true`，会恢复为加载时的状态（显示）；希望卸载后保持隐藏则关闭该设置。

## 编译修复（v1.2 实际未生效的原因）

v1.2 源码中 `ToggleDesktopIconsLocked()` 调用了后面才定义的 `IsDesktopLabelEditingLocked()`，缺少前向声明，导致编译失败，Windhawk 一直沿用 v1.1 的 DLL。
v1.3 已在 `ToggleDesktopIconsLocked()` 前补上声明：

```cpp
static bool IsDesktopLabelEditingLocked();
```

## v1.3 部署记录（2026-10-23）

使用 Windhawk 自带 clang 手动编译并写入引擎注册表：

- DLL：`C:\ProgramData\Windhawk\Engine\Mods\64\local@desktop-icons-double-click-toggle2_1.3_883825.dll`
- 注册表：`HKLM\SOFTWARE\Windhawk\Engine\Mods\local@desktop-icons-double-click-toggle2`（`Version=1.3`，`Settings\HideIconsOnStartup=1`）
- 源码：`C:\ProgramData\Windhawk\ModsSource\` 与 `EditorWorkspace\mod.wh.cpp`（旧版备份为 `*.v1.2.bak`）
- 注册表备份：`C:\ProgramData\Windhawk\Engine\ModsWritable\backup-desktop-icons-*.reg`

验证：explorer 加载了 `..._1.3_883825.dll`，`SysListView32` 初始 `IsWindowVisible=False`（图标已隐藏）。

## 文件清单

| 文件 | 说明 |
|---|---|
| `desktop-icons-double-click-toggle2.wh.cpp` | mod 源码（v1.3，含开机自动隐藏 + F2 修复） |
| `README.md` | 本文档 |

## 已修改的系统文件

- `C:\ProgramData\Windhawk\ModsSource\local@desktop-icons-double-click-toggle2.wh.cpp`（实际加载的源码）
- `C:\ProgramData\Windhawk\EditorWorkspace\mod.wh.cpp`（Windhawk UI 编辑器工作区副本）
- 备份：`local@desktop-icons-double-click-toggle2.wh.cpp.bak` / `mod.wh.cpp.bak`（v1.1 原版）

## 重新应用修复

```bat
copy /y "desktop-icons-double-click-toggle2.wh.cpp" "C:\ProgramData\Windhawk\ModsSource\local@desktop-icons-double-click-toggle2.wh.cpp"
copy /y "desktop-icons-double-click-toggle2.wh.cpp" "C:\ProgramData\Windhawk\EditorWorkspace\mod.wh.cpp"
```

（需要管理员权限，之后在 Windhawk UI 中关闭再启用该 Mod 触发重新编译）

## 回滚

```bat
copy /y "C:\ProgramData\Windhawk\ModsSource\local@desktop-icons-double-click-toggle2.wh.cpp.bak" "C:\ProgramData\Windhawk\ModsSource\local@desktop-icons-double-click-toggle2.wh.cpp"
copy /y "C:\ProgramData\Windhawk\EditorWorkspace\mod.wh.cpp.bak" "C:\ProgramData\Windhawk\EditorWorkspace\mod.wh.cpp"
```

（需要管理员权限，之后重新启用 Mod）

## 验证

- 登录或重启 explorer 后，桌面图标自动隐藏
- 双击桌面空白处 → 图标正常显示；再次双击 → 隐藏
- 选中桌面文件 → F2 → 在编辑框内双击/点击 → 重命名不再被取消
- 重启 explorer 后再次自动隐藏（mod 只执行一次启动隐藏，不会在双击显示后反复隐藏）

归档日期：2026-09-05（v1.3 更新：2026-10-23）
