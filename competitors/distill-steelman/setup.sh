#!/usr/bin/env bash
set -euo pipefail

# distill: knowledge files are injected directly into the workspace.
# No external dependencies needed — it's just markdown files + rules.
echo "[distill] No external install required — uses .claude/rules/ and knowledge/ files."
