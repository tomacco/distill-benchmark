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
