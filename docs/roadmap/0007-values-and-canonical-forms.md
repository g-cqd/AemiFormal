---
status: not-started
phase: tla
milestone: M2
target: TLAValues
blocked-by: ["0003", "0036", "0033"]
date: 2026-11-04
---

# 0007 — Values and canonical forms

Word-sized values, canonical sets, records, functions and sequences, equality and ordering, serialisation to canonical bytes (`Varint`). The hash is not here: exact mode needs only the bytes (0037 adds fingerprints). **Done when** a property test shows canonicalisation is idempotent and equal values have equal bytes.
