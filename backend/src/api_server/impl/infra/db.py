import os
import sqlite3
from pathlib import Path

from api_server.impl.persistence import MIGRATION_ROOT
from api_server.impl.utils import logger_from_env

logger = logger_from_env("db")


def get_db(
    db_path: str | os.PathLike = os.getenv("DB_PATH", "mouni.db"),
    migrations_dir: str | os.PathLike = MIGRATION_ROOT,
) -> sqlite3.Connection:
    """
    Create (or open) a SQLite database, apply migrations, and return the connection.

    Args:
        db_path: Path to the SQLite database file.
        migrations_dir: Path to directory containing migration SQL files.

    Returns:
        sqlite3.Connection object.
    """
    logger.info(f"Connecting to DB file: {db_path}")

    # Ensure the migrations directory exists
    migrations_dir = Path(migrations_dir)
    if not migrations_dir.is_dir():
        raise FileNotFoundError(f"Migrations directory not found: {migrations_dir}")

    db_path = Path(db_path)
    if (
        db_path.exists()
        and not migrations_dir.is_file()
        and not db_path.suffix == ".db"
    ):
        raise ValueError(f"Invalid db path: {db_path}")

    if not db_path.parent.exists():
        db_path.parent.mkdir(exist_ok=True, parents=True)

    # Connect to SQLite DB (will create file if missing)
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row

    conn.execute("PRAGMA foreign_keys = ON")

    # Create a table to track applied migrations
    conn.execute("""
    CREATE TABLE IF NOT EXISTS schema_migrations (
        filename TEXT PRIMARY KEY,
        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)
    conn.commit()

    # Get set of already applied migrations
    applied = set(
        row["filename"]
        for row in conn.execute("SELECT filename FROM schema_migrations")
    )

    # List all migration files (e.g., 001_init.sql, 002_add_expenses.sql)
    migration_files = sorted(f for f in migrations_dir.glob("*.sql"))

    for mig_file in migration_files:
        if mig_file.name in applied:
            continue  # Skip already applied migrations

        with mig_file.open("r", encoding="utf-8") as f:
            sql = f.read()

        logger.info(f"Applying migration: {mig_file.name}")
        try:
            conn.executescript(sql)
            conn.execute(
                "INSERT INTO schema_migrations(filename) VALUES (?)", (mig_file.name,)
            )
            conn.commit()
        except sqlite3.Error as e:
            conn.rollback()
            raise RuntimeError(f"Failed to apply migration {mig_file}: {e}") from e

    return conn
