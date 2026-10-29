# Neovim 统一配置（Everforest Hard）

Windows、WSL、`ssh dojo` 服务器三端共用这一份配置。

```
editors/nvim/
├── init.vim                 主配置（含 dojo 原有的 asm 构建快捷键）
├── colors/
│   └── everforest.lua       配色（生成产物，勿手改）
└── README.md
```

## 改色

`colors/everforest.lua` 是**生成产物**，勿手改。色值唯一权威是本仓库的
[`palette/tokens.yaml`](../../palette/tokens.yaml)（19 个角色）。

本仓库只放成品，不带上游生成器（`everforest-themes` 仓库的 `generator/gen_nvim.py`，
目前未公开）。想自己改色两条路：

1. 直接改 `colors/everforest.lua` 里的色值（简单，但会和 `palette/tokens.yaml` 脱钩）
2. 按 `palette/tokens.yaml` 的 19 个角色替换模板里的 `{{角色名}}` 占位符重新渲染

## 三端如何用上这份配置

### Windows

Neovim 已用 scoop 安装。配置目录是指向本目录的 junction：

```
%LOCALAPPDATA%\nvim  ->  <仓库>\editors\nvim
```

重新建立（若链接丢了）：

```powershell
New-Item -ItemType Junction -Path "$env:LOCALAPPDATA\nvim" -Target "$env:USERPROFILE\Projects\windows-everforest-rice\editors\nvim"
```

### WSL（Ubuntu-24.04）

Neovim 装在 `~/.local/opt/nvim-linux-x86_64`，可执行文件软链到 `~/.local/bin/nvim`。
配置目录软链到 Windows 侧同一份文件（WSL 通过 `/mnt/c` 访问）：

```bash
ln -sfn /mnt/c/Users/<YourName>/Projects/windows-everforest-rice/editors/nvim ~/.config/nvim
```

### dojo 服务器

服务器不能直接读本地目录，用 scp 覆盖（服务器原 `init.vim` 已并入本目录）：

```bash
cd /c/Users/<YourName>/Projects/windows-everforest-rice/editors/nvim
ssh dojo 'cp ~/.config/nvim/init.vim ~/.config/nvim/init.vim.bak && mkdir -p ~/.config/nvim/colors'
scp init.vim dojo:~/.config/nvim/init.vim
scp colors/everforest.lua dojo:~/.config/nvim/colors/everforest.lua
```

## 配色说明

代码语义对齐 VSCode 的 Everforest Pro（hard）：

| 语法 | 颜色 |
|---|---|
| 关键字 / 条件 / 异常 | `#e67e80` 红 |
| 存储类型 / 运算符 | `#e69875` 橙 |
| 字符串 / 数字 | `#dbbc7f` 黄 / `#d699b6` 紫 |
| 函数 / 转义 | `#a7c080` 绿 |
| 预处理 / import / 命名空间 | `#83c092` 青 |
| 类型 / 类 | `#7fbbb3` 蓝 |
| 标识符 / 标点 | `#d3c6aa` 米白 |
| 注释 | `#859289` 灰斜体 |

界面色（行高亮、选区、搜索结果、行号、缩进线、括号匹配）均由
`colors/everforest.lua` 里的 `blend()` 按 VSCode 的 alpha 规则从同一色板推导，
与 `extensions/everforest-hard/themes/everforest-hard-dark.json` 的 `colors` 段一致。

## 验证

```bash
nvim --headless -c 'colorscheme everforest' -c 'lua print(vim.g.colors_name)' -c 'qa'
# 期望输出 everforest
```
