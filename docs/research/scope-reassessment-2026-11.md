# Scope reassessment — 2026-11-04

Supersedes the scoping in `aemiformal-study-2026-11.md` §3 and §8, which narrowed too early. Owner's direction: nothing here is unrealistic,
the scopes are big and are worked iteratively and smartly. The goal is the most complete implementation possible.

## Measured, not recalled (GitHub API, trees at default branch, 2026-11-04)

| Reference | Size |
|---|---|
| TLC `tlc2` / SANY `tla2sany` / PlusCal `pcal` (Java) | 3.4 MB / 2.2 MB / 1.1 MB (370 / 111 / 41 files); `tla2tex` 0.7 MB |
| TLAPS `tlapm` | OCaml 2.6 MB, Isabelle theories 0.6 MB; backends are separate programs |
| Apalache | Scala 4.0 MB |
| Lean 4 kernel `src/kernel` (C++) | 343 KB in 36 files; `src/library` 260 KB; `src/runtime` 703 KB; `lean.h` 153 KB |
| Lean 4 in Lean: `Init` / `Std` / `Lean` | 9.4 / 7.8 / 12.6 MB; of `Lean`: `Elab` 3.5, `Meta` 4.6, `Parser` 0.35, `Compiler` 1.1 |
| Mathlib | 103 MB of Lean (a user of the elaborator, not part of it) |

Also probed: Lean ships a C++ IR interpreter (`src/library/ir_interpreter.cpp`, 75 KB) and an IR declaration map (`declMapExt`); external kernel
checkers exist (`leanprover/lean4export`, `ammkrn/nanoda_lib` in Rust, `digama0/lean4lean`, `leanprover/lean4checker`). Not probed: that IR is persisted in
`.olean` files, and the `.olean` format's stability across releases. TLC 1.7.4 is the latest release (`gh api`).

## What changed my mind

"Lean's elaborator is written in Lean, so it is not realistic" was the wrong reason. Rewriting 30 MB of Lean source by hand and tracking upstream is
costly, but the route is not closed: the runtime plus an IR interpreter can **host** the upstream-compiled elaborator, then native Swift can replace
parts one at a time, each checked against the hosted original (a strangler). The same shape fits the rest: TLAPS delegates its backends first; the
symbolic checker delegates to z3 first; a Swift SAT/SMT core comes after, with the delegate as its oracle.

## What stays as a constraint on "done" (not a scope exclusion)

1. **Conformance is by invariant, not by bytes.** Java TLC with several workers is itself not reproducible (trace and generated counts vary), so
   "identical output" has no definition. Contract: same verdict, same distinct-state count and diameter, valid and BFS-minimal counterexamples.
2. **Unbounded and undecidable inputs end in a typed error with a limit named**, as TLC does for infinite enumeration; no checker decides them.
3. **State explosion is exponential for every implementation.** The tool's gains are constants (evaluator, layout, memory, parallelism) until the
   algorithmic tiers (symmetry, VIEW, symbolic) land; claims are measured per tier.
4. **Implementation correctness is evidenced, not proved**: oracles, differential and property tests, fuzzing, mutation, and proofs about the
   *algorithms* in TLA+ and Lean. Verifying Swift source itself would need a Swift semantics.
5. **Java-only surfaces are replaced, not emulated**: TLC's loading of Java `.class` module overrides and RMI distribution have no Swift
   equivalent; they become a plugin protocol and a transport (ADR-0009).

## Iteration order (vertical slices; each runs end to end and is measured)

1. TLA+ safety checker on a pinned corpus (front end, evaluator, BFS, `.cfg`): the first number against TLC.
2. Parallel search, fingerprint set, traces, checkpoint/resume.
3. Liveness, then symmetry, VIEW, simulation.
4. PlusCal; standard modules; editor services.
5. Lean independent kernel checker over exports (closes the loop on `development/formal/lean`).
6. Lean runtime + `.olean` reader + IR interpreter: host the upstream elaborator; then native replacements, profile-driven.
7. TLAPS proof manager and obligations, SMT by delegation.
8. Symbolic checking by delegation; then a Swift SAT core and SMT theories.

## Follow-ups found on the way (not fixed here)

- `AemiJSON` HEAD (aemi `4879ca7`) and `AemiProtobuf` HEAD (aemi `b31f499` through AemiJSON `33f4959`) **do not resolve together**: probed with
  `swift package resolve` ("aemi is required using two different revision-based requirements"). `modeler` pins the older pair. AemiFormal needs
  AemiJSON and AemiProtobuf together, so AemiProtobuf's pins need a bump first.
