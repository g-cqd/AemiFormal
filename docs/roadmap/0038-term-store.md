---
status: not-started
phase: shared
milestone: M0
target: FormalTerms
blocked-by: []
date: 2026-11-04
---

# 0038 — Term store (spike, then decision)

Hash-consed immutable DAGs in an arena: 32-bit ids, structural interning, a hash and flags cached per node, traversal (fold, instantiate, abstract) on an explicit stack. Hypothesis: TLA+ core, Lean `Expr` and `Level`, SMT terms and proof obligations can share storage, interning and traversal while keeping their own node kinds.

**Method:** build it against two synthetic generators, one binder-heavy like Lean terms and one operator-heavy like TLA+ expressions, and against the same workload in a specialised store. **Done when** the result is recorded as an ADR: one store, or two stores sharing only the intern table. The rule is to share when the shared form is not measurably slower than the specialised one.
