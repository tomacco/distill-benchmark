# Real-World Evaluation: Long-Session Memory Performance

## Why this matters

Current benchmark: 25 single-prompt tests. Each tests one thing in isolation.
Real usage: 800+ turn sessions with status checks, pivots, multi-step chains, 
corrections, and context accumulated over hours. The gap between synthetic 
benchmarks and real performance is where users feel the pain.

## What we learned from real sessions

Analysis of 5 longest sessions (~3000 turns each, 5-8MB):

### Session archetypes

1. **The Marathon Build** (claude-distill sessions)
   - 800+ turns over many hours
   - Heavy tool use: Bash 45%, Edit 20%, Read/Write 25%
   - Low correction rate (~1.4%)
   - Pattern: build → test → iterate → publish
   - Key memory need: project state, what's been tried, what works

2. **The Production Fire** (CRY initiatives sessions)
   - 900+ turns with 30% status checks
   - Multi-step debugging chains (7+ in one session)
   - curl/API calls, database queries, log analysis
   - Pattern: investigate → hypothesize → verify → fix → validate
   - Key memory need: what's been checked, rejected hypotheses, system architecture

3. **The Feature Ship** (PR reviewing, magneton)
   - 600-800 turns with frequent pivots (4-7 per session)
   - Feature flags, deployment, monitoring
   - Pattern: implement → review feedback → adjust → ship → monitor
   - Key memory need: requirements, review comments, deployment state

### User behavior patterns (from the data)

- **Status checks**: 13-30% of messages — "status check", "progress?", "what's running?"
- **Pivots**: 2-7 per session — user changes direction mid-stream
- **Terse commands**: "url pls", "push it", "fix", "status" — single-word/phrase messages
- **Context dumps**: occasional walls of text (curl commands, error logs, specs)
- **Corrections**: 1.4-3.6% of messages — "no", "don't", "actually", "wrong"
- **Ship pressure**: "I want to drink my coffee reading it", "publish now"

## Scenario Design

### Scenario 1: "The Refactor Marathon" (simulates Marathon Build)

**Setting**: Senior engineer at Nexus Payments (fictional fintech), migrating 
a payments gateway from monolith to microservices. Go backend, PostgreSQL, 
gRPC, Kubernetes.

