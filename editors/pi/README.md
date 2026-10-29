# Everforest 主题 for Pi (coding agent TUI)

将 [sainnhe/everforest](https://github.com/sainnhe/everforest) 的 **hard（高对比度）调色板**（暗色 + 浅色），映射到 pi 的 TUI 主题系统。
映射规则参考了 pi 内置 `dark.json` / `light.json` 的结构与 token 语义，色值全部取自 Everforest hard 色板（见 `Notes/` 速查表）。

文件：`everforest.json`（暗色）、`everforest-light.json`（浅色）

## 安装

1. 把两个 `.json` 复制到 pi 的全局主题目录：
   `~/.pi/agent/themes/`
2. 在 pi 内用 `/settings` 选择 `everforest` 或 `everforest-light`（立即生效，无需重启）。
3. 或在 `settings.json` 里写：
   ```json
   { "theme": "everforest" }
   ```
4. 想跟随终端明暗自动切换：
   ```bash
   pi --use-theme everforest/everforest-light
   ```

> **热加载**：编辑当前激活中的主题文件时，pi 会自动重载，即时看到配色变化。

## 色值映射（Everforest hard / dark → pi token）

| pi token | Everforest token | hex |
|---|---|---|
| `accent`（logo/光标/选中） | `green` | `#a7c080` |
| `text` / `toolTitle` / `userMessageText` | `fg` | `#d3c6aa` |
| `border` | `bg3` | `#414b50` |
| `borderAccent` | `aqua` | `#83c092` |
| `borderMuted` | `bg2` | `#374145` |
| `selectedBg` / `searchMatchBg` | `bg2` | `#374145` |
| `userMessageBg` / `customMessageBg` | `bg1` | `#2e383c` |
| `toolPendingBg` / `toolErrorBg` | `bg_dim` | `#1e2326` |
| `toolSuccessBg` | `bg0` | `#272e33` |
| `success` | `aqua` | `#83c092` |
| `error` | `red` | `#e67e80` |
| `warning` / `mdHeading` | `yellow` | `#dbbc7f` |
| `mdLink` / `customMessageLabel` / `syntaxVariable` | `blue` | `#7fbbb3` |
| `mdCode` / `mdListBullet` / `syntaxType` | `aqua` | `#83c092` |
| `mdCodeBlock` / `toolDiffAdded` / `syntaxString` / `bashMode` | `green` | `#a7c080` |
| `toolDiffRemoved` / `syntaxKeyword` | `red` | `#e67e80` |
| `syntaxNumber` | `purple` | `#d699b6` |
| `syntaxFunction` | `yellow` | `#dbbc7f` |
| `muted` / `toolOutput` / `mdQuote` / `toolDiffContext` | `grey2` | `#9da9a0` |
| `dim` / `mdLinkUrl` | `grey1` | `#859289` |
| `syntaxComment` / `mdCodeBlockBorder` / `mdQuoteBorder` / `mdHr` | `grey0` | `#7a8478` |
| 思考级别边框 `thinkingOff→Max` | `bg3 → grey0 → blue → aqua → green → yellow → orange` | 逐级递增 |

> 浅色版 `everforest-light.json` 使用同套语义映射到 hard 浅色色板（`bg0 #fffbef`、`fg #5c6a72`、`green #8da101` 等），token 结构完全一致。

## 说明

- 51 个必填 token 全部定义，已通过 pi `theme-schema.json` 校验。
- 结构完全参照 pi 内置主题（`vars` 定义色板 + `colors` 引用），与内置 `dark`/`light` 同构，方便后续微调对比度档（只改 `vars` 里的背景系即可）。
- 语法高亮按 Everforest vim 语义分配：关键字=red、字符串=green、类型=aqua、数字=purple、变量=blue、注释=grey。
