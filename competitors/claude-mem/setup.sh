#!/usr/bin/env bash
set -euo pipefail

echo "[claude-mem] Setting up claude-mem (thedotmack/claude-mem)..."

# TODO: Verify these install commands work in practice.
# claude-mem requires Bun as its runtime.

# Check for bun
if ! command -v bun &>/dev/null; then
    echo "[claude-mem] ERROR: bun is not installed. Install via: curl -fsSL https://bun.sh/install | bash"
    echo "[claude-mem] Attempting to install bun..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi

# Install claude-mem globally via bun
# TODO: Verify this is the correct install command — check repo README
if ! command -v claude-mem &>/dev/null; then
    echo "[claude-mem] Installing claude-mem globally..."
    bun install -g claude-mem
else
    echo "[claude-mem] claude-mem already installed."
fi

# TODO: Verify ChromaDB dependency — may need separate install
# pip install chromadb or run as a service

echo "[claude-mem] Setup complete (verify with: claude-mem --version)"
