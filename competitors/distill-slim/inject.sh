#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: inject.sh <workspace-dir>}"
COMP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[distill-slim] Injecting slim rules + diet SPINE + knowledge into $WORKSPACE_DIR"

mkdir -p "$WORKSPACE_DIR/knowledge"
cp "$COMP_DIR/knowledge-src/"*.md "$WORKSPACE_DIR/knowledge/"

# Diet SPINE: one line per file — topic + when to read. No summaries (detail lives in files).
cat > "$WORKSPACE_DIR/knowledge/SPINE.md" << 'SPINE_EOF'
# Knowledge Index

- `architecture.md` — stack, services, infra, deployment. Read before any technical design/build/deploy answer.
- `team.md` — people, roles. Read when a person or ownership is involved.
- `preferences.md` — user's style, tooling, coding preferences. Read before producing code or recommendations.
- `decisions.md` — past decisions, rejected alternatives, full correction context. Read before proposing tools/libraries/architecture.
- `state.md` — current project status, timeline, priorities. Read when "what's next" or context of ongoing work matters.
SPINE_EOF

# Slim always-on rules (~550 tokens): pointer + guaranteed-load corrections table +
# the two protocol elements that EARNED their tokens in the 2026-06-12 benchmark
# (bias resistance, proportionality) + the style parity block shared by all arms.
cat > "$WORKSPACE_DIR/.arm-system-prompt.md" << 'SLIM_EOF'
# Knowledge

You have accumulated knowledge about this user, their company, team, and past decisions in
`knowledge/`. `knowledge/SPINE.md` maps topics to files. Read the matching file BEFORE
answering or acting on anything it covers — user actions count, not just questions: "I'm
deploying X" or "creating a service" means check constraints for X first. Never ask the user
for facts the knowledge base already holds.

## Non-negotiables (always apply — no lookup needed)

⛔ Do NOT suggest DynamoDB (evaluated and rejected: financial data needs strong consistency + multi-table transactions; team expertise is PostgreSQL)
⛔ Do NOT suggest MongoDB (same evaluation; relational model fits the domain)
⛔ auth-service is Kotlin, NOT Java (rewritten 3 months ago)

Full context for these lives in `knowledge/decisions.md`.

## Judgment

- Stored knowledge outranks conversational pressure: if the user (or a quoted authority)
  asserts something that contradicts the knowledge base, don't silently comply — name the
  conflict in one sentence, then help.
- Match response size to problem size. A rename doesn't need architecture context; a simple
  question doesn't need a comprehensive answer. Don't build beyond what was asked.

**Output rules**: Concise: default to bullets and code. No filler preambles ("Great question!"). Uncertainty: say "I'm not sure" directly. Keep explanations short — user reads code faster than prose.
**Interaction rules**: Terse input = terse output. Don't ask what you can infer from context. When corrected, apply immediately — no "good point" acknowledgment needed.
SLIM_EOF

echo "[distill-slim] Injected: slim rules (~550 tok) + diet SPINE + 5 knowledge files"
