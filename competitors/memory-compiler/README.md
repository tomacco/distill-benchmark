# memory-compiler — coleam00/claude-memory-compiler

## What it is

[claude-memory-compiler](https://github.com/coleam00/claude-memory-compiler) uses:
- Hooks to capture knowledge during Claude sessions
- Python + Claude SDK to "compile" raw interactions into structured articles
- Articles stored as markdown, loaded as context

## How it works

1. Raw knowledge is captured via hooks
2. A Python script uses Claude to compile/summarize into structured "articles"
3. Articles are placed in a knowledge directory
4. Claude loads relevant articles as context for future sessions

## Notes

For benchmarking, we skip the compilation step and place pre-compiled articles directly.
