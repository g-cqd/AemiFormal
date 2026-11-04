---
status: not-started
phase: tla
milestone: M1
target: TLASyntax
blocked-by: ["0004", "0039"]
date: 2026-11-04
---

# 0005 — Parser to a tape, with a fuzzer

Tokens to an AST tape with byte ranges and recovery after an error, on the parsing kit. **Done when** the corpus parses, malformed inputs give diagnostics, and a fuzz target runs clean for a stated duration.
