# ==================== pwndbg context 自动分屏 ====================
# 布局:左边主 pane(程序输入输出 + pwndbg 命令行),
#       右边一列 4 个 pane,从上到下 BACKTRACE / STACK / REGS / DISASM
#
# 支持情况:
#   tmux 会话内      → 自动分屏(推荐;在 Windows Terminal 里跑 tmux 即可)
#   Windows Terminal → 由于 WSL interop 启动的 wt.exe 无法定位"当前窗口",
#                      从 WSL 内部自动 split 会开出新窗口,故默认不做。
#                      可行做法:
#                        (a) 手动在 WT 里分好 4 个 pane,各跑 ~/.gdb-ctx/pane.sh <section>,
#                            再在 gdb 里执行 ctx-attach;
#                        (b) 给 WT profile 配 windowName,然后
#                            export PWNDBG_CTX_WT_WINDOW=<窗口名> 并执行 ctx-split
#
# 禁用:export PWNDBG_NO_CTX_SPLIT=1
# 命令:ctx-split(分屏)/ ctx-attach(接上已有的 pane)/ ctx-kill(清理)
python
import atexit, os, subprocess, time, gdb

_CTX_DIR = os.path.expanduser("~/.gdb-ctx")
_CTX_PANE_SH = os.path.join(_CTX_DIR, "pane.sh")
_DEVNULL = subprocess.DEVNULL
_CTX_SECTIONS = ("backtrace", "stack", "regs", "disasm")
_PANE_SH_BODY = """#!/bin/bash
sec="${1:?usage: pane.sh <section> <watch_pid> [timeout]}"
watch="${2:-0}"
tmo="${3:-0}"
mkdir -p "$HOME/.gdb-ctx"
tty > "$HOME/.gdb-ctx/$sec"
printf '\\033]2;%s\\007' "${sec^^}"
echo "${WT_SESSION:-}" > "$HOME/.gdb-ctx/$sec.session"
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
"""

if not hasattr(gdb, "_pwndbg_ctx_panes"):
    gdb._pwndbg_ctx_panes = []
_ctx_panes = gdb._pwndbg_ctx_panes


def _ensure_pane_sh():
    os.makedirs(_CTX_DIR, exist_ok=True)
    cur = ""
    if os.path.exists(_CTX_PANE_SH):
        try:
            cur = open(_CTX_PANE_SH).read()
        except OSError:
            cur = ""
    if not cur:  # 已存在(dotfiles 部署的)则不动
        with open(_CTX_PANE_SH, "w") as f:
            f.write(_PANE_SH_BODY)
        os.chmod(_CTX_PANE_SH, 0o755)


def _ctx_output_all(pairs):
    from pwndbg.commands.context import contextoutput
    for sec, tty in pairs:
        contextoutput(sec, tty, True, "top")


def _read_tty(sec, max_age=6 * 3600):
    """读 pane.sh 登记过的 tty;太旧或已失效的忽略"""
    p = os.path.join(_CTX_DIR, sec)
    try:
        if time.time() - os.path.getmtime(p) > max_age:
            return None
        tty = open(p).read().strip()
    except OSError:
        return None
    return tty if tty and os.path.exists(tty) else None


def _ctx_wait_tty(timeout=20.0):
    got = {}
    deadline = time.time() + timeout
    while time.time() < deadline and len(got) < len(_CTX_SECTIONS):
        time.sleep(0.2)
        for sec in _CTX_SECTIONS:
            if sec not in got and (tty := _read_tty(sec, max_age=60)):
                got[sec] = tty
    return [(s, got[s]) for s in _CTX_SECTIONS if s in got]


def ctx_attach_panes(verbose=True):
    """接上 ~/.gdb-ctx 下已登记(新鲜)的 tty —— 手动分屏场景用"""
    pairs = [(s, t) for s in _CTX_SECTIONS if (t := _read_tty(s))]
    if pairs:
        _ctx_output_all(pairs)
        if verbose:
            print("[ctx-attach] 已接上 %d 个 pane: %s"
                  % (len(pairs), ", ".join(s for s, _ in pairs)))
    elif verbose:
        print("[ctx-attach] 没有发现可用的 pane 登记(先在各 pane 里跑 pane.sh)")
    return pairs


# ---------------- tmux:左主 + 右列 4 个 ----------------
def _ctx_tmux(*args):
    out = subprocess.check_output(
        ["tmux", "split-window", "-P", "-F", "#{pane_id}:#{pane_tty}", "-d", *args, "cat -"],
        text=True, stderr=_DEVNULL,
    ).strip()
    return out.split(":", 1)


