#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: cleanup.sh <workspace-dir>}"

echo "[distill] Cleaning up injected knowledge from $WORKSPACE_DIR"

rm -rf "$WORKSPACE_DIR/.claude/rules/distill.md"
rm -rf "$WORKSPACE_DIR/knowledge"

# Remove .claude/rules dir if empty
rmdir "$WORKSPACE_DIR/.claude/rules" 2>/dev/null || true
rmdir "$WORKSPACE_DIR/.claude" 2>/dev/null || true

echo "[distill] Cleanup complete."
