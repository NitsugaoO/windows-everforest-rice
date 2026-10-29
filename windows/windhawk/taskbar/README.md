# Everforest 主题 for Windows 11 Taskbar Styler (Windhawk)

将 [sainnhe/everforest](https://github.com/sainnhe/everforest) 的 **hard（高对比度）暗色**调色板，映射到 Windhawk 的 **Windows 11 Taskbar Styler** 模块配置。
参照自官方 [windows-11-taskbar-styling-guide](https://github.com/ramensoftware/windows-11-taskbar-styling-guide) 的 target 与 RosePine 主题结构。

文件：`everforest-theme.yaml`

## 安装

1. 打开 **Windhawk** → 安装 **Windows 11 Taskbar Styler** 模块。
2. 打开模块的 **Settings** 选项卡，切到 **Textual mode**。
3. 把 `everforest-theme.yaml` 全部内容粘贴到文本框，点 **Save settings**。
4. 若想恢复默认，用 Windhawk safe-mode `Ctrl+Win+W` 或到模块里禁用。

> 可搭配同站模块增强，非必需：[Taskbar height and icon size](https://windhawk.net/mods/taskbar-icon-size)、[Taskbar Labels](https://windhawk.net/mods/taskbar-labels)。

## 色值映射（Everforest hard / dark → Taskbar 角色）

| Windhawk 角色 | Everforest token | hex |
|---|---|---|
| 任务栏底板背景 `Rectangle#BackgroundFill` | `bg0` | `#272e33` |
| 任务栏边框 `Rectangle#BackgroundStroke` | `bg2` | `#374145` |
| 缩略图/悬浮 `HoverFlyoutBackgroundControl` | `bg0` | `#272e33` |
| 任务列表按钮背景 `Border#BackgroundElement` | `bg0` | `#272e33` |
| 任务栏按钮文字 `TextBlock#LabelControl` | `fg` | `#d3c6aa` |
| 运行指示条(active/inactive) | `green`/`grey0` | `#a7c080` / `#7a8478` |
| 运行指示条(需关注) | `red` | `#e67e80` |
| 系统托盘悬浮 `SystemTrayFrameGrid` | `bg0` | `#272e33` |
| 托盘溢出 `OverflowFlyoutBackgroundBorder` | `bg0` | `#272e33` |

## 说明

- 当前为 **hard 暗色**版；浅色/明暗自动切换可参照 `docs/EVERFOREST-THEMES-NOTES.md` §5 的 `@Light/@Dark` 机制（未做，`themes-collection/` 已删除）。
- 去掉了 RosePine 的个人偏好项（隐藏开始按钮、改系统图标、自定义字体等），只保留 Everforest 配色核心。
- target 会随 Windows build 变化，部分失效属正常，用官方 **UWPSpy** 可精确定位后微调。
