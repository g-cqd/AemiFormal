---
status: not-started
phase: shared
milestone: M0
target: FormalOracle
blocked-by: []
date: 2026-11-04
---

# 0043 — Oracle runner and conformance harness

A test-support target that runs the pinned tools as subprocesses (Java TLC 1.7.4 with an explicitly chosen JVM, `lean` and its bundled `leanchecker`, `leanexport` and `nanoda_bin`, `z3`, `cadical`) with limits, captures verdict, counts and output, and compares through `AemiTestKit`'s `ReferenceComparison`. Subprocesses go through `swift-subprocess`, as in `ask` and `swift-search`. The TLC pin comes from one place: the tool lock that `swift-ci`'s `TLC` already reads.

**SANY as an oracle:** `java -cp tla2tools.jar tla2sany.xml.XMLExporter -o M.tla` prints the semantic tree as XML. Probed on `LineSplitter.tla` with OpenJDK 27: 736 located nodes, levels 0 to 3, resolved operator references. Without `-o` it failed XML validation (cause not investigated; what `-o` does was not read from the source).
**Corpus:** `tlaplus/Examples` by commit, fetched and hash-verified and not vendored; its manifests carry expected distinct-state counts and results (observed for 2026-11-04 `0e32a039`).
**Done when** one command runs a model under TLC and returns its verdict and counts, and a `.buggy.cfg` control is recognised as must-fail.
