---
status: accepted
date: 2026-11-04
---

# 0008 — Lean is reached by hosting, then replacing

## Context

The Lean elaborator and library are about 30 MB of Lean source, compiled by Lean to IR and C. Upstream has a C++ IR interpreter and independent kernel
checkers in other languages exist (probed).

## Decision

Order: (1) an independent kernel checker over the export format; (2) a Lean runtime (object model, big numbers, strings, arrays, tasks, I/O) and an
IR interpreter in Swift, reading the distribution's compiled library as data; (3) native Swift replacements for kernel, then profile-driven hot
paths, each differential-tested against the hosted original. Version pinned per Lean release, like TLC.

## Consequences

Early completeness comes from hosting; independence grows with each replacement. Open until probed: that IR is persisted in `.olean` files, the
format's stability across releases, and interpreter speed against native.
