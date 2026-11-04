---
status: not-started
blocked-by: [0012 0016 0020]
date: 2026-11-04
---

# 0029 — Prove the algorithms, then the code

TLA+ models of the fingerprint set, the search and SCC checked by TLC; Lean proofs of the same, and of the kernel's rules, checked by the Lean checker (0020). Then Lean models of the Swift data structures, and of the code as far as the tooling reaches. **Done when** each shipped algorithm names its proof and a mutated algorithm fails it.
