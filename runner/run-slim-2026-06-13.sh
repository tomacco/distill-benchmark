#!/usr/bin/env bash
# distill-slim head-to-head (2026-06-13): add the slim arm to all three existing seed dirs,
# then RE-RUN blind eval everywhere (the judge scores arms jointly, so adding an arm
# invalidates prior joint rankings) + aggregate. Idempotent on the collection side.
set -euo pipefail
cd "$(dirname "$0")/.."
export PATH="/c/Users/Ivan/AppData/Local/Microsoft/WinGet/Packages/jqlang.jq_Microsoft.Winget.Source_8wekyb3d8bbwe:$PATH"

for p in /c/Users/Ivan/.claude-tester /c/Users/Ivan/.claude-personal; do
    cp /c/Users/Ivan/.claude/.credentials.json "$p/.credentials.json"
done
echo "[creds] profiles refreshed"

for d in results/2026-06-12 results/2026-06-12-s2 results/2026-06-12-s3; do
    echo "===== COLLECT distill-slim into $d ====="
    RESULTS_DIR="$d" COMPETITORS="distill-slim" ./runner/resume-collection.sh
done

export CLAUDE_BIN=/c/Users/Ivan/.local/bin/claude.exe PYTHON_BIN=python EVAL_MODEL=opus
for d in results/2026-06-12 results/2026-06-12-s2 results/2026-06-12-s3; do
    # Resume-cheap: skip dirs ONLY when ALL 29 evals include the slim arm in the joint
    # ranking (probing one file is not enough — a limit-killed eval pass leaves a fresh/stale
    # mix, observed 2026-06-13: 5 fresh + 24 stale in one dir).
    fresh=0
    for f in "$d/scores/"*.json; do
        [ -f "$f" ] || continue
        jq -e '.label_mapping | to_entries | map(.value) | index("distill-slim")' "$f" >/dev/null 2>&1 && fresh=$((fresh+1))
    done
    if [ "$fresh" -eq 29 ]; then
        echo "===== SKIP EVAL $d (29/29 fresh slim-inclusive scores) ====="
        continue
    fi
    echo "($fresh/29 fresh in $d)"
    echo "===== RE-EVAL $d (joint ranking incl. slim) ====="
    ./runner/blind-eval.sh --results-dir "$d"
done

./runner/aggregate.sh
echo "ALL DONE"
