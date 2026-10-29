#!/usr/bin/env python3
"""YASB 上 OBS 组件的点击动作。

用法：
    obs_action.py left    未录制 → 开始录制；录制中 → 暂停 / 恢复
    obs_action.py right   录制中 → 停止录制，然后在资源管理器里打开录像目录并选中最新文件；
                          未录制 → 只打开录像目录

依赖同目录的 obs_status.py 提供的配置读取、认证与请求封装。
OBS 未运行（连不上 WebSocket）时静默返回，不弹任何错误。
"""

from __future__ import annotations

import subprocess
import sys
import time
from pathlib import Path

from obs_status import connect, load_obs_config, request

# 停止录制后等一会儿再打开目录，给 OBS 留出写完 moov 的时间
STOP_SETTLE_SECONDS = 1.5


def get_record_dir() -> Path | None:
    """从 OBS 的 profile 配置（basic.ini 的 RecFilePath）里读出录像输出目录。"""
    profiles = (
        Path.home() / "AppData" / "Roaming" / "obs-studio"
        / "basic" / "profiles"
    )
    for ini in profiles.glob("*/basic.ini"):
        try:
            text = ini.read_text(encoding="utf-8-sig", errors="ignore")
        except OSError:
            continue
        for line in text.splitlines():
            if line.startswith("RecFilePath="):
                raw = line.split("=", 1)[1].strip().strip('"')
                if raw:
                    return Path(raw)
    return None


def open_record_folder(select_latest: bool = True) -> None:
    """在资源管理器里打开录像目录；select_latest 为真时顺带选中最新的 mp4。"""
    folder = get_record_dir()
    if not folder or not folder.exists():
        return

    target = None
    if select_latest:
        mp4s = sorted(
            folder.glob("*.mp4"),
            key=lambda p: p.stat().st_mtime,
            reverse=True,
        )
        if mp4s:
            target = mp4s[0]

    if target:
        subprocess.Popen(f'explorer /select,"{target}"')
    else:
        subprocess.Popen(f'explorer "{folder}"')


def main() -> int:
    action = sys.argv[1].lower() if len(sys.argv) > 1 else "left"
    host, port, password = load_obs_config()

    try:
        ws = connect(host, port, password)
    except Exception:
        return 1  # OBS 没开 / websocket 没启用：静默失败

    try:
        status = request(ws, "GetRecordStatus", "before")
        active = bool(status.get("outputActive"))

        if action == "left":
            if active:
                request(ws, "ToggleRecordPause", "act")  # 暂停 / 恢复
            else:
                request(ws, "StartRecord", "act")        # 开始录制
        elif action == "right":
            if active:
                request(ws, "StopRecord", "act")
                time.sleep(STOP_SETTLE_SECONDS)          # 等文件写完
            open_record_folder(select_latest=active)
    except Exception:
        return 1
    finally:
        try:
            ws.close()
        except Exception:
            pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
