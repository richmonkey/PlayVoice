"""
Database migration: create the `blocks` and `reports` tables.

Usage (from the backend/ directory):
    python scripts/migrate_add_block_report_tables.py
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from models import db, Block, Report  # noqa: E402

VERSION = 1
def main() -> None:
    db.connect(reuse_if_open=True)
    try:
        existing = set(db.get_tables())
        db.create_tables([Block, Report], safe=True)
        db.pragma("user_version", VERSION)        
        for table, model in (("blocks", Block), ("reports", Report)):
            status = "already existed" if table in existing else "created"
            print(f"[migrate] table '{table}' {status}")
    finally:
        if not db.is_closed():
            db.close()


if __name__ == "__main__":
    main()
