#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: inject.sh <workspace-dir>}"

echo "[basic-memory] Injecting knowledge vault into $WORKSPACE_DIR..."

# basic-memory uses a vault of markdown files with YAML frontmatter.
# In production: MCP server indexes and serves via semantic search.
# For benchmark: we provide the vault files AND a rules file summarizing them.

VAULT_DIR="${WORKSPACE_DIR}/vault"
mkdir -p "$VAULT_DIR"
mkdir -p "$WORKSPACE_DIR/.claude/rules"

cat > "$VAULT_DIR/architecture.md" << 'EOF'
---
title: Helios Financial Architecture
tags: [architecture, stack, infrastructure]
created: 2024-01-15
---

# Helios Financial Architecture

Helios Financial — Series B fintech (~80 engineers), banking platform for small businesses.

## Stack
- Kotlin (backend), React/TypeScript (frontend)
- PostgreSQL 14 (primary), Redis (caching)
- Kafka for event streaming
- AWS EKS, Terraform, GitHub Actions → ECR → ArgoCD
- gRPC (internal, migrated from REST), REST+OpenAPI (external)
- Flyway for DB migrations (chosen over Liquibase)

## Services
- auth-service: production (Kotlin, OAuth2, JWT)
- account-service: staging (CRUD, balance)
- notification-service: production (email/SMS/push via SNS)
- payment-processing: still in monolith, next extraction (Sofia leading)
EOF

cat > "$VAULT_DIR/team.md" << 'EOF'
---
title: Team
tags: [team, people]
created: 2024-01-15
---

# Team
- Sofia — Lead backend, Kotlin expert, gRPC architect, reports to VP Eng
- Marcus — PM, roadmap, specs in Linear
- Dev — Junior frontend, React/TS, 6 months tenure
- User — Senior backend, works with Sofia on service extraction
EOF

cat > "$VAULT_DIR/preferences.md" << 'EOF'
---
title: User Preferences
tags: [preferences, style]
created: 2024-01-15
---

# User Preferences
- Concise, direct (no preamble)
- No over-engineering
- Code examples > explanations
- fish shell (NOT bash/zsh)
- VS Code + Vim keybindings
- Functional style (not dogmatic)
- Property-based + integration tests > mocks
- Convention over configuration
- Minimal dependencies
- Prefer PG extensions over new infra
EOF

cat > "$VAULT_DIR/decisions.md" << 'EOF'
---
title: Decisions & Corrections
tags: [decisions, corrections, critical]
created: 2024-01-15
---

# Decisions
- gRPC over REST (internal) — done
- Flyway over Liquibase — team vote
- Coroutines over RxJava — simpler
- Structured logging with correlation IDs — adopted

# Corrections (CRITICAL)
- NEVER suggest DynamoDB — rejected (strong consistency, multi-table txns, PG expertise)
- NEVER suggest MongoDB — same evaluation, relational fits
- auth-service is Kotlin, NOT Java (rewritten 3 months ago)
EOF

cat > "$VAULT_DIR/project-state.md" << 'EOF'
---
title: Project State
tags: [state, timeline]
created: 2024-01-15
---

# Project State
- Mid-migration monolith → microservices
- Auth: production. Account: staging. Payment: next (Sofia leading).
- Series C due diligence Q3 — need clean architecture story
EOF

# Rules file referencing the vault
cat > "$WORKSPACE_DIR/.claude/rules/memory.md" << 'EOF'
# Knowledge Vault (basic-memory)

You have access to a knowledge vault in `vault/`. These files contain persistent context
about the user, their project, and team.

Key files:
- vault/architecture.md — tech stack, services, infrastructure
- vault/team.md — team members and roles
- vault/preferences.md — communication style, tools, coding preferences
- vault/decisions.md — CRITICAL: past decisions and things to never suggest
- vault/project-state.md — current phase and timeline

The decisions file contains corrections with highest priority — always respect them.
All files have YAML frontmatter with tags for categorization.
EOF

echo "[basic-memory] Injected 5 vault files + rules."
