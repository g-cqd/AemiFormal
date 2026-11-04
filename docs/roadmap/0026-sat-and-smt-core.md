---
status: not-started
phase: proof
milestone: M7
target: FormalSAT
blocked-by: ["0025", "0035", "0036", "0042"]
date: 2026-11-04
---

# 0026 — A Swift SAT core, then SMT theories

CDCL first, with `cadical` (bundled with Lean) and `z3` as oracles; theories one at a time; congruence closure on the graph kernel's union-find.
