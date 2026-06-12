#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: inject.sh <workspace-dir>}"
COMP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[claude-md-native] Injecting CLAUDE.md index + memory files into $WORKSPACE_DIR"

mkdir -p "$WORKSPACE_DIR/memory"
cp "$COMP_DIR/knowledge-src/"*.md "$WORKSPACE_DIR/memory/"

cat > "$WORKSPACE_DIR/CLAUDE.md" << 'INDEX_EOF'
# Project Memory

Knowledge about this user, their company, and past decisions lives in `memory/`.
Read the relevant file BEFORE answering anything it covers.

| Topic | File |
|-------|------|
| Architecture & stack | `memory/architecture.md` |
| Team & people | `memory/team.md` |
| User preferences (style, tooling) | `memory/preferences.md` |
| Decisions & corrections (⛔ = non-negotiable) | `memory/decisions.md` |
| Project state & timeline | `memory/state.md` |

When the user announces an action, check the relevant file for constraints first.

**Output rules**: Concise: default to bullets and code. No filler preambles ("Great question!"). Uncertainty: say "I'm not sure" directly. Keep explanations short — user reads code faster than prose.
**Interaction rules**: Terse input = terse output. Don't ask what you can infer from context. When corrected, apply immediately — no "good point" acknowledgment needed.
INDEX_EOF

echo "[claude-md-native] Injected: CLAUDE.md + 5 memory files"
