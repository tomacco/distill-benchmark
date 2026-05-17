#!/usr/bin/env bash
# collect.sh — Output capture and metadata collection
#
# Sourced by run-benchmark.sh. Not meant to be run standalone.

set -euo pipefail

CLAUDE_BIN="node /opt/homebrew/opt/claude-code-npm/libexec/lib/node_modules/@anthropic-ai/claude-code/cli.js"
TIMEOUT_SECONDS=120

# Detect Claude Code version (cached)
_CLAUDE_VERSION=""
get_claude_version() {
    if [ -z "$_CLAUDE_VERSION" ]; then
        _CLAUDE_VERSION=$($CLAUDE_BIN --version 2>/dev/null | head -1 || echo "unknown")
    fi
    echo "$_CLAUDE_VERSION"
}

# Run Claude with a prompt, capture output + metadata
# Usage: collect_run <workspace> <prompt> <system_prompt_file> <output_json> [<competitor_id>] [<test_id>]
collect_run() {
    local workspace="$1"
    local prompt="$2"
    local system_prompt_file="$3"  # empty string if none
    local output_json="$4"
    local competitor_id="${5:-}"
    local test_id="${6:-}"

    local output_file
    output_file=$(mktemp /tmp/benchmark-out.XXXXXXXXXX)
    local start_time end_time latency_ms exit_code=0

    # Build command
    local cmd_args=(
        --dangerously-skip-permissions
        -p "$prompt"
    )
    if [ -n "$system_prompt_file" ] && [ -f "$system_prompt_file" ]; then
        cmd_args+=(--append-system-prompt-file "$system_prompt_file")
    fi

    start_time=$(python3 -c 'import time; print(int(time.time()*1000))')

    # Run with isolation env vars and timeout
    (
        cd "$workspace" && \
        CLAUDE_CONFIG_DIR="$HOME/.claude-personal" \
        CLAUDE_CODE_USE_BEDROCK=0 \
        ANTHROPIC_DEFAULT_OPUS_MODEL= \
        ANTHROPIC_DEFAULT_SONNET_MODEL= \
        ANTHROPIC_DEFAULT_HAIKU_MODEL= \
        ANTHROPIC_MODEL= \
        AWS_PROFILE= AWS_ACCESS_KEY_ID= AWS_SECRET_ACCESS_KEY= \
        AWS_SESSION_TOKEN= AWS_DEFAULT_REGION= \
        AWS_SHARED_CREDENTIALS_FILE=/dev/null AWS_CONFIG_FILE=/dev/null \
        $CLAUDE_BIN "${cmd_args[@]}" > "$output_file" 2>/dev/null
    ) &
    local pid=$!
    ( sleep "$TIMEOUT_SECONDS" && kill "$pid" 2>/dev/null ) &
    local wd=$!
    wait "$pid" || exit_code=$?
    kill "$wd" 2>/dev/null || true
    wait "$wd" 2>/dev/null || true

    end_time=$(python3 -c 'import time; print(int(time.time()*1000))')
    latency_ms=$((end_time - start_time))

    # Read output
    local output_text=""
    if [ -s "$output_file" ]; then
        output_text=$(cat "$output_file")
    fi
    local output_length=${#output_text}
    # Rough token estimate: ~4 chars per token
    local output_tokens_approx=$((output_length / 4))

    # Get competitor version from VERSION file if it exists
    local comp_version="unknown"
    local proj_root
    proj_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    if [ -n "$competitor_id" ] && [ -f "$proj_root/competitors/$competitor_id/VERSION" ]; then
        comp_version=$(cat "$proj_root/competitors/$competitor_id/VERSION")
    fi

    # Write JSON result with version metadata
    mkdir -p "$(dirname "$output_json")"
    jq -n \
        --arg output "$output_text" \
        --arg prompt "$prompt" \
        --argjson latency "$latency_ms" \
        --argjson exit_code "$exit_code" \
        --argjson output_length "$output_length" \
        --argjson output_tokens "$output_tokens_approx" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg competitor_id "$competitor_id" \
        --arg test_id "$test_id" \
        --arg competitor_version "$comp_version" \
        --arg claude_version "$(get_claude_version)" \
        --arg benchmark_version "$(cat "$proj_root/VERSION" 2>/dev/null || echo '0.1.0')" \
        '{
            test_id: $test_id,
            competitor_id: $competitor_id,
            prompt: $prompt,
            output: $output,
            timestamp: $timestamp,
            latency_ms: $latency,
            exit_code: $exit_code,
            output_length_chars: $output_length,
            output_length_tokens_approx: $output_tokens,
            versions: {
                competitor: $competitor_version,
                claude: $claude_version,
                benchmark: $benchmark_version
            }
        }' > "$output_json"

    # Clean up
    rm -f "$output_file"

    # Return exit code (0 = success, non-zero = timeout or error)
    return $exit_code
}
