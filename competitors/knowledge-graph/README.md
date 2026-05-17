# knowledge-graph — shaneholloman/mcp-knowledge-graph

## What it is

[mcp-knowledge-graph](https://github.com/shaneholloman/mcp-knowledge-graph) is an MCP server that provides:
- JSONL-based knowledge graph storage
- Entities and relations as first-class concepts
- Node.js runtime
- Graph traversal for context retrieval

## How it works

1. Knowledge is stored as entities (nodes) and relations (edges) in JSONL format
2. An MCP server exposes tools for querying the graph
3. Claude uses the MCP tools to traverse relations and find relevant context

## Notes

Requires Node.js/npm. MCP server must be configured and running during tests.
