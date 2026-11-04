---
status: not-started
phase: lean
milestone: M5
target: LeanObjects
blocked-by: ["0033", "0043"]
date: 2026-11-04
---

# 0044 — Lean object reader (.olean and .ir)

Map a module file and read it in place: header (`olean`, version, flags, version string, githash, base address), relocation, object layout from `lean.h`. `RawFileMap` is read-only, which fits. The loader of the same Lean build refuses a file unless version string and githash match (probed), so one exact build is pinned (ADR-0008). `.ir` files use the same container.
**Open (probe first):** whether pointers can be used in place at the stored base address or must be relocated, and bignum encoding (the GMP flag).
**Done when** every module of the pinned release reads and its constant count equals what `lean` reports.
