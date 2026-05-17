# distill-benchmark

This project benchmarks Claude memory/knowledge enhancement tools against each other.

## Your role

You are running competitive benchmarks. You must be HONEST — this project exists to find truth, not to validate distill. If another approach outperforms distill, that's a finding to celebrate and learn from.

## Key principles

1. **Blind evaluation**: when scoring outputs, you MUST NOT know which system produced them. Use the blind-eval approach.
2. **Honest reporting**: distill losing on a dimension is valuable data, not a failure.
3. **No real company names**: all test scenarios use fictional companies (Helios Financial by default).
4. **Reproducible**: every test must be re-runnable with the same inputs.

## Project context

- aura-distill: https://github.com/tomacco/aura-distill
- Research findings: https://tomacco.github.io/aura-distill/research/
- The system uses: rules/distill.md (retrieval rules) + SPINE index + tiered knowledge files
- Key capabilities to benchmark: retrieval, correction durability, bias resistance, proportionality, user model

## First steps

1. Research what other Claude memory tools exist (MCP servers, skills, custom instructions approaches)
2. Design the test battery (use scenarios from aura-distill's existing research as starting points)
3. Build the runner framework
4. Execute and evaluate
