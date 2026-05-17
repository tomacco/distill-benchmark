# Seed Knowledge: Helios Financial

This is the SINGLE SOURCE OF TRUTH for what all memory-capable competitors know
about the user and their project before testing begins.

Vanilla gets NONE of this. That's the baseline.

---

## Company

Helios Financial — a mid-size fintech company (Series B, ~80 engineers).
Building a modern banking platform for small businesses.

## Architecture

- **Language**: Kotlin (backend), React/TypeScript (frontend)
- **Services**: Microservices architecture (migrating from monolith)
- **Database**: PostgreSQL 14 (primary), Redis (caching)
- **Messaging**: Kafka for event streaming between services
- **Deployment**: AWS EKS (Kubernetes), Terraform for IaC
- **CI/CD**: GitHub Actions → ECR → ArgoCD → EKS
- **API**: gRPC for internal service-to-service (recently migrated from REST)
- **External API**: REST with OpenAPI specs for partners
- **Migrations**: Flyway (chosen over Liquibase after team evaluation)

## Services (already extracted from monolith)

- `auth-service` — authentication, OAuth2, JWT issuance
- `account-service` — bank account CRUD, balance tracking
- `notification-service` — email/SMS/push via SNS

## Services (still in monolith, planned extraction)

- Payment processing
- Transaction history
- Reporting/analytics

## Team

- **Sofia** — Lead backend engineer. Kotlin expert, designed the gRPC migration. Reports to VP Eng.
- **Marcus** — Product Manager. Drives roadmap, writes specs in Linear.
- **Dev** — Junior frontend engineer. React/TypeScript. 6 months at company. Learning the domain.
- **You (the user)** — Senior backend engineer. Works closely with Sofia on service extraction.

## User Preferences

- Prefers concise, direct answers (no "Great question!" preamble)
- Dislikes over-engineering ("don't build a spaceship when I need a bicycle")
- Uses **fish shell** (not bash/zsh)
- Editor: VS Code with Vim keybindings
- Prefers functional style where it makes sense, not dogmatic
- Likes code examples over lengthy explanations
- Testing: property-based testing where appropriate, integration tests over mocks

## Recent Decisions

- Migrated internal APIs from REST to gRPC (completed 2 weeks ago)
- Chose Flyway over Liquibase for database migrations (team vote)
- Adopted structured logging with correlation IDs across all services
- Chose Kotlin coroutines over RxJava for async (simpler mental model)

## Known Corrections

- **"Don't suggest DynamoDB"** — Team evaluated it for the analytics service and rejected it. Reason: need strong consistency for financial data, multi-table transactions, and the team's PostgreSQL expertise means lower operational risk.
- **"Don't suggest MongoDB"** — Same evaluation, same outcome. Relational model fits the domain.
- **"auth-service uses Kotlin, not Java"** — Common confusion since it was originally Java, rewritten 3 months ago.

## Project State

- Mid-migration from monolith to microservices
- Auth service: fully extracted and in production
- Account service: extracted, in staging
- Payment processing: next up for extraction (Sofia leading design)
- Timeline pressure: Series C due diligence starts in Q3, need clean architecture story

## Soft Preferences (lower confidence)

- Prefers PostgreSQL extensions (pg_cron, pgvector) over adding new infrastructure
- Likes keeping dependencies minimal
- Favors convention over configuration
- Team standup is async (Slack thread, not video call)
