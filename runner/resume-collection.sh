#!/usr/bin/env bash
# Idempotent collection resume for the 2026-06-12 backend-comparison run.
# Re-runs ONLY missing or failed (exit!=0 / empty / rate-limited) test×competitor pairs,
# so it can be invoked repeatedly across rate-limit windows until the set is complete.
# Aborts the sweep immediately if the session limit is still active (exit 2).
set -euo pipefail

export PATH="/c/Users/Ivan/AppData/Local/Microsoft/WinGet/Packages/jqlang.jq_Microsoft.Winget.Source_8wekyb3d8bbwe:$PATH"
export CLAUDE_BIN=/c/Users/Ivan/.local/bin/claude.exe
export PYTHON_BIN=python
export BENCH_MODEL=sonnet

cd "$(dirname "$0")/.."
RD="results/2026-06-12"

ok() {
    # valid result: exit 0, substantive output, not a rate-limit message
    jq -e '.exit_code == 0 and (.output | length > 100) and ((.output | test("hit your session limit")) | not)' "$1" >/dev/null 2>&1
}

missing=0
for c in no-memory distill claude-md-native sqlite-bm25; do
    for t in tests/*/*.md; do
        id=$(basename "$t" .md)
        f="$RD/raw/$id/$c.json"
        if [ -f "$f" ] && ok "$f"; then
            continue
        fi
        missing=$((missing+1))
        echo ">>> [$c/$id] running"
        ./runner/run-benchmark.sh --competitor "$c" --test "$id" --results-dir "$RD" || true
        if [ -f "$f" ] && jq -e '.output | test("hit your session limit")' "$f" >/dev/null 2>&1; then
            echo "!!! SESSION LIMIT STILL ACTIVE — aborting sweep (re-run after reset)"
            exit 2
        fi
        if [ ! -f "$f" ] || ! ok "$f"; then
            echo "!!! [$c/$id] still invalid after retry (non-limit failure) — continuing"
        fi
    done
done

echo "COLLECTION COMPLETE ($missing pairs were (re)run this sweep)"
