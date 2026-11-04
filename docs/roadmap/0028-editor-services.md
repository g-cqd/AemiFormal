---
status: not-started
phase: services
milestone: M8
target: FormalLSP
blocked-by: ["0006", "0034", "0040"]
date: 2026-11-04
---

# 0028 — Editor services

Diagnostics, symbols, hover and definition over the front end, served through `AemiJSONRPC` (Content-Length framing, probed). Highlighting through `AemiLexers`: its `Language` has no TLA+ or Lean, so that is a contribution upstream.
