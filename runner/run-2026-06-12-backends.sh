#!/usr/bin/env bash
# Driver for the 2026-06-12 memory-backend comparison run (Windows 11 / Git Bash).
#
# Self-contained 4-way comparison (NOT merged with 2026-05 runs: different Claude
# version + default model would make cross-run scores incomparable):
#   no-memory        — control
#   distill          — aura-distill v1.1.4 (current main rules)
#   claude-md-native — same knowledge, native CLAUDE.md index, no protocol (prototype)
#   sqlite-bm25      — same knowledge behind a real FTS5/BM25 search CLI (prototype)
#
# Collection pinned to sonnet (within-run consistency, cost control);
# blind eval pinned to opus (stronger judge). Competitors run SEQUENTIALLY.
set -euo pipefail

export PATH="/c/Users/Ivan/AppData/Local/Microsoft/WinGet/Packages/jqlang.jq_Microsoft.Winget.Source_8wekyb3d8bbwe:$PATH"
export CLAUDE_BIN=/c/Users/Ivan/.local/bin/claude.exe
export PYTHON_BIN=python
export BENCH_MODEL=sonnet

cd "$(dirname "$0")/.."
RESULTS_DIR="results/2026-06-12"

for c in no-memory distill claude-md-native sqlite-bm25; do
    echo ""
    echo "############ COMPETITOR: $c ############"
    ./runner/run-benchmark.sh --competitor "$c" --results-dir "$RESULTS_DIR"
done

echo "Collection complete. Next: EVAL_MODEL=opus ./runner/blind-eval.sh --results-dir $RESULTS_DIR"
