# distill-slim — prototype (2026-06-13)

The evidence-pruned redesign of distill's always-on context, built from the 2026-06-12
benchmark findings (research/2026-06-12-overnight/memory-backends.md §6-§7 in aura-distill):

| Kept (earned its tokens) | Dropped/moved (no measurable read-side value) |
|---|---|
| Thin index pointer + read-before-answer trigger (incl. action triggers) | Marker taxonomy ([CONTEXT]/[UPDATED]/[PROVISIONAL]/...) |
| ⛔ corrections as an ALWAYS-LOADED table (bm25's win, made structural) | Confidence/assertiveness ladder |
| Bias-resistance sentence (won 3/3 seeds) | Origin tracking prose |
| Proportionality sentence (won 3/3 seeds) | Memory-pressure protocol (write-path; lives in /distill) |
| Style block (parity with all arms) | Per-file mini-summaries in the SPINE |

Always-on cost: ~550 tokens vs ~1.9k (full rules) — and the diet SPINE is ~120 tokens vs 3.6k
in the real installation. Same knowledge files as every other arm.

Hypothesis under test: slim ≥ full distill overall, and slim closes the corrections gap.
If a deleted element turns out load-bearing, the per-category deltas will say which.
