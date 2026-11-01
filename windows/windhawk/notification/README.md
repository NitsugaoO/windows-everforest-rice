# Everforest 主题 for Windows 11 Notification Center Styler (Windhawk)

把 [sainnhe/everforest](https://github.com/sainnhe/everforest) 的 **hard（高对比度）暗色**
套到 Windows 的通知体系上。一个 mod 同时覆盖四块 UI：

| UI | target |
|---|---|
| 通知中心（Win+N） | `Grid#NotificationCenterGrid` |
| 日历 / 时钟弹出 | `Grid#CalendarCenterGrid` |
| 快速设置（音量 / 亮度 / 网络） | `Grid#ControlCenterRegion` |
| 右下角 toast 卡片 | `Border#ToastBackgroundBorder, Border#ToastBackgroundBorder2` |

文件：`everforest-theme.yaml`（由 `src/notification.yaml` 渲染）

## 设计范围（2026-11 定稿）

**只做三件事：背景色、透明化、描边。** 文字色 / 圆角 / 悬停反馈 / 图标一律交回
系统默认 —— 想改这些请在 `src/notification.yaml` 里加规则，不要在产物里改。

## 参数（与 YASB / WT 共用同一套系统亚克力）

```
<AcrylicBrush TintColor="#272e33" TintOpacity="0.45" TintLuminosityOpacity="0.6" FallbackColor="#272e33"/>
BorderBrush=#374145   BorderThickness=1
```

| 参数 | 值 | 为什么要这个值 |
|---|---|---|
| 画刷 | **`AcrylicBrush`** | 系统亚克力，与 Windows Terminal 的 `useAcrylic` **同一个画刷类**。原来用的 `WindhawkBlur` 只做「模糊 + 线性 tint」，缺亮度层和噪点 → 怎么调都「灰、闷、不够深」（实测结论）|
| `TintColor` | `#272e33`（角色「背景」/ bg0） | 与 yasb 的 `--yasb-bar-bg`、WT 的 scheme background 同一个颜色 |
| `TintOpacity` | `0.45` | 色罩强度。别按「DWM 72% + CSS 72%」手算成 0.92 —— 合成公式对不上观感，只能实测调 |
| `TintLuminosityOpacity` | `0.6` | **亮度层**：按背景亮度提亮/压暗，这才是「基于壁纸」的观感（`WindhawkBlur` 没有这一层）|
| `FallbackColor` | `#272e33` | `AcrylicBrush` 在某些 shell 窗口可能退化 —— 失败时表现为「突然变实」，有兜底就不会变全透 |
| `BorderBrush` | `#374145`（角色「浮层」/ bg2） | yasb 状态栏的 `border-bottom` 就是这个色；绿色只留给 accent / hover |
| `BorderThickness` | `1` | 亚克力浮层需要 1px 描边才「浮」得起来 |

> 摘要：开始菜单 / 任务栏 / toast 用的是 **XAML `AcrylicBrush`**；WT 用系统 `useAcrylic`；
> YASB 只能走 DWM（`translucent-windows` 的 accent blur + CSS 半透明两层叠加）；
> VSCode 需要 patch Electron（Vibrancy），**本机与 everforest 主题冲突，已放弃**。

## 安装

1. Windhawk → 安装 **Windows 11 Notification Center Styler**（本机已装 1.8）。
2. 模块 **Settings** → **Textual mode**。
3. 粘贴 `everforest-theme.yaml` 全文 → **Save settings**。
4. 验证：按 `Win+N` 看通知中心，按 `Win+A` 看快速设置，再触发一条 toast
   （改音量、截图成功提示、或下面的测试命令）。

### 发一条测试 toast

```powershell
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
$t = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
$texts = $t.GetElementsByTagName('text')
$texts.Item(0).AppendChild($t.CreateTextNode('Everforest toast 测试')) | Out-Null
$texts.Item(1).AppendChild($t.CreateTextNode('背景 / 透明 / 描边是否生效')) | Out-Null
$n = [Windows.UI.Notifications.ToastNotification]::new($t)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Microsoft.WindowsStore_8wekyb3d8bbwe!App').Show($n)
```

> `CreateToastNotifier()` 的 AppId 要指向一个真实注册过的应用（上面用的是商店的 AppId），
> 用随便的字符串会静默失败 —— 这是 Windows 的已知限制，不是主题的问题。

## 已知坑

- **toast 的外层容器必须设透明**（`ActionCenter.FlexibleToastView#FlexibleNormalToastView`），
  否则它自己的底色会盖在 `$GlassBrush` 上，看起来像「玻璃没生效」。
- 通知中心里**每条通知卡片**（`ActionCenter.FlexibleItemView`）仍保留系统背景，
  本主题故意不碰 —— 铺玻璃会让一屏通知变成一堆玻璃块，反而脏。
- 若改完样式后面板**点不动**，先重启 explorer，再怀疑样式（同 `generator/RULES.md` 里
  开始菜单那条踩坑）。
- target 随 Windows build 变化会失效，属正常现象；用官方 **UWPSpy** 定位真实类名。

## 恢复默认

Windhawk safe-mode `Ctrl+Win+W`，或在模块里禁用；也可以把 Textual mode 清空后 Save。
