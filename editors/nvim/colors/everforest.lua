-- ============================================================
-- Everforest Hard for Neovim
-- 由 generator/gen_nvim.py 从 src/nvim.lua + themes/everforest/tokens.yaml 生成。
-- 代码高亮语义对齐 VSCode 的 Everforest Pro（hard）：
--   关键字 red / 存储与运算符 orange / 字符串 yellow / 转义与函数 green
--   预处理与命名空间 aqua / 类型与类 blue / 数字与常量 purple
--   标识符与标点 fg / 注释 grey1 斜体
-- ============================================================

-- 色板（占位符由生成器替换为 tokens.yaml 里的 Hex）
local p = {
  bg_dim = "#1e2326",  -- #1e2326
  bg0    = "#272e33",  -- #272e33
  bg1    = "#2e383c",  -- #2e383c
  bg2    = "#374145",  -- #374145
  bg3    = "#414b50",  -- #414b50
  bg4    = "#495156",  -- #495156
  fg     = "#d3c6aa",  -- #d3c6aa
  grey2  = "#9da9a0",  -- #9da9a0
  grey1  = "#859289",  -- #859289
  grey0  = "#7a8478",  -- #7a8478
  bg_red = "#2d353b",  -- #2d353b
  green  = "#a7c080",  -- #a7c080
  aqua   = "#83c092",  -- #83c092
  yellow = "#dbbc7f",  -- #dbbc7f
  orange = "#e69875",  -- #e69875
  red    = "#e67e80",  -- #e67e80
  blue   = "#7fbbb3",    -- #7fbbb3
  purple = "#d699b6",    -- #d699b6
}

local function hex2rgb(hex)
  local h = hex:gsub("#", "")
  return tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16)
end

-- 把 fg 按 alpha 叠到 bg 上，得到 VSCode 那种半透明选区的实色
local function blend(fg, alpha, bg)
  local fr, fgn, fb = hex2rgb(fg)
  local br, bgn, bb = hex2rgb(bg)
  local r = math.floor(fr * alpha + br * (1 - alpha) + 0.5)
  local g = math.floor(fgn * alpha + bgn * (1 - alpha) + 0.5)
  local b = math.floor(fb * alpha + bb * (1 - alpha) + 0.5)
  return string.format("#%02x%02x%02x", r, g, b)
end

