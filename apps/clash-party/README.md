# Everforest for Clash Party

Clash Party 的单文件 CSS 主题，配色取自 Everforest Hard（与 VSCode / Neovim 主题同一色板）。

```
ClashParty/
└── everforest.css     ← 生成产物，勿手改
```

## 安装

```bash
cd %USERPROFILE%\Themes
python generator/gen_clash_party.py
```

脚本会把 `everforest.css` 复制到 Clash Party 的主题目录：

```
%APPDATA%\mihomo-party\themes\everforest.css
```

然后打开 Clash Party → 设置 → 外观 / 主题 → 选择 **Everforest**。

也可以手动安装：把 `everforest.css` 复制到上面的 `themes` 目录
（或使用设置里的“导入主题”选择该文件）。

## 机制

Clash Party 会把主题 CSS 通过 `webContents.insertCSS()` 注入窗口。
主题只覆盖 HeroUI 的 CSS 变量（`--heroui-*`），不重写组件结构，因此对版本更新比较稳。

- 主背景 / 面板 / 浮层：`bg0 → bg1 → bg2`
- 正文 / 次要 / 更淡文字：`fg → grey2 → grey1`
- 主色 = 鼠尾草绿 `#a7c080`，次色 / 成功 = 青 `#83c092`，警告 = 黄 `#dbbc7f`，危险 = 红 `#e67e80`
- 强调色的 50–900 色阶由主色按亮度推导，50 最暗、500 为主色、900 最亮
- 强制暗色：浅色模式下也套同一套变量，避免出现半深半浅
- 额外细节：选区半透明绿、滚动条跟随面板色、侧栏比主区域深一档

## 改色

色值唯一来源是 `themes/everforest/tokens.yaml`。改完后重新生成：

```bash
python generator/gen_clash_party.py
```

如果只想更新仓库里的文件、不复制到 Clash Party：

```bash
python generator/gen_clash_party.py --no-install
```

## 注意

Clash Party 升级大版本后，如果 HeroUI 变量或组件结构变化，主题可能需要跟着调整
（主题市场也曾因 UI 组件更新导致旧主题失效）。届时对照新版 `config.yaml`
或主题市场的 `default.css` 检查变量名即可。
