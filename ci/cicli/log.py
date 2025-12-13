# SPDX-License-Identifier: Apache-2.0 OR MIT

"""
Log configuration and formatting utilities.
"""

import logging
import sys


def configure_logger(level: str = "info") -> None:
    """
    Configure the root logger.
    """

    formatter = _ColoredFormatter(use_color=sys.stderr.isatty())
    handler = logging.StreamHandler(sys.stderr)
    handler.setFormatter(formatter)

    root_logger = logging.getLogger()
    list(map(root_logger.removeHandler, root_logger.handlers[:]))
    list(map(root_logger.removeFilter, root_logger.filters[:]))

    root_logger.addHandler(handler)
    root_logger.setLevel(_conv_log_level(level))


def _conv_log_level(level: str) -> int:
    """
    Convert a log level string to an integer.
    """

    return {
        "d": logging.DEBUG,
        "i": logging.INFO,
        "w": logging.WARNING,
        "e": logging.ERROR,
        "c": logging.CRITICAL,
    }[level[0]]


class _ColoredFormatter(logging.Formatter):
    """
    Colored log formatter.
    """

    _RESET = "\033[0m"
    _BOLD = "\033[1m"
    _DIM = "\033[2m"

    _LEVEL_COLORS = {
        logging.DEBUG: "\033[36m",  # Cyan
        logging.INFO: "\033[32m",  # Green
        logging.WARNING: "\033[33m",  # Yellow
        logging.ERROR: "\033[31m",  # Red
        logging.CRITICAL: "\033[35m",  # Magenta
    }

    def __init__(self, use_color=False):
        super().__init__()
        self.use_color = use_color

    def format(self, record):
        if not self.use_color:
            return f"{self._formatTime(record)} [{record.levelname[0]}] {record.getMessage()}"

        level_color = _ColoredFormatter._LEVEL_COLORS.get(record.levelno, self._RESET)
        return (
            f"{self._DIM}{self._formatTime(record)}{self._RESET} "
            f"{level_color}{self._BOLD}[{record.levelname[0]}]{self._RESET} "
            f"{record.getMessage()}"
        )

    def _formatTime(self, record):
        ct = self.converter(record.created)
        return f"{ct.tm_year:04d}-{ct.tm_mon:02d}-{ct.tm_mday:02d} {ct.tm_hour:02d}:{ct.tm_min:02d}:{ct.tm_sec:02d}"
