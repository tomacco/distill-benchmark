# Claude Code Memory/Knowledge Enhancement Tools: Landscape Research

**Date**: 2026-05-17  
**Purpose**: Competitive landscape for distill-benchmark

---

## Summary

The Claude memory tools ecosystem breaks into **6 categories**:

1. **Mega-project (plugin/hooks)** — claude-mem (76k stars)
2. **MCP Memory Servers** — basic-memory, mcp-knowledge-graph, memory-graph, mnemex, etc.
3. **Hooks-based memory systems** — claude-memory-compiler, claude-code-auto-memory, claude-memory-engine
4. **Skills/templates** — skill-based-architecture, claude-code-memory-bank, claude-memory-template
5. **External memory platforms** — mem0 (56k stars), pinkpixel-dev/mem0-mcp
6. **Rules/instructions-only approaches** — aura-distill, yegor256/prompt, CLAUDE.md patterns

---

## TIER 1: Major Projects (1000+ stars, active)

### 1. claude-mem (thedotmack)
- **URL**: https://github.com/thedotmack/claude-mem
- **Stars**: 76,252
- **Last activity**: May 17, 2026 (v13.2.0, 1899 commits, 270 releases)
- **Description**: Persistent context across sessions for every agent. Captures everything your agent does, compresses it with AI, and injects relevant context into future sessions.
- **Mechanism**: Claude Code plugin + lifecycle hooks + MCP tools + worker service
- **How it works**: 
  - 5 lifecycle hooks (SessionStart, UserPromptSubmit, PostToolUse, Stop, SessionEnd)
  - Worker service (Bun, port 37777) with HTTP API and web viewer UI
  - SQLite + Chroma vector DB for hybrid semantic/keyword search
  - Progressive disclosure: index → timeline → full details (token-efficient)
  - Privacy controls via `<private>` tags
  - Citation system referencing past observations by ID
- **Dependencies**: Node.js 18+, Bun (auto-installed), uv (auto-installed), SQLite 3
- **Status**: **DOMINANT PLAYER** — extremely mature, massive community

### 2. basic-memory (basicmachines-co)
- **URL**: https://github.com/basicmachines-co/basic-memory
- **Stars**: 3,040
- **Last activity**: May 16, 2026 (v0.21.1, 79 releases)
- **Description**: AI conversations that actually remember. Never re-explain your project to your AI again.
- **Mechanism**: MCP server
- **How it works**:
  - Plain Markdown files as primary knowledge store (human + AI read/write)
  - Local SQLite index with FastEmbed vector embeddings for semantic search
  - Knowledge graph with Observations and Relations (wikilinks)
  - Bidirectional sync between filesystem and database
  - Optional cloud version (Tigris S3, Neon Postgres)
  - Works with Claude Desktop, Claude Code, Cursor, VS Code, ChatGPT, Codex
- **Dependencies**: Python 3.12+, uv
- **Status**: **STRONG CONTENDER** — professional, well-maintained, broad integration

