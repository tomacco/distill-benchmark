# distill — aura-distill Knowledge System

## What it is

[aura-distill](https://github.com/tomacco/aura-distill) uses a tiered knowledge architecture:
- A retrieval rules file (.claude/rules/distill.md) that tells Claude how to find knowledge
- A SPINE index (knowledge/SPINE.md) that maps topics to files
- Tiered knowledge files organized by domain

## How it works

1. Rules file is placed in .claude/rules/ so Claude auto-loads it
2. The rules instruct Claude to consult the SPINE index for relevant knowledge
3. SPINE maps queries to specific knowledge files (architecture, preferences, team, etc.)
4. Knowledge files contain structured, retrievable facts with confidence levels

## Key differentiator

Proportional retrieval — Claude only loads what's relevant, not the entire knowledge base.
Correction durability — explicit "don't suggest X" entries survive context pressure.
