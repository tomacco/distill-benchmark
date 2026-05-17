#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: cleanup.sh <workspace-dir>}"

# Vanilla: nothing was injected, nothing to clean up.
echo "[vanilla] No cleanup required."
