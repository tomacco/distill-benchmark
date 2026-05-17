#!/usr/bin/env bash
# inject.sh — Competitor injection logic
#
# Sourced by run-benchmark.sh. Not meant to be run standalone.

set -euo pipefail

PROJ_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Inject a competitor's knowledge into the workspace and config
# Usage: inject_competitor <competitor_id> <workspace>
inject_competitor() {
    local competitor_id="$1"
    local workspace="$2"
    local inject_script="$PROJ_ROOT/competitors/$competitor_id/inject.sh"

    if [ ! -f "$inject_script" ]; then
        echo "ERROR: No inject.sh found for competitor '$competitor_id'" >&2
        return 1
    fi

    bash "$inject_script" "$workspace"
}

# Clean up a competitor's injected knowledge
# Usage: cleanup_competitor <competitor_id> <workspace>
cleanup_competitor() {
    local competitor_id="$1"
    local workspace="$2"
    local cleanup_script="$PROJ_ROOT/competitors/$competitor_id/cleanup.sh"

    if [ ! -f "$cleanup_script" ]; then
        echo "ERROR: No cleanup.sh found for competitor '$competitor_id'" >&2
        return 1
    fi

    bash "$cleanup_script" "$workspace"
}

# Run setup for a competitor (idempotent install)
# Usage: setup_competitor <competitor_id>
setup_competitor() {
    local competitor_id="$1"
    local setup_script="$PROJ_ROOT/competitors/$competitor_id/setup.sh"

    if [ ! -f "$setup_script" ]; then
        echo "ERROR: No setup.sh found for competitor '$competitor_id'" >&2
        return 1
    fi

    bash "$setup_script"
}

# Get list of all competitors with valid configs
list_competitors() {
    local competitors_dir="$PROJ_ROOT/competitors"
    for dir in "$competitors_dir"/*/; do
        local id
        id=$(basename "$dir")
        if [ -f "$dir/inject.sh" ] && [ -f "$dir/cleanup.sh" ]; then
            echo "$id"
        fi
    done
}
