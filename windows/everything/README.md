# Everforest 主题 for Everything 1.5（实验版）

将 [sainnhe/everforest](https://github.com/sainnhe/everforest) 的 **hard（高对比度）暗色**调色板，应用到 Everything 1.5 实验版的**暗色主题**。

Everything 1.5 的主题机制：**把一段 `/key=value;...` 命令粘贴到 Everything 搜索框按回车**即可应用（无需改 ini）。参照自 [Catppuccin Everything 主题](https://github.com/Courage-1984/everything1.5a) 的用法。

## 文件

- `everforest-theme-command.txt` —— **完整版**命令（覆盖全部 dark 颜色键）
- `everforest-theme-command-core.txt` —— **核心版**命令（主要界面区域）

## 应用方法

1. 打开 Everything 1.5。
2. 打开 `everforest-theme-command.txt`（或 core 版），**复制整段命令**。
3. 粘贴到 Everything 的**搜索框**，按 **回车**。
4. 主题即时生效；若未显示暗色，检查 `Tools → Options → Font and Colors` 是否已切到 dark（`theme=2` 会强制暗色）。

> 该命令是"即时应用"性质的：会写入 Everything 配置并即时生效。想恢复默认：`Tools → Options → Font and Colors → Reset` 或手动改回。

## 色值映射（Everforest hard / dark → Everything 角色）

| Everything 角色 | Everforest token | hex |
|---|---|---|
| 主背景（normal/pane/preview/statusbar 等） | `bg0` | `#272e33` |
| 面板/悬停/列头/交替行/侧栏（mouseover/header/alternate） | `bg1` | `#2e383c` |
| 选中行（selected/selected_inactive） | `bg2` | `#374145` |
| 主前景（所有文字） | `fg` | `#d3c6aa` |
| 强调色 accent / 热词 hot / 当前排序列 | `green` | `#a7c080` |

## 说明

- 仅**暗色**版（对应 `theme=2` + `dark_*` 键）；浅色版可参照同一映射用非 `dark_` 键（暂未做）。
- `bold` 相关键保持默认，未强制。
- 若个别区域颜色不生效，用 `Everything` 的 `Tools → Options → Font and Colors` 查看实际键名，反馈给我调整。
