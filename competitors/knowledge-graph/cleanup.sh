#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: cleanup.sh <workspace-dir>}"

echo "[knowledge-graph] Cleaning up..."
rm -rf "$WORKSPACE_DIR/knowledge-graph"
rm -rf "$WORKSPACE_DIR/.claude"
echo "[knowledge-graph] Cleanup complete."
