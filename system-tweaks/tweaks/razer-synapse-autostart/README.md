# Razer Synapse 4 —— 关闭开机自启

彻底禁用雷蛇 Synapse 4 开机自启（`RazerAppEngine`），同时**保留灯效联动与板载宏**。

> 实施日期：2026-10-13
> 环境：Windows + Razer Synapse 4（RazerAppEngine `4.0.827`，app 版本 `4.0.0.2610010314`）

## 现状

| 阶段 | `HKCU\...\CurrentVersion\Run` | `HKCU\...\Explorer\StartupApproved\Run` | 效果 |
|---|---|---|---|
| 改造前 | `RazerAppEngine` 存在（带 `--autoStart=1`） | 无该条目 | 开机自启，托盘隐藏运行（实测 **10 个** `RazerAppEngine.exe` 进程） |
| 改造后 | ✅ 已删除 | ✅ `RazerAppEngine` = `03 00 00 00 …`（禁用） | 开机不启动 |

原 Run 值：

```
"C:\Program Files\Razer\RazerAppEngine\RazerAppEngine.exe"
  --url-params=apps=synapse,chroma-app
  --launch-force-hidden=synapse,chroma-app
  --autoStart=1
```

## 实现路径：两处改动，缺一不可

### 1️⃣ 删除 Run 自启项（立即生效）

```powershell
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'RazerAppEngine'
```

### 2️⃣ 在「启动审批」写入禁用位（兜底锁）

```powershell
$k = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run'
$dis = [byte[]](0x03,0,0,0,0,0,0,0,0,0,0,0)   # 03 = 禁用；02 = 启用
New-ItemProperty -Path $k -Name 'RazerAppEngine' -PropertyType Binary -Value $dis -Force
```

**为什么必须有第 2 步**：Synapse 4 会在内部维持一个 `"isAutoStart": true` 状态
（见 `%LOCALAPPDATA%\Razer\RazerAppEngine\User Data\Logs\settings.log` 里的 `SoftwareInstallation ~ apps: [...]`，
该字段在 `synapse` 与 `chroma-app` 两个条目上均为 `true`，且被 web 组件的 IndexedDB / 服务端配置持有）。
只删 Run 项的话，手动打开一次 Synapse 就可能被重新写回。

`StartupApproved\Run` 是**任务管理器「启动应用 → 禁用」背后的真实机制**：
Windows 遍历 Run 值时先查这里，为 `03` 则跳过。Windows / Synapse 一般不会去动这个键，
所以是可靠的兜底——**即使 Run 值被写回来，也不会开机启动**。

> 本机格式验证：`LenovoBaiying`、`Badlion Client` 的 Run 值仍在，但 `StartupApproved` 为 `03`，
> 即「已禁用」。`OneDrive` 是带时间戳的变体：`03 00 00 00 <8 字节 FILETIME>`（共 12 字节）。

## 影响范围

- ✅ **按键映射 / 宏依然生效** —— 存在设备板载内存中
- ✅ **灯效联动不受影响** —— 5 个 Razer 服务（Chroma SDK ×3、Game Manager 3、Experience）**未做任何改动**，
  仍为自动启动。Wallpaper Engine 的 Chroma 联动依赖它，因此刻意没动
- ⚠️ 要改灯效 / 调宏时，需**手动启动** Synapse（开始菜单搜「Razer」）
- ⚠️ 若 Synapse 弹窗询问「是否开机自启」，选**否**
- ℹ️ 本改动只影响当前用户（HKCU），换用户或重装 Razer 需重做

## 验证方法

⚠️ **改完立刻看不到变化** —— 当时 `RazerAppEngine` 的 10 个进程仍在运行，必须**重启**后才体现。

重启后任选其一确认：

```powershell
# A. 查进程（应为空）
Get-Process RazerAppEngine -ErrorAction SilentlyContinue

# B. 查两处注册表
(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run').RazerAppEngine          # 应为空
(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run').RazerAppEngine[0]  # 应为 3
```

或直接看「任务管理器 → 启动应用」：`RazerAppEngine` 应消失（若被 Synapse 写回，则显示为「已禁用」）。

## 还原方法

双击本目录的 [`restore-razer-autostart.reg`](restore-razer-autostart.reg)（会恢复 Run 值并把审批位改回 `02` 启用）。

或手动：

```powershell
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'RazerAppEngine' `
  -Value '"C:\Program Files\Razer\RazerAppEngine\RazerAppEngine.exe" --url-params=apps=synapse,chroma-app --launch-force-hidden=synapse,chroma-app --autoStart=1'
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run' -Name 'RazerAppEngine'
```

## 踩坑记录

| 坑 | 原因 | 对策 |
|---|---|---|
| **Synapse 会自己把自启项加回来** | 内部 `isAutoStart: true` 存在 IndexedDB / 服务端，删 Run 项治标不治本 | 不硬刚内部状态（改不动、会被覆盖）；改在 `StartupApproved\Run` 写禁用位兜底 |
| **Synapse 4 的 UI 里找不到「随 Windows 启动」开关** | 改版后开关被移走 / 隐藏（实测托盘右键与设置页均无） | 放弃走 UI，直接改注册表 |
| **Git Bash 下 `reg.exe` 报「无效语法…REG EXPORT /?」** | MSYS 把 `/y`、`/v`、`/f` 当成路径参数转换 | 改用 PowerShell 原生 cmdlet（`Remove-ItemProperty` / `New-ItemProperty`），绕开 `/` 参数 |
| **不确定「禁用」的二进制值该写什么** | 该格式无官方文档 | 从本机已有条目**反推**：`LenovoBaiying`（已禁用）为 `03 00 00 00 …`，启用为 `02 00 00 00 …` |
| **查雷蛇是否另有自启来源** | 同类问题的常见遗漏（见上级 README 踩坑速查） | 已确认：**无登录触发计划任务**、启动文件夹为空；仅 1 处 Run 项 + 6 个服务（其中 Elevation 为手动） |

## 路径依赖

- `RazerAppEngine.exe` 位于 `C:\Program Files\Razer\RazerAppEngine\`（**Razer 安装目录，非本仓库**）——
  本目录可自由移动、重命名，不影响已生效的配置
- 反之：**重装 Razer Synapse 会重建 Run 自启项**，届时需按本文重做一次
