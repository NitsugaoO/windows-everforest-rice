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
| 底板 / 缩略图 flyout / 托盘溢出（玻璃） | `bg0`｜背景 | `#272e33` |
| 底板描边 / 托盘上边细线 | `bg2`｜浮层 | `#374145` |
| 运行指示条 active / inactive / 需要关注 | `green` / `grey1` / `red` | `#a7c080` / `#859289` / `#e67e80` |

> 2026-11 精简重做：只保留「背景 + 透明 + 描边」，**唯一的功能色是运行指示条**
> （删掉会回落到系统 accent 蓝）。圆角 / 任务名文字色 / 按钮背景 / 悬停特效
> 均已交回系统默认（旧版见 git 历史）。`AcrylicBrush` + `TintOpacity=0.45` + 亮度层 `0.6`、描边 `#374145`
> 与 YASB 状态栏对齐，理由见 [`../Notification/README.md`](../Notification/README.md)。

## 说明

- 当前为 **hard 暗色**版；浅色/明暗自动切换可参照 `docs/EVERFOREST-THEMES-NOTES.md` §5 的 `@Light/@Dark` 机制（未做，`themes-collection/` 已删除）。
- 去掉了 RosePine 的个人偏好项（隐藏开始按钮、改系统图标、自定义字体等），只保留 Everforest 配色核心。
- target 会随 Windows build 变化，部分失效属正常，用官方 **UWPSpy** 可精确定位后微调。
