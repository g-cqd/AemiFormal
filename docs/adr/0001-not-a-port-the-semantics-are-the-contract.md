---
status: accepted
date: 2026-11-04
---

# 0001 — Not a port: the semantics are the contract

## Context

The owner's instruction: do not copy TLC, TLA+ or Lean code into Swift. Make it idiomatic, restructure the architecture for speed and
safety, and keep it scientifically accurate.

## Decision

The sources of truth are the language definitions and the observable behaviour of the reference tools. Java TLC 1.7.4 (the pin in
swift-ci) and the installed Lean are oracles run as subprocesses in tests and CI only; AemiFormal never links, embeds or translates
them. Each construct gets a written denotation and its error cases in `docs/semantics/` before its code. Where the reference leaves
behaviour unspecified, the choice is an ADR.

## Consequences

Disagreement with an oracle is triaged, not assumed to be our bug. The architecture is free to differ (ADR-free design lives in
`docs/research/aemiformal-study-2026-11.md` §4) where a measurement supports it.
