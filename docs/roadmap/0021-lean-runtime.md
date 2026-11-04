---
status: not-started
phase: lean
milestone: M6
target: LeanRuntime
blocked-by: ["0036", "0044", "0042"]
date: 2026-11-04
---

# 0021 — Lean runtime in Swift

Object model with reference counts matching the layout in 0044, big numbers, strings, arrays, thunks and tasks, references, I/O. **Done when** the runtime's own tests match the specification of each primitive in `lean.h`.
