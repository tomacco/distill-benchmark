#!/usr/bin/env bash
# run-benchmark.sh — Main benchmark orchestrator
#
# Runs all (or selected) competitors through all (or selected) tests,
# collecting output and metadata for blind evaluation.
#
# Usage:
#   ./runner/run-benchmark.sh                           # Run everything
#   ./runner/run-benchmark.sh --competitor vanilla      # Only vanilla
#   ./runner/run-benchmark.sh --test R1                 # Only test R1
#   ./runner/run-benchmark.sh --competitor distill --test R1  # One combo
#   ./runner/run-benchmark.sh --dry-run                 # Show what would run
#   ./runner/run-benchmark.sh --list                    # List available tests/competitors

set -euo pipefail

PROJ_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER_DIR="$PROJ_ROOT/runner"

# Source canonical isolation library from aura-distill
CANONICAL_ISOLATE="$HOME/git/tomaccos/aura-distill/tests/lib/isolate.sh"
if [ -f "$CANONICAL_ISOLATE" ]; then
    source "$CANONICAL_ISOLATE"
else
    echo "ERROR: Canonical isolation library not found at $CANONICAL_ISOLATE" >&2
    echo "Falling back to local isolation library." >&2
    source "$RUNNER_DIR/lib/isolate.sh"
fi

# Source benchmark-specific libraries
source "$RUNNER_DIR/lib/inject.sh"
source "$RUNNER_DIR/lib/collect.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Defaults
FILTER_COMPETITOR=""
FILTER_TEST=""
DRY_RUN=0
LIST_MODE=0
RESULTS_DIR="$PROJ_ROOT/results/$(date +%Y-%m-%d)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --competitor|-c)
            FILTER_COMPETITOR="$2"
            shift 2
            ;;
        --test|-t)
            FILTER_TEST="$2"
            shift 2
            ;;
        --dry-run|-n)
            DRY_RUN=1
            shift
            ;;
        --list|-l)
            LIST_MODE=1
            shift
            ;;
        --results-dir)
            RESULTS_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--competitor ID] [--test ID] [--dry-run] [--list]"
            echo ""
            echo "Options:"
            echo "  --competitor, -c ID   Run only this competitor"
            echo "  --test, -t ID         Run only this test (e.g. R1, C2, B3)"
            echo "  --dry-run, -n         Show what would run without executing"
            echo "  --list, -l            List available tests and competitors"
            echo "  --results-dir DIR     Override results directory"
            echo "  -h, --help            Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Discover all test files
discover_tests() {
    local tests_dir="$PROJ_ROOT/tests"
    for category_dir in "$tests_dir"/*/; do
        [ -d "$category_dir" ] || continue
        local category
        category=$(basename "$category_dir")
        # Skip non-category dirs (seed-knowledge.md is a file, not dir)
        for test_file in "$category_dir"/*.md; do
            [ -f "$test_file" ] || continue
            local test_id
            test_id=$(basename "$test_file" .md)
            echo "$test_id|$category|$test_file"
        done
    done | sort
}

# Extract prompt from test file (content between ## Prompt and next ##)
extract_prompt() {
    local test_file="$1"
    sed -n '/^## Prompt$/,/^## /{/^## Prompt$/d;/^## /d;p;}' "$test_file" | sed 's/^[[:space:]]*//' | sed '/^$/d'
}

# Extract context section and write to temp file (returns path, or empty)
extract_context() {
    local test_file="$1"
    local context
    context=$(sed -n '/^## Context$/,/^## /{/^## Context$/d;/^## /d;p;}' "$test_file" | sed '/^$/d')

    if [ -z "$context" ] || [ "$context" = "None" ] || [ "$context" = "None." ]; then
        echo ""
        return
    fi

    local ctx_file
    ctx_file=$(mktemp /tmp/benchmark-context-XXXXXXXX.md)
    echo "$context" > "$ctx_file"
    echo "$ctx_file"
}

# List mode
if [ "$LIST_MODE" -eq 1 ]; then
    echo "=== Available Competitors ==="
    list_competitors | while read -r c; do
        echo "  $c"
    done
    echo ""
    echo "=== Available Tests ==="
    discover_tests | while IFS='|' read -r test_id category _; do
        echo "  $test_id ($category)"
    done
    exit 0
fi

# Gather what to run
COMPETITORS=()
if [ -n "$FILTER_COMPETITOR" ]; then
    COMPETITORS=("$FILTER_COMPETITOR")
else
    while IFS= read -r c; do
        COMPETITORS+=("$c")
    done < <(list_competitors)
fi

TESTS=()
TEST_CATEGORIES=()
TEST_FILES=()
while IFS='|' read -r test_id category test_file; do
    if [ -n "$FILTER_TEST" ] && [ "$test_id" != "$FILTER_TEST" ]; then
        continue
    fi
    TESTS+=("$test_id")
    TEST_CATEGORIES+=("$category")
    TEST_FILES+=("$test_file")
