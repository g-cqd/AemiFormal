---
status: not-started
phase: shared
milestone: M3
target: FormalParallel
blocked-by: ["0033"]
date: 2026-11-04
---

# 0042 — Parallel kernel

Dedicated worker threads (`BlockingOffloadPool` is built for blocking calls with a bounded queue, not for compute shards), a sharded frontier, termination detection, and a lock-free insert-only table over `SharedAtomicU64`. Probed 2026-11-04: 8 threads offered 2,000,000 keys 16,000,000 times and the table counted exactly 2,000,000 insertions.
**Consumers:** the parallel search (0013), a SAT portfolio (0026), the Lean runtime's tasks (0021), parallel obligations (0024).
**Method:** the termination-detection and insertion protocols are specified in TLA+ and checked by Java TLC first, with a `.buggy.cfg` that must fail. **Done when** a stress test under ThreadSanitizer is clean and the model passes.
