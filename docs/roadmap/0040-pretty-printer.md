---
status: not-started
phase: shared
milestone: M0
target: FormalPretty
blocked-by: ["0034"]
date: 2026-11-04
---

# 0040 — Pretty printer

A width-aware document algebra rendered with an explicit stack. **Consumers:** TLA+ unparse (also useful to `modeler`, whose `TLAModule` builds text by hand), PlusCal output, TLAPS obligations, trace states, kernel error messages, reports.
**Done when** rendering is idempotent at every width on a generated corpus and a very deep document renders without recursion.
