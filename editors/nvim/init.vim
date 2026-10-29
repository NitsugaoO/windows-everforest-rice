" ============================================================
" 统一 Neovim 配置 —— Windows / WSL / dojo 服务器共用这一份
" 配色：Everforest Hard（colors/everforest.lua，由 generator/gen_nvim.py 生成）
" ============================================================

" ===== 基础显示 =====
set termguicolors
set background=dark
syntax enable

" ===== Everforest =====
colorscheme everforest

" ===== 汇编构建：全部走 as + ld（不经过 gcc） =====
augroup AsmBuild
  autocmd!

  " as 的报错格式：file.s:8: Error: ambiguous operand size for `mov'
  autocmd FileType asm setlocal errorformat=%f:%l:\ %m,%f:%l:%c:\ %m

  " 直接 :make → 构建 file.so
  autocmd FileType asm setlocal makeprg=~/bin/asmb\ %

  " \b ：保存并构建 .so（as + ld -shared）
  autocmd FileType asm nnoremap <buffer> <leader>b :w<CR>:setlocal makeprg=~/bin/asmb\ %<CR>:make<CR>

  " \x ：保存并构建可执行文件（as + ld -o，需要 .global _start）
  autocmd FileType asm nnoremap <buffer> <leader>x :w<CR>:setlocal makeprg=~/bin/asmb\ -x\ %<CR>:make<CR>

  " \r ：运行当前文件对应的可执行文件
  autocmd FileType asm nnoremap <buffer> <leader>r :!%:r<CR>
augroup END

" ===== Alt+↑/↓ 移动行（类似 VSCode）=====
" Normal 模式：移动当前行，并保持缩进
nnoremap <M-Up>   :m .-2<CR>
nnoremap <M-Down> :m .+1<CR>

" Insert 模式：移动后回到插入位置
inoremap <M-Up>   <Esc>:m .-2<CR>gi
inoremap <M-Down> <Esc>:m .+1<CR>gi

" Visual 模式：移动选中的整块，保持选中
vnoremap <M-Up>   :m '<-2<CR>gv
vnoremap <M-Down> :m '>+1<CR>gv

" 兼容一部分终端：Alt+方向键被发成 ESC + 方向键
" （如果下面这两条导致 Esc 后按方向键异常，可删掉）
nnoremap <Esc><Up>   :m .-2<CR>
nnoremap <Esc><Down> :m .+1<CR>
