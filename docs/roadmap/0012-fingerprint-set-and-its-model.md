---
status: not-started
blocked-by: [0011]
date: 2026-11-04
---

# 0012 — Fingerprint set, and its TLA+ model

Lock-free sharded set; its insertion protocol is specified in TLA+ and checked first by Java TLC. **Done when** the model passes, its `.buggy.cfg` fails, and a stress test agrees.
