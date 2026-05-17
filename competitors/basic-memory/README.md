# basic-memory — basicmachines-co/basic-memory

## What it is

[basic-memory](https://github.com/basicmachines-co/basic-memory) is an MCP server providing:
- Markdown-based knowledge storage (vault)
- SQLite for metadata
- Vector search for retrieval
- Python-based

## How it works

1. Knowledge is stored as markdown files in a "vault" directory
2. Files are indexed into SQLite with vector embeddings
3. An MCP server exposes search/retrieve tools to Claude
4. Claude queries the MCP server to find relevant knowledge

## Notes

Requires Python 3.10+, pip/pipx install. MCP server must be running during tests.
