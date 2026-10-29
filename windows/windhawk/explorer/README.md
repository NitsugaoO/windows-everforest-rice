# Everforest 主题 for Windows 11 File Explorer Styler (Windhawk)

将 [sainnhe/everforest](https://github.com/sainnhe/everforest) 的 **hard（高对比度）暗色**调色板，映射到 Windhawk 的 **Windows 11 File Explorer Styler** 模块配置。
参照自官方 [windows-11-file-explorer-styling-guide](https://github.com/ramensoftware/windows-11-file-explorer-styling-guide) 的配色 target 与 Matter 主题结构。

文件：`everforest-theme.yaml`

## 安装

1. 打开 **Windhawk** → 安装 **Windows 11 File Explorer Styler** 模块。
2. 打开模块的 **Settings** 选项卡，切到 **Textual mode**。
3. 把 `everforest-theme.yaml` 全部内容粘贴到文本框，点 **Save settings**。
4. 若想恢复默认，用 Windhawk safe-mode `Ctrl+Win+W` 或到模块里禁用。

## 色值映射（Everforest hard / dark → File Explorer 角色）

| Windhawk 角色 | Everforest token | hex |
|---|---|---|
| 标签页文字 `Grid#TabContainer > TextBlock` | `fg` | `#d3c6aa` |
| 选中标签背景 `Path#SelectedBackgroundPath` | `bg2` | `#374145` |
| Tab 条背景 `Grid#TabContainerGrid` | `bg1` | `#2e383c` |
| Tab 内容区 `TabViewItem > Grid#TabContainer` | `bg0` | `#272e33` |
| 导航栏背景 `Grid#NavigationBarControlGrid` | `bg1` | `#2e383c` |
| 命令栏背景 `CommandBar#FileExplorerCommandBar` | `bg1` | `#2e383c` |
| 详情视图背景 `Grid#DetailsViewControlRootGrid` | `bg0` | `#272e33` |
| 详情视图缩略图 `StackPanel#DetailsViewThumbnail` | `bg2` | `#374145` |
| 主页背景 `Grid#HomeViewRootGrid` | `bg0` | `#272e33` |
| 主体内容区背景 `Grid#PART_LayoutRoot` | `bg0` | `#272e33` |
| Gallery 背景 | `bg0` | `#272e33` |

配色逻辑：内容区/主页用主背景 `bg0`，导航栏/命令栏/Tab 条作为"面板层"用 `bg1`，选中标签/缩略图用 `bg2` 做低调高亮，文字用 `fg`。与 Start Menu 保持同一套 Everforest 层级。

## 说明

- 当前为 **hard 暗色**版；浅色/明暗自动切换的方案与坑见 `docs/EVERFOREST-THEMES-NOTES.md` §5（`themes-collection/` 已删除，2026-08 决定暂缓）。
- **主体背景是系统 Mica 材质**：File Explorer 的文件列表/主体区域背景由系统 **Mica** 材质控制，Windhawk 的 styler 主题**无法直接替换 Mica**（官方 guide 明确说明）。所以"上方标题/工具区变色、主体不变"是正常现象。
- **让主体变成 Everforest 背景色的做法**（二选一）：
  1. **Translucent Windows**（Windhawk mod，[windhawk.net/mods/translucent-windows](https://windhawk.net/mods/translucent-windows)）：给 File Explorer 设置背景效果/颜色，选"不透明 + 纯色 `#272e33`"即可覆盖 Mica。
  2. **MicaForEveryone**：把 File Explorer 的 Mica 替换为自定义纯色 `#272e33`。
- 上方 Tab 条/命令栏/导航栏的背景由本主题直接控制（已生效）；主体由 Mica 工具控制，二者叠加即完整 Everforest 效果。
- target 随 Windows build 变化，部分失效属正常，用官方 **UWPSpy** 可精确定位后微调。
