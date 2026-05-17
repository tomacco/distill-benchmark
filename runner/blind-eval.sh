#!/usr/bin/env bash
# blind-eval.sh — Blind evaluation of benchmark results
#
# Reads raw outputs, shuffles and anonymizes them, sends to Claude
# with a scoring rubric, and stores scores as JSON.
#
# Usage:
#   ./runner/blind-eval.sh                          # Evaluate latest results
#   ./runner/blind-eval.sh --results-dir results/2026-05-17
#   ./runner/blind-eval.sh --test R1                # Only evaluate test R1

set -euo pipefail

PROJ_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER_DIR="$PROJ_ROOT/runner"

CLAUDE_BIN="node /opt/homebrew/opt/claude-code-npm/libexec/lib/node_modules/@anthropic-ai/claude-code/cli.js"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Defaults
RESULTS_DIR=""
FILTER_TEST=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --results-dir|-r)
            RESULTS_DIR="$2"
            shift 2
            ;;
        --test|-t)
            FILTER_TEST="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--results-dir DIR] [--test ID]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Find latest results dir if not specified
if [ -z "$RESULTS_DIR" ]; then
    RESULTS_DIR=$(ls -dt "$PROJ_ROOT/results"/2* 2>/dev/null | head -1)
    if [ -z "$RESULTS_DIR" ]; then
        echo -e "${RED}ERROR: No results found. Run the benchmark first.${NC}" >&2
        exit 1
    fi
fi

echo "========================================="
echo "       BLIND EVALUATION"
echo "========================================="
echo ""
echo "Results dir: $RESULTS_DIR"
echo ""

RAW_DIR="$RESULTS_DIR/raw"
SCORES_DIR="$RESULTS_DIR/scores"
mkdir -p "$SCORES_DIR"

# Delegate to Python worker (avoids bash 3 limitations with associative arrays)
export PROJ_ROOT RAW_DIR SCORES_DIR FILTER_TEST CLAUDE_BIN
python3 "$RUNNER_DIR/blind_eval_worker.py"
