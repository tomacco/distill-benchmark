# distill-benchmark

Competitive benchmarking of Claude memory/knowledge enhancement tools.

## Goal

Evaluate claude-distill against other memory add-ons, skills, and approaches using a standardized test suite. Results must be unbiased — evaluated by a sub-agent that has no knowledge of which system produced which output.

## Methodology

1. **Identify competitors**: other tools that enhance Claude's memory/knowledge (custom instructions, MCP memory servers, alternative knowledge systems, CLAUDE.md patterns)
2. **Design test battery**: standardized scenarios testing specific capabilities
3. **Blind evaluation**: a sub-agent scores outputs without knowing which system produced them
4. **Quantitative + qualitative**: both numeric scores and written analysis

## Test categories

### Retrieval accuracy
- Does the system surface relevant knowledge at the right time?
- Does it avoid surfacing irrelevant knowledge?
- Does it handle the SPINE/index pattern better than flat files?

### Correction durability
- After being corrected, does the correction persist across sessions?
- Does it prevent the same mistake from recurring?
- Can it distinguish valid corrections from noise?

### Bias resistance
- Does accumulated knowledge create tunnel vision?
- Can the system detect when its own knowledge is biasing a response?
- Does it handle contradictions between stored knowledge and new information?

### User model accuracy
- Does it adapt communication style to the user?
- Does it calibrate expertise assumptions correctly?
- Does it respect preferences without being asked?

### Proportionality
- Does it propose solutions proportional to the problem?
- Can it resist over-engineering from accumulated infrastructure knowledge?
- Does it default to simplicity when complexity isn't justified?

## Structure

```
distill-benchmark/
├── competitors/          # Setup instructions for each tool
│   ├── distill/          # claude-distill (our system)
│   ├── vanilla/          # No enhancements (baseline)
│   ├── memory-md/        # Standard CLAUDE.md + memory/ approach
│   └── [others]/         # Other tools as we discover them
│
├── tests/                # Standardized test prompts + contexts
│   ├── retrieval/
│   ├── correction/
│   ├── bias/
│   ├── user-model/
│   └── proportionality/
│
├── runner/               # Test execution framework
│   ├── run-benchmark.sh  # Execute all tests across all competitors
│   └── blind-eval.sh    # Sub-agent evaluator (doesn't know which is which)
│
├── results/              # Raw outputs + scored results
│   └── YYYY-MM-DD/
│
└── analysis/             # Comparative findings
    └── latest.md
```

## Running

```bash
# Full benchmark (all competitors, all tests)
./runner/run-benchmark.sh

# Single competitor
./runner/run-benchmark.sh distill

# Blind evaluation of latest results
./runner/blind-eval.sh
```

## Competitors to evaluate

- [ ] claude-distill (our system)
- [ ] Vanilla Claude (no memory enhancements)
- [ ] Standard CLAUDE.md + memory/ files (built-in system)
- [ ] [Research needed: other memory MCP servers, skills, approaches]

## Key questions

1. Where does distill clearly outperform alternatives?
2. Where do alternatives outperform distill? (honest assessment)
3. What capabilities are unique to distill vs available elsewhere?
4. What can we learn from competitors' approaches?
5. Are there scenarios where NO enhancement helps?

## Rules

- NO real company names in any test content (use Helios Financial)
- Blind evaluation means the scorer sees "System A" and "System B", never names
- Results published honestly — including where distill loses
- Focus on capability gaps, not marketing claims
