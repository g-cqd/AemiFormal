---
status: not-started
phase: shared
milestone: M0
target: FormalSupport
blocked-by: []
date: 2026-11-04
---

# 0033 — Limits and budgets

One vocabulary for "a limit was reached": a typed error naming the limit, its value and what was being done. Steps, bytes, depth, count and time, with time read through the `AemiRuntime` clock seam so the `wall-clock` discipline rule holds.

**Consumers:** every parser, evaluator, search, kernel check and solver (ADR-0003 makes a limit the only way to stop).
**Done when** the lexer, the evaluator and the search can all report through it, and a test shows a limit stops a loop that would otherwise run forever.
