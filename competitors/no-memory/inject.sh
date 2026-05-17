#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: inject.sh <workspace-dir>}"

# Vanilla: no knowledge injection. That's the whole point.
echo "[vanilla] No knowledge to inject — baseline mode."
