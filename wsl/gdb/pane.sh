#!/bin/bash
# pwndbg context 接收 pane —— 把自己的 tty 登记给 gdb,pwndbg 的分区输出就会送到这里。
#
# 用法: pane.sh <section> [watch_pid] [timeout_seconds]
#   section     backtrace / stack / regs / disasm
#   watch_pid   可选;填了就在该进程消失后自动退出(让终端 pane 自己关掉)
#   timeout     可选;秒数,0 或省略 = 不超时
#
# 权威源: my_dot/dotfiles/wsl/gdb/pane.sh (由 sync-dotfiles.ps1 部署)
sec="${1:?usage: pane.sh <section> [watch_pid] [timeout]}"
watch="${2:-0}"
tmo="${3:-0}"

mkdir -p "$HOME/.gdb-ctx"
tty > "$HOME/.gdb-ctx/$sec"
printf '\033]2;%s\007' "${sec^^}"                       # pane 标题 = 大写的 section 名
echo "${WT_SESSION:-}" > "$HOME/.gdb-ctx/$sec.session"  # 记录所在 WT 会话,便于排查窗口问题

if [ "$watch" != "0" ]; then
    (
        while kill -0 "$watch" 2>/dev/null; do sleep 1; done
        kill -TERM "$$" 2>/dev/null
    ) &
fi

if [ "$tmo" != "0" ]; then
    exec timeout "$tmo" cat
fi
exec cat
