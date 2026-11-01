# Everforest 主题 for Windows Terminal

Windows Terminal 的**配置片段**（不是完整 `settings.json`）：`profiles.defaults` 的透明参数 +
`Everforest Dark Hard` 配色方案。

文件：`windows-terminal.json`（由 `src/windows_terminal.json` 渲染）

## 效果

| 项 | 值 | 说明 |
|---|---|---|
| `opacity` | `72` | 窗口不透明度（WT 用 **0-100 整数**，不是 CSS 的 0.72）|
| `useAcrylic` | `true` | 打开亚克力；tint 色自动取 scheme 的 `background` |
| `background` | `#272e33`（角色「背景」） | 与 yasb 的 `--yasb-bar-bg`、Windhawk 玻璃画刷同一个色 |
| `foreground` | `#d3c6aa`（角色「正文」） | |

所以 WT 的实际观感 = `#272e33` @ 72% 亚克力 —— 与状态栏 / 开始菜单 / 任务栏 / toast /
VSCode 终端用的是同一组参数。

## 安装（手动合并）

WT 的配置里除了配色还有 keybindings / profiles / actions，**不能整个覆盖**，只合并两块：

1. 打开 `设置`（`Ctrl+,`）→ 左下角「打开 JSON 文件」，或直接编辑
   `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`
2. 把 `profiles.defaults` 的四项抄进去（`colorScheme` / `font` / `opacity` / `useAcrylic`）
3. 把 `schemes` 里同名的 `Everforest Dark Hard` 替换成文件里的版本
4. 保存即热重载，不用重启

## 注意

- **`compatibility.enableUnfocusedAcrylic`** 建议设为 `true`（本来默认就是），否则窗口失焦
  时会掉成实色，切换窗口时观感跳变。
- 单个 profile 里如果写了 `opacity`，会**覆盖** `profiles.defaults` —— 例如
  `tupa-launcher` 那条 profile 显式写了 `"opacity": 100`，它就不会透。
- `selectionBackground` 用的是角色「浮层」`#374145`。WT 默认的 `#4C3743` 是 Everforest
  上游的 `bg_visual`（偏红），**不在本项目的 19 个角色里**，`audit.py` 会判它越界，所以换掉。
- WT 的亚克力走**系统 AcrylicBrush**，不是 Windhawk 的 `WindhawkBlur`。两者参数对得上，
  但模糊算法不同 —— 想要逐像素一致做不到，只能观感接近。
- 浅色 scheme（Light Soft/Medium/Hard）**没有纳入项目**：本仓库只维护一套 hard 暗色
  （见 `STATE.md`「阶段」）。
