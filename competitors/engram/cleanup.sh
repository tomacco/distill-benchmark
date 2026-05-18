#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: cleanup.sh <workspace-dir>}"

echo "[engram] Cleaning up..."
rm -rf "$WORKSPACE_DIR/.claude"
echo "[engram] Cleanup complete."
