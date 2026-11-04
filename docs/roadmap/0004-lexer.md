---
status: not-started
phase: tla
milestone: M1
target: TLASyntax
blocked-by: ["0033", "0034"]
date: 2026-11-04
---

# 0004 — TLA+ lexer

Bytes to tokens, including the layout rule for `/\` and `\/` lists and proof-step labels. SANY has no token dump. Its XML export (0043) gives line and column for every node, so leaf nodes (identifiers, numbers, strings, operators) are compared by location, and accept/reject per module is compared across the corpus.
**Done when** every leaf location in SANY's export for the corpus is a token boundary of ours, no module SANY accepts is rejected, and malformed bytes give diagnostics.
