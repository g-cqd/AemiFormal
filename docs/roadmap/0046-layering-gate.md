---
status: not-started
phase: shared
milestone: M0
target: AemiFormalTests
blocked-by: ["0033"]
date: 2026-11-04
---

# 0046 — Layering gate

A test that reads each target's imports and fails when a target imports above its layer or a layer-0 kernel imports a TLA+ or Lean target (ADR-0011). Broken on purpose once.
**Done when** the allowed-imports table is the single source of truth and the gate fires on a deliberate violation.
