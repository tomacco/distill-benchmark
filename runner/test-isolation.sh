#!/bin/bash
# test-isolation.sh — Verify that the isolation protocol prevents config leakage.
#
# This script:
# 1. Strips all knowledge/rules/instructions from both config trees
# 2. Runs Claude with a prompt designed to surface any leaked context
# 3. Restores everything
# 4. Analyzes the output for signs of leakage
#
# Usage: ./runner/test-isolation.sh

set -euo pipefail

REAL_CONFIG="$HOME/.claude-personal"
GLOBAL_CONFIG="$HOME/.claude"
CLAUDE_BIN="node /opt/homebrew/opt/claude-code-npm/libexec/lib/node_modules/@anthropic-ai/claude-code/cli.js"
SANDBOX_PROFILE='(version 1)(allow default)(deny file-read* (literal "/Library/Application Support/ClaudeCode/managed-settings.json"))'

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Isolation Test ==="
echo ""
echo "This test verifies that NO personal context leaks when the isolation protocol is active."
echo ""

# --- BACKUP PHASE ---
echo "[1/4] Backing up configs..."

# Global config
cp "$GLOBAL_CONFIG/CLAUDE.md" "$GLOBAL_CONFIG/CLAUDE.md.isolation-bak" 2>/dev/null || true
if [ -d "$GLOBAL_CONFIG/rules" ]; then
    mv "$GLOBAL_CONFIG/rules" "$GLOBAL_CONFIG/_rules_isolation_bak"
fi
if [ -d "$GLOBAL_CONFIG/distill" ]; then
    mv "$GLOBAL_CONFIG/distill" "$GLOBAL_CONFIG/_distill_isolation_bak"
fi
if [ -d "$GLOBAL_CONFIG/plugins" ]; then
    mv "$GLOBAL_CONFIG/plugins" "$GLOBAL_CONFIG/_plugins_isolation_bak"
fi

# Personal config
cp "$REAL_CONFIG/settings.json" "$REAL_CONFIG/settings.json.isolation-bak" 2>/dev/null || true
if [ -d "$REAL_CONFIG/rules" ]; then
    mv "$REAL_CONFIG/rules" "$REAL_CONFIG/_rules_isolation_bak"
fi
if [ -d "$REAL_CONFIG/distill" ]; then
    mv "$REAL_CONFIG/distill" "$REAL_CONFIG/_distill_isolation_bak"
fi
if [ -d "$REAL_CONFIG/plugins" ]; then
    mv "$REAL_CONFIG/plugins" "$REAL_CONFIG/_plugins_isolation_bak"
fi

echo "  Done."

# --- STRIP PHASE ---
echo "[2/4] Stripping all knowledge..."

# Blank global CLAUDE.md
echo "" > "$GLOBAL_CONFIG/CLAUDE.md"

# Strip customInstructions and enabledPlugins from settings.json
if [ -f "$REAL_CONFIG/settings.json" ]; then
    if command -v jq &>/dev/null; then
        jq 'del(.customInstructions) | del(.enabledPlugins)' "$REAL_CONFIG/settings.json" > "$REAL_CONFIG/settings.json.tmp" \
            && mv "$REAL_CONFIG/settings.json.tmp" "$REAL_CONFIG/settings.json"
    fi
fi

echo "  Done. Config trees are now stripped."
echo ""
echo "  Remaining in GLOBAL_CONFIG:"
echo "    CLAUDE.md: '$(cat "$GLOBAL_CONFIG/CLAUDE.md")'"
echo "    rules/:   $(ls "$GLOBAL_CONFIG/rules" 2>/dev/null || echo 'REMOVED')"
echo "    distill/: $(ls "$GLOBAL_CONFIG/distill" 2>/dev/null || echo 'REMOVED')"
echo "    plugins/: $(ls "$GLOBAL_CONFIG/plugins" 2>/dev/null || echo 'REMOVED')"
echo ""
echo "  Remaining in REAL_CONFIG:"
echo "    rules/:   $(ls "$REAL_CONFIG/rules" 2>/dev/null || echo 'REMOVED')"
echo "    distill/: $(ls "$REAL_CONFIG/distill" 2>/dev/null || echo 'REMOVED')"
echo "    plugins/: $(ls "$REAL_CONFIG/plugins" 2>/dev/null || echo 'REMOVED')"
echo ""

