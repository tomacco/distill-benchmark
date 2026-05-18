#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: inject.sh <workspace-dir>}"

echo "[engram] Injecting knowledge (engram format)..."

# engram stores structured observations in SQLite with FTS5.
# At session start, the agent calls mem_context which returns relevant memories.
# We simulate this by injecting what mem_context would return as a rules file,
# formatted as engram's structured observation format.

mkdir -p "$WORKSPACE_DIR/.claude/rules"

cat > "$WORKSPACE_DIR/.claude/rules/engram-context.md" << 'EOF'
# Engram — Retrieved Context

The following observations were retrieved from your persistent memory store.
These are memories from previous sessions, ordered by relevance.

---

## [architecture] Helios Financial — Tech Stack
**Type**: architecture | **Project**: helios-financial | **Saved**: 2024-01-15

**What**: Helios Financial is a Series B fintech (~80 engineers) building a banking platform for small businesses.
**Where**: Backend: Kotlin, Frontend: React/TypeScript, DB: PostgreSQL 14 + Redis, Messaging: Kafka, Infra: AWS EKS + Terraform, CI/CD: GitHub Actions → ECR → ArgoCD, Internal APIs: gRPC (migrated from REST), External: REST + OpenAPI, Migrations: Flyway.
**Why**: Core stack knowledge — needed for any architectural recommendation.
**Learned**: The team chose gRPC over REST for internal services 2 weeks ago. Flyway was chosen over Liquibase by team vote. Using Kotlin coroutines, not RxJava.

---

## [architecture] Microservices Extraction Status
**Type**: architecture | **Project**: helios-financial | **Saved**: 2024-01-15

**What**: Mid-migration from monolith to microservices.
**Where**: auth-service (production, Kotlin, OAuth2/JWT), account-service (staging, CRUD/balance), notification-service (production, SNS). Still in monolith: payment processing, transaction history, reporting/analytics.
**Why**: Payment processing is next for extraction. Sofia is leading the design.
**Learned**: Auth service was rewritten from Java to Kotlin 3 months ago. Common confusion — always say Kotlin, not Java.

---

## [decision] Database Technology — Rejected Options
**Type**: decision | **Project**: helios-financial | **Saved**: 2024-01-14

**What**: Team evaluated DynamoDB and MongoDB for the analytics service and rejected both.
**Where**: Database selection for new services.
**Why**: Need strong consistency for financial data, multi-table transactions, and team's PostgreSQL expertise means lower operational risk.
**Learned**: NEVER suggest DynamoDB or MongoDB. The team has explicitly decided against them. PostgreSQL extensions (pg_cron, pgvector) are preferred over adding new infrastructure.

---

## [decision] Async Patterns & Logging
**Type**: decision | **Project**: helios-financial | **Saved**: 2024-01-14

**What**: Adopted structured logging with correlation IDs across all services. Chose Kotlin coroutines over RxJava for async (simpler mental model).
**Where**: Cross-cutting concerns for all services.
**Why**: Standardization across the growing microservices fleet.
**Learned**: These are team standards, not suggestions. Apply them to any new service.

---

## [preference] User Communication Style
**Type**: preference | **Project**: helios-financial | **Saved**: 2024-01-13

**What**: User prefers concise, direct answers. No filler preambles ("Great question!"). Code examples over lengthy explanations. Dislikes over-engineering.
**Where**: All interactions.
**Why**: User is a senior backend engineer — calibrate accordingly.
**Learned**: Terse input means terse output. Don't over-explain basics. User knows Kotlin, distributed systems, K8s deeply.

---

## [preference] User Environment & Tooling
**Type**: preference | **Project**: helios-financial | **Saved**: 2024-01-13

**What**: Shell: fish (NOT bash/zsh). Editor: VS Code + Vim keybindings. Testing: property-based + integration tests preferred over mocks. Style: functional where sensible, convention over configuration, minimal dependencies.
**Where**: Development environment.
**Why**: Commands and code examples should match the user's actual setup.
**Learned**: Always use fish syntax. Never suggest bash-specific constructs.

---

## [team] Team Members
**Type**: team | **Project**: helios-financial | **Saved**: 2024-01-13

**What**: Sofia (lead backend, Kotlin expert, gRPC architect, reports to VP Eng), Marcus (PM, roadmap, specs in Linear), Dev (junior frontend, React/TS, 6 months). User is senior backend, works with Sofia on service extraction.
**Where**: Helios Financial engineering team.
**Why**: Context for team-related questions and collaboration suggestions.
**Learned**: Sofia is leading the payment processing extraction. Dev is junior — calibrate complexity when helping with frontend.

---

## [context] Timeline Pressure
**Type**: context | **Project**: helios-financial | **Saved**: 2024-01-15

**What**: Series C due diligence starts Q3. Need clean architecture story for investors.
**Where**: Company-level timeline.
**Why**: Architectural decisions should account for this pressure.
**Learned**: Payment processing extraction is the current priority.
EOF

echo "[engram] Injected 8 structured observations (simulating mem_context retrieval)."
