# sqlite-bm25 — BM25 retrieval over the same knowledge, via a real CLI tool

**Research prototype built in-repo (2026-06-12), not an external product.** Tests the strongest
minimal-dependency challenger from the memory-backend survey: replace the always-on index +
on-demand file reads with a near-zero always-on footprint + an explicit retrieval tool call.

## Design

- The exact same Helios Financial knowledge as the `distill` competitor, chunked by `## ` section
  into an SQLite FTS5 table (`build_db.py`, Python stdlib only — no dependencies).
- The agent gets: `kb.py` (search CLI, ~40 LoC), `knowledge.db`, and a ~150-token rules file
  instructing it to search before answering. The markdown sources are NOT in the workspace —
  retrieval through the tool is the only access path.
- BM25 ranking via `bm25(kb)`; OR-query over alphanumeric tokens (sanitized for FTS5 syntax).

## What this isolates

vs `distill`: same knowledge, but ~150 always-on tokens instead of ~1,900 (rules) + ~300 (SPINE),
at the price of a tool round-trip per retrieval and reliance on the agent actually calling the tool.
The survey literature ("Is Grep All You Need?", LoCoMo file-agent results) predicts parity on recall
at this KB scale; the open questions are tool-call reliability and total token cost.

## Honesty notes

- This is a steelman we built ourselves; if it beats distill, that's the finding we came for.
- Failure mode to watch in raw outputs: agent answers WITHOUT searching (rules ignored) — score
  honestly; that reliability gap is part of the result.
