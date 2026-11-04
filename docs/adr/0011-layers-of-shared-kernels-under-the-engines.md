---
status: accepted
date: 2026-11-04
---

# 0011 — Layers of shared kernels under the engines

## Context

The roadmap covers a TLA+ front end, TLC, PlusCal, a Lean kernel checker, a Lean runtime and interpreter, TLAPS, symbolic checking and a SAT/SMT core.
Their needs overlap: limits, positions, graphs, big numbers, hash-consed terms, parsing, printing, files, threads, oracles. The ecosystem already supplies
part of that (`docs/research/shared-components-2026-11.md`) and lacks the rest (big numbers, SAT, work queues, e-graphs, graph kernels it can share).

## Decision

Three layers of SwiftPM targets; a target imports only from its own layer or below.

- **Layer 0, generic kernels:** `FormalSupport`, `FormalGraph`, `FormalNumeric`, `FormalTerms`, `FormalParsing`, `FormalPretty`, `FormalStore`, `FormalParallel`. They know nothing of TLA+ or Lean. Each is written so it can move into `aemi` by changing its module name and nothing else.
- **Layer 1, languages and engines:** `TLASyntax`, `TLAConfig`, `TLAValues`, `TLAEval`, `TLC`, `PlusCal`, `LeanObjects`, `LeanKernel`, `LeanRuntime`, `LeanIR`, `LeanHost`, `TLAPS`, `Symbolic`, `FormalSAT`.
- **Layer 2, products:** `FormalReport`, `FormalPlugin`, `FormalLSP`, and the executables.
- **Test support, never shipped:** `FormalOracle` (pinned tools, corpus, comparison) over `AemiTestKit`.

**Reuse first.** An Aemi piece is used as it is. A kernel is written here only for a recorded gap.
**Share with two consumers.** A piece is a layer-0 kernel when at least two roadmap entries, or one entry and one existing repository, need it. Otherwise it stays in its engine target, written so it can move. The 128-bit hash (0037) is the worked case: one consumer, so it lives in `TLC` until a second appears.
**Promotion is a move of a target into aemi,** done by the owner because it changes another repository. Until then the kernel stays here with its tests.
**One store for terms is a hypothesis.** Roadmap 0038 builds it against two workloads and records an ADR: one store, or two sharing only the intern table.
**Tests and benchmarks use `AemiTestKit`** (property tests with shrinking, byte-mutation fuzzing, seeded random, allocation counting, benchmark records), not a new framework.

## Consequences

`DocumentationLayout` checks that every roadmap entry has a phase, a milestone no earlier than its blockers', and no cycle. Roadmap 0046 adds the import-layer gate. Roadmap numbers are never reused or renumbered, so references in the diary stay true.
