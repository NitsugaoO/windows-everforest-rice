# Everforest 主题 for tacky-borders

将 [sainnhe/everforest](https://github.com/sainnhe/everforest) 的 **hard（高对比度）暗色**调色板应用到 [tacky-borders](https://github.com/luke-you/tacky-borders)（Windows 11/10 自定义窗口边框工具）。

文件：`config.yaml`（`generator/generate.py` 生成的归档副本；实际生效位置为 `%USERPROFILE%\.config\tacky-borders\config.yaml`）

## 安装 / 生效

1. 若尚未安装：`scoop install tacky-borders`（配置在 `%USERPROFILE%\.config\tacky-borders\`，非持久化）。
2. 在仓库根目录运行 `python generator/generate.py`（本目录文件由 `src/tacky-borders.yaml` 生成，并**同步到实际生效位置**）。
3. 保存后自动热重载（`watch_config_changes: true`）；若未生效，托盘图标右键 → **Reload Borders**。

## 配置说明（当前方案：实色边框）

| 项 | 值 | 说明 |
|---|---|---|
| `active_color` | `#a7c080`（`accent` 鼠尾草绿） | 仅当前激活窗口显示 Everforest 主题绿边框 |
| `inactive_color` | `#00000000`（透明） | 非激活窗口不画边框，系统原生风格不变 |
| `border_width` | `2` | 边框粗细 2px |
| `border_offset` | `-1` | 向内收 1px，贴窗框 |
| `border_radius` | `-1` | 自动匹配窗口圆角（Win11 推荐） |

## 其他可配置项（本主题未用，备用）

- **渐变**：`active_color: { colors: ["#83c092","#a7c080","#dbbc7f"], direction: 135deg }`
- **动画**（需 `rendering_backend: V2`）：`animations: { active: [{type: Spiral, duration: 1800, easing: Linear}] }`
- **逐应用规则**：`window_rules:`（按 Class/Title/Process 匹配，可覆盖颜色或 `enabled: false` 禁用）
- 完整可配置项见 [tacky-borders 官方 README](https://github.com/luke-you/tacky-borders)。
