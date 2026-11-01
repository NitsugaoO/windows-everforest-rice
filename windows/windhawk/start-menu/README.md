# Everforest 主题 for Windows 11 Start Menu Styler (Windhawk)

将 [sainnhe/everforest](https://github.com/sainnhe/everforest) 的 **hard（高对比度）暗色**调色板，映射到 Windhawk 的 **Windows 11 Start Menu Styler** 模块配置。参照自 styling-guide 仓库的 [Everblush 主题](https://github.com/ramensoftware/windows-11-start-menu-styling-guide/tree/main/Themes/Everblush)（同为绿色系暗色，结构最接近）。

> **2026-11 精简重做**：现在只做「背景色 + 透明化 + 描边」三件事，文字色 / 圆角 /
> 悬停高光 / 图标色 / 按钮三态全部交回系统默认（旧版 183 行的完整定制见 git 历史）。
> 参数与 YASB 状态栏 / WT 对齐：`AcrylicBrush` + `TintOpacity=0.45` + 亮度层 `0.6`、描边 `#374145`，理由见
> [`../Notification/README.md`](../Notification/README.md)。

文件清单：

- `everforest-theme.yaml` —— **主用**。适配 **redesigned 25H2 开始菜单**（已按 2026-11 精简）
- `everforest-theme-classic.yaml` —— 备用。适配 **classic 开始菜单**（**尚未精简**，仍是完整定制版）
- `_archive/everforest-theme-auto.yaml` —— **已弃用试验**（明暗感知版，`{ThemeResource}` 会随系统明暗自动切换，但因 YAML `{}` flow-map 报错且用户决定暂不用，移入归档；将来写"自动切换脚本"时可参考其 `@Dark/@Light` 资源机制）

> 决定记录（2026-08-28）：Start Menu 维持**只使用暗色硬编码版**；"随系统明暗自动切换"改为**待办**，等再做几个软件的主题后写脚本实现。

## 安装

1. 打开 **Windhawk** → 安装 **Windows 11 Start Menu Styler** 模块。
2. 打开模块的 **Settings** 选项卡，切到 **Textual mode**。
3. 把对应主题文件的全部内容粘贴到文本框，点 **Save settings**。
4. 若想恢复默认，用 Windhawk 的 safe-mode 快捷键 `Ctrl+Win+W` 或到模块里禁用。

## 色值映射（Everforest hard / dark → Windhawk 角色）

| Windhawk 角色 | Everforest token | hex |
|---|---|---|
| 玻璃背景（主面板 / 主页 / 应用列表 / 搜索页 / 文件夹浮层 / 右键菜单） | `bg0`｜背景 | `#272e33` |
| 描边（主面板 + 右键菜单，1px） | `bg2`｜浮层 | `#374145` |
| 搜索框底（唯一的实色填充） | `bg_dim`｜最深 | `#1e2326` |

> 前两行与 yasb 状态栏用的是同一对色（背景 + 浮层）；绿色不再出现在边框上。

## 可选：搜索 WebView 的 CSS

开始菜单的搜索内容区（除顶部搜索框外）是 WebView，需用 CSS 单独上色。在 Styler 模块里按需加：

```css
body {
  background: #272e33 !important;
  color: #d3c6aa !important;
}
```

> `#272e33` = Everforest `bg0`（hard 暗色主背景）。

## 重要安全提示

- 这只是**文件上色配置**，本身不注入系统；真正的注入来自 **Windhawk** 模块本身。
- **before 任何操作先建系统还原点**。
- 只从 **Windhawk 官网 / 官方 GitHub Release** 安装模块与导入配置。
- 一次只启用一个模块测试；玩**反作弊游戏**时给游戏进程加**排除**，避免 Windhawk 注入被游戏判定。
- 目标选择器（`Border#AcrylicBorder` 等）会随 Windows build 变化，**在较高版本更新后可能失效**，属正常现象，按模块更新说明处理。
- `foreground/background` 颜色若要微调，直接改对应 hex 即可。
