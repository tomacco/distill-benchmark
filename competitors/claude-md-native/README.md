# claude-md-native — native CLAUDE.md index + on-demand topic files

**Research prototype built in-repo (2026-06-12), not an external product.** The "do nothing,
use the native feature" control from the memory-backend survey: Claude Code natively auto-loads
a project `CLAUDE.md`; topic files are read on demand. This is architecturally identical to
aura-distill (thin index + lazy files) but with a ~120-token index and NO retrieval protocol,
markers, confidence metadata, or always-on preference block.

## What this isolates

vs `distill`: the same knowledge behind the same architecture — the only difference is distill's
~1,900-token rules protocol (+ markers + always-on prefs). If scores tie, the protocol text isn't
earning its tokens on these tests. If distill wins (expected on bias/correction/proportionality
categories), the delta IS the measured value of the protocol.

## Simulation fidelity

Real native auto-memory (v2.1.59+) also auto-MAINTAINS its files (write path). This competitor
only reproduces the read path, which is what these single-turn tests exercise.
