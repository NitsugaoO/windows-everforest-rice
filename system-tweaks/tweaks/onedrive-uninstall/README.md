# 卸载 OneDrive

> 彻底移除未使用的 OneDrive（Windows 11 内置组件），消除其开机自启与后台更新任务。

## 来源

- 处理日期：2026-09-13
- 起因：检查开机启动项时发现 OneDrive 项，用户确认「现在没有用」

## 卸载前检查（确认可安全移除）

| 检查项 | 结果 | 结论 |
|---|---|---|
| OneDrive 进程 | **未运行** | 本就没在跑 |
| `C:\Users\<YourName>\OneDrive` 文件夹 | **不存在** | 从未完成过设置 / 已解除链接 |
| 账户配置 `HKCU\...\OneDrive\Accounts\*` | `Personal`/`Business1` 子键存在，但 `UserEmail`、`DisplayName` **全为空** | 无有效登录账户 |
| `LastRunKeyDisabledTime` | `1780287590` ≈ **2026-06-01** | 其 Run 项曾被禁用过又恢复 |

综合判断：**完全空转状态，卸载零损失**。

## ⚠️ 关键：只删 Run 项是不够的

OneDrive 有**多个**自启入口，必须一并处理：

| 入口 | 说明 |
|---|---|
| `HKCU\...\Run` 的 `OneDrive` 值 | 常规自启项 |
| 计划任务 `OneDrive Startup Task-S-1-5-21-...` | **登录触发**，会把它拉起来 |
| 计划任务 `OneDrive Reporting Task-S-1-5-21-...` | 遥测上报 |
| 计划任务 `OneDrive Per-Machine Standalone Update Task` | 定时更新 |

> 只删 Run 项的话，`OneDrive Startup Task`（LogonTrigger）照样会在每次登录时启动它。

## 执行

微软官方推荐命令（64 位系统）：

```powershell
# 注意：本机 SysWOW64 下并没有 OneDriveSetup.exe，实际用的是 System32 这份
& "$env:SystemRoot\System32\OneDriveSetup.exe" /uninstall
```

> 📌 微软文档写的是 `%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall`，
> 但本机 `SysWOW64` 下**不存在**该文件，只有 `System32\OneDriveSetup.exe`（约 89 MB）。
> 遇到这种情况直接换 System32 路径即可。

**返回 `ExitCode: 0`**，且卸载器**自动清理了**上述全部入口：

- ✅ `HKCU\...\Run` 的 `OneDrive` 值已移除
- ✅ 3 个计划任务全部删除
- ✅ 启动文件夹本就没有相关项

## 残留与延迟清理（正常现象）

卸载后 `C:\Program Files\Microsoft OneDrive` 仍在，其中两项被排入系统延迟删除队列：

```
HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations
  \??\C:\Program Files\Microsoft OneDrive\26.153.0809.0004\FileCoAuthLib64.dll
  \??\C:\Program Files\Microsoft OneDrive\26.153.0809.0004\FileSyncShell64.dll
```

原因：`FileSyncShell64.dll` 是**资源管理器的云同步 Shell 扩展**，此刻被 `explorer.exe`
加载中，无法立即删除，系统安排在**重启后**清理。

**结论：卸载后需重启一次才算彻底干净。**

## ⚠️ 不要误删系统组件

卸载后在服务里可能看到 **`cldflt`（Cloud Files Mini Filter Driver）**——
这是 **Windows 自带的**云文件筛选器驱动，**不属于 OneDrive**，供所有云盘类应用使用，
**请勿删除**。

## 验证方法

```powershell
# 进程应为 0
(Get-Process OneDrive -EA SilentlyContinue | Measure-Object).Count

# Run 项应不含 OneDrive
(Get-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run").Property -contains "OneDrive"

# 计划任务应为 0 个
@(Get-ScheduledTask | Where-Object { $_.TaskName -like "*OneDrive*" }).Count

# 重启后安装目录应消失
Test-Path "C:\Program Files\Microsoft OneDrive"
```

## 如需恢复

OneDrive 可从微软官网重新下载安装（<https://www.microsoft.com/microsoft-365/onedrive/download>），
安装后重新登录账户即可，**无数据损失风险**（本机从未有过同步数据）。