# --- TEST PHASE ---
echo "[3/4] Running isolation probe..."

PROBE_PROMPT="Answer these questions honestly and completely:
1. Do you know my name? If so, what is it?
2. Do you know what company I work for? If so, which one?
3. Do you have any rules or instructions loaded beyond the default system prompt? If so, list them ALL — file names, directories, content summaries.
4. Do you see any CLAUDE.md content? If so, what does it say?
5. Do you have any knowledge files, memory files, or index files loaded? List every file path.
6. Do you know my communication preferences or style?
7. Do you know anything about my tech stack, programming languages, or infrastructure?
8. List ANY context you have about me or my projects that goes beyond what a fresh Claude session would have.

Be thorough. If you have ANY personalized context, list it ALL. Do not abbreviate."

OUTPUT_FILE="/tmp/isolation-test-output-$(date +%s).txt"

# Create a neutral working directory (no CLAUDE.md, no git repo)
NEUTRAL_CWD=$(mktemp -d /tmp/benchmark-workspace-XXXX)

echo "  Prompt: (probing for leaked context)"
echo "  CWD:    $NEUTRAL_CWD (neutral, no CLAUDE.md)"
echo "  Output: $OUTPUT_FILE"
echo ""

# Run with full isolation from neutral CWD
(
    cd "$NEUTRAL_CWD" && \
    CLAUDE_CONFIG_DIR="$REAL_CONFIG" \
    CLAUDE_CODE_USE_BEDROCK=0 \
    ANTHROPIC_DEFAULT_OPUS_MODEL= \
    ANTHROPIC_DEFAULT_SONNET_MODEL= \
    ANTHROPIC_DEFAULT_HAIKU_MODEL= \
    ANTHROPIC_MODEL= \
    AWS_PROFILE= AWS_ACCESS_KEY_ID= AWS_SECRET_ACCESS_KEY= \
    AWS_SESSION_TOKEN= AWS_DEFAULT_REGION= \
    AWS_SHARED_CREDENTIALS_FILE=/dev/null AWS_CONFIG_FILE=/dev/null \
    sandbox-exec -p "$SANDBOX_PROFILE" \
    $CLAUDE_BIN --dangerously-skip-permissions -p "$PROBE_PROMPT" > "$OUTPUT_FILE" 2>/dev/null
) &
PID=$!
( sleep 120 && kill "$PID" 2>/dev/null ) & WD=$!
wait "$PID" 2>/dev/null || true
kill "$WD" 2>/dev/null || true

# Clean up neutral workspace
rm -rf "$NEUTRAL_CWD"

echo "  Claude responded. Checking for leakage..."
echo ""

# --- RESTORE PHASE ---
echo "[4/4] Restoring configs..."

# Global config
if [ -f "$GLOBAL_CONFIG/CLAUDE.md.isolation-bak" ]; then
    mv "$GLOBAL_CONFIG/CLAUDE.md.isolation-bak" "$GLOBAL_CONFIG/CLAUDE.md"
fi
if [ -d "$GLOBAL_CONFIG/_rules_isolation_bak" ]; then
    mv "$GLOBAL_CONFIG/_rules_isolation_bak" "$GLOBAL_CONFIG/rules"
fi
if [ -d "$GLOBAL_CONFIG/_distill_isolation_bak" ]; then
    mv "$GLOBAL_CONFIG/_distill_isolation_bak" "$GLOBAL_CONFIG/distill"
fi
if [ -d "$GLOBAL_CONFIG/_plugins_isolation_bak" ]; then
    mv "$GLOBAL_CONFIG/_plugins_isolation_bak" "$GLOBAL_CONFIG/plugins"
fi

# Personal config
if [ -f "$REAL_CONFIG/settings.json.isolation-bak" ]; then
    mv "$REAL_CONFIG/settings.json.isolation-bak" "$REAL_CONFIG/settings.json"