local function apply()
  local hl = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  local bg = p.bg0

  -- ----------------------------------------------------------
  -- 从 VSCode colors 段推导的界面色（与 everforest-hard-dark.json 一致）
  -- ----------------------------------------------------------
  local line            = blend(p.grey1, 0.05, bg)  -- editor.lineHighlightBackground
  local selection       = blend(p.green, 0.25, bg)  -- editor.selectionBackground
  local selection_blur  = blend(p.green, 0.15, bg)  -- inactiveSelectionBackground
  local selection_hl    = blend(p.green, 0.12, bg)  -- selectionHighlightBackground
  local word_hl         = blend(p.green, 0.15, bg)  -- wordHighlightBackground
  local word_hl_strong  = blend(p.green, 0.20, bg)  -- wordHighlightStrongBackground
  local find            = blend(p.yellow, 0.35, bg) -- findMatchBackground
  local find_hl         = blend(p.yellow, 0.20, bg) -- findMatchHighlightBackground
  local find_range      = blend(p.yellow, 0.12, bg) -- findRangeHighlightBackground
  local whitespace      = blend(p.grey1, 0.50, bg)  -- editorWhitespace.foreground
  local indent          = blend(p.grey1, 0.25, bg)  -- editorIndentGuide.background
  local indent_active   = blend(p.grey1, 0.45, bg)  -- editorIndentGuide.activeBackground
  local linenr          = blend(p.grey1, 0.60, bg)  -- editorLineNumber.foreground
  local ruler           = blend(p.grey1, 0.40, bg)  -- editorRuler.foreground
  local bracket_match   = blend(p.green, 0.30, bg)  -- editorBracketMatch.background
  local scrollbar       = blend(p.grey1, 0.30, bg)  -- scrollbarSlider.background
  local scrollbar_hover = blend(p.grey1, 0.40, bg)
  local scrollbar_active= blend(p.grey1, 0.50, bg)
  local diff_add        = blend(p.green, 0.15, bg)
  local diff_change     = blend(p.blue, 0.15, bg)
  local diff_delete     = blend(p.red, 0.15, bg)
  local diff_text       = blend(p.yellow, 0.22, bg)

  -- ----------------------------------------------------------
  -- 基础 UI
  -- ----------------------------------------------------------
  hl("Normal",        { fg = p.fg, bg = bg })
  hl("NormalNC",      { fg = p.fg, bg = bg })
  hl("NormalFloat",   { fg = p.fg, bg = p.bg1 })
  hl("FloatBorder",   { fg = p.bg3, bg = p.bg1 })
  hl("FloatTitle",    { fg = p.green, bg = p.bg1, bold = true })
  hl("FloatFooter",   { fg = p.grey1, bg = p.bg1 })
  hl("Cursor",        { fg = bg, bg = p.green })
  hl("lCursor",       { fg = bg, bg = p.green })
  hl("CursorIM",      { fg = bg, bg = p.green })
  hl("TermCursor",    { fg = bg, bg = p.green })
  hl("TermCursorNC",  { fg = bg, bg = p.grey1 })
  hl("CursorLine",    { bg = line })
  hl("CursorColumn",  { bg = line })
  hl("CursorLineNr",  { fg = p.grey1, bold = true })
  hl("ColorColumn",   { bg = ruler })
  hl("LineNr",        { fg = linenr })
  hl("LineNrAbove",   { fg = linenr })
  hl("LineNrBelow",   { fg = linenr })
  hl("SignColumn",    { bg = bg })
  hl("FoldColumn",    { fg = p.grey0, bg = bg })
  hl("Folded",        { fg = p.grey1, bg = p.bg1 })
  hl("VertSplit",     { fg = p.bg3, bg = bg })
  hl("WinSeparator",  { fg = p.bg3, bg = bg })

  -- 状态栏 / 标签页（对齐 VSCode statusBar / tabBar）
  hl("StatusLine",    { fg = p.grey2, bg = p.bg_dim })
  hl("StatusLineNC",  { fg = p.grey0, bg = p.bg_dim })
  hl("StatusLineTerm",{ fg = p.grey2, bg = p.bg_dim })
  hl("StatusLineTermNC", { fg = p.grey0, bg = p.bg_dim })
  hl("TabLine",       { fg = p.grey0, bg = p.bg_dim })
  hl("TabLineSel",    { fg = p.fg, bg = bg })
  hl("TabLineFill",   { bg = p.bg_dim })
  hl("WinBar",        { fg = p.grey2, bg = bg, bold = true })
  hl("WinBarNC",      { fg = p.grey0, bg = bg })

  -- 补全 / 悬浮菜单
  hl("Pmenu",          { fg = p.fg, bg = p.bg1 })
  hl("PmenuSel",       { fg = p.fg, bg = p.bg2, bold = true })
  hl("PmenuKind",      { fg = p.blue, bg = p.bg1 })
  hl("PmenuKindSel",   { fg = p.blue, bg = p.bg2 })
  hl("PmenuExtra",     { fg = p.grey1, bg = p.bg1 })
  hl("PmenuExtraSel",  { fg = p.grey1, bg = p.bg2 })
  hl("PmenuSbar",      { bg = p.bg1 })
  hl("PmenuThumb",     { bg = p.bg3 })
  hl("WildMenu",       { fg = p.fg, bg = selection })

  -- 选区 / 搜索 / 括号匹配
  hl("Visual",       { bg = selection })
  hl("VisualNOS",    { bg = selection_blur })
  hl("Search",       { fg = p.fg, bg = find })
  hl("IncSearch",    { fg = p.fg, bg = find_hl, bold = true })
  hl("CurSearch",    { link = "Search" })
  hl("Substitute",   { fg = p.fg, bg = blend(p.orange, 0.45, bg) })
  hl("MatchParen",   { fg = p.green, bg = bracket_match, bold = true })

  -- 不可见字符 / 空行
  hl("NonText",      { fg = whitespace })
  hl("EndOfBuffer",  { fg = bg })
  hl("SpecialKey",   { fg = whitespace })
  hl("Whitespace",   { fg = whitespace })
  hl("Conceal",      { fg = p.grey1 })

  -- 消息 / 杂项
  hl("Directory",    { fg = p.blue })
  hl("Title",        { fg = p.green, bold = true })
  hl("ErrorMsg",     { fg = p.red })
  hl("WarningMsg",   { fg = p.yellow })
  hl("MoreMsg",      { fg = p.aqua })
  hl("Question",     { fg = p.green })
  hl("ModeMsg",      { fg = p.fg, bold = true })
  hl("Error",        { fg = p.red })
  hl("Todo",         { fg = p.yellow, bold = true })
  hl("Debug",        { fg = p.orange })
  hl("debugPC",      { bg = p.bg1 })
  hl("debugBreakpoint", { fg = bg, bg = p.red })
  hl("QuickFixLine", { bg = selection })

  -- 拼写检查
  hl("SpellBad",     { sp = p.red, undercurl = true })
  hl("SpellCap",     { sp = p.yellow, undercurl = true })
  hl("SpellLocal",   { sp = p.aqua, undercurl = true })
  hl("SpellRare",    { sp = p.purple, undercurl = true })

  -- 版本管理 / diff
  hl("Added",        { fg = p.green })
  hl("Changed",      { fg = p.yellow })
  hl("Removed",      { fg = p.red })
  hl("DiffAdd",      { bg = diff_add })
  hl("DiffChange",   { bg = diff_change })
  hl("DiffDelete",   { bg = diff_delete })
  hl("DiffText",     { bg = diff_text })
  hl("diffAdded",    { fg = p.green })
  hl("diffRemoved",  { fg = p.red })
  hl("diffChanged",  { fg = p.yellow })
  hl("diffOldFile",  { fg = p.yellow })
  hl("diffNewFile",  { fg = p.green })
  hl("diffFile",     { fg = p.blue })
  hl("diffLine",     { fg = p.grey1 })
  hl("diffIndexLine",{ fg = p.purple })

  -- ----------------------------------------------------------
  -- LSP 诊断（VSCode 的 squiggle / 行内提示）
  -- ----------------------------------------------------------
  hl("DiagnosticError",  { fg = p.red })
  hl("DiagnosticWarn",   { fg = p.yellow })
  hl("DiagnosticInfo",   { fg = p.aqua })
  hl("DiagnosticHint",   { fg = p.blue })
  hl("DiagnosticOk",     { fg = p.green })

  hl("DiagnosticVirtualTextError", { fg = p.red })
  hl("DiagnosticVirtualTextWarn",  { fg = p.yellow })
  hl("DiagnosticVirtualTextInfo",  { fg = p.aqua })
  hl("DiagnosticVirtualTextHint",  { fg = p.blue })
  hl("DiagnosticVirtualTextOk",    { fg = p.green })

  hl("DiagnosticUnderlineError", { sp = p.red, undercurl = true })
  hl("DiagnosticUnderlineWarn",  { sp = p.yellow, undercurl = true })
  hl("DiagnosticUnderlineInfo",  { sp = p.aqua, undercurl = true })
  hl("DiagnosticUnderlineHint",  { sp = p.blue, undercurl = true })
  hl("DiagnosticUnderlineOk",    { sp = p.green, undercurl = true })

  hl("DiagnosticFloatingError", { fg = p.red, bg = p.bg1 })
  hl("DiagnosticFloatingWarn",  { fg = p.yellow, bg = p.bg1 })
  hl("DiagnosticFloatingInfo",  { fg = p.aqua, bg = p.bg1 })
  hl("DiagnosticFloatingHint",  { fg = p.blue, bg = p.bg1 })
  hl("DiagnosticFloatingOk",    { fg = p.green, bg = p.bg1 })

  hl("DiagnosticSignError", { fg = p.red, bg = bg })
  hl("DiagnosticSignWarn",  { fg = p.yellow, bg = bg })
  hl("DiagnosticSignInfo",  { fg = p.aqua, bg = bg })
  hl("DiagnosticSignHint",  { fg = p.blue, bg = bg })
  hl("DiagnosticSignOk",    { fg = p.green, bg = bg })

  hl("DiagnosticDeprecated", { sp = p.red, strikethrough = true })
  hl("DiagnosticUnnecessary", { fg = p.grey0 })

  -- ----------------------------------------------------------
  -- LSP 引用 / 内联提示
  -- ----------------------------------------------------------
  hl("LspReferenceText",            { bg = word_hl })
  hl("LspReferenceRead",            { bg = word_hl })
  hl("LspReferenceWrite",           { bg = word_hl_strong })
  hl("LspSignatureActiveParameter", { fg = p.green, bold = true })
  hl("LspCodeLens",                 { fg = p.grey1 })
  hl("LspCodeLensSeparator",        { fg = p.grey0 })
  hl("LspInlayHint",                { fg = p.grey1, bg = p.bg1, italic = true })

  -- ----------------------------------------------------------
  -- Treesitter：注释 / 常量 / 字符串
  -- ----------------------------------------------------------
  hl("@comment",          { fg = p.grey1, italic = true })
  hl("@comment.error",    { fg = p.red, italic = true })
  hl("@comment.warning",  { fg = p.yellow, italic = true })
  hl("@comment.todo",     { fg = p.orange, italic = true, bold = true })
  hl("@comment.note",     { fg = p.aqua, italic = true })

  hl("@constant",           { fg = p.purple })
  hl("@constant.builtin",   { fg = p.purple })
  hl("@constant.macro",     { fg = p.purple })
  hl("@number",             { fg = p.purple })
  hl("@number.float",       { fg = p.purple })
  hl("@boolean",            { fg = p.purple })
  hl("@character",          { fg = p.yellow })
  hl("@character.special",  { fg = p.green })

  hl("@string",                 { fg = p.yellow })
  hl("@string.regexp",          { fg = p.yellow })
  hl("@string.escape",          { fg = p.green })
  hl("@string.special",         { fg = p.green })
  hl("@string.special.symbol",  { fg = p.purple })
  hl("@string.special.url",     { fg = p.aqua, underline = true })
  hl("@string.documentation",   { fg = p.grey2 })

  -- ----------------------------------------------------------
  -- Treesitter：函数 / 关键字 / 类型
  -- ----------------------------------------------------------
  hl("@function",             { fg = p.green })
  hl("@function.call",        { fg = p.green })
  hl("@function.builtin",     { fg = p.green })
  hl("@function.macro",       { fg = p.purple })
  hl("@function.method",      { fg = p.green })
  hl("@function.method.call", { fg = p.green })
  hl("@method",               { fg = p.green })
  hl("@method.call",          { fg = p.green })
  hl("@constructor",          { fg = p.blue })
  hl("@operator",             { fg = p.orange })

  hl("@keyword",              { fg = p.red })
  hl("@keyword.function",     { fg = p.red })
  hl("@keyword.return",       { fg = p.red })
  hl("@keyword.conditional",  { fg = p.red })
  hl("@keyword.repeat",       { fg = p.red })
  hl("@keyword.exception",    { fg = p.red })
  hl("@keyword.operator",     { fg = p.orange })
  hl("@keyword.import",       { fg = p.aqua })
  hl("@keyword.directive",    { fg = p.aqua })
  hl("@keyword.directive.define", { fg = p.aqua })
  hl("@keyword.type",         { fg = p.blue })
  hl("@keyword.modifier",     { fg = p.orange })
  hl("@keyword.storage",      { fg = p.orange })
  hl("@conditional",          { fg = p.red })
  hl("@repeat",               { fg = p.red })
  hl("@exception",            { fg = p.red })
  hl("@include",              { fg = p.aqua })
  hl("@define",               { fg = p.aqua })
  hl("@preproc",              { fg = p.aqua })
  hl("@storageclass",         { fg = p.orange })
  hl("@type.qualifier",       { fg = p.orange })
  hl("@label",                { fg = p.aqua })
  hl("@decorator",            { fg = p.aqua })

  hl("@type",             { fg = p.blue })
  hl("@type.builtin",     { fg = p.blue })
  hl("@type.definition",  { fg = p.blue })
  hl("@class",            { fg = p.blue })
  hl("@class.builtin",    { fg = p.blue })
  hl("@structure",        { fg = p.blue })
  hl("@enum",             { fg = p.blue })
  hl("@enumMember",       { fg = p.blue })
  hl("@namespace",        { fg = p.aqua })
  hl("@module",           { fg = p.aqua })

  -- ----------------------------------------------------------
  -- Treesitter：标识符 / 标点
  -- ----------------------------------------------------------
  hl("@variable",                 { fg = p.fg })
  hl("@variable.builtin",         { fg = p.purple })
  hl("@variable.parameter",       { fg = p.fg })
  hl("@variable.parameter.builtin", { fg = p.purple })
  hl("@variable.member",          { fg = p.fg })
  hl("@variable.special",         { fg = p.purple })
  hl("@property",                 { fg = p.fg })
  hl("@field",                    { fg = p.fg })
  hl("@attribute",                { fg = p.aqua })

  hl("@punctuation.bracket",   { fg = p.fg })
  hl("@punctuation.delimiter", { fg = p.fg })
  hl("@punctuation.special",   { fg = p.green })

  -- ----------------------------------------------------------
  -- Treesitter：Markdown / 文本
  -- ----------------------------------------------------------
  hl("@text.title",     { fg = p.red, bold = true })
  hl("@text.literal",   { fg = p.green })
  hl("@text.uri",       { fg = p.green, underline = true })
  hl("@text.reference", { fg = p.purple })
  hl("@text.emphasis",  { italic = true })
  hl("@text.strong",    { bold = true })
  hl("@text.strike",    { strikethrough = true })
  hl("@text.diff.add",  { fg = p.green })
  hl("@text.diff.delete", { fg = p.red })
  hl("@text.quote",     { fg = p.grey2, italic = true })
  hl("@text.math",      { fg = p.blue })
  hl("@text.note",      { fg = p.aqua })
  hl("@text.warning",   { fg = p.yellow })
  hl("@text.danger",    { fg = p.red })

  hl("@markup.heading",     { fg = p.red, bold = true })
  hl("@markup.heading.1",   { fg = p.red, bold = true })
  hl("@markup.heading.2",   { fg = p.orange, bold = true })
  hl("@markup.heading.3",   { fg = p.yellow, bold = true })
  hl("@markup.heading.4",   { fg = p.green, bold = true })
  hl("@markup.heading.5",   { fg = p.blue, bold = true })
  hl("@markup.heading.6",   { fg = p.purple, bold = true })
  hl("@markup.heading.delimiter", { fg = p.grey1 })
  hl("@markup.italic",      { italic = true })
  hl("@markup.bold",        { bold = true })
  hl("@markup.strikethrough", { strikethrough = true })
  hl("@markup.link",        { fg = p.purple })
  hl("@markup.link.label",  { fg = p.purple })
  hl("@markup.link.url",    { fg = p.green, underline = true })
  hl("@markup.raw",         { fg = p.green })
  hl("@markup.raw.block",   { fg = p.green })
  hl("@markup.list",        { fg = p.red })
  hl("@markup.list.checked",   { fg = p.green })
  hl("@markup.list.unchecked", { fg = p.grey1 })
  hl("@markup.quote",       { fg = p.grey2, italic = true })
  hl("@markup.math",        { fg = p.blue })
  hl("@markup.environment",      { fg = p.purple })
  hl("@markup.environment.name", { fg = p.blue })

  -- ----------------------------------------------------------
  -- Treesitter：HTML / XML
  -- ----------------------------------------------------------
  hl("@tag",            { fg = p.orange })
  hl("@tag.builtin",    { fg = p.orange })
  hl("@tag.attribute",  { fg = p.yellow })
  hl("@tag.delimiter",  { fg = p.green })

  -- ----------------------------------------------------------
  -- 经典（非 treesitter）语法组，保证 fallback 与 legacy 文件类型一致
  -- ----------------------------------------------------------
  hl("Comment",        { fg = p.grey1, italic = true })
  hl("Constant",       { fg = p.purple })
  hl("String",         { fg = p.yellow })
  hl("Character",      { fg = p.yellow })
  hl("Number",         { fg = p.purple })
  hl("Boolean",        { fg = p.purple })
  hl("Float",          { fg = p.purple })
  hl("Identifier",     { fg = p.fg })
  hl("Function",       { fg = p.green })
  hl("Statement",      { fg = p.red })
  hl("Conditional",    { fg = p.red })
  hl("Repeat",         { fg = p.red })
  hl("Label",          { fg = p.aqua })
  hl("Operator",       { fg = p.orange })
  hl("Keyword",        { fg = p.red })
  hl("Exception",      { fg = p.red })
  hl("PreProc",        { fg = p.aqua })
  hl("Include",        { fg = p.aqua })
  hl("Define",         { fg = p.aqua })
  hl("Macro",          { fg = p.purple })
  hl("PreCondit",      { fg = p.aqua })
  hl("Type",           { fg = p.blue })
  hl("StorageClass",   { fg = p.orange })
  hl("Structure",      { fg = p.blue })
  hl("Typedef",        { fg = p.blue })
  hl("Special",        { fg = p.green })
  hl("SpecialChar",    { fg = p.green })
  hl("Tag",            { fg = p.orange })
  hl("Delimiter",      { fg = p.fg })
  hl("SpecialComment", { fg = p.grey1, italic = true })
  hl("Underlined",     { underline = true })
  hl("Ignore",         { fg = p.grey0 })

  hl("htmlTag",        { fg = p.green })
  hl("htmlEndTag",     { fg = p.green })
  hl("htmlTagName",    { fg = p.orange })
  hl("htmlArg",        { fg = p.yellow })
  hl("htmlString",     { fg = p.green })
  hl("htmlSpecialChar",{ fg = p.purple })

  hl("markdownH1",               { fg = p.red, bold = true })
  hl("markdownH2",               { fg = p.orange, bold = true })
  hl("markdownH3",               { fg = p.yellow, bold = true })
  hl("markdownH4",               { fg = p.green, bold = true })
  hl("markdownH5",               { fg = p.blue, bold = true })
  hl("markdownH6",               { fg = p.purple, bold = true })
  hl("markdownHeadingDelimiter", { fg = p.grey1 })
  hl("markdownLinkText",         { fg = p.purple })
  hl("markdownUrl",              { fg = p.green, underline = true })
  hl("markdownCode",             { fg = p.green })
  hl("markdownCodeBlock",        { fg = p.green })
  hl("markdownBold",             { bold = true })
  hl("markdownItalic",           { italic = true })
  hl("markdownListMarker",       { fg = p.red })
  hl("markdownRule",             { fg = p.grey1 })
  hl("markdownQuote",            { fg = p.grey2, italic = true })

  hl("yamlKey",        { fg = p.aqua })
  hl("yamlString",     { fg = p.green })
  hl("jsonKeyword",    { fg = p.orange })
  hl("jsonString",     { fg = p.green })
  hl("jsonBoolean",    { fg = p.purple })

  -- ----------------------------------------------------------
  -- 常用插件
  -- ----------------------------------------------------------
  -- gitsigns
  hl("GitSignsAdd",            { fg = p.green })
  hl("GitSignsChange",         { fg = p.yellow })
  hl("GitSignsDelete",         { fg = p.red })
  hl("GitSignsAddNr",          { fg = p.green })
  hl("GitSignsChangeNr",       { fg = p.yellow })
  hl("GitSignsDeleteNr",       { fg = p.red })
  hl("GitSignsAddLn",          { bg = diff_add })
  hl("GitSignsChangeLn",       { bg = diff_change })
  hl("GitSignsDeleteLn",       { bg = diff_delete })
  hl("GitSignsCurrentLineBlame", { fg = p.grey0, italic = true })

  -- telescope
  hl("TelescopeNormal",         { fg = p.fg, bg = p.bg1 })
  hl("TelescopeBorder",         { fg = p.bg3, bg = p.bg1 })
  hl("TelescopeTitle",          { fg = p.green, bg = p.bg1, bold = true })
  hl("TelescopePromptNormal",   { fg = p.fg, bg = p.bg1 })
  hl("TelescopePromptBorder",   { fg = p.bg3, bg = p.bg1 })
  hl("TelescopePromptTitle",    { fg = bg, bg = p.green, bold = true })
  hl("TelescopeResultsTitle",   { fg = p.green, bg = p.bg1, bold = true })
  hl("TelescopePreviewTitle",   { fg = bg, bg = p.blue, bold = true })
  hl("TelescopeSelection",      { fg = p.fg, bg = p.bg2 })
  hl("TelescopeSelectionCaret", { fg = p.green, bg = p.bg2 })
  hl("TelescopeMatching",       { fg = p.green, bold = true })
  hl("TelescopeMultiSelection", { fg = p.yellow, bg = p.bg2 })
  hl("TelescopeResultsDiffAdd",    { fg = p.green })
  hl("TelescopeResultsDiffDelete", { fg = p.red })
  hl("TelescopeResultsDiffChange", { fg = p.yellow })
  hl("TelescopeResultsComment",    { fg = p.grey1 })

  -- nvim-cmp
  hl("CmpItemAbbr",           { fg = p.fg })
  hl("CmpItemAbbrDeprecated", { fg = p.grey0, strikethrough = true })
  hl("CmpItemAbbrMatch",      { fg = p.green, bold = true })
  hl("CmpItemAbbrMatchFuzzy", { fg = p.green, bold = true })
  hl("CmpItemMenu",           { fg = p.grey0 })
  hl("CmpGhostText",          { fg = p.grey1, italic = true })
  hl("CmpItemKind",           { fg = p.blue })
  hl("CmpItemKindText",       { fg = p.fg })
  hl("CmpItemKindMethod",     { fg = p.green })
  hl("CmpItemKindFunction",   { fg = p.green })
  hl("CmpItemKindConstructor",{ fg = p.blue })
  hl("CmpItemKindField",      { fg = p.fg })
  hl("CmpItemKindVariable",   { fg = p.fg })
  hl("CmpItemKindClass",      { fg = p.blue })
  hl("CmpItemKindInterface",  { fg = p.blue })
  hl("CmpItemKindModule",     { fg = p.aqua })
  hl("CmpItemKindProperty",   { fg = p.fg })
  hl("CmpItemKindUnit",       { fg = p.purple })
  hl("CmpItemKindValue",      { fg = p.purple })
  hl("CmpItemKindEnum",       { fg = p.blue })
  hl("CmpItemKindKeyword",    { fg = p.red })
  hl("CmpItemKindSnippet",    { fg = p.purple })
  hl("CmpItemKindColor",      { fg = p.purple })
  hl("CmpItemKindFile",       { fg = p.blue })
  hl("CmpItemKindReference",  { fg = p.purple })
  hl("CmpItemKindFolder",     { fg = p.blue })
  hl("CmpItemKindEnumMember", { fg = p.blue })
  hl("CmpItemKindConstant",   { fg = p.purple })
  hl("CmpItemKindStruct",     { fg = p.blue })
  hl("CmpItemKindEvent",      { fg = p.orange })
  hl("CmpItemKindOperator",   { fg = p.orange })
  hl("CmpItemKindTypeParameter", { fg = p.blue })

  -- nvim-tree
  hl("NvimTreeNormal",          { fg = p.grey2, bg = bg })
  hl("NvimTreeFolderIcon",      { fg = p.blue })
  hl("NvimTreeFolderName",      { fg = p.blue })
  hl("NvimTreeOpenedFolderName",{ fg = p.green, bold = true })
  hl("NvimTreeEmptyFolderName", { fg = p.grey0 })
  hl("NvimTreeRootFolder",      { fg = p.green, bold = true })
  hl("NvimTreeSpecialFile",     { fg = p.purple })
  hl("NvimTreeSymlink",         { fg = p.aqua })
  hl("NvimTreeCursorLine",      { bg = line })
  hl("NvimTreeIndentMarker",    { fg = indent })
  hl("NvimTreeWinSeparator",    { fg = p.bg3, bg = bg })
  hl("NvimTreeGitDirty",        { fg = p.yellow })
  hl("NvimTreeGitNew",          { fg = p.green })
  hl("NvimTreeGitDeleted",      { fg = p.red })

  -- neo-tree
  hl("NeoTreeNormal",        { fg = p.grey2, bg = bg })
  hl("NeoTreeDirectoryName", { fg = p.blue })
  hl("NeoTreeDirectoryIcon", { fg = p.blue })
  hl("NeoTreeRootName",      { fg = p.green, bold = true })
  hl("NeoTreeFileName",      { fg = p.grey2 })
  hl("NeoTreeCursorLine",    { bg = line })
  hl("NeoTreeGitAdded",      { fg = p.green })
  hl("NeoTreeGitModified",   { fg = p.yellow })
  hl("NeoTreeGitDeleted",    { fg = p.red })
  hl("NeoTreeGitUntracked",  { fg = p.orange })

  -- indent-blankline
  hl("IblIndent",                 { fg = indent })
  hl("IblScope",                  { fg = indent_active })
  hl("IndentBlanklineChar",       { fg = indent })
  hl("IndentBlanklineContextChar",{ fg = indent_active })

  -- which-key
  hl("WhichKey",           { fg = p.green })
  hl("WhichKeyGroup",      { fg = p.blue })
  hl("WhichKeyDesc",       { fg = p.fg })
  hl("WhichKeySeparator",  { fg = p.grey0 })
  hl("WhichKeyFloat",      { bg = p.bg1 })
  hl("WhichKeyBorder",     { fg = p.bg3, bg = p.bg1 })
  hl("WhichKeyValue",      { fg = p.grey1 })

  -- illuminate
  hl("IlluminatedWordText",  { bg = word_hl })
  hl("IlluminatedWordRead",  { bg = word_hl })
  hl("IlluminatedWordWrite", { bg = word_hl_strong })

  -- lazy.nvim
  hl("LazyNormal",       { fg = p.fg, bg = p.bg1 })
  hl("LazyButton",       { fg = p.fg, bg = p.bg2 })
  hl("LazyButtonActive", { fg = bg, bg = p.green })
  hl("LazyH1",           { fg = bg, bg = p.green, bold = true })
  hl("LazySpecial",      { fg = p.aqua })
  hl("LazyProgressDone", { fg = p.green })
  hl("LazyProgressTodo", { fg = p.bg3 })

  -- nvim-notify
  hl("NotifyERRORBorder", { fg = p.red })
  hl("NotifyWARNBorder",  { fg = p.yellow })
  hl("NotifyINFOBorder",  { fg = p.aqua })
  hl("NotifyDEBUGBorder", { fg = p.grey1 })
  hl("NotifyTRACEBorder", { fg = p.purple })
  hl("NotifyERRORIcon",   { fg = p.red })
  hl("NotifyWARNIcon",    { fg = p.yellow })
  hl("NotifyINFOIcon",    { fg = p.aqua })
  hl("NotifyDEBUGIcon",   { fg = p.grey1 })
  hl("NotifyTRACEIcon",   { fg = p.purple })
  hl("NotifyERRORTitle",  { fg = p.red, bold = true })
  hl("NotifyWARNTitle",   { fg = p.yellow, bold = true })
  hl("NotifyINFOTitle",   { fg = p.aqua, bold = true })
  hl("NotifyDEBUGTitle",  { fg = p.grey1, bold = true })
  hl("NotifyTRACETitle",  { fg = p.purple, bold = true })

  -- ----------------------------------------------------------
  -- 终端 ANSI（对齐 VSCode terminal.ansi*）
  -- ----------------------------------------------------------
  vim.g.terminal_color_0  = p.bg_dim
  vim.g.terminal_color_1  = p.red
  vim.g.terminal_color_2  = p.aqua
  vim.g.terminal_color_3  = p.yellow
  vim.g.terminal_color_4  = p.blue
  vim.g.terminal_color_5  = p.purple
  vim.g.terminal_color_6  = p.aqua
  vim.g.terminal_color_7  = p.grey2
  vim.g.terminal_color_8  = p.grey1
  vim.g.terminal_color_9  = p.red
  vim.g.terminal_color_10 = p.aqua
  vim.g.terminal_color_11 = p.yellow
  vim.g.terminal_color_12 = p.blue
  vim.g.terminal_color_13 = p.purple
  vim.g.terminal_color_14 = p.aqua
  vim.g.terminal_color_15 = p.fg

  -- 只暴露给喜爱 :set scrollbar 的新版本 Neovim（不存在时静默忽略）
  pcall(function()
    hl("ScrollbarHandle", { bg = scrollbar })
    hl("ScrollbarHandleHover", { bg = scrollbar_hover })
    hl("ScrollbarHandleActive", { bg = scrollbar_active })
  end)

  -- 让 :terminal 的默认配色也使用上面的 ANSI
  vim.g.terminal_color_background = bg
  vim.g.terminal_color_foreground = p.fg
end

-- ------------------------------------------------------------
-- 入口
-- ------------------------------------------------------------
if vim.g.colors_name then
  pcall(vim.cmd, "highlight clear")
end
if vim.fn.exists("syntax_on") == 1 then
  pcall(vim.cmd, "syntax reset")
end

vim.o.termguicolors = true
vim.o.background = "dark"  -- 目前只生成 hard 暗色，强制 dark 以免插件取到浅色推导值
vim.g.colors_name = "everforest"

apply()
