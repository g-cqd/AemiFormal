---
status: not-started
phase: lean
milestone: M6
target: LeanIR
blocked-by: ["0044", "0021"]
date: 2026-11-04
---

# 0022 — Lean IR decoder and interpreter

Decode the IR declarations from `.ir` files and interpret them. Upstream's interpreter ran one compute-bound program about 80 times slower than native (53 s against 0.66 s user CPU, diary 02), so speed is a goal of this entry, not an assumption. **Done when** it runs a pinned program with output equal to the real binary's, and its time against upstream's interpreter is recorded.
