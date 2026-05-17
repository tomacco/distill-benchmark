# Testing Methodology

## Isolated Profile Pattern

Each competitor runs in an isolated Claude Code config directory. This ensures:
- No cross-contamination between systems
- Clean baseline per test
- Reproducible results

### How it works

```
~/.claude-personal/     ← Has API auth (OAuth session). Used as base for all tests.
~/.claude-sofia/        ← Persona: lead engineer (knowledge + rules)
~/.claude-marcus/       ← Persona: PM (knowledge + rules)
~/.claude-distill-test/ ← distill competitor config
~/.claude-vanilla-test/ ← vanilla baseline config
~/.claude-memory-md/    ← standard memory.md competitor config
```

### Test isolation protocol

Before EACH test condition:
1. **Blank `~/.claude/CLAUDE.md`** — prevents personal context leaking
2. **Clear `$REAL_CONFIG/rules/`** — removes any active rules
3. **Hide `~/.claude/distill/`** — `mv` to `_distill_hidden` (the real install)
4. **Hide `$REAL_CONFIG/distill/`** — same for the personal config
5. **Install ONLY the competitor's knowledge** into a temp dir
6. **Point rules (if any) to that temp dir**

After EACH condition:
1. Restore `~/.claude/CLAUDE.md`
2. Restore rules
3. Unhide distill directories
4. Clean temp dirs

### The auth problem

Claude Code requires an authenticated session. New config dirs don't have auth.
Solution: ALL tests run with `CLAUDE_CONFIG_DIR="$HOME/.claude-personal"` (which has OAuth),
but we swap the rules/knowledge in and out of that dir temporarily.

### Why not just use --append-system-prompt?

We use BOTH:
- `--append-system-prompt-file` for injecting test CONTEXT (simulated session history, bias conditions)
- Rules dir + knowledge files for injecting the SYSTEM UNDER TEST (distill rules, memory.md, etc.)

This mirrors real usage: the system prompt is what the user experiences, the rules/knowledge is what the tool provides.

### Running a single test

```bash
REAL_CONFIG="$HOME/.claude-personal"
CLAUDE_BIN="node /opt/homebrew/opt/claude-code-npm/libexec/lib/node_modules/@anthropic-ai/claude-code/cli.js"
SANDBOX_PROFILE='(version 1)(allow default)(deny file-read* (literal "/Library/Application Support/ClaudeCode/managed-settings.json"))'

# Environment that forces Anthropic API (not Bedrock)
CLAUDE_CONFIG_DIR="$REAL_CONFIG" \
CLAUDE_CODE_USE_BEDROCK=0 \
ANTHROPIC_DEFAULT_OPUS_MODEL= \
ANTHROPIC_DEFAULT_SONNET_MODEL= \
ANTHROPIC_DEFAULT_HAIKU_MODEL= \
ANTHROPIC_MODEL= \
AWS_PROFILE= AWS_ACCESS_KEY_ID= AWS_SECRET_ACCESS_KEY= \
AWS_SESSION_TOKEN= AWS_DEFAULT_REGION= \
AWS_SHARED_CREDENTIALS_FILE=/dev/null AWS_CONFIG_FILE=/dev/null \
sandbox-exec -p "$SANDBOX_PROFILE" \
$CLAUDE_BIN --dangerously-skip-permissions -p "$PROMPT"
```

### sandbox-exec

macOS sandboxing to prevent reading managed settings (which would override our test config):
```
(version 1)(allow default)(deny file-read* (literal "/Library/Application Support/ClaudeCode/managed-settings.json"))
```

### Timeout

Each condition gets 120 seconds. Background process + watchdog kill:
```bash
( run_command > output ) &
PID=$!
( sleep 120 && kill "$PID" 2>/dev/null ) & WD=$!
wait "$PID" 2>/dev/null || true
kill "$WD" 2>/dev/null || true
```

### Known issues

1. **CWD confound** — Claude sees the current repo and may reference it. Doesn't affect most tests but can refuse prompts that don't match the project.
2. **`~/.claude/distill/` vs `~/.claude-personal/distill/`** — two paths, both must be hidden. The runner must hide BOTH.
3. **VERSION bump race** — GitHub Action bumps version on every push to main. Always `git stash && git pull --rebase` before pushing.
4. **Domain-adjacent terms** — even generic-sounding words ("savings", "portfolio") can leak context when the project domain overlaps the tester's employer. Use completely different industries.

### Blind evaluation

For competitive benchmarks, the evaluator sub-agent receives:
- "System A output" and "System B output" (no names)
- Scoring rubric
- It scores both without knowing which is distill vs competitor

This eliminates experimenter bias in evaluation.
