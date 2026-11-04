---
status: not-started
phase: tla
milestone: M2
target: TLAEval
blocked-by: ["0008", "0036"]
date: 2026-11-04
---

# 0017 — Standard modules

`Naturals`, `Integers`, `Sequences`, `FiniteSets`, `Bags`, `TLC`, `Json`, `Randomization` natively, and the `TLAPS` module (`tlaplus/Examples` `MCBakery` imports it and the TLC 1.7.4 jar does not ship it). `Randomization` and simulation need a shipped deterministic generator: `AemiTestKit.SeededRNG` is test-only. **Done when** each operator has a test from its documented definition.
