# -*- coding: utf-8 -*-
"""把 yasb 内置 widget 的「阈值状态色」从文字挪到图标上。

为什么需要它
------------
yasb 内置 widget 里，状态 class 挂的位置并不统一：

    组件          挂在哪        源码
    ----------    ----------    ----------------------------------
    电池          图标 QLabel   battery.py:199  -> "icon status-high"
    CPU/GPU/内存  文字 QLabel   cpu.py:188      -> "label status-high"

Qt 样式表（QSS）没有兄弟选择器、父选择器和伪元素，所以 CSS 层面无法
「看到文字上的状态，再去给旁边的图标上色」。想要「只有图标变色、数字保持
米白」就只能覆写 _update_label，把 class 也挂到图标上（并手动 refresh）。

安装方式
--------
yasb 用 cx_Freeze 打包，纯 Python 模块都在 lib/library.zip 里。本文件由同目录
的 install_patches.py 注入到：

    <yasb>/lib/library.zip  ->  core/widgets/yasb/status_icons.py

config.yaml 里把 type 换成 yasb.status_icons.*IconWidget 即可。
scoop 升级 yasb 后 library.zip 会被覆盖，重跑 install_patches.py 就能恢复。

状态语义
--------
CPU / GPU / 内存（数值越高越糟，阈值见 config.yaml）：
    low 绿 / medium 黄 / high 橙 / critical 红

WiFi：
    ok           有连接且有 Internet        -> 绿
    no-internet  有连接但没有 Internet      -> 红
    off          没有任何活动连接（关 WiFi）-> 灰
"""

from __future__ import annotations

import logging

from core.utils.utilities import refresh_widget_style
from core.widgets.yasb.cpu import CpuWidget
from core.widgets.yasb.gpu import GpuWidget
from core.widgets.yasb.memory import MemoryWidget
from core.widgets.yasb.wifi import WifiWidget

logger = logging.getLogger("status_icons")


def _set_icon_status(labels, status: str) -> None:
    """给 class 含 icon 的 QLabel 挂上 status-{status}，其余 class 原样保留。

    与 yasb 自己的 _set_device_state_classes 同一手法：setProperty 之后必须
    调 refresh_widget_style，否则 Qt 不会重新应用样式表（issue #142 那类问题）。
    """
    for label in labels:
        classes = (label.property("class") or "").split()
        if "icon" not in classes:
            continue
        kept = [c for c in classes if not c.startswith("status-")]
        new_class = " ".join(kept + [f"status-{status}"])
        if label.property("class") != new_class:
            label.setProperty("class", new_class)
            refresh_widget_style(label)


def _labels_of(widget, *names) -> tuple:
    """安全地收集 widget 上若干 label 列表（属性不存在时当作空）。"""
    collected = []
    for name in names:
        collected.extend(getattr(widget, name, None) or [])
    return tuple(collected)


class CpuIconWidget(CpuWidget):
    """CPU 负载：图标随 cpu_thresholds 变色，数字保持米白。"""

    def _update_label(self, data):
        super()._update_label(data)
        _set_icon_status(
            _labels_of(self, "_widgets", "_widgets_alt"),
            self._get_cpu_threshold(data.percent),
        )


class GpuIconWidget(GpuWidget):
    """GPU 利用率：图标随 gpu_thresholds 变色。"""

    def _update_label(self, gpu_data):
        super()._update_label(gpu_data)
        _set_icon_status(
            _labels_of(self, "_widgets", "_widgets_alt"),
            self._get_gpu_threshold(gpu_data.utilization),
        )


class MemoryIconWidget(MemoryWidget):
    """内存占用：图标随 memory_thresholds 变色（阈值按占用率判定）。"""

    def _update_label(self, virtual_mem, swap_mem):
        super()._update_label(virtual_mem, swap_mem)
        _set_icon_status(
            _labels_of(self, "_widgets", "_widgets_alt"),
            self._get_virtual_memory_threshold(virtual_mem.percent),
        )


class WifiIconWidget(WifiWidget):
    """WiFi 三态：图标变色（有网绿 / 无外网红 / 无连接灰）。"""

    _last_status: str | None = None  # 仅在状态变化时记一行日志，便于排查

    def _update_label(self):
        super()._update_label()
        status = self._connectivity_status()
        if status != WifiIconWidget._last_status:
            logger.info("wifi state -> %s", status)
            WifiIconWidget._last_status = status
        _set_icon_status(
            _labels_of(
                self,
                "_widgets",
                "_widgets_alt",
                "_widgets_ethernet",
                "_widgets_ethernet_alt",
            ),
            status,
        )

    @staticmethod
    def _connectivity_status() -> str:
        """用 WinRT 的连接级别判定三态（不发包，毫秒级）。

        yasb 自带的 WiFiWorker 只认 INTERNET_ACCESS 的连接，因此「关掉 WiFi」和
        「连上路由器但没外网」在它眼里都是 "Disconnected"，分不开。这里改看所有
        连接 profile 的 NetworkConnectivityLevel 数值：

            INTERNET_ACCESS (3)      -> ok            绿
            LOCAL/CONSTRAINED (1,2)  -> no-internet   红
            没有 profile 或全是 0    -> off           灰

        只依赖 INTERNET_ACCESS 这个枚举名（yasb 自己的 wifi_managers.py 也在用它），
        其余分支直接用数值比较，避免枚举成员改名导致属性错误。
        """
        try:
            from winrt.windows.networking.connectivity import (
                NetworkConnectivityLevel,
                NetworkInformation,
            )

            internet_level = int(NetworkConnectivityLevel.INTERNET_ACCESS)
            levels = [
                int(profile.get_network_connectivity_level())
                for profile in NetworkInformation.get_connection_profiles()
            ]
        except Exception as exc:  # WinRT 不可用时按「无连接」处理（灰）
            logger.debug("connectivity probe failed: %s", exc)
            return "off"

        logger.debug("connectivity levels: %s", levels)

        if internet_level in levels:
            return "ok"
        if not levels or not any(levels):
            return "off"
        return "no-internet"
