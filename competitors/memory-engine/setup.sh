#!/usr/bin/env bash
set -euo pipefail

echo "[memory-engine] Setting up claude-memory-engine (HelloRuru/claude-memory-engine)..."

# memory-engine has zero external dependencies — it's just hooks + markdown.
# TODO: Verify if we need to clone the repo for hook scripts, or if we can
# replicate the behavior with just the file structure.

# TODO: May need to install hooks into Claude's hook directory:
# ~/.claude/hooks/ or similar
# For benchmark purposes, we inject the memory files directly.

echo "[memory-engine] No external dependencies required (zero-dep system)."
echo "[memory-engine] Setup complete."
