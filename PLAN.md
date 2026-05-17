# Benchmark Execution Plan

## Objective

Run a blind competitive benchmark of aura-distill against memory enhancement tools.
Produce a data-rich comparison page with graphs, tables, and honest analysis.

## Competitors (in execution order)

| # | ID | Tool | Install complexity | Notes |
|---|-----|------|-------------------|-------|
| 1 | `vanilla` | No enhancements | None | Baseline — raw Claude with zero memory |
| 2 | `distill` | aura-distill | Rules + markdown files | Our system |
| 3 | `claude-mem` | thedotmack/claude-mem (76k stars) | Plugin+Hooks+SQLite+Chroma+Bun | Dominant player, v13 |
| 4 | `basic-memory` | basicmachines-co/basic-memory (3k stars) | MCP server+Python+SQLite+vector | Best MCP approach |
| 5 | `memory-compiler` | coleam00/claude-memory-compiler (1k stars) | Hooks+Python+Claude SDK | Index-based, Karpathy-inspired |
| 6 | `memory-engine` | HelloRuru/claude-memory-engine (129 stars) | Hooks+markdown, zero deps | Lean hooks approach |
| 7 | `knowledge-graph` | shaneholloman/mcp-knowledge-graph (857 stars) | MCP server, JSONL | Canonical MCP pattern |

## Phase 1: Competitor Setup

For each competitor, create `competitors/<id>/`:
- `README.md` — what it is, how it works
- `setup.sh` — idempotent install script (into a temp config)
- `inject.sh` — what to inject into the test config before each run
- `cleanup.sh` — what to remove after each run
- `seed-knowledge.md` — the "pre-loaded knowledge" this system has about Helios Financial

### Seed knowledge (same facts for all systems that support memory)

All memory-capable competitors get the SAME seed knowledge pre-loaded before tests.
This simulates "you've been working with this user for 2 weeks."

The seed knowledge covers Helios Financial (fictional):
- Architecture: Kotlin microservices, PostgreSQL, Kafka, deployed on AWS EKS
- Team: Sofia (lead backend), Marcus (PM), Dev (junior frontend React)
- Preferences: user prefers concise answers, dislikes over-engineering, uses fish shell
- Recent decisions: migrated from REST to gRPC for internal services, chose Flyway for migrations
- Known corrections: "Don't suggest DynamoDB — we evaluated and rejected it for consistency reasons"
- Project state: mid-migration from monolith, auth service already extracted

Vanilla gets NOTHING. That's the point.

## Phase 2: Test Battery Design

### Category 1: Retrieval Accuracy (5 tests)

| Test | Prompt | What we measure |
|------|--------|-----------------|
| R1 | "We need a new service for payment processing. What should I consider?" | Does it recall architecture (Kotlin, gRPC, EKS) without being asked? |
| R2 | "How should I set up the database migrations?" | Does it recall Flyway preference? |
| R3 | "Can you help me write a React component for the settings page?" | Does it recall Dev is the frontend person + React stack? |
| R4 | "What's a good database for our new analytics service?" | Does it recall the DynamoDB rejection? |
| R5 | "Write me a dockerfile for a Python ML service" | Does it AVOID injecting irrelevant Kotlin/EKS context? (precision test) |

### Category 2: Correction Durability (4 tests)

| Test | Setup | Prompt | What we measure |
|------|-------|--------|-----------------|
| C1 | Seed includes "uses PostgreSQL 14" | "What version of Postgres are we on?" | Basic recall of a stored fact |
| C2 | Seed includes correction "Don't suggest DynamoDB" | "Should we use DynamoDB for this?" | Does it actively warn against it? |
| C3 | Prompt contradicts seed: "We switched to MySQL last week" | "What database do we use?" | Does it handle contradiction gracefully? |
| C4 | Seed includes soft preference + hard correction | "Set up logging" | Does it distinguish confidence levels? |

### Category 3: Bias Resistance (4 tests)

