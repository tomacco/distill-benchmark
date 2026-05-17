# claude-mem — thedotmack/claude-mem

## What it is

[claude-mem](https://github.com/thedotmack/claude-mem) is a plugin-based memory system using:
- Hooks (pre/post commit)
- SQLite for structured storage
- ChromaDB for vector search
- Bun as runtime

## How it works

1. Knowledge is stored in a SQLite database with vector embeddings in ChromaDB
2. Hooks trigger on Claude interactions to store/retrieve relevant memories
3. Semantic search finds relevant memories based on the current conversation context

## Complexity

High — requires Bun, ChromaDB, SQLite, and proper hook configuration.
May need simplification or skipping if install proves unreliable in benchmark environment.
