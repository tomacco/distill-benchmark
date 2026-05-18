<p align="center">
  <img src="analysis/favicon.svg" width="64" height="64" alt="benchmark">
</p>

<h1 align="center">Persistent Context Benchmark</h1>

<p align="center">
  <strong>Blind evaluation of AI memory systems — 7 tools, 175 tests, honest results</strong>
</p>

<p align="center">
  <a href="https://tomacco.github.io/distill-benchmark/"><img src="https://img.shields.io/badge/📊_Live_Results-tomacco.github.io-e8b168?style=for-the-badge" alt="Live Results"></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/retrieval-4.3-6ec5a8?style=flat-square&labelColor=1e1a2d" alt="retrieval">
  <img src="https://img.shields.io/badge/correction-4.4-6ec5a8?style=flat-square&labelColor=1e1a2d" alt="correction">
  <img src="https://img.shields.io/badge/bias-4.1-e8b168?style=flat-square&labelColor=1e1a2d" alt="bias">
  <img src="https://img.shields.io/badge/user_model-4.3-e8b168?style=flat-square&labelColor=1e1a2d" alt="user model">
  <img src="https://img.shields.io/badge/proportionality-4.3-e8b168?style=flat-square&labelColor=1e1a2d" alt="proportionality">
  <img src="https://img.shields.io/badge/persistence-4.7-6ec5a8?style=flat-square&labelColor=1e1a2d" alt="persistence">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/tests-175-b0a0cc?style=flat-square&labelColor=1e1a2d" alt="175 tests">
  <img src="https://img.shields.io/badge/competitors-7-b0a0cc?style=flat-square&labelColor=1e1a2d" alt="7 competitors">
  <img src="https://img.shields.io/badge/evaluation-blind-b0a0cc?style=flat-square&labelColor=1e1a2d" alt="blind evaluation">
  <img src="https://img.shields.io/badge/Claude_Code-2.1.109-b0a0cc?style=flat-square&labelColor=1e1a2d" alt="Claude Code 2.1.109">
</p>

---

## What is this?

AI assistants forget everything between sessions. **Persistent context systems** attempt to fix this — giving AI a working memory of your preferences, decisions, and project knowledge.

This benchmark measures how well they actually work. Each system receives identical knowledge about a fictional company, then answers the same 25 prompts. A blind evaluator scores every response without knowing which system produced it.

## Results

**[→ See the full interactive results](https://tomacco.github.io/distill-benchmark/)**

| Rank | System | Score | Approach |
|------|--------|-------|----------|
| 🥇 | [knowledge-graph](https://github.com/shaneholloman/mcp-knowledge-graph) | 4.32 | JSONL entities + relations |
| 🥈 | [aura-distill](https://github.com/tomacco/aura-distill) | 4.21 | Rules + SPINE index + tiered files |
| 🥉 | [claude-mem](https://github.com/thedotmack/claude-mem) | 4.01 | Compressed progressive disclosure |
| 4 | [basic-memory](https://github.com/basicmachines-co/basic-memory) | 3.67 | Markdown vault + YAML frontmatter |
| 5 | [memory-engine](https://github.com/HelloRuru/claude-memory-engine) | 3.56 | Simple markdown files |
| 6 | [memory-compiler](https://github.com/coleam00/claude-memory-compiler) | 3.37 | Compiled articles |
| 7 | No Memory | 2.81 | Baseline (no enhancements) |

## What's tested

| Category | What it measures |
|----------|-----------------|
| **Retrieval** | Can it surface relevant knowledge without being asked? |
| **Correction** | When you say "don't suggest X," does it remember? |
| **Bias** | Does stored knowledge create tunnel vision? |
| **User Model** | Does it calibrate communication to your level? |
| **Proportionality** | Does solution complexity match problem size? |
| **Persistence** | Does persistent context save more tokens than it costs? |

## Methodology

1. Seed identical knowledge into each system (same facts, different formats)
2. Send the same prompt to all 7 systems under isolated conditions
3. Shuffle responses and label as "System A", "System B", etc.
4. Blind evaluator scores each on 3 criteria per category (1-5 scale)
5. De-anonymize only after scoring

All test data uses a fictional company (Helios Financial). Raw data is in `results/`.

## Running the benchmark

```bash
# Full run (all 7 competitors × 25 tests)
./runner/run-benchmark.sh

# Single competitor
./runner/run-benchmark.sh --competitor distill

# Single test
./runner/run-benchmark.sh --competitor distill --test R1

# Blind evaluation
./runner/blind-eval.sh

# Aggregate scores → analysis/data.json
./runner/aggregate.sh
```

## Structure

```
├── competitors/          # 7 systems, each with inject.sh + cleanup.sh
├── tests/                # 25 test prompts across 6 categories
├── runner/               # Orchestrator, blind evaluator, aggregator
├── results/              # Raw outputs + blind scores (by date)
├── analysis/             # Visualization (GitHub Pages) + data.json
└── docs/                 # GitHub Pages deployment
```

## Key findings

- **Correction durability** is where memory systems shine most vs no-memory (+3.4 gap)
- **Stored knowledge can create bias** — memory systems slightly underperform on bias resistance
- **Format matters** — JSONL graph and rules+SPINE both outperform flat markdown files
- **Latency cost** — memory systems average 20-22s vs 16s for no-memory (25-37% overhead)
- All raw data is public for independent verification

## License

MIT
