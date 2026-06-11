#!/usr/bin/env python
"""kb.py — search the knowledge base (SQLite FTS5 / BM25).

Usage: python kb.py search "<keywords>" [k]
Returns the top-k matching knowledge chunks (default k=5).
"""
import os
import re
import sqlite3
import sys

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")  # Windows defaults to cp1252; KB content is UTF-8

DB = os.path.join(os.path.dirname(os.path.abspath(__file__)), "knowledge.db")


def search(query, k=5):
    tokens = re.findall(r"[A-Za-z0-9_]+", query)
    if not tokens:
        print("NO QUERY TERMS")
        return
    match = " OR ".join(tokens)
    con = sqlite3.connect(DB)
    rows = con.execute(
        "SELECT file, section, content, bm25(kb) AS score "
        "FROM kb WHERE kb MATCH ? ORDER BY score LIMIT ?",
        (match, k),
    ).fetchall()
    con.close()
    if not rows:
        print("NO RESULTS — try different keywords")
        return
    for fname, section, content, score in rows:
        print(f"=== {fname} :: {section} (relevance {-score:.2f})")
        print(content.strip())
        print()


if __name__ == "__main__":
    if len(sys.argv) < 3 or sys.argv[1] != "search":
        print(__doc__)
        sys.exit(1)
    search(sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 5)