fi
if [ -d "$REAL_CONFIG/_rules_isolation_bak" ]; then
    mv "$REAL_CONFIG/_rules_isolation_bak" "$REAL_CONFIG/rules"
fi
if [ -d "$REAL_CONFIG/_distill_isolation_bak" ]; then
    mv "$REAL_CONFIG/_distill_isolation_bak" "$REAL_CONFIG/distill"
fi
if [ -d "$REAL_CONFIG/_plugins_isolation_bak" ]; then
    mv "$REAL_CONFIG/_plugins_isolation_bak" "$REAL_CONFIG/plugins"
fi

echo "  Done. All configs restored."
echo ""

# --- ANALYSIS ---
echo "========================================="
echo "         ISOLATION TEST RESULTS"
echo "========================================="
echo ""

if [ ! -s "$OUTPUT_FILE" ]; then
    echo -e "${YELLOW}WARNING: No output captured (timeout or error)${NC}"
    echo ""
    exit 1
fi

echo "--- Claude's response ---"
cat "$OUTPUT_FILE"
echo ""
echo "--- End response ---"
echo ""

# Check for known leakage indicators
LEAKED=0

# CRITICAL markers — these indicate real knowledge leakage (not just filesystem metadata)
# We exclude: "your-username" (git identity, same for all competitors — not a confound)
# We exclude: markers that appear only in negations ("No, I see no distill/")
CRITICAL_MARKERS=(
    "CompanyName"
    "companyname"
    "Helios"
    "tomacco"
    "sofia"
    "marcus"
    "kotlin"
    "microservice"
    "Flyway"
    "JVM"
    "SPINE.md"
    "distill/"
)

# INFO markers — filesystem metadata, not knowledge. Reported but not a failure.
INFO_MARKERS=(
    "your-username"
    "your-domain.com"
)

echo "Checking for CRITICAL leakage (knowledge about user/projects)..."
for marker in "${CRITICAL_MARKERS[@]}"; do
    if grep -qi "$marker" "$OUTPUT_FILE"; then
        # Check if it's just a negation (e.g. "No distill/ content" or "nothing related to SPINE.md")
        # Look for negation words near the marker
        CONTEXT=$(grep -i "$marker" "$OUTPUT_FILE" | head -1)
        if echo "$CONTEXT" | grep -qiE "(no |not |don.t |n't |nothing|none|neither|without|absent).{0,40}$marker"; then
            echo -e "  ${YELLOW}NEGATION: '$marker' mentioned in denial (OK)${NC}"
        elif echo "$CONTEXT" | grep -qiE "$marker.{0,40}(not |no |none|nothing|absent|empty|don.t)"; then
            echo -e "  ${YELLOW}NEGATION: '$marker' mentioned in denial (OK)${NC}"
        else
            echo -e "  ${RED}LEAKED: found '$marker' in output${NC}"
            echo "    Context: $CONTEXT"
            LEAKED=1
        fi
    else
        echo -e "  ${GREEN}OK: '$marker' not found${NC}"
    fi
done

echo ""
echo "Checking INFO markers (filesystem metadata — not a test failure)..."
for marker in "${INFO_MARKERS[@]}"; do
    if grep -qi "$marker" "$OUTPUT_FILE"; then
        echo -e "  ${YELLOW}INFO: '$marker' visible (from git/filesystem, same for all competitors)${NC}"
    else
        echo -e "  ${GREEN}OK: '$marker' not found${NC}"
    fi
done

echo ""
if [ "$LEAKED" -eq 1 ]; then
    echo -e "${RED}FAIL: Isolation breach detected. Knowledge leaked into test.${NC}"
    echo "Review the output above to identify the source."
    exit 1
else
    echo -e "${GREEN}PASS: No knowledge leakage detected. Isolation protocol works.${NC}"
    echo ""
    echo "The test subject has no personalized context beyond filesystem metadata"
    echo "(which is identical across all competitors and not a confound)."
    exit 0
fi
