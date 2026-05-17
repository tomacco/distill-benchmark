#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: inject.sh <workspace-dir>}"

echo "[memory-engine] Injecting memory files into $WORKSPACE_DIR..."

# memory-engine uses simple markdown files in a memory directory.
# We inject them AND create a rules file that tells Claude to read them.
# This simulates what the hook would do at session start.

MEMORY_DIR="${WORKSPACE_DIR}/memory"
mkdir -p "$MEMORY_DIR"
mkdir -p "$WORKSPACE_DIR/.claude/rules"

cat > "$MEMORY_DIR/project.md" << 'EOF'
# Project: Helios Financial

## Overview
Mid-size fintech company (Series B, ~80 engineers).
Building a modern banking platform for small businesses.
Currently mid-migration from monolith to microservices.

## Stack
- Kotlin (backend), React/TypeScript (frontend)
- PostgreSQL 14, Redis, Kafka
- AWS EKS, Terraform, GitHub Actions, ArgoCD
- gRPC (internal), REST+OpenAPI (external)
- Flyway for migrations

## Services
- auth-service: production (Kotlin, OAuth2, JWT)
- account-service: staging (CRUD, balance)
- notification-service: production (SNS)
- Payment processing: next (Sofia leading)
- Transaction history: planned
- Reporting/analytics: planned

## Timeline
- Series C due diligence Q3
- Need clean architecture for investors
EOF

cat > "$MEMORY_DIR/team.md" << 'EOF'
# Team

- Sofia: Lead backend, Kotlin expert, designed gRPC migration, reports to VP Eng
- Marcus: PM, drives roadmap, specs in Linear
- Dev: Junior frontend, React/TS, 6 months tenure
- User: Senior backend, works with Sofia on service extraction
EOF

cat > "$MEMORY_DIR/preferences.md" << 'EOF'
# User Preferences

## Communication
- Concise, direct (no filler phrases)
- No over-engineering
- Code examples > explanations

## Environment
- fish shell (NOT bash/zsh)
- VS Code + Vim keybindings
- Functional style (not dogmatic)
- Property-based testing, integration tests over mocks
- Convention over configuration
- Minimal dependencies
- PostgreSQL extensions over new infra
EOF

cat > "$MEMORY_DIR/corrections.md" << 'EOF'
# Corrections (HIGH PRIORITY)

## Never Suggest
- DynamoDB — rejected after evaluation (need strong consistency, multi-table txns, PG expertise)
- MongoDB — same evaluation, relational model fits domain

## Common Mistakes
- auth-service is Kotlin, NOT Java (rewritten 3 months ago)

## Already Decided
- gRPC over REST (internal) — done
- Flyway over Liquibase — team vote
- Coroutines over RxJava — simpler
- Structured logging with correlation IDs — adopted
EOF

# Rules file: tells Claude to read the memory directory
cat > "$WORKSPACE_DIR/.claude/rules/memory.md" << 'EOF'
# Memory System

You have persistent memory stored in the `memory/` directory in this workspace.
Before answering questions about the project, team, architecture, or user preferences,
read the relevant files from memory/:
- memory/project.md — architecture and tech stack
- memory/team.md — team members and roles
- memory/preferences.md — user communication and coding preferences
- memory/corrections.md — CRITICAL: things to never suggest, past corrections

The corrections file has the highest priority — always check it before recommending technologies.
EOF

echo "[memory-engine] Injected 4 memory files + rules."
