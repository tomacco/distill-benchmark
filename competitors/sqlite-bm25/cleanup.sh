#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: cleanup.sh <workspace-dir>}"

rm -f "$WORKSPACE_DIR/kb.py" "$WORKSPACE_DIR/knowledge.db"
rm -f "$WORKSPACE_DIR/.claude/rules/kb-search.md"
rmdir "$WORKSPACE_DIR/.claude/rules" 2>/dev/null || true
rmdir "$WORKSPACE_DIR/.claude" 2>/dev/null || true

echo "[sqlite-bm25] Cleaned up"
