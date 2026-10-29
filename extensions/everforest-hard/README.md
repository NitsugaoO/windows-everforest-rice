# Everforest Hard

**Everforest (hard / high contrast) theme for VSCode** — 独立扩展，不依赖 Everforest Pro。

由设计令牌（`palette/tokens.yaml`）自动生成：
- **UI 颜色**：完整的 Everforest hard 配色 + ui 三态（idle / hover / selected）
- **语法高亮**：沿用 everforest-pro 的 tokenColors 语义，medium 色替换为 hard 色

## 安装（本地）

```bash
# 用 vsce 打包
npx @vscode/vsce package
# 安装
code --install-extension everforest-hard-1.0.0.vsix
```

## 重新生成

`themes/everforest-hard-dark.json` 是生成产物，色值唯一权威是
[`palette/tokens.yaml`](../../palette/tokens.yaml)。生成器（上游 `everforest-themes`
仓库的 `generator/gen_vscode.py`）目前未公开；改色后按 tokens 的 19 个角色重新渲染，
再重新打包安装即可。仓库里同时提供了打包好的 `everforest-hard-1.0.0.vsix`。

## 许可

MIT（基底语法高亮取自 [sainnhe/everforest](https://github.com/sainnhe/everforest) + everforest-pro 的 AndreiLucaci，均已 MIT 授权）
