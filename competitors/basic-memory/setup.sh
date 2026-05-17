#!/usr/bin/env bash
set -euo pipefail

echo "[basic-memory] Setting up basic-memory (basicmachines-co/basic-memory)..."

# TODO: Verify the correct package name on PyPI
# basic-memory requires Python 3.10+

if ! command -v python3 &>/dev/null; then
    echo "[basic-memory] ERROR: python3 not found."
    exit 1
fi

# Install via pipx for isolation (preferred) or pip
if command -v pipx &>/dev/null; then
    if ! pipx list 2>/dev/null | grep -q "basic-memory"; then
        echo "[basic-memory] Installing via pipx..."
        pipx install basic-memory
    else
        echo "[basic-memory] Already installed via pipx."
    fi
else
    echo "[basic-memory] pipx not found, falling back to pip..."
    pip install --user basic-memory 2>/dev/null || pip3 install --user basic-memory
fi

# TODO: Verify the binary name — might be `basic-memory` or `bmem` or similar
echo "[basic-memory] Setup complete. Verify with: basic-memory --version"
