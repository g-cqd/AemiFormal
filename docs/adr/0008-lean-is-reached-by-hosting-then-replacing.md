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

Early completeness comes from hosting; independence grows with each replacement. Probed 2026-11-04 (diary 2026-11-04-02, Lean 4.35.0):
- IR is persisted, but in a separate `.ir` file per module (about 381 MB for the whole release); `.olean` keeps only a subset in module mode.
- The container is versioned and the loader requires an exact version-string and githash match: pin one exact Lean build, as with TLC.
- Upstream's interpreter ran one compute-bound program about 80 times slower than native (53 s against 0.66 s user CPU). Hosting the elaborator is
  therefore a means to completeness, and the native replacements in step 3 are where speed comes from.
- Not probed: the interpreter on the elaborator itself, and the object layout details a Swift reader needs.
