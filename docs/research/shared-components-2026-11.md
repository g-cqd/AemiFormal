# Shared components — 2026-11-04

What the components of AemiFormal can share with each other and with the Aemi ecosystem. Decision recorded in ADR-0011; the work is in
`docs/roadmap/`. Evidence tags: **[read]** source read this session; **[probed]** something was run; **[design]** reasoning, not yet tested.

## Method

Every Aemi product's public declarations were read, the sibling repositories were searched for prior art (build directories excluded), and the
claims that decide the dependency plan were run: resolution and build under a macOS 26 floor, a concurrent fingerprint set, a SANY export, the Lean
file format. The first ecosystem search timed out on its last patterns and was repeated without build directories before any "none found" below.

## What the ecosystem already provides

| Need | Piece | Fit | Evidence |
|---|---|---|---|
| Bytes, varints, checked arithmetic, tape slots | `AemiKernel` (`Varint` with zigzag, `CheckedMath`, `ByteReader`, `TapeSlot`: 4-bit tag, 28-bit aux, 32-bit offset) | as is; tape offsets cap at 4 GiB, fine for sources, not for term stores | [read] |
| Hashing | `WyHash`, `XXH64`: 64-bit, seedable. `WyHash` documents that it does not defend against crafted keys | 128-bit and keyed fingerprints are a gap (0037) | [read] |
| Integrity | `AemiKernels.crc32c` (hardware), `AemiDigest` SHA-256 | as is | [read] |
| Names | `AemiInterner`: `Symbol` is `UInt32`, one writer, `freeze()`, `merge(workers:)` with symbol remaps, `serialized()` | as is for identifiers and strings; parallel interning by many writers is a gap | [read], merge [probed] |
| Atomics on raw memory | `SharedAtomicU64` (load-acquire, store-release, `compareExchangeAcqRel`) | core of a lock-free table | [read] |
| Concurrent set | none; built on the atomics: 8 threads offered 2,000,000 keys 16,000,000 times and the table counted 2,000,000 insertions | the protocol works; resize, disk and speed are open (0042, 0012) | [probed] |
| Files | `AemiIO`: `RawFileMap` is **read-only** (`PROT_READ`), `AtomicFile.replace`, `DurabilityProfile` | reading `.olean`/`.ir` fits; a writable growable mapping is a gap (0041) | [read] |
| Workers | `AemiRuntime`: `BlockingOffloadPool` (blocking calls, queue depth 1024), `ScratchPool`, `ResourcePool`, `mapConcurrently`, clock seams | fine-grained search workers are a gap (0042); clock seam is how time enters (0033) | [read] |
| Measurement | `AemiMetrics.ProcessProbe`: wall, process and thread CPU, resident and footprint bytes, instructions, cycles, children's CPU and peak RSS | the baseline harness (0002) | [read] |
| Tests | `AemiTestKit`: `Generator`/`forAll` with iterative shrinking, `ByteMutator` and `fuzzNeverTraps`, `SeededRNG` (SplitMix64), `ReferenceComparison`, `mallocDelta`/`expectAllocations`, `recordBenchmark`, load tests | as is; `SeededRNG` is test-only, so `Randomization` needs a shipped generator (0017) | [read] |
| JSON-RPC, LSP framing | `AemiJSONRPC` (Content-Length framing, connection, cancellation) | editor services and a plugin transport (0027, 0028) | [read], builds [probed] |
| Highlighting | `AemiLexers` (`LineLexer` with per-line `LexState`): `Language` has no TLA+ or Lean | a contribution upstream (0028) | [read] |
| Diagrams | `AemiMermaid`: flowchart, pie, sequence, state | traces and state graphs (0014); no remote on this repo yet | [read] |
| Subprocesses | `swift-subprocess`, used by `ask`, `swift-search`, Atelier | oracle runner (0043) | [read] |
| TLC pin and verdicts | `swift-ci` `TLC`: version, SHA-256, model discovery with must-fail by name, verdict from output | one source for the pin (0043) | [read] |
| Emitting TLA+ | `modeler` `TLAModule` builds text by hand (340 lines) | a consumer of the printer and syntax kits later | [read] |
| Iterative SCC | `arcleak` `StronglyConnectedComponents`: iterative Tarjan over `[[Int]]`, 63 lines, internal | the shape ADR-0003 needs; storage is too narrow for TLC (0035) | [read] |
| Union-find | `dolly` and `SwiftStaticAnalysis`: the same private `UnionFind`, `find` recursive | duplicated, and recursive (bounded by rank, so not a bug, but it would fail our gate) | [read] |
| Arenas | `SwiftStaticAnalysis` `Arena` (public, `~Copyable`); `AemiInterner`'s chunked arena (internal) | model for the term store (0038) | [read] |

**Not found anywhere in the ecosystem** (name-based search; a differently named implementation would be missed): big integers, SAT/BDD, work-stealing queues,
e-graphs or congruence closure, persistent maps.

## Platform facts [probed]