done < <(discover_tests)

TOTAL_RUNS=$(( ${#COMPETITORS[@]} * ${#TESTS[@]} ))

echo "========================================="
echo "       DISTILL BENCHMARK RUNNER"
echo "========================================="
echo ""
echo "Competitors: ${COMPETITORS[*]}"
echo "Tests:       ${#TESTS[@]} (${TESTS[*]})"
echo "Total runs:  $TOTAL_RUNS"
echo "Results dir: $RESULTS_DIR"
echo ""

if [ "$DRY_RUN" -eq 1 ]; then
    echo "[DRY RUN] Would execute:"
    for comp in "${COMPETITORS[@]}"; do
        for i in "${!TESTS[@]}"; do
            echo "  $comp × ${TESTS[$i]} (${TEST_CATEGORIES[$i]})"
        done
    done
    echo ""
    echo "Total: $TOTAL_RUNS runs"
    exit 0
fi

if [ ${#COMPETITORS[@]} -eq 0 ]; then
    echo -e "${RED}ERROR: No competitors found. Run setup first.${NC}" >&2
    exit 1
fi
if [ ${#TESTS[@]} -eq 0 ]; then
    echo -e "${RED}ERROR: No tests found. Write test files first.${NC}" >&2
    exit 1
fi

# Pre-flight checks
if ! command -v jq &>/dev/null; then
    echo -e "${RED}ERROR: jq is required but not installed.${NC}" >&2
    exit 1
fi

# Main execution loop
RUN_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

echo "Starting benchmark..."
echo ""

# Begin isolation (strips all personal context, sets up neutral workspace)
isolate_begin
# The canonical library sets its own EXIT trap, but we add our own messaging
trap 'isolate_end; echo -e "\n${YELLOW}Interrupted — configs restored.${NC}"' INT TERM

for comp in "${COMPETITORS[@]}"; do
    echo -e "${BLUE}=== Competitor: $comp ===${NC}"

    for i in "${!TESTS[@]}"; do
        test_id="${TESTS[$i]}"
        category="${TEST_CATEGORIES[$i]}"
        test_file="${TEST_FILES[$i]}"
        RUN_COUNT=$((RUN_COUNT + 1))

        echo -n "  [$RUN_COUNT/$TOTAL_RUNS] $test_id ($category)... "

        # Create per-run workspace (fresh each time to prevent cross-contamination)
        workspace=$(mktemp -d /tmp/benchmark-workspace-XXXXXXXX)
        echo "# Neutral benchmark workspace" > "$workspace/README.md"

        # Inject competitor knowledge into workspace
        if ! inject_competitor "$comp" "$workspace" 2>/dev/null; then
            echo -e "${RED}INJECT FAILED${NC}"
            FAIL_COUNT=$((FAIL_COUNT + 1))
            rm -rf "$workspace"
            continue
        fi

        # Extract prompt and context
        prompt=$(extract_prompt "$test_file")
        context_file=$(extract_context "$test_file")

        # Run and collect
        output_json="$RESULTS_DIR/raw/$test_id/${comp}.json"

        if collect_run "$workspace" "$prompt" "$context_file" "$output_json" "$comp" "$test_id"; then
            echo -e "${GREEN}OK${NC} ($(jq -r '.latency_ms' "$output_json")ms, $(jq -r '.output_length_chars' "$output_json") chars)"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo -e "${YELLOW}TIMEOUT/ERROR${NC}"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi

        # Cleanup
        cleanup_competitor "$comp" "$workspace" 2>/dev/null || true
        rm -rf "$workspace"
        [ -n "$context_file" ] && rm -f "$context_file"

        # Clear any rules that may have leaked into REAL_CONFIG during inject
        rm -f "$REAL_CONFIG/rules/distill.md" 2>/dev/null || true
    done
    echo ""
done

# Restore all configs
isolate_end

echo "========================================="
echo "         BENCHMARK COMPLETE"
echo "========================================="
echo ""
echo -e "  Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "  Failed: ${RED}$FAIL_COUNT${NC}"
echo -e "  Total:  $TOTAL_RUNS"
echo ""
echo "Results: $RESULTS_DIR/raw/"
echo ""

# Write summary
mkdir -p "$RESULTS_DIR"
jq -n \
    --arg date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --argjson total "$TOTAL_RUNS" \
    --argjson passed "$PASS_COUNT" \
    --argjson failed "$FAIL_COUNT" \
    --arg competitors "$(IFS=,; echo "${COMPETITORS[*]}")" \
    --arg tests "$(IFS=,; echo "${TESTS[*]}")" \
    '{
        timestamp: $date,
        total_runs: $total,
        passed: $passed,
        failed: $failed,
        competitors: ($competitors | split(",")),
        tests: ($tests | split(","))
    }' > "$RESULTS_DIR/summary.json"

echo "Summary written to $RESULTS_DIR/summary.json"
