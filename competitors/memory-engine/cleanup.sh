#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: cleanup.sh <workspace-dir>}"

echo "[memory-engine] Cleaning up..."
rm -rf "$WORKSPACE_DIR/memory"
rm -rf "$WORKSPACE_DIR/.claude"
echo "[memory-engine] Cleanup complete."
