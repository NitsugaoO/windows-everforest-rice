# Everforest 主题 for Windows 11 Start Menu Styler (Windhawk)

将 [sainnhe/everforest](https://github.com/sainnhe/everforest) 的 **hard（高对比度）暗色**调色板，映射到 Windhawk 的 **Windows 11 Start Menu Styler** 模块配置。参照自 styling-guide 仓库的 [Everblush 主题](https://github.com/ramensoftware/windows-11-start-menu-styling-guide/tree/main/Themes/Everblush)（同为绿色系暗色，结构最接近）。

文件清单（**当前主用 = 暗色硬编码版**）：

- `everforest-theme.yaml` —— **主用**。适配 **redesigned 25H2 开始菜单**（hard 暗色，硬编码 hex）
- `everforest-theme-classic.yaml` —— **主用**。适配 **classic 开始菜单**（hard 暗色，硬编码 hex）
- `everforest-theme-light.yaml` / `everforest-theme-classic-light.yaml` —— **备选浅色版**（hard 浅色，手动切换时粘贴用）
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
| 开始菜单/搜索底板背景 | `bg0` | `#272e33` |
| 搜索框/文件夹浮层/弹层背景 | `bg1` | `#2e383c` |
| 主文字 | `fg` | `#d3c6aa` |
| 次级文字 | `grey2` | `#9da9a0` |
| 强调色（列表标题、状态文字） | `green` | `#a7c080` |
| 次级强调（标题、文件夹图标、文本） | `yellow` | `#dbbc7f` |
| 用户头像名 | `blue` | `#7fbbb3` |
| 图标次级强调 | `grey2` | `#9da9a0` |
| 按钮背景（"全部显示""视图：网格"等） | `bg0` | `#272e33` |
| 半透明强调/描边 | `green`+alpha | `#26a7c080` / `#82a7c080` |

（`#26`/`#d2` 为 alpha 前缀，`#26`≈15% 透明、`#d2`≈82%，与 Everblush 主题一致。）

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
