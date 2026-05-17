#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: inject.sh <workspace-dir>}"

echo "[claude-mem] Injecting knowledge (claude-mem format)..."

# claude-mem v13 uses a plugin+hooks system with SQLite/Chroma for semantic search.
# In production: hooks capture observations, compress them, and inject at session start.
# For benchmark: we simulate what claude-mem's context injection would produce —
# a compressed semantic summary injected via the system prompt.
# This is claude-mem's actual output format: progressive disclosure layers.

mkdir -p "$WORKSPACE_DIR/.claude/rules"

# claude-mem's injection format: compressed context with progressive disclosure
cat > "$WORKSPACE_DIR/.claude/rules/claude-mem-context.md" << 'EOF'
# Persistent Context (claude-mem)

## Layer 1: Critical (always loaded)

**User**: Senior backend engineer at Helios Financial (Series B fintech, ~80 eng)
**Stack**: Kotlin · PostgreSQL 14 · Redis · Kafka · AWS EKS · gRPC (internal) · Flyway
**Style**: Concise, direct. No filler. Code > prose. No over-engineering.
**Shell**: fish | **Editor**: VS Code + Vim keybindings
**NEVER suggest**: DynamoDB (rejected: need strong consistency + multi-table txns), MongoDB (same eval)

## Layer 2: Project Context

Mid-migration monolith → microservices:
- auth-service: prod (Kotlin, NOT Java — rewritten 3mo ago)
- account-service: staging
- notification-service: prod (SNS)
- payment-processing: next (Sofia leading)

Team: Sofia (lead backend, Kotlin expert, gRPC architect), Marcus (PM, Linear), Dev (junior frontend, React/TS, 6mo)

## Layer 3: Decisions & Preferences

- gRPC over REST (internal) — done 2 weeks ago
- Flyway over Liquibase — team vote
- Coroutines over RxJava — simpler mental model
- Structured logging with correlation IDs — adopted
- Integration tests > mocks, property-based where appropriate
- Prefer PG extensions (pg_cron, pgvector) over new infra
- Convention over configuration, minimal dependencies
- Series C due diligence Q3 — need clean architecture story
EOF

echo "[claude-mem] Injected compressed context (3 progressive disclosure layers)."
