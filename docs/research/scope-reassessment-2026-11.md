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

## Definitions and ambitions

**Definition of conformance.** Java TLC with several workers is not reproducible byte for byte (trace and generated counts vary), so "identical
output" has no meaning to test against. Conformance is: same verdict, same distinct-state count and diameter, and counterexamples that are valid
behaviours and BFS-minimal. This is a definition, not a limit.

**Unbounded inputs** (infinite enumeration, divergent recursion) end in a typed error naming the limit, as TLC does. Nothing here is a ceiling.

**Linear time is the ambition.** The reachable-state search is already linear in reachable states and transitions, and liveness by SCC is linear in the
graph. The aim is to make cost grow with something smaller than the state count wherever the problem allows. Each tier is a roadmap entry with its
own finish line, and none of these is built or measured yet:

| Tier | Idea | Cost then depends on |
|---|---|---|
| One-step and inductive checks | An inductive invariant is checked in one step from any state satisfying it, no search | size of one transition, not the state space |
| k-induction, IC3/PDR | Prove an invariant from bounded unrolling and learned lemmas | size of the proof, not the reachable set |
| Symbolic (BDD, SAT) | Sets of states as formulas or diagrams | formula size |
| Symmetry | One canonical representative per orbit | orbits, not states |
| Partial-order reduction | Explore one interleaving per equivalence class | classes, not interleavings |
| Abstraction, assume-guarantee | Check components against contracts | components, not their product |
| Counting and lumping | Merge states that behave alike | classes |

Precedent in the family: AemiRegex ADR-0001 chose linear time by construction. What each tier's complexity is in the worst case I recall
(model checking is PSPACE-hard for these logics) and have not probed; the point of the tiers is the cases that are not worst cases.

**Correctness: prove as much as can be proved.** Oracles, differential and property tests, fuzzing and mutation are the floor. Above it: proofs
about each algorithm in TLA+ and Lean (the fingerprint set, the search, SCC, the kernel's rules), and proofs about the Swift where it is
practical (Lean models of the data structures, then of the code, as far as the tooling reaches). Roadmap 0029.

**Extensions** go through a plugin protocol (ADR-0009). That is the design for user code that TLC loads as Java.

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
