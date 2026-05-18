# Apple Container Isolation (WIP)

## Status: Blocked by VPN

Apple Container (github.com/apple/container) is installed and works for basic containers,
but outbound networking fails when corporate VPN is active.

## What works
- Installed v0.12.3 on macOS 26 + Apple M4 Pro
- `container system start` — service runs
- `container run alpine echo hello` — works (~13s cold, instant warm)
- `container run node:22-slim node --version` — works
- Container gets IP on vmnet (192.168.65.0/24), gateway 192.168.65.1

## What doesn't work
- No outbound internet from containers (DNS and raw IP both fail)
- Gateway (192.168.65.1) is unreachable from inside container
- npm install, curl, wget — all timeout

## Root cause
Corporate VPN (utun4) captures the default route. The vmnet bridge (bridge100)
has its default route rejected (`!` flag in routing table). Traffic from
192.168.65.0/24 has no path to the internet.

```
$ netstat -rn | grep default
default            link#22            UCSg                utun4        ← VPN grabs all
default            192.168.1.1        UGScIg                en0
default            link#24            UCSIg           bridge100      ! ← blocked
```

## Pending steps to fix

1. **Test without VPN** — disconnect VPN, run `container run --rm alpine ping -c1 8.8.8.8`
   - If this works → VPN is the only blocker
   - If this fails → deeper vmnet/NAT issue

2. **Try static route bypass** (with VPN on):
   ```
   sudo route add 192.168.65.0/24 -interface bridge100
   ```
   VPN may override this. Test immediately after adding.

3. **Try host networking mode** — check if Apple Container supports `--network host`
   or equivalent that shares the host's network stack (like Docker's `--net=host`)

4. **Pre-install Claude Code in image** — build a custom image with Claude Code baked in,
   mount only the API key at runtime. This avoids needing npm install inside the container:
   ```
   FROM node:22-slim
   RUN npm install -g @anthropic-ai/claude-code
   ```
   Then: `container run -v ~/.claude-personal:/root/.claude-personal benchmark-image claude -p "prompt"`

5. **Alternative: use Dockerfile with volume mounts** — mount the project dir + config dir
   into the container, run Claude from there

## Why we want this
- True filesystem isolation (no backup/restore dance)
- Zero risk of config leakage between competitors
- Each test runs in a fresh ephemeral environment
- Can measure resource usage (CPU, memory) per competitor
- No EXIT trap needed — container dies, everything dies

## Current workaround
Using local profile isolation (isolate_begin/isolate_end from aura-distill).
Works but requires careful backup/restore of ~/.claude/ and ~/.claude-personal/.
