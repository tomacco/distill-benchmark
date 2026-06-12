#!/usr/bin/env bash
# Morning rerun, post-adversarial-review design: 1 full seed (4 arms) + 2 extra seeds of the
# critical pair (distill vs claude-md-native), then blind eval (opus) per seed dir + aggregate.
# Idempotent: re-invoke after any failure; completed cells are skipped.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "===== SWEEP 1/3: full 4-way, seed 1 ====="
RESULTS_DIR="results/2026-06-12" ./runner/resume-collection.sh

echo "===== SWEEP 2/3: critical pair, seed 2 ====="
RESULTS_DIR="results/2026-06-12-s2" COMPETITORS="distill claude-md-native" ./runner/resume-collection.sh

echo "===== SWEEP 3/3: critical pair, seed 3 ====="
RESULTS_DIR="results/2026-06-12-s3" COMPETITORS="distill claude-md-native" ./runner/resume-collection.sh

echo "===== BLIND EVAL (opus judge) ====="
export CLAUDE_BIN=/c/Users/Ivan/.local/bin/claude.exe PYTHON_BIN=python EVAL_MODEL=opus
for d in results/2026-06-12 results/2026-06-12-s2 results/2026-06-12-s3; do
    ./runner/blind-eval.sh --results-dir "$d"
done

echo "===== AGGREGATE (seed-1 dir only; cross-seed variance computed separately) ====="
./runner/aggregate.sh

echo "ALL DONE"