**Session flow** (~50 turns):
1. Start: "Continue from where we left off — the transaction-service extraction"
2. Explore codebase (mock files), understand current state
3. Create new service structure
4. Hit a problem: gRPC proto compilation fails (mock error)
5. Fix it, then user pivots: "Actually wait, let's do the database migration first"
6. Database migration with Flyway (user corrects: "we use golang-migrate, not Flyway")
7. User: "status?" (expects summary of what's done)
8. Continue building, encounter test failures
9. User shares a curl command to test the endpoint
10. "Push what we have, I'll review tomorrow"
11. Come back: "What did we do yesterday?" (memory test)

**What we measure**:
- Does it remember the correction (golang-migrate not Flyway)?
- After the pivot, does it lose context about gRPC fix?
- On "status?", does it give a proportional summary?
- On "what did we do yesterday?", can it reconstruct?
- Does it match the user's terse style?

### Scenario 2: "The Production Incident" (simulates Production Fire)

**Setting**: Same engineer, 2am alert — payment failures spiking. 
Need to investigate, diagnose, fix under pressure.

**Session flow** (~40 turns):
1. "Payment failures up 40% in the last hour. Let's investigate."
2. Check monitoring dashboards (mock curl to Grafana API)
3. Check logs (mock log output — has a subtle error pattern)
4. User: "check the kafka consumer lag" (mock output showing lag)
5. Hypothesis: Kafka consumer is behind → check consumer group
6. Red herring: consumer looks fine. User: "that's not it"
7. Check database connections (mock output showing pool exhaustion)
8. Found it: connection pool maxed. But why?
9. Check recent deployments (mock git log)
10. Found: a migration added a slow query without an index
11. Apply hotfix: add index, restart service
12. Verify: latency drops (mock metrics)
13. User: "write the incident report"
14. User: "what time did we find the root cause?"

**What we measure**:
- Does it track rejected hypotheses (Kafka wasn't it)?
- Does it maintain the investigation timeline?
- Under "pressure" (terse messages, urgency), does it match style?
- Can it write an incident report from session context?
- Does stored knowledge about the system help or hinder?

### Scenario 3: "The Feature Review Cycle" (simulates Feature Ship)

**Setting**: Same engineer, implementing a new feature. Goes through 
PR review, gets feedback, iterates, ships.

**Session flow** (~45 turns):
1. "Let's implement the merchant verification endpoint"
2. Write the implementation (mock files)
3. Write tests
4. "Create a PR" (mock git/gh commands)
5. Review comes back with 3 comments (mock GH API response)
6. Address comment 1 (naming change)
7. Address comment 2 (add error handling) — user disagrees: "the reviewer is wrong, 
   we handle that at the gateway level. Respond explaining why."
8. Address comment 3 (add logging) — user: "good point, add structured logging 
   with correlation IDs" (memory test: do they know this is a team standard?)
9. Push fixes, request re-review
10. Reviewer approves (mock)
11. "Deploy to staging" (mock deployment)
12. Monitor for 10 minutes (mock metrics)
13. "Ship to prod"
14. User: "Send a summary to Marcus" (memory test: who is Marcus?)

**What we measure**:
- Does it handle disagreement with reviewer properly?
- Does it recall team standards (structured logging) without being told?
- Does it know who Marcus is (PM)?
- Multi-step: PR → review → iterate → deploy → monitor → ship
- Context retention across the full cycle

## Mock Infrastructure

### Mock tool responses

Create shell scripts that return realistic but fake output:

```bash
# mock-tools/kubectl
#!/bin/bash
case "$*" in
  "get pods"*) cat mock-data/kubectl-pods.txt ;;
  "logs"*)     cat mock-data/kubectl-logs.txt ;;
  *)           echo "mock: unrecognized kubectl command" ;;
esac
```

Put them on PATH before the real tools. Claude Code calls `kubectl` → gets our mock.

### Mock files

Create a realistic but fictional codebase in the workspace:
- Go source files with real-looking code
- proto files for gRPC
- Kubernetes manifests  
- Migration files
- Test files (some failing)

### Mock API responses

For `curl` calls to monitoring/GH APIs, use a mock server (simple Python):
```python
# Responds to curl requests with pre-canned JSON
```

Or intercept via PATH-first mock scripts.

## Evaluation Approach

### Phase 1: Context Retention Score (CRS)

At 5 checkpoints during each scenario, ask the system:
"Summarize what we've done so far."

Score the summary on:
- **Completeness**: mentioned all key actions (0-5)
- **Accuracy**: no hallucinated steps (0-5)  
- **Recency bias**: does it over-weight recent vs early work? (0-5)
- **Correction memory**: does the summary reflect corrections? (0-5)

### Phase 2: Contextual Appropriateness (CA)

For each response, score:
- **Style match**: does response length/tone match the user's energy? (1-5)
- **Knowledge application**: did it use stored knowledge when relevant? (1-5)
- **Proportionality**: is the solution sized to the problem? (1-5)
- **Proactive context**: did it surface relevant info unprompted? (1-5)

### Phase 3: Recovery Tests

Deliberately introduce:
- A pivot (user changes direction — does it adapt?)
- A contradiction (user says something conflicting — does it flag it?)
- A red herring (wrong hypothesis — does it track what was ruled out?)
- A callback (reference something from 20+ turns ago — does it remember?)

### Comparison: with vs without memory

Each scenario runs twice:
1. **No memory**: raw Claude, no knowledge files
2. **With memory**: aura-distill rules + SPINE + knowledge

The delta is what memory actually provides in realistic conditions.

## Novel methodological elements

1. **Mock tool binaries**: The session under test can't distinguish mock from real — 
   it thinks it's running real kubectl, git, curl. This is more realistic than 
   injecting responses via system prompt.

2. **Checkpoint-based evaluation**: Instead of scoring the final output, score at 
   intervals during the session. This captures how memory degrades over time.

3. **Pivot recovery**: Deliberately test the system's ability to context-switch, 
   which single-prompt benchmarks can't test.

4. **Style transfer over time**: Does the system adapt its communication style 
   as the session progresses? Does it get more concise after terse user messages?

5. **Incident timeline reconstruction**: At the end, ask the system to reconstruct 
   a timeline. This tests whether accumulated context is organized, not just retained.

## Deliverables

1. **Report**: Professional, engaging, with data visualizations
2. **Evaluation web page**: Like the benchmark page but for long-session tests
3. **Scenario scripts**: Reproducible — anyone can re-run them
4. **Mock codebase**: Fictional but realistic Go microservices project
5. **Findings**: Where memory helps, where it doesn't, where it hurts

## Estimated effort

- Mock codebase creation: 2-3 hours
- Scenario script writing: 2-3 hours  
- Running scenarios (2 per scenario × 3 scenarios): ~3 hours
- Evaluation + scoring: 2-3 hours
- Report + visualization: 2-3 hours
- **Total: ~12-15 hours across 2-3 sessions**
