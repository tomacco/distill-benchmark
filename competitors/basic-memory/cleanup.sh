#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: cleanup.sh <workspace-dir>}"

echo "[basic-memory] Cleaning up..."
rm -rf "$WORKSPACE_DIR/vault"
rm -rf "$WORKSPACE_DIR/.claude"
echo "[basic-memory] Cleanup complete."
