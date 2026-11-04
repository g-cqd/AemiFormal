---
status: not-started
blocked-by: []
date: 2026-11-04
---

# 0002 — Probe harness and corpus

Pinned JVM and TLC 1.7.4, a corpus fixed by hash (the ecosystem's own models first, then a public set), and a runner that records states/s, bytes per state, wall time and scaling from 1 to 8 workers, median and spread. **Done when** the diary holds the first full baseline. Closes the gap that only 3 small models were run.

First numbers exist (diary 2026-11-04-02: `tlaplus/Examples` models, 0.5M to 1.3M distinct states) but were taken at load average 21 to 28 on 8 cores. Re-run on a
quiet machine, capture the 1-worker verdict, and fix the script that truncated it. The Examples manifests give expected distinct counts to check against.
