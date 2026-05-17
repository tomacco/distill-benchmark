#!/usr/bin/env bash
set -euo pipefail

echo "[knowledge-graph] Setting up mcp-knowledge-graph (shaneholloman/mcp-knowledge-graph)..."

# TODO: Verify the correct npm package name
# Requires Node.js 18+

if ! command -v node &>/dev/null; then
    echo "[knowledge-graph] ERROR: node not found."
    exit 1
fi

# TODO: Verify if this is published to npm or needs to be cloned
# Option 1: npm global install
if ! command -v mcp-knowledge-graph &>/dev/null; then
    echo "[knowledge-graph] Installing mcp-knowledge-graph..."
    npm install -g @shaneholloman/mcp-knowledge-graph 2>/dev/null || \
    npm install -g mcp-knowledge-graph 2>/dev/null || \
    echo "[knowledge-graph] WARNING: npm install failed — may need manual install from repo"
else
    echo "[knowledge-graph] Already installed."
fi

# TODO: May need to configure MCP server in Claude's settings
# This would go in ~/.claude/settings.json or similar

echo "[knowledge-graph] Setup complete (verify MCP server availability)."
