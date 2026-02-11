import logging
import os
from logging import Formatter, Logger, StreamHandler


def create_logger(name: str, level: str | int = logging.INFO) -> Logger:
    """
    Create a basic logger with the given name and level.
    Level can be a logging.Level enum or a string ("DEBUG", "INFO", etc.)
    """
    logger = logging.getLogger(name)

    if isinstance(level, str):
        level = level.upper()
        level = getattr(logging, level, logging.INFO)

    logger.setLevel(level)

    if not logger.handlers:
        handler = StreamHandler()
        handler.setFormatter(
            Formatter("[%(asctime)s] %(levelname)s %(name)s - %(message)s")
        )
        logger.addHandler(handler)

    return logger


def logger_from_env(name: str, env_var: str = "LOG_LEVEL") -> Logger:
    """
    Create a logger where the level is taken from an environment variable.
    Defaults to INFO if env var not set or invalid.
    """
    level = os.environ.get(env_var, "INFO")
    return create_logger(name, level)


def setup_uvicorn_logger() -> None:
    """
    Returns a logger to replace the uvicorn original logger and have consistent logging
    """
    logger = logger_from_env("uvicorn.override")

    logger.handlers.clear()

    handler = StreamHandler()
    handler.setFormatter(Formatter("[%(asctime)s] %(levelname)s - %(message)s"))
    logger.addHandler(handler)

    # Replace Uvicorn internal loggers with the same handler
    for name in ["uvicorn", "uvicorn.error", "uvicorn.access"]:
        ulogger = logging.getLogger(name)
        ulogger.handlers.clear()
        ulogger.propagate = False
        for h in logger.handlers:
            ulogger.addHandler(h)
        ulogger.setLevel(logger.level)
