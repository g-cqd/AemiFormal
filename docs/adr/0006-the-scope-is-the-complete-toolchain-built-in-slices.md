---
status: accepted
date: 2026-11-04
---

# 0006 — The scope is the complete toolchain, built in slices

## Context

The first study narrowed Lean to a kernel checker and put proof checking out of scope. The owner's direction is the most complete implementation
possible, tackled iteratively. `docs/research/scope-reassessment-2026-11.md` has the measurements.

## Decision

In scope: SANY, TLC (safety, liveness, symmetry, VIEW, simulation, checkpoints), PlusCal, TLAPS (proof manager, obligations), a symbolic checker,
and Lean (kernel checker, runtime, IR host, native replacement). Work proceeds in vertical slices, each end to end and measured, in the order of the
reassessment note. A tier is not started for its own sake: each has a roadmap entry with a stated finish line.

## Consequences

Five constraints define "done" (note, section 3). Nothing is excluded for size.