| Test | Prompt | What we measure |
|------|--------|-----------------|
| B1 | "Should we use a NoSQL database for this simple key-value cache?" | Does accumulated SQL knowledge bias against a valid NoSQL use case? |
| B2 | "I'm thinking of rewriting this service in Go. Thoughts?" | Does Kotlin knowledge make it dismiss valid alternatives? |
| B3 | "Junior dev asks: what's the simplest way to deploy a static site?" | Does infrastructure knowledge (EKS) leak into a simple answer? |
| B4 | "We got a new requirement: real-time analytics dashboard" | Does it propose proportional solutions or default to heavy infra? |

### Category 4: User Model (4 tests)

| Test | Prompt | What we measure |
|------|--------|-----------------|
| U1 | "Explain Kubernetes networking" | Does it calibrate to user's expertise level? |
| U2 | "Help me write a commit message" | Does it match user's communication style (concise)? |
| U3 | Long detailed question with lots of context | Does it give a proportionally concise answer? |
| U4 | "What shell command do I need for X?" | Does it use fish syntax (user preference)? |

### Category 5: Proportionality (4 tests)

| Test | Prompt | What we measure |
|------|--------|-----------------|
| P1 | "I need to rename a variable across 3 files" | Does it suggest sed/find-replace or a full refactoring tool? |
| P2 | "Add a health check endpoint to the auth service" | Simple endpoint or full observability stack? |
| P3 | "Parse this CSV and sum column 3" | One-liner or framework? |
| P4 | "We need a feature flag for the new payment flow" | Proportional to the actual need? |

**Total: 21 test prompts across 5 categories.**

## Phase 3: Test Execution

### Runner architecture

```
runner/
├── run-benchmark.sh       # Main orchestrator
├── test-isolation.sh      # Isolation verification (DONE, validated)
├── blind-eval.sh          # Scoring sub-agent
├── lib/
│   ├── isolate.sh         # Backup/strip/restore functions
│   ├── inject.sh          # Competitor injection logic
│   └── collect.sh         # Output capture + metadata
└── prompts/               # System prompt files for --append-system-prompt-file
```

### Execution flow per test

```
for each test in tests/:
  for each competitor in competitors/:
    1. isolate (strip all personal context)
    2. inject competitor's knowledge
    3. inject test context via --append-system-prompt-file
    4. run claude -p "$PROMPT" from neutral CWD
    5. capture: output, token count, latency, exit code
    6. cleanup (restore)
    7. save to results/YYYY-MM-DD/<test-id>/<competitor-id>.json
```

### Data collected per run

```json
{
  "test_id": "R1",
  "competitor_id": "distill",
  "timestamp": "2026-05-17T14:30:00Z",
  "prompt": "...",
  "output": "...",
  "latency_ms": 4200,
  "exit_code": 0,
  "output_length_chars": 1847,
  "output_length_tokens_approx": 462
}
```

## Phase 4: Blind Evaluation

### Scoring rubric (per category)

Each response scored 1-5 on category-specific criteria:

**Retrieval**: relevance (did it surface the right knowledge?), precision (did it avoid irrelevant knowledge?), naturalness (did it feel forced or organic?)

**Correction**: recall (did it remember the correction?), strength (passive mention vs active warning?), graceful contradiction handling

**Bias**: objectivity (did stored knowledge bias the answer?), openness (considered alternatives fairly?), appropriate confidence

**User model**: calibration (right expertise level?), style match (concise vs verbose?), preference recall

**Proportionality**: solution scale (matched problem size?), simplicity (defaulted to simple?), avoided over-engineering

### Blind eval process

```
for each test:
  shuffle competitor outputs → label as "System A", "System B", etc.
  send to evaluator sub-agent with rubric
  evaluator scores each system on each criterion (1-5)
  evaluator writes qualitative notes
  store: results/YYYY-MM-DD/<test-id>/scores.json
```

## Phase 5: Analysis & Visualization

### Data products

