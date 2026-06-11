#!/usr/bin/env python
"""Build knowledge.db (SQLite FTS5, BM25) from a directory of markdown files.

Usage: python build_db.py <src_dir> <db_path>
Chunks each file by `## ` section; one FTS5 row per section.
Stdlib only.
"""
import os
import re
import sqlite3
import sys


def chunks(path):
    name = os.path.basename(path)
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    parts = re.split(r"(?m)^## ", text)
    head = parts[0].strip()
    title = head.splitlines()[0].lstrip("# ").strip() if head else name
    if len(parts) == 1:
        return [(name, title, text.strip())]
    out = []
    for part in parts[1:]:
        lines = part.splitlines()
        section = lines[0].strip()
        out.append((name, f"{title} / {section}", "## " + part.strip()))
    return out


def main(src_dir, db_path):
    if os.path.exists(db_path):
        os.remove(db_path)
    con = sqlite3.connect(db_path)
    con.execute("CREATE VIRTUAL TABLE kb USING fts5(file, section, content)")
    n = 0
    for fname in sorted(os.listdir(src_dir)):
        if fname.endswith(".md"):
            for row in chunks(os.path.join(src_dir, fname)):
                con.execute("INSERT INTO kb VALUES (?, ?, ?)", row)
                n += 1
    con.commit()
    con.close()
    print(f"[build_db] indexed {n} chunks into {db_path}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
