---
status: not-started
phase: shared
milestone: M0
target: FormalParsing
blocked-by: ["0033", "0034"]
date: 2026-11-04
---

# 0039 — Parsing kit

Token buffer and cursor, precedence tables (TLA+ operator precedences are ranges that overlap), layout tracking for the conjunction and disjunction lists, error recovery with synchronisation sets, tape output on `TapeSlot`. Never traps on any bytes.

**Consumers:** TLA+ (0005), PlusCal (0018), configuration (0010), proof language (0024). Not Lean's surface syntax (hosted, ADR-0008).
**Done when** the kit parses a small expression language end to end in tests, every malformed input yields diagnostics, and `fuzzNeverTraps` from `AemiTestKit` runs clean.
