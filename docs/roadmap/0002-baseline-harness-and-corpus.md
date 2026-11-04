---
status: not-started
phase: shared
milestone: M0
target: FormalOracle
blocked-by: ["0043"]
date: 2026-11-04
---

# 0002 — Baseline harness and corpus

Wall time, user and system CPU, peak resident memory and instruction counts for the oracle runs, taken with `AemiMetrics.ProcessProbe` (it reports children's CPU and peak RSS), median and spread over repeated runs, and 1 to 8 workers. Run on a quiet machine: check `uptime` first.

First numbers exist (diary 2026-11-04-02, `MCLamportMutex`, `PaxosCommit`, `CoffeeCan`) but were taken at load average 21 to 28 on 8 cores, and the 1-worker verdicts were not all captured.
**Done when** the diary holds a baseline over the whole fixed corpus with each run's load recorded.
