---
status: not-started
phase: shared
milestone: M0
target: FormalGraph
blocked-by: []
date: 2026-11-04
---

# 0035 — Graph kernels

Iterative strongly connected components over a storage protocol (CSR in memory, or a `Span` of edges on disk, or successors computed on the fly), iterative union-find, topological order and cycle reporting. No recursion (ADR-0003).

**Consumers:** liveness (0016), name resolution and recursive-operator detection (0006), Lean declaration order (0020), congruence closure (0026). Outside this repository: `arcleak` has an iterative Tarjan over `[[Int]]` (63 lines, internal), and `dolly` a private `UnionFind` whose `find` is recursive. Promotion to aemi is the owner's decision (ADR-0011).
**Done when** results equal a naive reachability-based reference on generated graphs, a 10^6-node chain and ring run in linear time with a flat stack, and `arcleak`'s output on its own fixtures is reproduced.
