#!/usr/bin/env python3
"""查询 OBS 录制状态，输出 YASB custom widget 所需的 JSON。

由 YASB 的 custom widget 通过 exec_options.run_cmd 周期调用。
未录制 / OBS 未运行时输出空字符串，配合 hide_empty: true 让整块 widget 隐藏。

前置条件：OBS 里「工具 > WebSocket 服务器设置」已勾选启用。
端口与密码从 OBS 自身的配置文件读取，不在此硬编码。
"""

from __future__ import annotations

import base64
import hashlib
import json
import socket
import sys
from pathlib import Path

# Windows 下 stdout 接管道（YASB 就是这么调用的）时默认用 GBK，
# 输出 ⏺ 之类的非 GBK 字符会直接 UnicodeEncodeError 并导致脚本崩溃、输出为空。
# 强制 UTF-8，与 YASB 那边的 output.decode("utf-8") 对齐。
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

OBS_WS_CONFIG = (
    Path.home()
    / "AppData" / "Roaming" / "obs-studio"
    / "plugin_config" / "obs-websocket" / "config.json"
)
# 超时要压得远小于 yasb 的 run_interval(1000ms)。
#
# 实测：这台机器上连接一个**已关闭**的本地端口要等约 2 秒才返回
# ConnectionRefused（SYN 被静默丢弃而非 RST）。若超时设成 2 秒，每次轮询
# 都跑不完就进入下一轮，旧的 worker 被 stop() 后不再 emit，widget 会永远
# 卡在最后一次成功的数据上（表现为“关掉 OBS 后组件还显示 IDLE”）。
TIMEOUT = 0.4          # websocket 握手/读取超时
PROBE_TIMEOUT = 0.3    # 端口预检超时


def load_obs_config() -> tuple[str, int, str]:
    """从 OBS 的 obs-websocket 配置里取 host / port / password。"""
    try:
        raw = json.loads(OBS_WS_CONFIG.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return "127.0.0.1", 4455, ""
    return (
        "127.0.0.1",
        int(raw.get("server_port") or 4455),
        raw.get("server_password") or "",
    )


def build_auth(password: str, salt: str, challenge: str) -> str:
    """obs-websocket 5.x 的认证串：base64(sha256(base64(sha256(pwd+salt)) + challenge))"""
    secret = base64.b64encode(hashlib.sha256((password + salt).encode()).digest())
    return base64.b64encode(
        hashlib.sha256(secret + challenge.encode()).digest()
    ).decode()


def request(ws, request_type: str, request_id: str = "req") -> dict:
    """发送一次 OpCode 6 请求，等待对应的 OpCode 7 响应。"""
    ws.send(json.dumps({
        "op": 6,
        "d": {"requestType": request_type, "requestId": request_id},
    }))
    while True:
        msg = json.loads(ws.recv())
        if msg.get("op") == 7 and (msg.get("d") or {}).get("requestId") == request_id:
            return (msg["d"].get("responseData") or {})


def connect(host: str, port: int, password: str):
    """建立并完成 Identify 握手，返回已就绪的 websocket 连接。"""
    import websocket  # websocket-client

    ws = websocket.create_connection(f"ws://{host}:{port}", timeout=TIMEOUT)
    hello = json.loads(ws.recv())
    identify = {"op": 1, "d": {"rpcVersion": 1}}
    auth = (hello.get("d") or {}).get("authentication")
    if auth:
        identify["d"]["authentication"] = build_auth(
            password, auth["salt"], auth["challenge"]
        )
    ws.send(json.dumps(identify))
    ws.recv()  # OpCode 2: Identified
    return ws


def format_duration(ms: float) -> str:
    total = int(ms // 1000)
    hours, rem = divmod(total, 3600)
    minutes, seconds = divmod(rem, 60)
    return f"{hours}:{minutes:02d}:{seconds:02d}" if hours else f"{minutes:02d}:{seconds:02d}"


def port_open(host: str, port: int) -> bool:
    """先快速探一下端口，避免 OBS 已关闭时白等一整轮 websocket 超时。"""
    try:
        with socket.create_connection((host, port), timeout=PROBE_TIMEOUT):
            return True
    except OSError:
        return False


def fetch_status() -> dict | None:
    """连上 OBS 取录制状态；任何失败都返回 None（视为未录制）。"""
    host, port, password = load_obs_config()
    if not port_open(host, port):
        return None
    try:
        ws = connect(host, port, password)
    except Exception:
        return None
    try:
        return request(ws, "GetRecordStatus", "status")
    except Exception:
        return None
    finally:
        try:
            ws.close()
        except Exception:
            pass


def main() -> int:
    """输出纯文本（配合 config 里的 return_format: string）。

    --idle  空闲态：OBS 在运行但没录制时输出 IDLE（用于可点击的“开始录制”组件）
    默认     录制态：录制中输出 "REC 00:12" / "PAUSE 00:12"，其余情况输出空

    两种情况在 **连不上 OBS** 时都输出空字符串，配合 hide_empty 把组件隐藏。
    另外这里 **不能** 用 JSON 模式：空输出会让 exec_data 变成 None，
    而 None 参与 str.format 会抛异常，YASB 的 except 分支反而把
    '{data[text]}' 这个字面量显示到状态栏上（hide_empty 也会被跳过）。
    """
    idle_mode = "--idle" in sys.argv[1:]
    status = fetch_status()

    if status is None:
        print("")            # OBS 没开 / WebSocket 没启用 → 组件隐藏
        return 0

    active = bool(status.get("outputActive"))
    if idle_mode:
        print("" if active else "IDLE")
        return 0

    if not active:
        print("")
        return 0

    duration = format_duration(status.get("outputDuration", 0))
    paused = bool(status.get("outputPaused"))
    # 只用 ASCII：Windows 中文环境下管道输出默认是 GBK，非 GBK 字符会直接让脚本崩溃
    print(f"{'PAUSE' if paused else 'REC'} {duration}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
