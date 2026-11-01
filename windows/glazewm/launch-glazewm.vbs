' 由计划任务 "GlazeWM" 调用的启动包装脚本
'
' 为什么需要这个包装:
'   glazewm.exe 的 manifest 带有 uiAccess="true"。计划任务以
'   LeastPrivilege 令牌直接 CreateProcess 该 exe 时会失败并返回
'   ERROR_ELEVATION_REQUIRED (740)。经由普通程序(本脚本)间接启动即可绕过。
'
' 用 wscript 执行(它是 GUI 子系统程序,不创建控制台窗口),
' Run 的第二个参数 0 = 隐藏窗口,第三个参数 False = 不等待。

Set sh = CreateObject("WScript.Shell")
sh.Run """C:\Users\<YourName>\scoop\apps\glazewm\current\glazewm.exe""", 0, False
