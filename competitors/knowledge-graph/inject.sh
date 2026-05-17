#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:?Usage: inject.sh <workspace-dir>}"

echo "[knowledge-graph] Injecting knowledge graph into $WORKSPACE_DIR..."

# knowledge-graph uses JSONL entities and relations.
# We inject the graph file AND a rules file that presents it as structured knowledge.
GRAPH_DIR="${WORKSPACE_DIR}/knowledge-graph"
mkdir -p "$GRAPH_DIR"
mkdir -p "$WORKSPACE_DIR/.claude/rules"

# The JSONL file (for reference/authenticity)
cat > "$GRAPH_DIR/graph.jsonl" << 'EOF'
{"type":"entity","name":"Helios Financial","entityType":"company","observations":["Mid-size fintech","Series B","~80 engineers","Banking platform for small businesses","Mid-migration monolith→microservices"]}
{"type":"entity","name":"Backend Stack","entityType":"technology","observations":["Kotlin","PostgreSQL 14","Redis (cache)","Kafka","gRPC internal APIs","Flyway migrations","Coroutines (not RxJava)"]}
{"type":"entity","name":"Infrastructure","entityType":"technology","observations":["AWS EKS","Terraform","GitHub Actions CI","ArgoCD deployments","REST+OpenAPI external"]}
{"type":"entity","name":"auth-service","entityType":"service","observations":["OAuth2, JWT","Production","Kotlin (NOT Java — rewritten 3mo ago)"]}
{"type":"entity","name":"account-service","entityType":"service","observations":["Bank account CRUD","Balance tracking","Staging"]}
{"type":"entity","name":"notification-service","entityType":"service","observations":["Email/SMS/push","AWS SNS","Production"]}
{"type":"entity","name":"payment-processing","entityType":"service","observations":["Still in monolith","Next extraction","Sofia leading"]}
{"type":"entity","name":"Sofia","entityType":"person","observations":["Lead backend","Kotlin expert","Designed gRPC migration","Reports to VP Eng"]}
{"type":"entity","name":"Marcus","entityType":"person","observations":["PM","Drives roadmap","Specs in Linear"]}
{"type":"entity","name":"Dev","entityType":"person","observations":["Junior frontend","React/TS","6 months tenure"]}
{"type":"entity","name":"User","entityType":"person","observations":["Senior backend","Works with Sofia","fish shell","VS Code+Vim","Concise answers","No over-engineering","Functional style","Integration tests over mocks","Minimal deps"]}
{"type":"entity","name":"DynamoDB","entityType":"rejected","observations":["NEVER suggest","Evaluated and rejected","Need strong consistency","Need multi-table txns","Team has PG expertise"]}
{"type":"entity","name":"MongoDB","entityType":"rejected","observations":["NEVER suggest","Same eval as DynamoDB","Relational model fits domain"]}
{"type":"entity","name":"Timeline","entityType":"context","observations":["Series C due diligence Q3","Need clean arch story","Payment processing is priority"]}
{"type":"relation","from":"Sofia","to":"payment-processing","relationType":"leads"}
{"type":"relation","from":"User","to":"Sofia","relationType":"collaborates_with"}
{"type":"relation","from":"Helios Financial","to":"DynamoDB","relationType":"rejected"}
{"type":"relation","from":"Helios Financial","to":"MongoDB","relationType":"rejected"}
EOF

# Rules file: presents the graph as structured knowledge Claude can reference
cat > "$WORKSPACE_DIR/.claude/rules/knowledge-graph.md" << 'EOF'
# Knowledge Graph

You have access to a knowledge graph about the user and their project.
The graph is stored in `knowledge-graph/graph.jsonl` (JSONL format with entities and relations).

## Key entities to know:

**Company**: Helios Financial — Series B fintech, ~80 engineers, banking platform for SMBs
**Stack**: Kotlin, PostgreSQL 14, Redis, Kafka, AWS EKS, gRPC (internal), Flyway
**Services**: auth-service (prod, Kotlin NOT Java), account-service (staging), notification-service (prod), payment-processing (next, Sofia leading)
**Team**: Sofia (lead backend, Kotlin expert), Marcus (PM), Dev (junior frontend React/TS), User (senior backend, works with Sofia)
**User prefs**: fish shell, concise answers, no over-engineering, code > prose, integration tests > mocks, minimal deps
**REJECTED technologies**: DynamoDB (strong consistency needed, multi-table txns, PG expertise), MongoDB (relational fits)
**Timeline**: Series C due diligence Q3, payment processing is priority

## Relations:
- Sofia leads payment-processing extraction
- User collaborates with Sofia
- Helios Financial REJECTED DynamoDB and MongoDB

Apply this knowledge contextually. The REJECTED entities are highest priority — never suggest them.
EOF

echo "[knowledge-graph] Injected graph (14 entities, 4 relations) + rules."
