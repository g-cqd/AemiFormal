---
status: not-started
phase: tla
milestone: M1
target: TLASyntax
blocked-by: ["0003", "0005", "0035", "0038"]
date: 2026-11-04
---

# 0006 — Resolution, INSTANCE and levels

Name resolution, substitution, arity, recursion and constant/state/action/temporal levels into TLA Core. Identifiers through `AemiInterner`. **Oracle:** SANY's XML export (`XMLExporter -o`, probed on one module: 736 located nodes, levels 0 to 3, resolved operator references): node kinds, locations, levels and what each name resolves to are compared.
**Done when** the same modules are accepted and rejected as by SANY across the corpus, the exports agree on kind, level and resolution, and every difference is explained.
