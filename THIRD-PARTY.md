# 第三方出处与署名

本仓库的配置**结构**与**色值**大量派生自下面这些项目。各文件的头部注释里也保留了原始出处。

| 项目 | 许可 | 用在哪里 |
|---|---|---|
| [sainnhe/everforest](https://github.com/sainnhe/everforest) | MIT | **色板本身**。19 个角色的色值全部取自它的 hard（高对比）档，`palette/tokens.yaml` 每行末的注释就是它上游的色名 |
| [everforest-pro](https://github.com/AndreiLucaci)（AndreiLucaci） | MIT | VSCode 扩展的语法高亮 `tokenColors` 语义，medium 色替换为 hard 色 |
| [dracula/microsoft-edge](https://github.com/dracula/microsoft-edge) | MIT | `windows/edge/` 的 Edge 主题扩展骨架（manifest + 打包后的 `Cached Theme.pak`） |
| [ramensoftware/windows-11-start-menu-styling-guide](https://github.com/ramensoftware/windows-11-start-menu-styling-guide) | 见上游 | `windows/windhawk/start-menu/` 的 target 与结构（参照其 Everblush 主题） |
| [ramensoftware/windows-11-taskbar-styling-guide](https://github.com/ramensoftware/windows-11-taskbar-styling-guide) | 见上游 | `windows/windhawk/taskbar/` 的 target 与结构（参照其 RosePine 主题） |
| [ramensoftware/windows-11-file-explorer-styling-guide](https://github.com/ramensoftware/windows-11-file-explorer-styling-guide) | 见上游 | `windows/windhawk/explorer/` 的配色 target 与 Matter 主题结构 |
| [Akumy-01](https://github.com/Akumy-01) | 见上游 | `system-tweaks/tweaks/desktop-icons-toggle/` 的 Windhawk mod 源码基底（`desktop-icons-double-click-toggle2.wh.cpp` 文件头保留 `@github` 署名） |
| [amnweb/yasb](https://github.com/amnweb/yasb) | MIT | `windows/yasb/styles.css` 的原始 CSS 骨架与 widget 类名 |
| [luke-you/tacky-borders](https://github.com/luke-you/tacky-borders) | 见上游 | `windows/tacky-borders/config.yaml` 的配置项结构 |
| [Courage-1984/everything1.5a](https://github.com/Courage-1984/everything1.5a) | 见上游 | `windows/everything/` 的「粘贴命令到搜索框」这套用法 |

## 未包含在本仓库的内容

- **壁纸与开机动画**：使用了他人作品，版权不属于本项目，因此不随仓库分发。
- **注册表 / 计划任务的原始导出快照**：含本机自启软件清单等机器信息，已从发布版本移除；
  `system-tweaks/` 里只保留可复用的配置与说明。

如果你认为某个文件的署名不完整，请提 issue，会尽快补上。
