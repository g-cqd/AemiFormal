---
status: not-started
phase: tla
milestone: M2
target: TLAEval
blocked-by: ["0006", "0007"]
date: 2026-11-04
---

# 0008 — Evaluator v1 (the semantic reference)

An iterative interpreter over TLA Core in the library, with an explicit frame stack and limits. It is kept for good as the reference the fast evaluator (0009) is tested against. **Done when** it agrees with TLC on expression-level checks over generated inputs and on the corpus's invariants.
