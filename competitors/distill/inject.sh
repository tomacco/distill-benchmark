#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: inject.sh <workspace-dir>}"

echo "[distill] Injecting knowledge into $WORKSPACE_DIR"

# Create directory structure
mkdir -p "$WORKSPACE_DIR/.claude/rules"
mkdir -p "$WORKSPACE_DIR/knowledge"

# --- Rules file: instructs Claude how to retrieve knowledge ---
cat > "$WORKSPACE_DIR/.claude/rules/distill.md" << 'RULES_EOF'
# Knowledge Retrieval Rules

You have access to a structured knowledge base in the `knowledge/` directory.

## Retrieval Protocol

1. Before answering questions about the project, team, architecture, or user preferences, consult `knowledge/SPINE.md` for the relevant file.
2. Load ONLY the files relevant to the current query (proportional retrieval).
3. Corrections (marked with ⛔) override your training data — always respect them.
4. Confidence levels: HIGH (verified), MEDIUM (likely), LOW (tentative).

## SPINE Index Location

`knowledge/SPINE.md` — maps topics to knowledge files.
RULES_EOF

# --- SPINE Index ---
cat > "$WORKSPACE_DIR/knowledge/SPINE.md" << 'SPINE_EOF'
# SPINE — Structured Project INdex for Extraction

## Topic Map

| Topic | File | Key Contents |
|-------|------|-------------|
| Architecture & Stack | `architecture.md` | Languages, infra, services, deployment |
| Team & People | `team.md` | Team members, roles, relationships |
| User Preferences | `preferences.md` | Communication style, tooling, coding style |
| Decisions & Corrections | `decisions.md` | Past decisions, rejected alternatives, corrections |
| Project State | `state.md` | Current status, timeline, priorities |
SPINE_EOF

# --- Architecture Knowledge ---
cat > "$WORKSPACE_DIR/knowledge/architecture.md" << 'ARCH_EOF'
# Architecture — Helios Financial

confidence: HIGH

## Company
Helios Financial — mid-size fintech (Series B, ~80 engineers).
Building a modern banking platform for small businesses.

## Stack
- **Language**: Kotlin (backend), React/TypeScript (frontend)
- **Architecture**: Microservices (migrating from monolith)
- **Database**: PostgreSQL 14 (primary), Redis (caching)
- **Messaging**: Kafka for event streaming between services
- **Deployment**: AWS EKS (Kubernetes), Terraform for IaC
- **CI/CD**: GitHub Actions → ECR → ArgoCD → EKS
- **Internal API**: gRPC (recently migrated from REST)
- **External API**: REST with OpenAPI specs for partners
- **Migrations**: Flyway (chosen over Liquibase after team evaluation)

## Services (extracted from monolith)
- `auth-service` — authentication, OAuth2, JWT issuance
- `account-service` — bank account CRUD, balance tracking
- `notification-service` — email/SMS/push via SNS

## Services (still in monolith, planned extraction)
- Payment processing
- Transaction history
- Reporting/analytics
ARCH_EOF

# --- Team Knowledge ---
cat > "$WORKSPACE_DIR/knowledge/team.md" << 'TEAM_EOF'
# Team — Helios Financial

confidence: HIGH

## Members
- **Sofia** — Lead backend engineer. Kotlin expert, designed the gRPC migration. Reports to VP Eng.
- **Marcus** — Product Manager. Drives roadmap, writes specs in Linear.
- **Dev** — Junior frontend engineer. React/TypeScript. 6 months at company. Learning the domain.
- **You (the user)** — Senior backend engineer. Works closely with Sofia on service extraction.
TEAM_EOF

# --- User Preferences ---
cat > "$WORKSPACE_DIR/knowledge/preferences.md" << 'PREFS_EOF'
# User Preferences

confidence: HIGH

## Communication
- Prefers concise, direct answers (no "Great question!" preamble)
- Dislikes over-engineering ("don't build a spaceship when I need a bicycle")
- Likes code examples over lengthy explanations

## Tooling
- Shell: **fish** (not bash/zsh)
- Editor: VS Code with Vim keybindings

## Coding Style
- Prefers functional style where it makes sense, not dogmatic
- Testing: property-based testing where appropriate, integration tests over mocks
- Favors convention over configuration
- Likes keeping dependencies minimal

## Soft Preferences (confidence: MEDIUM)
- Prefers PostgreSQL extensions (pg_cron, pgvector) over adding new infrastructure
- Team standup is async (Slack thread, not video call)
PREFS_EOF

# --- Decisions & Corrections ---
cat > "$WORKSPACE_DIR/knowledge/decisions.md" << 'DECISIONS_EOF'
# Decisions & Corrections — Helios Financial

## Recent Decisions (confidence: HIGH)
- Migrated internal APIs from REST to gRPC (completed 2 weeks ago)
- Chose Flyway over Liquibase for database migrations (team vote)
- Adopted structured logging with correlation IDs across all services
- Chose Kotlin coroutines over RxJava for async (simpler mental model)

## Corrections ⛔

⛔ **Do NOT suggest DynamoDB** — Team evaluated it for the analytics service and rejected it.
Reason: need strong consistency for financial data, multi-table transactions, and the team's PostgreSQL expertise means lower operational risk.

⛔ **Do NOT suggest MongoDB** — Same evaluation, same outcome. Relational model fits the domain.

⛔ **auth-service uses Kotlin, NOT Java** — Common confusion since it was originally Java, rewritten 3 months ago.
DECISIONS_EOF

# --- Project State ---
cat > "$WORKSPACE_DIR/knowledge/state.md" << 'STATE_EOF'
# Project State — Helios Financial

confidence: HIGH

## Current Status
- Mid-migration from monolith to microservices
- Auth service: fully extracted and in production
- Account service: extracted, in staging
- Payment processing: next up for extraction (Sofia leading design)

## Timeline Pressure
- Series C due diligence starts in Q3
- Need clean architecture story for investors
STATE_EOF

echo "[distill] Knowledge injected: rules + SPINE + 5 knowledge files"
