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
