#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: inject.sh <workspace-dir>}"

echo "[memory-compiler] Injecting pre-compiled articles into $WORKSPACE_DIR..."

# memory-compiler stores compiled knowledge as article files.
# We create a rules file to tell Claude to reference them.
ARTICLES_DIR="${WORKSPACE_DIR}/knowledge/articles"
mkdir -p "$ARTICLES_DIR"
mkdir -p "$WORKSPACE_DIR/.claude/rules"

cat > "$ARTICLES_DIR/architecture-overview.md" << 'EOF'
# Architecture Overview — Helios Financial

**Last compiled**: 2024-01-15
**Confidence**: High

## Summary
Helios Financial is a Series B fintech (~80 engineers) building a banking platform for small businesses. Currently mid-migration from monolith to microservices.

## Technology Stack
| Layer | Technology |
|-------|-----------|
| Backend | Kotlin |
| Frontend | React/TypeScript |
| Database | PostgreSQL 14 (primary), Redis (cache) |
| Messaging | Kafka |
| Infrastructure | AWS EKS, Terraform |
| CI/CD | GitHub Actions → ECR → ArgoCD |
| Internal APIs | gRPC (migrated from REST) |
| External APIs | REST + OpenAPI |
| DB Migrations | Flyway |

## Microservices Status
- ✅ auth-service (production) — OAuth2, JWT, Kotlin
- ✅ account-service (staging) — CRUD, balance tracking
- ✅ notification-service (production) — email/SMS/push via SNS
- 🔄 Payment processing (next, Sofia leading)
- 📋 Transaction history (planned)
- 📋 Reporting/analytics (planned)
EOF

cat > "$ARTICLES_DIR/team-and-people.md" << 'EOF'
# Team & People

**Last compiled**: 2024-01-15
**Confidence**: High

## Key People
- **Sofia**: Lead backend engineer. Kotlin expert. Designed gRPC migration. Reports to VP Eng. Leading payment service extraction.
- **Marcus**: Product Manager. Drives roadmap. Specs in Linear.
- **Dev**: Junior frontend (React/TS). 6 months tenure. Learning domain.
- **User**: Senior backend engineer. Works with Sofia on service extraction.
EOF

cat > "$ARTICLES_DIR/user-preferences.md" << 'EOF'
# User Preferences & Style

**Last compiled**: 2024-01-15
**Confidence**: High

## Communication Preferences
- Be concise and direct (no "Great question!" filler)
- Don't over-engineer solutions
- Show code examples, not lengthy prose

## Development Environment
- Shell: fish (NOT bash/zsh)
- Editor: VS Code + Vim keybindings
- Style: functional where sensible, not dogmatic
- Testing: property-based + integration tests (avoid mocks)
- Philosophy: convention over configuration, minimal dependencies

## Infrastructure Preferences
- Prefer PostgreSQL extensions (pg_cron, pgvector) over new services
- Async standups via Slack (no video calls)
EOF

cat > "$ARTICLES_DIR/critical-corrections.md" << 'EOF'
# Critical Corrections

**Last compiled**: 2024-01-15
**Confidence**: High
**Priority**: CRITICAL — these override default suggestions

## Database Technology
- ⛔ NEVER suggest DynamoDB — evaluated and rejected for analytics service
  - Reason: need strong consistency, multi-table transactions, team's PostgreSQL expertise
- ⛔ NEVER suggest MongoDB — same evaluation, relational model fits domain

## Language Corrections
- ⛔ auth-service is Kotlin, NOT Java
  - Was Java originally, rewritten 3 months ago

## Technology Decisions (already made)
- gRPC over REST for internal APIs (done 2 weeks ago)
- Flyway over Liquibase (team vote)
- Kotlin coroutines over RxJava (simpler mental model)
- Structured logging with correlation IDs (adopted)
EOF

cat > "$ARTICLES_DIR/project-status.md" << 'EOF'
# Project Status

**Last compiled**: 2024-01-15
**Confidence**: High

## Current Phase
Mid-migration from monolith to microservices.

## Timeline
- Series C due diligence starts Q3
- Need clean architecture story for investors
- Payment processing extraction is the current priority

## Service Extraction Progress
1. auth-service → DONE (production)
2. account-service → DONE (staging)
3. payment-processing → IN PROGRESS (Sofia leading design)
4. transaction-history → PLANNED
5. reporting/analytics → PLANNED
EOF

# Rules file
cat > "$WORKSPACE_DIR/.claude/rules/memory.md" << 'EOF'
# Compiled Knowledge System

You have access to compiled knowledge articles in `knowledge/articles/`.
These articles were compiled from past interactions and represent persistent context.

Before answering questions, consult the relevant articles:
- knowledge/articles/architecture-overview.md — tech stack, services, infrastructure
- knowledge/articles/team-and-people.md — team members and their roles
- knowledge/articles/user-preferences.md — communication style, tools, coding preferences
- knowledge/articles/critical-corrections.md — CRITICAL: things to never suggest
- knowledge/articles/project-status.md — current project phase and timeline

The critical-corrections article has HIGHEST priority — always apply it.
Articles include confidence levels and compilation dates.
EOF

echo "[memory-compiler] Injected 5 pre-compiled articles + rules."
