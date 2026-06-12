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
    # Resume-cheap: skip dirs whose 29 evals already include the slim arm in the joint
    # ranking (i.e. were produced AFTER slim collection). Pre-slim evals lack the label.
    n=$(ls "$d/scores/"*.json 2>/dev/null | wc -l)
    probe=$(ls "$d/scores/"*.json 2>/dev/null | head -1)
    if [ "$n" -eq 29 ] && [ -n "$probe" ] && \
       jq -e '.label_mapping | to_entries | map(.value) | index("distill-slim")' "$probe" >/dev/null 2>&1; then
        echo "===== SKIP EVAL $d (29 fresh slim-inclusive scores) ====="
        continue
    fi
    echo "===== RE-EVAL $d (joint ranking incl. slim) ====="
    ./runner/blind-eval.sh --results-dir "$d"
done

./runner/aggregate.sh
echo "ALL DONE"
