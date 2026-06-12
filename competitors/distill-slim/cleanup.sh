#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: cleanup.sh <workspace-dir>}"

rm -f "$WORKSPACE_DIR/CLAUDE.md"
rm -rf "$WORKSPACE_DIR/memory"

echo "[claude-md-native] Cleaned up"
