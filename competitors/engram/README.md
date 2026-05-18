# engram

**Repo**: https://github.com/Gentleman-Programming/engram
**Stars**: 3.6k
**Approach**: Single Go binary + SQLite + FTS5 full-text search
**Architecture**: MCP server with 19 tools for save/search/session management

## How it works

Agent completes work → calls `mem_save` with structured fields (title, type, what, why, where, learned) → persisted to SQLite with FTS5 indexing → next session: agent searches memory via `mem_search`/`mem_context`.

## Knowledge format

Memories are structured observations with:
- Title + message content
- Type classification (architecture, decision, bugfix, etc.)
- Topic keys for organization
- Project scoping
- Timestamps + session metadata

Retrieval via FTS5 full-text search, not vector/embedding.

## For benchmark

Since engram uses an MCP server (mem_search tool calls), we simulate what the agent
would receive after a `mem_context` call at session start — the retrieved observations
formatted as engram would return them.
