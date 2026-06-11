#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: inject.sh <workspace-dir>}"
COMP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_BIN="${PYTHON_BIN:-$(command -v python || command -v python3)}"

echo "[sqlite-bm25] Injecting knowledge DB into $WORKSPACE_DIR"

mkdir -p "$WORKSPACE_DIR/.claude/rules"

# Search tool + FTS5 database built from knowledge-src (sources NOT copied into the
# workspace — the CLI is the only access path to the knowledge).
cp "$COMP_DIR/kb.py" "$WORKSPACE_DIR/kb.py"
"$PYTHON_BIN" "$COMP_DIR/build_db.py" "$COMP_DIR/knowledge-src" "$WORKSPACE_DIR/knowledge.db"

cat > "$WORKSPACE_DIR/.claude/rules/kb-search.md" << 'RULES_EOF'
# Knowledge Base — search before answering

You have a persistent knowledge base about this user, their company, team, preferences, and
past decisions. It is ONLY accessible through this command (run from the workspace root):

    python kb.py search "<keywords>"

RULES:
1. BEFORE answering anything that touches the user's company, project, stack, team,
   preferences, or past decisions: run at least one search with relevant keywords.
2. When the user announces an action ("I'm deploying X", "creating a service"):
   search for constraints about that action FIRST.
3. Results marked ⛔ are non-negotiable corrections. Never violate them.
4. Trust the knowledge base over your assumptions. If results are empty, retry once with
   different keywords, then proceed honestly.
RULES_EOF

echo "[sqlite-bm25] Injected: kb.py + knowledge.db + rules"
