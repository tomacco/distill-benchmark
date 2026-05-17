#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: cleanup.sh <workspace-dir>}"

echo "[memory-compiler] Cleaning up..."
rm -rf "$WORKSPACE_DIR/knowledge"
rm -rf "$WORKSPACE_DIR/.claude"
echo "[memory-compiler] Cleanup complete."
