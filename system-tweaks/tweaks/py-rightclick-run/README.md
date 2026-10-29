# .py 右键菜单「用 Python 运行」

> 在 `.py` 文件的右键上下文菜单添加「用 Python 运行」选项，点击后以 Python 解释器运行该脚本（窗口保持打开）。

## 来源

- 会话：`2026-08-29T19-09-31-790Z_01a04eed...jsonl`（`~/.pi/agent/sessions/--C--Users-<YourName>--/`）
- 背景：scoop 安装的 Python 未注册任何文件关联，需要完整建立 `.py` 关联链

## 当前状态

✅ **生效中**（2026-08 验证）

| 配置项 | 值 |
|---|---|
| `.py` → ProgID | `Python.File`（HKCU） |
| 右键菜单项 | 「用 Python 运行」（带 Python 图标） |
| 运行命令 | `cmd /k ""C:\Users\<YourName>\scoop\apps\python\current\python.exe" "%1""` |
| 双击 `.py` 行为 | 用 VSCode 打开（`open` 动词指向 Code.exe） |

## 注册表路径

全部位于 `HKCU\Software\Classes`（仅当前用户，无需管理员权限）：

```
HKCU\Software\Classes\.py                       (默认) = Python.File
HKCU\Software\Classes\Python.File               (默认) = Python 文件
HKCU\Software\Classes\Python.File\DefaultIcon  (默认) = C:\Users\<YourName>\scoop\apps\python\current\python.exe,0
HKCU\Software\Classes\Python.File\shell\RunPython
  ├─ (默认) = 用 Python 运行
  ├─ Icon  = C:\Users\<YourName>\scoop\apps\python\current\python.exe,0
  └─ command (默认) = cmd /k ""C:\Users\<YourName>\scoop\apps\python\current\python.exe" "%1""
HKCU\Software\Classes\Python.File\shell\open\command
                    (默认) = "%APPDATA%\Local\Programs\Microsoft VS Code\Code.exe" "%1"
```

> 💡 **可移植写法**：把上面的 `C:\Users\<YourName>` 换成 `%USERPROFILE%`，例如
> `%USERPROFILE%\scoop\apps\python\current\python.exe`。注册表值写 `%USERPROFILE%`
> 时需用 `REG_EXPAND_SZ` 类型才会自动展开。上方保留的是本机**实际写入**的绝对路径。

## 实施要点（经验教训）

1. **scoop Python 默认不注册关联**：`Python.File` ProgID 不存在，需完整创建关联链。
2. **PowerShell `New-Item` 对深层键有怪癖**：`HKCU:\...\shell\RunPython\command` 反复创建失败，
   最终改用 **`.reg` 文件 + `reg import`**（引号规则明确）成功。
3. **中文值需 UTF-8 BOM**：PowerShell 5.1 无 BOM 时按 GBK 解码会乱码，脚本要带 BOM。
4. **解释器路径用 `current` 链接**：`scoop\apps\python\current\python.exe`，升级后仍有效。
5. **测试残留要清理**：排查过程留下的 `shell\TestA` 测试键需删除（当时漏删过一次）。

## 验证方法

```powershell
# 查看当前配置
Get-ItemProperty 'HKCU:\Software\Classes\Python.File\shell\RunPython' | fl
Get-ItemProperty 'HKCU:\Software\Classes\Python.File\shell\RunPython\command' | fl

# 端到端测试命令（/c 自动退出）
cmd /c ""C:\Users\<YourName>\scoop\apps\python\current\python.exe" "C:\path\test.py""
```

## 如需重建

1. 逐级创建 `HKCU\Software\Classes` 下的键（用 `.reg` 文件 + `reg import` 最稳）
2. 中文值确认 UTF-8（BOM）
3. 测试后清理任何临时键