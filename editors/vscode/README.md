# VSCode

Everforest Hard 在本仓库以 **扩展形式** 提供，没有单独的主题 json 文件：

- [`extensions/everforest-hard/`](../../extensions/everforest-hard/) —— 扩展源码
  （`package.json` + `themes/everforest-hard-dark.json` + 图标）
- [`extensions/everforest-hard/everforest-hard-1.0.0.vsix`](../../extensions/everforest-hard/) —— 打包好的安装包

## 安装

```powershell
code --install-extension extensions\everforest-hard\everforest-hard-1.0.0.vsix
```

或在 VSCode 里打开「扩展」面板 → 右上角 `...` → **从 VSIX 安装**，选中上面那个文件。

装完按 `Ctrl+K Ctrl+T` 选 **Everforest Hard**。

## 为什么不做成单独的 json

配色要和 Neovim、yasb、Windhawk 共用同一份色板，而 VSCode 的 UI 颜色 + 语法高亮
加起来有几百个键。做成扩展后，改色只需重新渲染 `themes/*.json` 再重打包，
不用手动维护一个巨大的 json。
