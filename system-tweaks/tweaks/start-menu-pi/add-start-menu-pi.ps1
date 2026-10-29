#requires -Version 5.1
<#
.SYNOPSIS
    在当前用户的开始菜单「所有应用」列表中加入 Pi 快捷方式。

.DESCRIPTION
    创建 %APPDATA%\Microsoft\Windows\Start Menu\Programs\<ShortcutName>.lnk，
    启动方式与右键菜单「Run Pi Here」完全一致：
        wt.exe -d "%USERPROFILE%" pwsh -NoExit -Command "pi"
    图标复用仓库里的 context-menu\run-pi-here.ico。

    只写 HKCU 范围之外的用户级目录（开始菜单 Programs 文件夹），无需管理员权限。

.PARAMETER ShortcutName
    快捷方式名称，同时也是开始菜单里显示的名字，默认 Pi。

.PARAMETER IconPath
    图标路径，默认取仓库 context-menu\run-pi-here.ico。

.PARAMETER Remove
    删除快捷方式，而不是创建。

.EXAMPLE
    .\add-start-menu-pi.ps1
    创建/覆盖开始菜单里的 Pi。

.EXAMPLE
    .\add-start-menu-pi.ps1 -Remove
    卸载。
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ShortcutName = 'Pi',
    [string]$IconPath,
    [switch]$Remove
)

$ErrorActionPreference = 'Stop'

# 仓库根 = 本脚本所在目录(tweaks\start-menu-pi)的上两级
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not $IconPath) {
    $IconPath = Join-Path $repoRoot 'context-menu\run-pi-here.ico'
}

$startMenuDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
$lnkPath      = Join-Path $startMenuDir "$ShortcutName.lnk"

# ---------- 卸载 ----------
if ($Remove) {
    if (Test-Path -LiteralPath $lnkPath) {
        if ($PSCmdlet.ShouldProcess($lnkPath, '删除开始菜单快捷方式')) {
            Remove-Item -LiteralPath $lnkPath -Force
            Write-Host "[OK] 已删除: $lnkPath" -ForegroundColor Green
        }
    }
    else {
        Write-Host "[--] 不存在，无需删除: $lnkPath" -ForegroundColor Yellow
    }
    return
}

# ---------- 定位 wt.exe ----------
# 优先用 Windows Terminal 的 App Execution Alias：
#   %LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe
# 注意：Get-Command 会把该别名解析成「Program Files\WindowsApps\Microsoft.WindowsTerminal_<版本号>_...\wt.exe」，
# 那个路径里带版本号，Terminal 升级后就会失效 —— 所以只在别名不存在时才回退。
$aliasPath = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\wt.exe'
if (Test-Path -LiteralPath $aliasPath) {
    $target = $aliasPath
}
else {
    $fallback = (Get-Command wt.exe -ErrorAction SilentlyContinue | Select-Object -First 1).Source
    if (-not $fallback) {
        throw "找不到 wt.exe（Windows Terminal）。请先安装 Windows Terminal，或自行修改本脚本的启动命令。"
    }
    $target = $fallback
    Write-Warning "未找到 App Execution Alias，回退到带版本号的包路径（Terminal 升级后可能失效）: $target"
}
$arguments = '-d "{0}" pwsh -NoExit -Command "pi"' -f $env:USERPROFILE
$workDir = $env:USERPROFILE

# ---------- 创建 ----------
if (-not (Test-Path -LiteralPath $startMenuDir)) {
    throw "开始菜单目录不存在: $startMenuDir"
}

if ($PSCmdlet.ShouldProcess($lnkPath, '创建开始菜单快捷方式')) {
    $shell = New-Object -ComObject WScript.Shell
    $lnk = $shell.CreateShortcut($lnkPath)
    $lnk.TargetPath       = $target
    $lnk.Arguments        = $arguments
    $lnk.WorkingDirectory = $workDir
    $lnk.Description      = 'pi coding agent（Windows Terminal）'
    if (Test-Path -LiteralPath $IconPath) {
        $lnk.IconLocation = "$IconPath,0"
    }
    else {
        Write-Warning "图标不存在，跳过设置图标: $IconPath"
    }
    $lnk.Save()

    Write-Host "[OK] 已创建: $lnkPath" -ForegroundColor Green
    Write-Host "     Target    : $target"
    Write-Host "     Arguments : $arguments"
    Write-Host "     Icon      : $IconPath"
}

# ---------- 自检 ----------
if (-not $Remove -and (Test-Path -LiteralPath $lnkPath)) {
    $shell = New-Object -ComObject WScript.Shell
    $check = $shell.CreateShortcut($lnkPath)
    Write-Host ''
    Write-Host '--- 实际写入的快捷方式 ---' -ForegroundColor Cyan
    $check | Format-List TargetPath, Arguments, WorkingDirectory, IconLocation
    Write-Host '提示：开始菜单缓存可能有几秒延迟；若未出现，重启 explorer.exe 或注销重登。' -ForegroundColor DarkGray
}
