#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把 dotfiles/yasb/patches/ 里的模块注入 yasb 的 lib/library.zip。

为什么需要注入
--------------
yasb 用 cx_Freeze 打包，纯 Python 模块（core.*）都在 lib/library.zip 里，
而 WidgetBuilder 只会从 core.widgets.* 导入 widget 类：

    widget_module = import_module(f"core.widgets.{type 的前半段}")

所以「新增一个 widget 子类」没法放在用户目录里，只能往这个 zip 写文件。
patches/status_icons.py 就是这么用的（CPU/GPU/内存/WiFi 的图标变色）。

用法
----
    python install_patches.py             # 注入（幂等，内容相同则跳过）
    python install_patches.py --check     # 只看当前状态，不写文件
    python install_patches.py --restore   # 从 .orig-backup 还原原始 zip

注意
----
输出只用 ASCII：Windows 中文环境下控制台是 GBK，`✓` / `✗` 这类符号会让
print 直接 UnicodeEncodeError 崩掉（yasb 的 OBS 脚本踩过同一个坑）。
中文本身 GBK 能编码，可以保留。
scoop 升级 yasb 会换掉整个 apps/yasb/<版本>/ 目录，注入随之失效，
升级后重跑一次本脚本即可（首次运行会自动备份为 library.zip.orig-backup）。
"""

from __future__ import annotations

import argparse
import shutil
import sys
import zipfile
from pathlib import Path

PATCH_DIR = Path(__file__).resolve().parent
HOME = Path.home()
BACKUP_SUFFIX = ".orig-backup"

# patches 目录里的文件名 -> library.zip 内的路径
TARGETS = {
    "status_icons.py": "core/widgets/yasb/status_icons.py",
}


def find_zip(explicit: str | None) -> Path:
    if explicit:
        path = Path(explicit)
        if not path.exists():
            sys.exit(f"[ERROR] 指定的 zip 不存在: {path}")
        return path

    candidates = [
        HOME / "scoop" / "apps" / "yasb" / "current" / "lib" / "library.zip",
    ]
    for cand in candidates:
        if cand.exists():
            return cand
    sys.exit("[ERROR] 找不到 yasb 的 library.zip，请用 --zip 指定路径")


def load_modules() -> dict[str, bytes]:
    modules: dict[str, bytes] = {}
    for filename, zip_path in TARGETS.items():
        src = PATCH_DIR / filename
        if not src.exists():
            sys.exit(f"[ERROR] 源文件不存在: {src}")
        modules[zip_path] = src.read_bytes()
    return modules


def zip_entries(zip_path: Path) -> dict[str, bytes]:
    """只读出目标条目的内容，用于比较（避免整包解压）。"""
    found: dict[str, bytes] = {}
    with zipfile.ZipFile(zip_path) as z:
        names = set(z.namelist())
        for name in TARGETS.values():
            if name in names:
                found[name] = z.read(name)
    return found


def ensure_backup(zip_path: Path) -> Path | None:
    backup = zip_path.with_name(zip_path.name + BACKUP_SUFFIX)
    if not backup.exists():
        shutil.copy2(zip_path, backup)
        return backup
    return None


def inject(zip_path: Path, modules: dict[str, bytes]) -> str:
    """注入补丁。

    注意：yasb 运行时 library.zip 会被进程占用，无法整体替换（替换会被拒绝），
    所以这里一律用**追加**：zip 允许同名条目共存，而 zipimport 建立索引是顺序
    遍历 central directory，**后面的覆盖前面的**，因此追加的补丁版本会生效。
    反复重放会让包略微变大，用 --clean 可以整理（需先退出 yasb）。
    """
    existing = zip_entries(zip_path)

    # 已经注入且内容一致 -> 什么都不做
    if existing and all(existing.get(name) == data for name, data in modules.items()):
        return "unchanged"

    with zipfile.ZipFile(zip_path, "a", zipfile.ZIP_DEFLATED) as z:
        for name, data in modules.items():
            z.writestr(name, data)
    return "appended" if not existing else "updated"


def clean(zip_path: Path) -> str:
    """重写 zip，把同名旧条目去掉（需 yasb 已退出，否则替换会被拒绝）。"""
    modules = load_modules()
    tmp = zip_path.with_name(zip_path.name + ".tmp")
    with zipfile.ZipFile(zip_path) as zin, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            if item.filename in modules:
                continue
            zout.writestr(item, zin.read(item.filename))
        for name, data in modules.items():
            zout.writestr(name, data)
    tmp.replace(zip_path)
    return "cleaned"


def main() -> int:
    ap = argparse.ArgumentParser(description="注入 yasb widget 补丁到 lib/library.zip")
    ap.add_argument("--zip", help="library.zip 路径（默认自动探测 scoop 安装）")
    ap.add_argument("--check", action="store_true", help="只检查状态，不写文件")
    ap.add_argument("--restore", action="store_true", help="从 .orig-backup 还原")
    ap.add_argument("--clean", action="store_true", help="重写 zip 去除重复旧条目（需先退出 yasb）")
    args = ap.parse_args()

    zip_path = find_zip(args.zip)
    backup = zip_path.with_name(zip_path.name + BACKUP_SUFFIX)
    print(f"目标: {zip_path}")

    if args.restore:
        if not backup.exists():
            sys.exit(f"[ERROR] 没有备份文件: {backup}")
        shutil.copy2(backup, zip_path)
        print("[OK] 已从备份还原（注入的补丁已移除）")
        return 0

    modules = load_modules()

    if args.clean:
        try:
            print(f"[OK] {clean(zip_path)}")
        except PermissionError:
            sys.exit("[ERROR] 替换被拒绝，请先退出 yasb 再重试")
        return 0

    if args.check:
        existing = zip_entries(zip_path)
        healthy = True
        for name, data in modules.items():
            if name not in existing:
                print(f"  [MISSING] 未注入: {name}")
                healthy = False
            elif existing[name] == data:
                print(f"  [OK] 已注入且一致: {name}")
            else:
                print(f"  [STALE] 已注入但内容不同（需要重新注入）: {name}")
                healthy = False
        print(f"备份文件: {'存在' if backup.exists() else '不存在（首次注入会创建）'}")
        # 用退出码告知调用方（sync-dotfiles.ps1 会据此提示重放）
        return 0 if healthy else 1

    ensure_backup(zip_path)

    try:
        result = inject(zip_path, modules)
    except PermissionError:
        sys.exit("[ERROR] 写入被拒绝，请先退出 yasb 再重试")

    messages = {
        "unchanged": "已是最新，无需改动",
        "appended": "已注入",
        "updated": "已追加新版本（旧条目仍在，zipimport 优先用最新的）",
    }
    print(f"[OK] {messages[result]}")
    for name in modules:
        print(f"   -> {name}")
    print("   接着在 config.yaml 里把 type 换成 yasb.status_icons.*IconWidget，yasb 会自动重载。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
