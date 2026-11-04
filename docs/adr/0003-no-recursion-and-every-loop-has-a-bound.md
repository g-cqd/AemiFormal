---
status: accepted
date: 2026-11-04
---

# 0003 — No recursion, and every loop has a bound

## Context

A specification is untrusted input with arbitrary nesting, and an evaluator or a search that recurses on it overflows the stack or
never ends. AemiRegex made the same rule (its ADR-0003) and gates it.

## Decision

No function calls itself, directly or through others, in the libraries, tests, benchmarks or scripts. Tree-shaped work uses an
explicit stack whose growth is a limit; every loop is bounded by an input length, a limit or a budget. Exceeding one is a typed
error. `NoRecursionTests` enforces it with a heuristic scan, each rule broken on purpose.

## Consequences

Strongly connected components, the evaluator and the parser are written iteratively. TLA+'s recursive operators are evaluated
with an explicit frame stack and a depth limit, not by host recursion.