def _ctx_split_tmux():
    r = _ctx_tmux("-h", "-l", "35%")             # 右侧那一列
    s = _ctx_tmux("-v", "-t", r[0], "-l", "75%")  # 右列内从上往下切
    t = _ctx_tmux("-v", "-t", s[0], "-l", "67%")
    u = _ctx_tmux("-v", "-t", t[0], "-l", "50%")
    layout = {"backtrace": r, "stack": s, "regs": t, "disasm": u}
    _ctx_output_all([(sec, p[1]) for sec, p in layout.items()])
    _ctx_panes.extend(p[0] for p in layout.values())
    print("[ctx-split] tmux:context 已分到 4 个 pane(左主 + 右列)")


# ---------------- Windows Terminal:需要已知窗口名 ----------------
_WT_LAYOUT = [
    ("backtrace", ["-V", "--size", "0.35"]),
    ("stack",     ["-H", "--size", "0.75"]),
    ("regs",      ["-H", "--size", "0.67"]),
    ("disasm",    ["-H", "--size", "0.5"]),
]


def _ctx_split_wt():
    win = os.environ.get("PWNDBG_CTX_WT_WINDOW")
    if not win:
        print("[ctx-split] 未设置 PWNDBG_CTX_WT_WINDOW。")
        print("           从 WSL 内部调 wt.exe 无法定位当前窗口(-w 0/last/GUID 都会新开窗口),")
        print("           这是 WSL interop 的限制。请改用:")
        print("             1) 在 WT 里跑 tmux —— gdb 会自动分屏(推荐)")
        print("             2) 手动分好 pane 后执行 ctx-attach")
        print("             3) 给 WT profile 配 windowName 后 export PWNDBG_CTX_WT_WINDOW=<名字>")
        return
    _ensure_pane_sh()
    distro = os.environ.get("WSL_DISTRO_NAME", "Ubuntu-24.04")
    pid = str(os.getpid())
    for sec, split_args in _WT_LAYOUT:
        try:
            os.remove(os.path.join(_CTX_DIR, sec))
        except OSError:
            pass
        args = (["wt.exe", "-w", win, "split-pane"] + split_args +
                ["wsl.exe", "-d", distro, "--", "bash", _CTX_PANE_SH, sec, pid])
        try:
            subprocess.Popen(args, stdout=_DEVNULL, stderr=_DEVNULL)
        except Exception as e:
            print("[ctx-split] 调用 wt.exe 失败:", e)
            return
    pairs = _ctx_wait_tty()
    _ctx_output_all(pairs)
    print("[ctx-split] Windows Terminal:context 已分到 %d 个 pane" % len(pairs))


# ---------------- 分派 ----------------
def _ctx_split():
    if _ctx_panes:
        print("[ctx-split] 已经分过屏了,先 ctx-kill 再重试")
        return
    try:
        import pwndbg.commands.context  # noqa: F401
    except Exception as e:
        print("[ctx-split] pwndbg 未就绪:", e)
        return
    if os.environ.get("TMUX"):
        _ctx_split_tmux()
    elif os.environ.get("WT_SESSION") or os.environ.get("PWNDBG_CTX_WT_WINDOW"):
        _ctx_split_wt()
    else:
        print("[ctx-split] 当前既不在 tmux 也不是 Windows Terminal 会话,无法分屏")


def _ctx_kill():
    n = len(_ctx_panes)
    while _ctx_panes:
        pane = _ctx_panes.pop()
        subprocess.run(["tmux", "kill-pane", "-t", pane],
                       stdout=_DEVNULL, stderr=_DEVNULL)
    if n:
        print("[ctx-kill] 已清理 %d 个 tmux pane" % n)


atexit.register(_ctx_kill)


class _CtxSplitCmd(gdb.Command):
    """分屏:tmux 下自动;WT 下需 PWNDBG_CTX_WT_WINDOW"""
    def __init__(self):
        super().__init__("ctx-split", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        _ctx_split()


class _CtxAttachCmd(gdb.Command):
    """接上各 pane 里 pane.sh 登记过的 tty"""
    def __init__(self):
        super().__init__("ctx-attach", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        ctx_attach_panes()


class _CtxKillCmd(gdb.Command):
    """关闭由 ctx-split 打开的 tmux panes"""
    def __init__(self):
        super().__init__("ctx-kill", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        _ctx_kill()


for _cls in (_CtxSplitCmd, _CtxAttachCmd, _CtxKillCmd):
    try:
        _cls()
    except Exception:
        pass

if os.isatty(0) and os.environ.get("PWNDBG_NO_CTX_SPLIT") != "1":
    if os.environ.get("TMUX"):
        _ctx_split_tmux()
    elif os.environ.get("WT_SESSION"):
        # WT:优先接上手动开好的 pane;没有就安静地什么都不做
        ctx_attach_panes(verbose=False)
end
# ==================== /pwndbg context 分屏 ====================
