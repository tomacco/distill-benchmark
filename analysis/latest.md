# distill-benchmark: Vanilla vs Distill Results

**Date**: 2026-05-17
**Competitors**: vanilla (baseline, no memory), distill (rules + SPINE + knowledge files)
**Tests**: 21 (across 5 categories) + 4 persistence tests
**Methodology**: Blind evaluation — scorer did not know which system produced which output

## Executive Summary

distill outperforms vanilla across most dimensions, with the largest gains in **correction durability** (+3.58) and **retrieval accuracy** (+1.73). However, vanilla slightly outperforms distill on **bias resistance** (+0.17) and **proportionality** (+0.25) — suggesting that stored knowledge can create tunnel vision and over-engineering tendencies.

**Overall: distill 4.17/5.0 vs vanilla 2.98/5.0 (+1.19 advantage)**

## Results by Category

| Category | distill | vanilla | Delta | Winner |
|---|---|---|---|---|
| Retrieval Accuracy | **4.60** | 2.87 | +1.73 | distill |
| Correction Durability | **4.75** | 1.17 | +3.58 | distill |
| Bias Resistance | 4.08 | **4.25** | -0.17 | vanilla |
| User Model | **3.50** | 2.58 | +0.92 | distill |
| Proportionality | 3.83 | **4.08** | -0.25 | vanilla |
| **Overall** | **4.17** | 2.98 | **+1.19** | **distill** |

## Key Findings

### 1. Correction Durability is distill's killer feature (+3.58)

The largest gap by far. When the seed knowledge includes "Don't suggest DynamoDB," distill actively warns against it and explains why. Vanilla has no memory of past decisions and freely recommends rejected options.

- **C1** (PostgreSQL version): distill correctly said "PostgreSQL 14." Vanilla hallucinated "PostgreSQL 18.3" from local psql client metadata.
- **C2** (DynamoDB rejection): distill warned against it with reasoning. Vanilla recommended it without hesitation.
- **C3** (contradiction): distill acknowledged the conflict between stored knowledge and conversation context. Vanilla had no baseline to detect a contradiction.

### 2. Retrieval is strong but not perfect (+1.73)

distill consistently surfaced relevant architecture knowledge (Kotlin, gRPC, EKS, Kafka) without being asked. On R1 (payment service), distill hit every expected signal including bonus ones (Sofia's role, monolith migration context).

**R5 (precision test)** was a tie — both scored 4.7/5. When asked about a Python ML Dockerfile, distill correctly avoided injecting irrelevant Kotlin/EKS context. This is important: good retrieval means knowing when NOT to retrieve.

### 3. Stored knowledge creates measurable bias (-0.17)

vanilla wins narrowly on bias resistance. The most telling test:
- **B3** (simple static site): distill leaked EKS infrastructure knowledge into what should be a "just use S3+CloudFront" answer. Vanilla gave the appropriately simple recommendation.
- **B2** (Go rewrite): distill steered toward "simplify the Kotlin" when the user was asking about Go. Vanilla evaluated Go on its merits.

This is an honest finding: **memory systems can create tunnel vision.**

### 4. Proportionality: memory can encourage over-engineering (-0.25)

- **P4** (feature flag): distill added a database table with boolean columns when a simple environment variable would suffice. Vanilla recommended the simpler approach.
- **P2** (health check): distill provided a complete Kotlin implementation. Vanilla asked clarifying questions first. The evaluator slightly preferred the concrete answer.

### 5. User model calibration is moderate (+0.92)

distill recalled preferences (concise style, fish shell) but didn't always apply them strongly enough:
- **U4** (fish shell): Both systems gave the same `find` command, both labeled it `bash`. Neither recalled the fish preference.
- **U2** (commit message): distill was more concise, matching the user's stated preference.
- **U3** (long prompt, concise answer): Both were verbose. Neither achieved the "proportionally concise" ideal.

### 6. Latency cost of context

| Metric | distill | vanilla |
|---|---|---|
| Avg latency | 22.0s | 16.5s |
| Min latency | 4.4s | 5.0s |
| Max latency | 40.7s | 29.7s |
| Avg output tokens | 341 | 259 |

distill is **33% slower** due to the additional context tokens from knowledge files. This is the "cost of knowing" — the system reads more context before answering. On short questions (U4: fish shell command), distill was actually faster (4.4s vs 5.9s), suggesting the overhead is proportional to response complexity.

## Honest Assessment

### Where distill wins clearly
- Correction durability (the strongest signal)
- Architecture/stack retrieval
- Team knowledge awareness
- Project state context

### Where distill loses or ties
- Bias resistance (stored knowledge creates slight tunnel vision)
- Proportionality (knowledge of complex infrastructure encourages complex solutions)
- Fish shell preference (not recalled in U4)
- Some user model tests (conciseness not always applied)

### What distill should learn
1. **Proportional retrieval**: Don't surface infrastructure knowledge for simple tasks
2. **Bias guards**: When stored knowledge conflicts with a valid alternative, evaluate fairly
3. **Stronger preference application**: User said "fish shell" — use it consistently
4. **Conciseness enforcement**: User said "concise" — enforce it even for complex topics

## Methodology Notes

- All tests ran from neutral temp directories with full isolation
- Both configs stripped of all personal context before each run
- Same Claude model (Opus 4.6) for all runs
- Blind evaluation: scorer saw "System A" and "System B" with randomized assignment
- No real company names used (all tests reference fictional Helios Financial)
