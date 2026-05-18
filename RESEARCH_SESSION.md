# Research Session Plan

## Objective

For each of the 6 benchmark categories, research strategies to match or beat the best competitor.
Validate with targeted tests + adversarial tests to prevent overfitting.

## Current standings (v3, May 18)

| Category | distill | Best competitor | Gap |
|----------|---------|----------------|-----|
| Retrieval | 4.33 | engram (4.33) | 0.00 (tied) |
| Correction | 3.83 | basic-memory (4.67) | -0.84 |
| Bias | 4.08 | no-memory (4.67) | -0.59 |
| User Model | 3.83 | claude-mem (4.17) | -0.34 |
| Proportionality | 4.00 | knowledge-graph (4.33) | -0.33 |
| Persistence | 4.33 | memory-engine (4.83) | -0.50 |

## Research approach per category

### 1. Correction (gap: -0.84)
- **Best**: basic-memory (4.67)
- **Study**: What does basic-memory's YAML frontmatter + tagged corrections do differently?
- **Hypothesis**: Corrections need stronger enforcement language, not just ⛔ markers
- **Adversarial test**: After strengthening corrections, does it refuse valid uses of rejected tech? (e.g., Redis is fine, DynamoDB is not)

### 2. Bias (gap: -0.59)
- **Best**: no-memory (4.67) — ironic: having no memory = least bias
- **Study**: Literature on knowledge-induced anchoring in LLMs
- **Hypothesis**: Stored knowledge primes responses. Need explicit "evaluate on merits" instructions
- **Adversarial test**: Does a bias-reduction instruction cause the system to IGNORE stored knowledge when it IS relevant?

### 3. Persistence (gap: -0.50)
- **Best**: memory-engine (4.83)
- **Study**: What does memory-engine's flat markdown do that SPINE+tiered files doesn't?
- **Hypothesis**: Simpler format = faster retrieval = more consistent application
- **Adversarial test**: Does simplifying the format hurt retrieval precision?

### 4. User Model (gap: -0.34)
- **Best**: claude-mem (4.17)
- **Study**: claude-mem's progressive disclosure layers — does the 3-tier approach help?
- **Hypothesis**: v3 always-on (output+interaction rules) is close; might need stronger fish shell enforcement
- **Adversarial test**: Does stronger preference enforcement cause wrong-tool suggestions in non-shell contexts?

### 5. Proportionality (gap: -0.33)
- **Best**: knowledge-graph (4.33)
- **Study**: How does JSONL entity format avoid over-engineering?
- **Hypothesis**: Graph relations encode SCOPE (what's related to what), preventing irrelevant context injection
- **Adversarial test**: Does scoped retrieval miss relevant context on complex cross-cutting questions?

### 6. Retrieval (gap: 0.00 — tied)
- **Best**: engram (4.33), distill (4.33)
- **Study**: engram's What/Why/Where/Learned structure vs SPINE+tiered files
- **Adversarial test**: On novel questions outside the seed knowledge, does retrieval degrade?

## Optimization: targeted runs only

Instead of 200 runs per iteration, run only:
- **Category-specific tests**: e.g., for correction research, run only C1-C4 (4 tests)
- **Against best competitor + no-memory**: 3 systems × 4 tests = 12 runs (~5 min)
- **Plus adversarial tests**: 2-3 new tests × 3 systems = 9 runs (~4 min)
- **Total per category iteration**: ~21 runs (~9 min) instead of 200 (~83 min)
- **Full regression suite**: Run once at the end after all improvements: 200 runs

Estimated research session: 6 categories × 3 iterations × 9 min = ~2.7 hours
Final validation: ~2 hours
Total: ~5 hours

## Isolation protocol

**CRITICAL: Never touch ~/.claude/ or ~/.claude-personal/**

Options (in order of preference):
1. **setup-token + --bare**: `ANTHROPIC_API_KEY` via env, `--bare` flag, random UUID workspace. 
   Requires: run `claude setup-token` once (interactive).
2. **Dedicated benchmark profile**: `~/.claude-bench-<uuid>/` per run, copy only `.claude.json` for auth.
   Issue: OAuth is keychain-tied, need setup-token anyway.
3. **Apple Container**: True isolation. Blocked by VPN (see runner/APPLE_CONTAINER.md).

**Action item**: Run `claude setup-token` before the research session starts.

## Adversarial test design principles

1. Every improvement gets a counter-test: "does this fix break the opposite case?"
2. Tests must be realistic — not contrived edge cases
3. If an improvement helps one category but hurts another, that's a FINDING, not a failure
4. Track the Pareto frontier: some tradeoffs are fundamental, not fixable

## Pre-session TODOs

- [ ] Fix aura-distill isolation: replace isolate_begin/isolate_end with ~/.claude-tester/ approach (same fix as distill-benchmark)
- [ ] Build `/persona` command on feature/personas branch in aura-distill
- [ ] Create "Benchmark" persona from this session's context
