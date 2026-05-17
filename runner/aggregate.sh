#!/usr/bin/env bash
# aggregate.sh — Aggregate blind eval scores into analysis/data.json
#
# Reads scores from results/<date>/scores/ and produces a single JSON file
# that the visualization page (analysis/index.html) consumes.
#
# Usage:
#   ./runner/aggregate.sh                          # Use latest results
#   ./runner/aggregate.sh --results-dir results/2026-05-17

set -euo pipefail

PROJ_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --results-dir|-r) RESULTS_DIR="$2"; shift 2 ;;
        -h|--help) echo "Usage: $0 [--results-dir DIR]"; exit 0 ;;
        *) echo "Unknown: $1" >&2; exit 1 ;;
    esac
done

if [ -z "$RESULTS_DIR" ]; then
    RESULTS_DIR=$(ls -dt "$PROJ_ROOT/results"/2* 2>/dev/null | head -1)
    [ -z "$RESULTS_DIR" ] && { echo "ERROR: No results found." >&2; exit 1; }
fi

SCORES_DIR="$RESULTS_DIR/scores"
RAW_DIR="$RESULTS_DIR/raw"
OUTPUT="$PROJ_ROOT/analysis/data.json"

echo "Aggregating from: $RESULTS_DIR"
echo "Output: $OUTPUT"

# Helper: get category from test ID
get_category() {
    case "${1:0:1}" in
        R) echo "retrieval" ;;
        C) echo "correction" ;;
        B) echo "bias" ;;
        U) echo "user-model" ;;
        P) echo "proportionality" ;;
        *) echo "unknown" ;;
    esac
}

# Build the data.json structure using Python for reliable JSON construction
python3 << 'PYTHON_SCRIPT'
import json
import os
import sys
from pathlib import Path

results_dir = os.environ.get('RESULTS_DIR', '')
if not results_dir:
    results_dir = sys.argv[1] if len(sys.argv) > 1 else ''

proj_root = Path(results_dir).parent.parent if results_dir else Path('.')
scores_dir = Path(results_dir) / 'scores'
raw_dir = Path(results_dir) / 'raw'
output_path = proj_root / 'analysis' / 'data.json'

def get_category(test_id):
    prefix = test_id[0]
    return {'R': 'retrieval', 'C': 'correction', 'B': 'bias', 'U': 'user-model', 'P': 'proportionality', 'D': 'persistence'}.get(prefix, 'unknown')

# Collect all scores
competitor_scores = {}  # {competitor: [{test_id, category, scores, avg_score}]}
latency_data = {}  # {competitor: [latency_ms values]}

# Read scored evaluations
if scores_dir.exists():
    for score_file in sorted(scores_dir.glob('*.json')):
        if score_file.name.endswith('_raw.json'):
            continue
        test_id = score_file.stem
        category = get_category(test_id)
        try:
            with open(score_file) as f:
                data = json.load(f)
        except (json.JSONDecodeError, IOError):
            continue

        label_mapping = data.get('label_mapping', {})
        scores = data.get('scores', {})

        for label, comp_id in label_mapping.items():
            if comp_id not in competitor_scores:
                competitor_scores[comp_id] = []

            label_scores = scores.get(label, {})
            # Extract numeric scores (skip 'notes' field)
            numeric_scores = {k: v for k, v in label_scores.items() if isinstance(v, (int, float))}
            avg = sum(numeric_scores.values()) / len(numeric_scores) if numeric_scores else 0

            competitor_scores[comp_id].append({
                'test_id': test_id,
                'category': category,
                'scores': numeric_scores,
                'avg_score': round(avg, 2)
            })

# Read raw results for latency/token data
if raw_dir.exists():
    for test_dir in sorted(raw_dir.iterdir()):
        if not test_dir.is_dir():
            continue
        for result_file in test_dir.glob('*.json'):
            comp_id = result_file.stem
            try:
                with open(result_file) as f:
                    data = json.load(f)
            except (json.JSONDecodeError, IOError):
                continue

            if comp_id not in latency_data:
                latency_data[comp_id] = {'latencies': [], 'token_counts': [], 'char_counts': [], 'versions': {}}

            latency_data[comp_id]['latencies'].append(data.get('latency_ms', 0))
            latency_data[comp_id]['token_counts'].append(data.get('output_length_tokens_approx', 0))
            latency_data[comp_id]['char_counts'].append(data.get('output_length_chars', 0))

            # Capture version info from first result that has it
            versions = data.get('versions', {})
            if versions and not latency_data[comp_id]['versions']:
                latency_data[comp_id]['versions'] = versions

# Compute latency aggregates
latency_agg = {}
for comp, vals in latency_data.items():
    lats = vals['latencies']
    tokens = vals['token_counts']
    latency_agg[comp] = {
        'avg': round(sum(lats) / len(lats)) if lats else 0,
        'min': min(lats) if lats else 0,
        'max': max(lats) if lats else 0,
        'avg_tokens': round(sum(tokens) / len(tokens)) if tokens else 0,
        'total_runs': len(lats),
        'version': vals.get('versions', {}).get('competitor', 'unknown')
    }

# Get metadata
summary_file = Path(results_dir) / 'summary.json'
metadata = {}
if summary_file.exists():
    try:
        with open(summary_file) as f:
            metadata = json.load(f)
    except (json.JSONDecodeError, IOError):
        pass

# Build output
output = {
    'metadata': {
        'timestamp': metadata.get('timestamp', ''),
        'total_runs': metadata.get('total_runs', 0),
        'competitors': list(set(list(competitor_scores.keys()) + list(latency_data.keys()))),
        'versions': {
            'benchmark': Path(proj_root, 'VERSION').read_text().strip() if Path(proj_root, 'VERSION').exists() else '0.1.0',
            'claude': next((v.get('versions', {}).get('claude', 'unknown') for v in latency_data.values() if v.get('versions', {}).get('claude')), 'unknown'),
            'competitors': {comp: vals.get('versions', {}).get('competitor', 'unknown') for comp, vals in latency_data.items()}
        }
    },
    'scores': competitor_scores,
    'latency': latency_agg
}

output_path.parent.mkdir(parents=True, exist_ok=True)
with open(output_path, 'w') as f:
    json.dump(output, f, indent=2)

print(f"Written: {output_path}")
print(f"Competitors: {', '.join(output['metadata']['competitors'])}")
print(f"Score entries: {sum(len(v) for v in competitor_scores.values())}")
print(f"Latency entries: {sum(v['total_runs'] for v in latency_agg.values())}")
PYTHON_SCRIPT