### 3. claude-memory-compiler (coleam00)
- **URL**: https://github.com/coleam00/claude-memory-compiler
- **Stars**: 1,056
- **Last activity**: May 17, 2026
- **Description**: Hooks capture sessions, Claude Agent SDK extracts decisions/lessons, LLM compiler organizes into cross-referenced knowledge articles (inspired by Karpathy's LLM Knowledge Base).
- **Mechanism**: Claude Code hooks (SessionEnd + PreCompaction)
- **How it works**:
  - SessionEnd/PreCompaction hooks → flush.py captures transcripts
  - compile.py transforms daily logs into organized concept articles
  - Index-based retrieval (no vector DB, no RAG)
  - SessionStart hook injects index.md into next session
  - Health checking with link validation, orphan/contradiction detection
- **Dependencies**: Python + uv, Claude Agent SDK
- **Status**: **NOTABLE** — lean design, Karpathy-inspired, popular fork target

### 4. claude-sessions (iannuttall)
- **URL**: https://github.com/iannuttall/claude-sessions
- **Stars**: 1,200
- **Last activity**: May 15, 2026
- **Description**: Custom slash commands for comprehensive development session tracking and documentation.
- **Mechanism**: Claude Code custom slash commands
- **How it works**:
  - Markdown command files in `commands/` directory
  - Session lifecycle management (start, update, end, view, list)
  - Timestamped markdown files in `sessions/` directory
  - Auto git change tracking and summarization
- **Status**: **POPULAR** but limited scope — session logging, not semantic retrieval

---

## TIER 2: Serious MCP Servers (50-1000 stars, active)

### 5. mcp-knowledge-graph (shaneholloman)
- **URL**: https://github.com/shaneholloman/mcp-knowledge-graph
- **Stars**: 857
- **Last activity**: May 16, 2026 (v1.3.2)
- **Description**: Fork of the official Anthropic MCP memory server focused on local development. Knowledge graph with entities, relations, observations stored in JSONL.
- **Mechanism**: MCP server
- **How it works**:
  - Master database + optional named databases
  - JSONL file storage
  - Project-local memory via `.aim` directories
  - Safety markers against accidental overwrites
- **Status**: **WELL-ADOPTED** fork of official server with local-dev improvements

### 6. claude-code-memory-setup (lucasrosati)
- **URL**: https://github.com/lucasrosati/claude-code-memory-setup
- **Stars**: 652
- **Last activity**: May 17, 2026
- **Description**: Up to 71.5x fewer tokens per session using Obsidian + Graphify. Persistent memory, codebase knowledge graphs, and chat import pipeline.
- **Mechanism**: Claude Code skill + Obsidian vault + Graphify AST tool
- **How it works**:
  - Obsidian vault (Zettelkasten) for decisions/architecture/session logs
  - Graphify (pip install) transforms codebase into graph.json via tree-sitter AST
  - Chat import pipeline auto-archives conversations
  - Graph queries ~280 tokens vs ~20,000 for re-reading 40 files
  - Git hooks for incremental graph rebuilds
- **Dependencies**: Obsidian, Graphify, Python 3
- **Status**: **NOTABLE** — interesting approach combining existing tools; high token savings claims

### 7. memory-graph (memory-graph org)
- **URL**: https://github.com/memory-graph/memory-graph
- **Stars**: 201
- **Last activity**: May 16, 2026 (v0.12.4, 36 releases, 1200+ tests)
- **Description**: Graph DB-based MCP memory server for coding agents with intelligent relationship tracking.
- **Mechanism**: MCP server
- **How it works**:
  - Graph database (SQLite default, Neo4j, FalkorDB, Turso options)
  - 7 relationship categories with temporal queries
  - 9 core tools (12 in extended mode)
  - Multi-hop reasoning, migration tools between backends
  - Optional team multi-tenancy
- **Dependencies**: Python 3.9+, pipx
- **Status**: **WELL-ENGINEERED** — multi-backend, strong test suite, active releases

### 8. VAMFI/claude-user-memory
- **URL**: https://github.com/VAMFI/claude-user-memory
- **Stars**: 186
- **Last activity**: May 15, 2026
- **Description**: Autonomous agent substrate for Claude Code CLI. Research-Plan-Implement workflows with quality gates, TDD enforcement, multi-agent coordination. 4.8-5.5x faster development.
- **Mechanism**: Claude Code skill/substrate
- **Status**: **INTERESTING** — agent workflows, less pure memory focus

### 9. claude-code-auto-memory (severity1)
- **URL**: https://github.com/severity1/claude-code-auto-memory
- **Stars**: 144
- **Last activity**: May 16, 2026 (v0.9.2, 71 commits)
- **Description**: Plugin that automatically maintains CLAUDE.md files.
- **Mechanism**: Claude Code Plugin (PostToolUse + Stop hooks + isolated agents)
- **How it works**:
  - PostToolUse hook tracks Edit/Write/Bash operations (zero-token)
  - Stop hook spawns isolated "memory-updater" agent
  - Memory-processor skill analyzes changes, updates marker-delimited sections in CLAUDE.md
  - Monorepo support via hierarchical CLAUDE.md files
  - Two modes: real-time or git-commit-only
- **Status**: **ACTIVE, PRACTICAL** — automates the CLAUDE.md maintenance problem

### 10. claude-memory-engine (HelloRuru)
- **URL**: https://github.com/HelloRuru/claude-memory-engine
- **Stars**: 129
- **Last activity**: May 11, 2026 (v2.0)
- **Description**: Memory system built with hooks + markdown. Zero dependencies.
- **Mechanism**: Claude Code hooks + slash commands (36 markdown files)
- **How it works**:
  - 8 hooks (session-start/end, pre-compact, memory-sync, write-guard, etc.)
  - 18+ slash commands (/reflect, /analyze, /correct, /handoff, etc.)
  - "Student Loop" 8-step learning cycle with pattern detection
  - Cross-device sync via private GitHub repo
  - Smart Context loads per-project memory by working directory
  - ~200-500 tokens per session start
- **Dependencies**: None (pure markdown + hooks)
- **Status**: **LEAN, OPINIONATED** — zero-dep, bilingual EN/ZH

### 11. obra/claude-memory-extractor
- **URL**: https://github.com/obra/claude-memory-extractor
- **Stars**: 113
- **Last activity**: May 17, 2026
- **Description**: Analyzes Claude Code conversation logs to extract transferable lessons.
- **Mechanism**: Standalone CLI tool (post-processing)
- **How it works**:
  - Reads JSONL conversation files, breaks into chunks
  - Multi-dimensional analysis: Five Whys, psychological drivers, prevention strategies
  - Outputs markdown with YAML frontmatter, confidence scoring (1-5)
  - 85% match to human ground truth validation
- **Dependencies**: Node.js, Claude CLI
- **Status**: **UNIQUE APPROACH** — extraction/analysis, not real-time memory

### 12. mem0-mcp (pinkpixel-dev)
- **URL**: https://github.com/pinkpixel-dev/mem0-mcp
- **Stars**: 95
- **Last activity**: May 12, 2026
- **Description**: mem0 MCP Server — drop-in memory for AI agents via MCP.
- **Mechanism**: MCP server wrapping mem0 platform
- **How it works**:
  - Three backends: mem0 cloud, Supabase pgvector, or local in-memory
  - Tools: add_memory, search_memory, delete_memory
  - Scoping via userId, agentId, appId, sessionId
  - Semantic similarity search with filtering
- **Dependencies**: Node.js 18+, MEM0_API_KEY or OPENAI_API_KEY
- **Status**: **BRIDGE TOOL** — connects mem0 ecosystem to MCP

### 13. mem0-mcp-selfhosted (elvismdev)
- **URL**: https://github.com/elvismdev/mem0-mcp-selfhosted
- **Stars**: 84
- **Last activity**: May 13, 2026
- **Description**: Self-hosted mem0 MCP server with Qdrant + Neo4j + Ollama.
- **Mechanism**: MCP server (self-hosted mem0 stack)
- **Status**: Self-hosted alternative to cloud mem0

### 14. Durafen/Claude-code-memory
- **URL**: https://github.com/Durafen/Claude-code-memory
- **Stars**: 75
- **Last activity**: April 17, 2026
- **Description**: Universal semantic indexer providing persistent memory through knowledge graphs, Tree-sitter parsing, and Qdrant vector search.
- **Mechanism**: MCP server + semantic indexer
- **Status**: Interesting but slightly less active

### 15. WhenMoon-afk/claude-memory-mcp
- **URL**: https://github.com/WhenMoon-afk/claude-memory-mcp
- **Stars**: 67
- **Last activity**: May 4, 2026
- **Description**: Local-first continuity database for AI agents. Stores compact artifacts (snapshots, decisions, project state) rather than full transcripts.
- **Mechanism**: MCP server (SQLite, graph model)
- **How it works**:
  - Single `continuity` tool with actions: save, search, get, bundle, merge
  - Five artifact types: snapshot, decision, project_state, bundle, meta_snapshot
  - Progressive disclosure (compact summaries first)
  - No autonomous recording — explicit operations only
  - Portable JSON export/import
- **Status**: **INTENTIONALLY MINIMAL** — "boring infrastructure", no telemetry

### 16. mcp-duckdb-memory-server (IzumiSy)
- **URL**: https://github.com/IzumiSy/mcp-duckdb-memory-server
- **Stars**: 57
- **Last activity**: May 15, 2026 (v1.1.10, 151 commits)
- **Description**: Knowledge graph memory with DuckDB backend replacing JSON.
- **Mechanism**: MCP server
- **Status**: Active, DuckDB-powered alternative to official memory server

### 17. sdimitrov/mcp-memory
- **URL**: https://github.com/sdimitrov/mcp-memory
- **Stars**: 62
- **Last activity**: April 22, 2026
- **Description**: PostgreSQL + pgvector + BERT embeddings for semantic memory.
- **Mechanism**: MCP server
- **Status**: Early stage (2 commits) but interesting tech stack

### 18. msync (debugtheworldbot)
- **URL**: https://github.com/debugtheworldbot/msync
- **Stars**: 51
- **Last activity**: May 8, 2026
- **Description**: Sync Claude Code memories to Claude clients (claude.ai / Claude App).
- **Mechanism**: Standalone CLI tool
- **How it works**: Scans auto-generated memory locations, deduplicates, copies to clipboard for claude.ai/settings
- **Status**: Utility tool bridging Claude Code <-> Claude web

---

## TIER 3: Notable Smaller Projects & Approaches (20-50 stars)

### 19. mnemex (MadAppGang)
- **URL**: https://github.com/MadAppGang/mnemex
- **Stars**: 38
- **Last activity**: May 14, 2026 (v0.30.1, 38 releases, 194 commits)
- **Description**: Semantic code search via MCP. Tree-sitter parsing, BM25 + vector search, symbol graph with PageRank.
- **Mechanism**: MCP server + CLI + IDE plugins
- **How it works**: LanceDB local storage, hybrid search, doc indexing, watch mode, Git hooks
- **Status**: **VERY ACTIVE** — many releases, broad feature set. More "code search" than "memory" per se.

### 20. claude-code-memory-bank (hudrazine)
- **URL**: https://github.com/hudrazine/claude-code-memory-bank
- **Stars**: 38
- **Last activity**: March 30, 2026
- **Description**: Memory management optimized for Claude Code, based on Cline Memory Bank.
- **Mechanism**: Claude Code skill (CLAUDE.md + @import + custom commands)
- **How it works**:
  - 6 hierarchical markdown files (projectbrief → progress)
  - `memory-bank/` directory imported via @import in CLAUDE.md
  - Custom slash commands for workflows
- **Status**: Port of Cline Memory Bank to Claude Code. Less active recently.

### 21. ccat (nwiizo)
- **URL**: https://github.com/nwiizo/ccat
- **Stars**: 35
- **Last activity**: May 1, 2026
- **Description**: CLAUDE.md Context Analyzer — CLI tool for analyzing/managing Claude Code memory files.
- **Mechanism**: Standalone Rust CLI tool
- **How it works**: Parallel file scanning, import chain resolution, diagnostics (circular imports, security issues), multiple export formats
- **Status**: Utility for managing CLAUDE.md complexity, not a memory system itself

### 22. claude-memory-template (lukasz-fedor)
- **URL**: https://github.com/lukasz-fedor/claude-memory-template
- **Stars**: 29
- **Last activity**: May 2, 2026
- **Description**: Starter template for Claude Code memory: modular rules with glob patterns, persistent memory, session continuity with auto-handover hook, .claudeignore setup.
- **Mechanism**: Template/boilerplate (hooks + rules + .claudeignore)
- **Status**: Starter kit, not a tool

### 23. danielmarbach/mnemonic
- **URL**: https://github.com/danielmarbach/mnemonic
- **Stars**: 22
- **Last activity**: May 13, 2026 (v0.31.0, 52 releases, 497 commits)
- **Description**: Local MCP memory server backed by plain markdown + JSON. Git-synced. Semantic search via Ollama.
- **Mechanism**: MCP server
- **How it works**:
  - Dual vault: global (`~/mnemonic-vault/`) + project-local (`.mnemonic/`)
  - Local Ollama embeddings (no cloud)
  - Typed relationships between notes (explains, supersedes, example-of)
  - Lifecycle management: temporary vs permanent knowledge
  - Git integration (every mutation = descriptive commit)
  - Plain markdown: readable, diffable, mergeable
- **Dependencies**: Ollama (local embeddings)
- **Status**: **VERY ACTIVE** — 52 releases, 497 commits. Under-starred for its maturity.

### 24. serkansmg/smg-claude-memory-mcp
- **URL**: https://github.com/serkansmg/smg-claude-memory-mcp
- **Stars**: 22
- **Last activity**: May 16, 2026
- **Description**: Production-grade vector memory MCP server. Semantic search, per-project isolation, rules enforcement, team sharing via git.
- **Mechanism**: MCP server
- **Status**: Active, team-focused

---

## TIER 4: Frameworks & Skill Systems (tangential but relevant)

### 25. skill-based-architecture (WoJiSama)
- **URL**: https://github.com/WoJiSama/skill-based-architecture
- **Stars**: 244
- **Last activity**: May 17, 2026 (v1.14.0)
- **Description**: Meta-skill that distills codebase rules/workflows into a single `skills/<name>/` directory. Cross-harness (Cursor, Claude Code, Codex, Windsurf, Gemini).
- **Mechanism**: Claude Code skill framework
- **Relevance**: Includes after-action review (AAR) and self-maintenance. Structural pattern for knowledge, not memory retrieval.

### 26. agentic-harness-patterns-skill (keli-wen)
- **URL**: https://github.com/keli-wen/agentic-harness-patterns-skill
- **Stars**: 270
- **Last activity**: May 17, 2026
- **Description**: Agent skill teaching production patterns distilled from Claude Code's 512k-line codebase. Memory is Pattern #1.
- **Mechanism**: Claude Code skill (npx skills add)
- **Relevance**: Educational — describes memory patterns but doesn't implement persistence itself.

### 27. yegor256/prompt
- **URL**: https://github.com/yegor256/prompt
- **Stars**: 142
- **Last activity**: May 17, 2026
- **Description**: A plain-text prompt that teaches elegant coding — save to ~/.claude/CLAUDE.md.
- **Mechanism**: CLAUDE.md content (pure instructions)
- **Relevance**: Instructions-only approach. No memory persistence, just behavioral tuning.

---

## TIER 5: External Platforms (not Claude-specific)

### 28. mem0 (mem0ai)
- **URL**: https://github.com/mem0ai/mem0
- **Stars**: 55,913
- **Last activity**: May 17, 2026
- **Description**: Universal memory layer for AI Agents. Not Claude-specific but integrable via MCP wrappers.
- **Mechanism**: Platform/SDK (Python/JS) with managed cloud option
- **Status**: Major platform. Claude integration via pinkpixel-dev/mem0-mcp or elvismdev/mem0-mcp-selfhosted.

### 29. Official MCP Memory Server (Anthropic/modelcontextprotocol)
- **URL**: https://github.com/modelcontextprotocol/servers (inside `src/memory/`)
- **Stars**: 85,785 (entire servers repo)
- **Last activity**: May 17, 2026
- **Description**: Anthropic's reference implementation. Knowledge graph stored in JSONL.
- **Mechanism**: MCP server
- **How it works**: Entities + Relations + Observations in JSONL. 8 tools. Simple, reference-grade.
- **Status**: **CANONICAL** but basic — many forks add features (shaneholloman, IzumiSy, etc.)

---

## TIER 6: Rules/Distillation Approaches (aura-distill's category)

### 30. aura-distill (tomacco)
- **URL**: https://github.com/tomacco/aura-distill
- **Stars**: 11
- **Last activity**: May 17, 2026
- **Description**: Tiered knowledge system with SPINE index + rules-based retrieval. Pure markdown, no database, no MCP server.
- **Mechanism**: `~/.claude/rules/distill.md` (retrieval rules) + `~/.claude/distill/SPINE.md` (index) + tiered files
- **How it works**:
  - SPINE.md is a knowledge index Claude reads at session start
  - Domain-specific files loaded on-demand based on user actions
  - Correction durability via confidence markers
  - User model tracking
  - Zero dependencies, zero infrastructure
- **Status**: Our project. Small community but unique approach (rules-only, no tooling overhead).

---

## Competitive Matrix

| Tool | Stars | Mechanism | Storage | Search | Deps | Maintenance |
|------|-------|-----------|---------|--------|------|-------------|
| claude-mem | 76k | Plugin+Hooks+MCP | SQLite+Chroma | Hybrid semantic+keyword | Node+Bun+uv | Extremely active |
| basic-memory | 3k | MCP server | Markdown+SQLite | Vector+fulltext | Python 3.12+ | Very active |
| claude-memory-compiler | 1k | Hooks | Markdown files | Index-based (no vector) | Python+uv | Active |
| mcp-knowledge-graph | 857 | MCP server | JSONL | String match | Node.js | Active |
| claude-code-memory-setup | 652 | Skill+Obsidian | Obsidian vault+graph.json | Graph queries | Obsidian+Python | Active |
| memory-graph | 201 | MCP server | SQLite/Neo4j/etc | Graph+temporal | Python | Very active |
| claude-code-auto-memory | 144 | Plugin (hooks) | CLAUDE.md | N/A (maintains docs) | None | Active |
| claude-memory-engine | 129 | Hooks+commands | Markdown | Pattern-based | None | Active |
| mem0-mcp | 95 | MCP server | mem0 cloud/Supabase | Semantic | Node+API keys | Active |
| mnemex | 38 | MCP+CLI | LanceDB | BM25+vector | Node.js | Very active |
| mnemonic | 22 | MCP server | Markdown+JSON | Ollama embeddings | Ollama | Very active |
| **aura-distill** | 11 | Rules only | Markdown | Pattern-match in SPINE | **None** | Active |

---

## Key Observations for Benchmarking

1. **claude-mem dominates** the ecosystem with 76k stars. Any benchmark must include it as the primary competitor.

2. **Three distinct philosophies**:
   - **Heavy infrastructure** (claude-mem, memory-graph, basic-memory): databases, embeddings, worker services
   - **Lightweight hooks** (claude-memory-compiler, claude-memory-engine, claude-code-auto-memory): markdown + Claude Code hooks, no external deps
   - **Pure rules** (aura-distill): zero infrastructure, relies on Claude's native file reading

3. **distill's unique position**: Only tool that is purely rules-based with zero dependencies. Potential advantages: no infra cost, no startup latency, no token overhead from tool calls, portable across machines. Potential disadvantages: no semantic search, relies on SPINE accuracy, limited by Claude's context window.

4. **Token efficiency claims to verify**:
   - claude-code-memory-setup: "71.5x fewer tokens"
   - claude-mem: "progressive disclosure" layered retrieval
   - claude-memory-engine: "200-500 tokens per session start"
   - aura-distill: session-start cost = reading SPINE.md only

5. **Correction durability** (key distill feature) is unique — no other tool explicitly tracks confidence, validated/provisional/hardened knowledge, or handles contradictions.

6. **Most tools focus on recall; few focus on learning quality** — claude-memory-extractor and claude-memory-compiler are exceptions that try to extract lessons, not just store transcripts.

---

## Recommended Benchmark Competitors (priority order)

1. **claude-mem** — must-include, dominant player
2. **basic-memory** — best-in-class MCP memory, professional
3. **claude-memory-compiler** — closest philosophy to distill (structured knowledge, not raw dumps)
4. **claude-memory-engine** — zero-dep hooks approach, good comparison point
5. **claude-code-auto-memory** — different goal (maintains CLAUDE.md automatically)
6. **mcp-knowledge-graph** — reference MCP approach (Anthropic's canonical pattern)
7. **Official MCP Memory Server** — baseline
8. **mnemonic** — under-starred but mature, local-first MCP with typed relationships
