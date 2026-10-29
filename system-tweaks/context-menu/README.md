# 资源管理器右键「Run Pi Here」

> 在**文件夹**、**驱动器**、**文件夹空白处**的右键菜单加入「Run Pi Here」，
> 点击后在该目录用 Windows Terminal 打开 pwsh 并启动 `pi`。

## 来源

- 归档日期：2026-09
- 实现：HKCU 注册表（`Run-Pi-Here.reg` 导入）+ 配套图标 `run-pi-here.ico`

## 文件说明

| 文件 | 说明 |
|---|---|
| `Run-Pi-Here.reg` | 注册表导入文件，**UTF-16LE 编码**（注册表编辑器默认格式，勿存成 UTF-8） |
| `run-pi-here.ico` | 右键菜单项图标 |

## 注册表位置

全部位于 `HKCU\Software\Classes`（仅当前用户，无需管理员权限），共 **3 处**：

```
HKCU\Software\Classes\Directory\Background\shell\RunPiHere    ← 文件夹空白处
HKCU\Software\Classes\Directory\shell\RunPiHere               ← 文件夹上
HKCU\Software\Classes\Drive\shell\RunPiHere                   ← 驱动器上
```

三处内容一致：

| 值 | 内容 |
|---|---|
| `(默认)` | `Run Pi Here` |
| `Icon` | `<仓库>\system-tweaks\context-menu\run-pi-here.ico` |
| `command\(默认)` | `"<...>\wt.exe" -d "%V" pwsh -NoExit -Command "pi"` |

> `%V` = 被右键的目录/驱动器；`wt.exe` = Windows Terminal；`pwsh` = PowerShell 7。
> 使用 `-NoExit` 让窗口在 pi 退出后保留。

## 当前状态

✅ **生效中**（2026-09 验证：三处注册表项均存在，值与本目录的 `.reg` 一致）

本机实际写入的值：

```
Icon    = %USERPROFILE%\Projects\windows-everforest-rice\system-tweaks\context-menu\run-pi-here.ico
Command = "wt.exe" -d "%V" pwsh -NoExit -Command "pi"
```

> 📌 **2026-09-13 迁移记录**：本目录从 `~/.pi/my-plugins/system-tweaks/` 迁至
> `~/Projects/system-tweaks/`。由于 `Icon` 是**写死的绝对路径**，迁移后三处注册表项
> 图标全部失效，已更新为新路径（`.reg` 文件同步修正）。
> 详见 [`../README.md`](../README.md) 的「踩坑速查」。

## 安装 / 重建

```powershell
# 导入（HKCU，无需管理员）
reg import ".\Run-Pi-Here.reg"

# 验证
Get-ItemProperty 'HKCU:\Software\Classes\Directory\shell\RunPiHere'
Get-ItemProperty 'HKCU:\Software\Classes\Directory\shell\RunPiHere\command'
```

## 卸载

```powershell
Remove-Item -Recurse 'HKCU:\Software\Classes\Directory\Background\shell\RunPiHere'
Remove-Item -Recurse 'HKCU:\Software\Classes\Directory\shell\RunPiHere'
Remove-Item -Recurse 'HKCU:\Software\Classes\Drive\shell\RunPiHere'
```

## 可移植性

本仓库的 `Run-Pi-Here.reg` **已按可移植方式生成**：

| 项 | 写法 | 说明 |
|---|---|---|
| `Icon` | `hex(2):...`（REG_EXPAND_SZ） | 实际存的是 `%USERPROFILE%\Projects\windows-everforest-rice\system-tweaks\context-menu\run-pi-here.ico`，导入后随环境变量展开 |
| `command` | `wt.exe -d "%V" pwsh -NoExit -Command "pi"` | 依赖 `wt.exe` 在 PATH（Windows Terminal 默认如此） |

仓库要 clone 到 `%USERPROFILE%\Projects\windows-everforest-rice`。放在别处的话，
改 `Icon` 的 hex(2) 字符串（那是「UTF-16LE + 结尾 00 00」的十六进制）后重新导入，
或者干脆用 PowerShell 直接写：

```powershell
$ico = "$env:USERPROFILE\Projects\windows-everforest-rice\system-tweaks\context-menu\run-pi-here.ico"
foreach ($k in 'Directory\Background','Directory','Drive') {
    $p = "HKCU:\Software\Classes\$k\shell\RunPiHere"
    New-Item -Path $p -Force | Out-Null
    Set-ItemProperty $p -Name '(default)' -Value 'Run Pi Here'
    Set-ItemProperty $p -Name Icon -Value $ico -Type ExpandString
    New-Item -Path "$p\command" -Force | Out-Null
    Set-ItemProperty "$p\command" -Name '(default)' -Value 'wt.exe -d "%V" pwsh -NoExit -Command "pi"'
}
```
