---
status: not-started
phase: shared
milestone: M0
target: FormalNumeric
blocked-by: []
date: 2026-11-04
---

# 0036 — Arbitrary-precision integers

`Nat` and `Int` over limbs, with `multipliedFullWidth` and `UInt128`; division, gcd, shifts, power, base conversion; rationals after. The ecosystem has none (searched, 2026-11-04). Semantics of overflow are the caller's (TLC's `Int` is bounded, Lean's `Nat` is not).

**Consumers:** TLA+ values and `Integers` (0007), Lean kernel literals (0020) and runtime (0021), SMT arithmetic (0026).
**Oracles:** Python integers (3.15 is installed) and Homebrew GMP, both differential. Lean's `.olean` records whether persisted bignums use GMP, so the encoding of both is needed to read them.
**Done when** a property test against Python agrees on 10^6 generated operations per operator and the operators allocate only what they return.