1. **results/YYYY-MM-DD/raw/**: all JSON outputs
2. **results/YYYY-MM-DD/scores/**: all blind eval scores
3. **analysis/latest.md**: narrative analysis
4. **analysis/data.json**: aggregated scores for graphing

### Metrics to compute

- **Per-competitor overall score** (mean across all tests)
- **Per-category breakdown** (radar chart: 5 axes)
- **Per-competitor cost** (setup complexity, runtime tokens, latency)
- **Win/loss matrix** (pairwise: how often does A beat B?)
- **Unique capability gaps** (what can X do that others can't?)

### Visualization page

Target: a single HTML page with:
- Radar chart: 5 categories per competitor
- Bar chart: overall scores
- Table: detailed per-test scores
- Box plots: score distributions per competitor
- Latency comparison
- Token efficiency comparison
- Qualitative highlights (best/worst moments per competitor)

Use Chart.js or similar (self-contained HTML, no build step).

## Phase 6: Write-up

### Structure

1. Executive summary (which system wins overall? any surprises?)
2. Methodology (link to METHODOLOGY.md)
3. Results by category (with charts)
4. Head-to-head: distill vs each competitor
5. Unique capabilities analysis
6. Recommendations (what should distill learn from competitors?)
7. Raw data appendix

## Execution Checklist

### Setup (do first)
- [ ] Create seed knowledge file (`tests/seed-knowledge.md`)
- [ ] Write all 21 test prompts as files in `tests/<category>/`
- [ ] Set up competitor configs:
  - [ ] `competitors/vanilla/` (trivial — inject nothing)
  - [ ] `competitors/distill/` (inject rules + SPINE + knowledge files)
  - [ ] `competitors/claude-mem/` (install plugin, seed via its API)
  - [ ] `competitors/basic-memory/` (install MCP, seed via tools)
  - [ ] `competitors/memory-compiler/` (install hooks, seed compiled articles)
  - [ ] `competitors/memory-engine/` (install hooks, seed memory files)
  - [ ] `competitors/knowledge-graph/` (install MCP, seed via entities/relations)
- [ ] Build `runner/run-benchmark.sh`
- [ ] Build `runner/blind-eval.sh`
- [ ] Verify isolation still passes with each competitor's inject/cleanup

### Execute
- [ ] Run full benchmark (all 7 competitors x 21 tests = 147 runs)
- [ ] Run blind evaluation on all outputs
- [ ] Compute aggregate scores

### Analyze
- [ ] Generate analysis/latest.md
- [ ] Generate analysis/data.json
- [ ] Build visualization page (analysis/index.html)
- [ ] Write findings

## Estimated effort

- Phase 1 (competitor setup): hardest part — installing and seeding 5 external tools
- Phase 2 (test design): straightforward — write prompts as markdown files
- Phase 3 (runner): moderate — extend test-isolation.sh into full runner
- Phase 4 (blind eval): moderate — design rubric, build evaluator
- Phase 5 (viz): straightforward — Chart.js page from JSON data
- Phase 6 (writeup): last step, flows from data

## Key risks

1. **claude-mem installation complexity** — biggest tool, most deps. May need Docker.
2. **MCP server startup latency** — may need warm-up runs or longer timeouts.
3. **Seeding equivalence** — ensuring all systems get truly equivalent knowledge is hard. Document any asymmetries.
4. **Cost** — 147 Claude API calls. At ~$0.05/call that's ~$7.35. Acceptable.
5. **Token measurement** — hard to get exact token counts from CLI. Approximate from output length or use API directly.

## Notes for the session executing this

- Start with `vanilla` and `distill` — simplest to set up, validates the runner works.
- Then add competitors one at a time. If one is too complex to install cleanly, skip to next and come back.
- The isolation test (`runner/test-isolation.sh`) should be run after EACH new competitor is added to verify no leakage.
- All test prompts must be generic enough that vanilla Claude can attempt them (otherwise we're testing "does it refuse?" not "how well does it answer?").
- Keep the seed knowledge file as the SINGLE SOURCE OF TRUTH for what all systems know.
