#!/usr/bin/env bash
# isolate.sh — Backup/strip/restore functions for test isolation
#
# Sources by run-benchmark.sh. Not meant to be run standalone.

set -euo pipefail

REAL_CONFIG="$HOME/.claude-personal"
GLOBAL_CONFIG="$HOME/.claude"

# Backup all configs that could influence Claude's behavior
isolate_backup() {
    local tag="${1:-benchmark}"

    # Global config
    cp "$GLOBAL_CONFIG/CLAUDE.md" "$GLOBAL_CONFIG/CLAUDE.md.${tag}-bak" 2>/dev/null || true
    [ -d "$GLOBAL_CONFIG/rules" ] && mv "$GLOBAL_CONFIG/rules" "$GLOBAL_CONFIG/_rules_${tag}_bak"
    [ -d "$GLOBAL_CONFIG/distill" ] && mv "$GLOBAL_CONFIG/distill" "$GLOBAL_CONFIG/_distill_${tag}_bak"
    [ -d "$GLOBAL_CONFIG/plugins" ] && mv "$GLOBAL_CONFIG/plugins" "$GLOBAL_CONFIG/_plugins_${tag}_bak"

    # Personal config
    cp "$REAL_CONFIG/settings.json" "$REAL_CONFIG/settings.json.${tag}-bak" 2>/dev/null || true
    [ -d "$REAL_CONFIG/rules" ] && mv "$REAL_CONFIG/rules" "$REAL_CONFIG/_rules_${tag}_bak"
    [ -d "$REAL_CONFIG/distill" ] && mv "$REAL_CONFIG/distill" "$REAL_CONFIG/_distill_${tag}_bak"
    [ -d "$REAL_CONFIG/plugins" ] && mv "$REAL_CONFIG/plugins" "$REAL_CONFIG/_plugins_${tag}_bak"
}

# Strip all knowledge — leave only auth tokens
isolate_strip() {
    # Blank global CLAUDE.md
    echo "" > "$GLOBAL_CONFIG/CLAUDE.md"

    # Strip customInstructions and enabledPlugins from settings.json
    if [ -f "$REAL_CONFIG/settings.json" ] && command -v jq &>/dev/null; then
        jq 'del(.customInstructions) | del(.enabledPlugins)' "$REAL_CONFIG/settings.json" \
            > "$REAL_CONFIG/settings.json.tmp" \
            && mv "$REAL_CONFIG/settings.json.tmp" "$REAL_CONFIG/settings.json"
    fi
}

# Restore all configs from backup
isolate_restore() {
    local tag="${1:-benchmark}"

    # Global config
    [ -f "$GLOBAL_CONFIG/CLAUDE.md.${tag}-bak" ] && \
        mv "$GLOBAL_CONFIG/CLAUDE.md.${tag}-bak" "$GLOBAL_CONFIG/CLAUDE.md"
    [ -d "$GLOBAL_CONFIG/_rules_${tag}_bak" ] && \
        mv "$GLOBAL_CONFIG/_rules_${tag}_bak" "$GLOBAL_CONFIG/rules"
    [ -d "$GLOBAL_CONFIG/_distill_${tag}_bak" ] && \
        mv "$GLOBAL_CONFIG/_distill_${tag}_bak" "$GLOBAL_CONFIG/distill"
    [ -d "$GLOBAL_CONFIG/_plugins_${tag}_bak" ] && \
        mv "$GLOBAL_CONFIG/_plugins_${tag}_bak" "$GLOBAL_CONFIG/plugins"

    # Personal config
    [ -f "$REAL_CONFIG/settings.json.${tag}-bak" ] && \
        mv "$REAL_CONFIG/settings.json.${tag}-bak" "$REAL_CONFIG/settings.json"
    [ -d "$REAL_CONFIG/_rules_${tag}_bak" ] && \
        mv "$REAL_CONFIG/_rules_${tag}_bak" "$REAL_CONFIG/rules"
    [ -d "$REAL_CONFIG/_distill_${tag}_bak" ] && \
        mv "$REAL_CONFIG/_distill_${tag}_bak" "$REAL_CONFIG/distill"
    [ -d "$REAL_CONFIG/_plugins_${tag}_bak" ] && \
        mv "$REAL_CONFIG/_plugins_${tag}_bak" "$REAL_CONFIG/plugins"
}

# Create a neutral working directory
isolate_create_workspace() {
    mktemp -d /tmp/benchmark-workspace-XXXX
}

# Clean up workspace
isolate_cleanup_workspace() {
    local workspace="$1"
    [ -d "$workspace" ] && rm -rf "$workspace"
}