`aemi` at `4879ca7522a6` with `AemiJSON` at `61a8b82` resolves, and `AemiKernel`, `AemiKernels`, `AemiInterner`, `AemiIO`, `AemiRuntime`, `AemiMetrics`,
`AemiDigest`, `AemiJSONRPC` build together, with `AemiTestKit` in tests, under `platforms: [.macOS(.v26)]` (ADR-0005). `UInt128` is native and 16-byte
aligned. Python 3.15 and Homebrew GMP are installed (big-integer oracles); `z3` is installed; `cadical` ships in the Lean toolchain; Lean also bundles
`leanchecker`, `lean4lean`, `leanexport` and `nanoda_bin`. SANY exports a semantic tree: `XMLExporter -o` on one module gave 736 located nodes, levels 0 to 3
and resolved references (without `-o` it failed XML validation under JDK 27).

## Who needs what

● needs it, ○ could use it. Columns: **FE** TLA+ front end, **TLC** values/evaluator/search, **Liv** liveness and reductions, **PC** PlusCal,
**LK** Lean kernel checker, **LR** Lean objects/runtime/IR, **PF** TLAPS, **SY** symbolic and SAT/SMT, **SV** services.

| Kernel (roadmap) | FE | TLC | Liv | PC | LK | LR | PF | SY | SV |
|---|---|---|---|---|---|---|---|---|---|
| Limits and budgets (0033) | ● | ● | ● | ● | ● | ● | ● | ● | ● |
| Source map (0034) | ● | ○ | | ● | ○ | | ● | | ● |
| Graph kernels (0035) | ● | | ● | | ● | | | ● | |
| Big integers (0036) | | ● | | | ● | ● | | ● | |
| Term store (0038) | ● | | | | ● | | ● | ● | |
| Parsing kit (0039) | ● | ● | | ● | | | ● | | |
| Pretty printer (0040) | ○ | ● | | ● | ○ | | ● | | ● |
| Store and writable map (0041) | ○ | ● | ● | | | ○ | | | |
| Parallel kernel (0042) | | ● | ● | | | ● | ● | ● | |
| Oracle runner (0043) | ● | ● | ● | ● | ● | ● | ● | ● | |

The graph kernels have three external users already (`arcleak`, `dolly`, `SwiftStaticAnalysis`), which is why they are layer 0 and a candidate for aemi.

## Structure of the roadmap

46 entries: 13 shared, 20 TLA+, 6 Lean, 5 proofs and solvers, 2 services; milestones M0 to M8 (ADR-0011). Seven are ready now: 0033, 0034, 0035, 0036,
0037, 0038, 0043. Computed from the entries' `blocked-by` fields:

- **First measured number (0011, safety search):** a chain of 6, 0033 limits, 0004 lexer, 0005 parser, 0006 resolution, 0008 evaluator v1, 0011. The other kernels it needs (0034, 0035, 0038, 0039, 0036, 0007, 0010, 0043) are parallel branches.
- **Lean kernel checker (0020):** a chain of 2, since 0036, 0035, 0038 and 0043 are all ready now. It shares only layer-0 kernels with the TLA+ line, so it can run beside it, and it is the cheapest early deliverable that checks something real (the Lean files in `ask/development/formal`).
- **Longest chain:** 11, 0033, 0004, 0005, 0006, 0008, 0011, 0012, 0013, 0016, 0031, 0032: the TLA+ spine through liveness to the reductions.

The refinement changed these things, each because a check or a probe showed the first draft wrong:

- **0037 (128-bit hash)** had one consumer, so by the two-consumer rule it moved from shared to `TLC`.
- **0004 (lexer)** no longer waits on the semantics note; SANY has no token dump, so its oracle became the XML export's locations.
- **0011 (search)** runs on evaluator v1 (0008), kept for good as the reference, so the first number does not wait for the bytecode evaluator.
- **0019 and 0031** both claimed symmetry; 0019 keeps TLC's features and 0031 is only what goes beyond TLC.
- **0025 (symbolic)** no longer waits on TLAPS; it needs the core and `z3`.
- **0022 and 0045** were one entry; the interpreter needs the object reader and runtime, and hosting the elaborator also needs the kernel (0020).

## Deliberately not shared

- **TLA+ values and Lean objects.** Lean's object layout is fixed by `lean.h` and the compacted regions on disk, so reading in place requires matching it. TLA+ values are designed for canonical bytes and cheap hashing. They share big integers, an arena and a hash only.
- **The evaluators.** TLA+ evaluation over canonical values and Lean IR interpretation have different shapes; sharing them would slow both [design].
- **Lean's surface parser.** It is part of the hosted elaborator (ADR-0008).

## Open questions

- Does one term store serve TLA+ core and Lean `Expr` without a measured slowdown? (0038)
- Can `.olean` pointers be used in place at the stored base address, or must they be relocated, and how are bignums encoded? (0044)
- Does a Swift IR interpreter beat upstream's, which ran one program about 80 times slower than native? (0022)
- How many symbols does a Lean environment need, and does a 32-bit `Symbol` hold for Mathlib? Not counted.
- Concurrent interning by many writers, or merge after the fact? The merge exists and works on small inputs; its cost at TLC's rates is not measured.

## Follow-ups for the owner (other repositories, not changed here)

- `dolly` and `SwiftStaticAnalysis` carry the same recursive `UnionFind`; `arcleak` has an iterative SCC. A shared kernel in aemi would replace all three.
- `AemiProtobuf`'s `aemi` pin differs from `AemiJSON`'s, so the two do not resolve together.
- `AemiLexers.Language` could take TLA+ and Lean.
