# Testing Methodology

## Canonical Isolation Library

The test isolation protocol is maintained at:
```
~/git/tomaccos/aura-distill/tests/lib/isolate.sh
```

Source it and use: `isolate_begin`, `isolate_end`, `isolate_run`.
The benchmark runner sources this automatically.

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
~/.aura-distill-test/ ← distill competitor config
~/.claude-vanilla-test/ ← vanilla baseline config
~/.claude-memory-md/    ← standard memory.md competitor config
```

### Important: ~/.claude-personal is NOT a test subject

`~/.claude-personal` is infrastructure — it holds the OAuth session that lets us run tests.
It is NOT one of the competitors. We use it as the auth shell, then strip everything else out
so tests run clean. Think of it as "the key to the car" — we need it to drive, but the car
itself (knowledge, rules, instructions) gets swapped per competitor.

### Test isolation protocol (validated 2026-05-17)

Before EACH test condition:
1. **Blank `~/.claude/CLAUDE.md`** — prevents global personal context leaking
2. **Blank `$REAL_CONFIG/CLAUDE.md`** — prevents personal config instructions leaking
3. **Hide `~/.claude/rules/`** — removes global rules (including `distill.md`)
4. **Hide `$REAL_CONFIG/rules/`** — removes personal config rules
5. **Hide `~/.claude/distill/`** — `mv` to `_distill_isolation_bak`
6. **Hide `$REAL_CONFIG/distill/`** — same for the personal config
7. **Hide `~/.claude/plugins/`** — removes marketplace plugins (example-plugin, etc.)
8. **Hide `$REAL_CONFIG/plugins/`** — same for personal config
9. **Strip `settings.json`** — remove `customInstructions` and `enabledPlugins` keys
10. **Run from neutral CWD** — `mktemp -d /tmp/benchmark-workspace-XXXX` (no CLAUDE.md, no git repo)
11. **Install ONLY the competitor's knowledge** into the appropriate dirs
12. **Point rules (if any) to the competitor's config**

After EACH condition:
1. Restore `~/.claude/CLAUDE.md`
2. Restore `$REAL_CONFIG/CLAUDE.md`
3. Restore `~/.claude/rules/`
4. Restore `$REAL_CONFIG/rules/`
5. Unhide distill directories
6. Restore plugins directories
7. Restore `settings.json` files
8. Clean temp dirs

### What remains visible (non-confounding)

After full isolation, Claude still sees:
- **Git email** (`user@example.com`) — from git global config, same for all competitors
- **Home dir path** (`/Users/$USER/`) — filesystem metadata
- **Platform/shell** — macOS, zsh

These are identical across all test conditions and do not constitute knowledge about the user's
preferences, tech stack, or projects. They are NOT a confound.

### The auth problem

Claude Code requires an authenticated session. New config dirs don't have auth.
Solution: ALL tests run with `CLAUDE_CONFIG_DIR="$HOME/.claude-personal"` (which has OAuth),
but we swap the rules/knowledge in and out of that dir temporarily.

This means `~/.claude-personal` must be CLEAN before each test — only its auth tokens remain.
Everything that could influence Claude's behavior (CLAUDE.md, rules/, distill/, settings
customInstructions) gets temporarily removed. The only thing left is the OAuth session.

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

1. **CWD confound** — SOLVED: run from neutral temp dir (`/tmp/benchmark-workspace-XXXX`).
2. **Two config trees** — `~/.claude/` (global) and `$REAL_CONFIG` (`~/.claude-personal/`) BOTH have rules/, distill/, plugins/, CLAUDE.md, settings.json. The runner must clean BOTH paths.
3. **Plugins** — marketplace plugins (e.g. marketplace plugins) inject agents, commands, skills, and docs. Must hide `plugins/` dirs AND strip `enabledPlugins` from settings.json.
4. **VERSION bump race** — GitHub Action bumps version on every push to main. Always `git stash && git pull --rebase` before pushing.
5. **Domain-adjacent terms** — even generic-sounding words ("savings", "portfolio") can leak context when the project domain overlaps the tester's employer. Use completely different industries.
6. **settings.json residue** — `customInstructions` and `enabledPlugins` in settings.json are equivalent to CLAUDE.md/rules content. Must be stripped or it defeats isolation.

### Blind evaluation

For competitive benchmarks, the evaluator sub-agent receives:
- "System A output" and "System B output" (no names)
- Scoring rubric
- It scores both without knowing which is distill vs competitor

This eliminates experimenter bias in evaluation.
