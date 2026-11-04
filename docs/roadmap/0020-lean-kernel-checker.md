---
status: not-started
phase: lean
milestone: M5
target: LeanKernel
blocked-by: ["0036", "0038", "0035", "0043"]
date: 2026-11-04
---

# 0020 — Lean independent kernel checker

Expressions, levels, declarations, inductives and recursors, quotients, definitional equality, export reader. Two inputs, so they check each other: the `leanexport` text and the `.olean` objects (0044, once it exists). **Oracles:** `leanchecker`, `lean4lean`, `nanoda_bin`, all bundled with the toolchain. **Done when** it accepts the exports of Lean's own library for the pinned release, rejects a corpus of corrupted ones, and checks `development/formal/lean` from `ask`.
