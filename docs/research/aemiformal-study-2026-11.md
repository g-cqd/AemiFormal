# AemiFormal — a study

Status: **proposal, nothing built.** Date 2026-11-04. Written against the local checkouts in this directory and
`gh repo list` for `g-cqd` and `Aemi-Studio`. Claims are marked **[probed]** (run or read this session, command in §2 or
named file) or **[recalled]** (from memory of the TLA+ / Lean literature; must be probed before it drives a decision —
the evidence rule, ask WHITE-PAPER §0).

## 0. The rule this study sets for itself

**Not a port.** The Java TLC/SANY/TLAPS and Lean 4 (C++ kernel, Lean-written elaborator) sources are not translated.
The contract is the *language semantics* (Lamport, *Specifying Systems*; the TLA+2 manual; Lean 4's kernel theory:
CIC with universe levels, inductive types, quotients, proof irrelevance, eta) and the *observable behaviour* of the
reference tools, which are used as **oracles** (run, compared, never linked or copied). Every architectural choice below
starts from "what does Swift and the Aemi kernel make cheap?", not "what did Java do?". Where this study says "TLC does X",
it is naming a behaviour to match or beat, not a design to copy.

## 1. Ecosystem acknowledged

Read from `Package.swift`, READMEs and AGENTS/white papers. Local = checked out here; all remotes were public in `gh`.

| Repo | Role | What AemiFormal takes from it |
|---|---|---|
| **Aemi-Studio/aemi** | Kernel package: `AemiKernel` (WyHash, XXH64, SparseSet, TapeSlot, ByteReader, CheckedMath, Varint, UTF-8, number parse), `AemiKernels` (SIMD/C scans), `AemiUnicode`, `AemiInterner`, `AemiIO` (RawFileMap, AtomicFile, DurabilityProfile, watching), `AemiRuntime` (ScratchPool, ConcurrentMap, BlockingOffloadPool, TaskProvider/Clock seams), `AemiMetrics`, `AemiFileSystem`, `AemiProcess`, `AemiLexers`, `AemiDiff`, `AemiTestKit`, Format/Lint plugins | Everything low-level. One revision pinned per graph (ADR-0030) |
| **AemiJSON** | Tape-based conformant JSON, Schema, Pointer, Patch | Trace/report output; Apalache ITF import/export |
| **AemiProtobuf** | Bounds-checked wire core, `@ProtoMessage`, descriptors, framing | On-disk checkpoint/trace records, worker wire format |
| **AemiRegex** | Linear-time RE2 engine, Unicode tables, "no recursion, every loop bounded" ADR-0003 | The *discipline* (ADR-0003) and the oracle-fixture method. Not on a hot path |
| **AemiMarkdown** | Streaming bounded zero-copy parser; **already ships 3 TLA+ models + `tlc.sh` with must-fail `.buggy.cfg` controls** | Report rendering in a terminal; the model/control convention |
| **AemiMermaid** (local only, no remote) | Mermaid layout to a flat scene | State-graph and counterexample diagrams |
| **ask** | Terminal agent; white paper, budgets, `SourceStructureTests`, `development/formal/` (found 1 TLA+ and 2 Lean-found faults, REPORT.md) | The standards; first consumer (agent tool `formal_check`) |
| **TerminalKit** | Terminal stack | Live progress line (TLC-style) with the tiered reset ladder |
| **HTTP** | SwiftNIO-free HTTP/1.1·2·3 | Optional: remote workers / result server. Not core |
| **analyzerkit** + **deadwood, dolly, arcleak, fcheck** | Shared project model; unused code, clones, ARC leaks, path obligations | Gates under `--strict`; fcheck's durable-replace rule matters for checkpoints |
| **modeler** | Swift → Mermaid + *TLA+ skeleton for TLC* + reentrancy/lock-gap checks | Producer of `.tla`. Its own docs say the skeleton "over-approximates" and AemiMarkdown found it unusable for protocols — AemiFormal makes that loop fast enough to iterate |
| **litmus** | Mutation testing | Mutation gate for evaluator and checker (kills "tests that never failed") |
| **swift-ci** | Reusable workflow + tested CLI; **pins `tla2tools.jar` 1.7.4 by SHA-256 and runs `tla-models`** | The oracle runner; later switches its `tla` command to AemiFormal |
| **swift-search** | Declarations/usages, CLI + MCP | Navigation of the new repo by agents |
| **skills, project-hooks, pi-integrations, apple-docs** | Engineering harness, hooks, docs MCP | Hooks/gates; `apple-docs` for system APIs before subprocesses |
| Others (CSVCoder, URLBuilder, Abysm, MacFS, Atelier, InternedStrings, AemiSwift/Utilities/UI shims, AemiSDR; Aemi-Studio: dependence, Cami, Nad, Pasitea, Bilbary, AemiGlass) | Unrelated to this work | Not used. Read at README level only |

Observations, unverified beyond the files named: `AemiUI` and `AemiUtilities` have `Aemi-Studio` remotes but are absent from
`gh repo list Aemi-Studio`; `ask-merge2` is not a git repo; AemiProtobuf's manifest pins `aemi` at `b31f499…` while
AemiJSON/AemiRegex/AemiMarkdown pin `4879ca7…`. Depending on both AemiProtobuf and AemiJSON from a new package would hit
the one-revision-per-identity rule (aemi ADR-0030) unless the pins are aligned first. Probe with `swift package resolve`.

## 2. What was measured today (baseline for "tremendously fast")

Oracle: `tla2tools.jar` 1.7.4, SHA-256 matches swift-ci's pin **[probed]**; Homebrew OpenJDK 27.0.1 arm64; 8 cores;
`-workers auto`; the models are AemiMarkdown's own in `docs/formal`. Commands: `java -cp … tlc2.TLC -deadlock -workers auto
-metadir <tmp> -config M.cfg M.tla`, wall clock, 3 runs.

| Model | States generated / distinct | Wall (3 runs) | What it measures |
|---|---|---|---|
| LineSplitter | 49,188 / 19,682 | 2.30, 1.99, 1.95 s | Mostly **JVM start-up**; no throughput conclusion |
| SnapshotProtocol | 25,512 / 7,563 | 1.63, 2.10, 1.76 s | Same |
| **EditResync** | **3 / 2** | **138.4, 154.4, 141.3 s (median 141.3)** | **Pure expression evaluation**: one invariant over ~10⁶ cases |

Consequences:

1. The only heavy model in the ecosystem is bound by TLC's **evaluator**, not by its search. A compiled evaluator is the
   first measurable target, and EditResync is its first benchmark (unchanged `.tla`, same verdict, wall time).
2. There is **no state-throughput baseline yet** (states/s, memory per state, scaling 1→8 workers). The three models are too small.
   A corpus of large specs is needed (`tlaplus/Examples` is the usual one **[recalled]**, not downloaded; network not used here).
3. A suspicion I formed and **dropped**: TLC's banner prints `x86_64` on this aarch64 host. `java -XshowSettings` reports
   `os.arch = aarch64` for both JBR (the PATH default, Android Studio) and Homebrew OpenJDK, so it is a banner quirk, not
   Rosetta. Lesson for the harness: always pin the JVM explicitly; the PATH `java` here is Android Studio's.
4. TLC defaults seen in its banner: 4096 MB heap, `MSBDiskFPSet`, `DiskStateQueue` **[probed, log]**.
5. Lean is **not installed**, no `elan`/`lake`. TLAPS/Apalache not installed. `z3` is (Homebrew) — relevant to §5.4.

Targets are *hypotheses until probed*: ≥10× on EditResync, ≥3× states/s at 8 workers vs TLC on the corpus, ≤½ the bytes
per distinct state. They become budgets only after the first measured run (ask's budget rule: median and spread, interleaved).

## 3. Scope, with honest feasibility

**TLA+ / TLC is the product. Lean is a separate, narrower product.** They share infrastructure, not a roadmap.

### 3.1 TLA+ side (full pipeline, phased)

| Tier | Component | Replaces | Notes |
|---|---|---|---|
| T0 | Lexer + parser + semantic analysis (name resolution, `INSTANCE`/substitution, operator levels const/state/action/temporal, arity, recursion) | SANY | Layout-sensitive `/\` `\/` bullet lists; diagnostics with byte ranges |
| T1 | Evaluator + explicit-state checker: safety (`INVARIANT`, `PROPERTY` of `[]P`), deadlock, constraints, `.cfg` | TLC core | The speed/safety centre |
| T2 | Liveness: fairness, `<>`, `~>`, temporal quantifiers via tableau + SCC | TLC liveness | Hardest correctness item; model-checked by itself (§6) |
| T3 | Symmetry, VIEW, simulation mode, trace exploration, checkpoint/resume, `-dump`, coverage | TLC options | Each needs a stated semantics before code |
| T4 | PlusCal translator (P-syntax and C-syntax) | pcal | Front-end to T0 AST, output is TLA+ |
| T5 | Standard modules natively: Naturals, Integers, Reals(subset), Sequences, FiniteSets, Bags, TLC, Json, Randomization | Java `tlc2.module.*` overrides | Native, typed, not reflective |
| T6 | Proof checking | TLAPS | **Out of scope**: needs backends (Isabelle/Zenon/SMT). Revisit after Lean tier |
| T7 | Symbolic checking | Apalache | Optional later via `z3` as a subprocess oracle, not a dependency |

### 3.2 Lean side — what is and is not realistic **[recalled; probe first]**

Lean 4's parser, macro system, elaborator and tactics are written *in Lean* and bootstrapped; only the kernel is small, C++-sized
in the thousands of lines. A faithful "Lean in Swift" would mean re-implementing the elaborator and ecosystem (Mathlib is built on
its exact behaviour). **That is not recommended.** The defensible, high-value subset:

| Tier | Component | Why it is feasible | Value to you |
|---|---|---|---|
| L0 | **Independent kernel checker**: expression/level/declaration model, inductive and recursor generation, quotient, definitional equality (whnf, delta, iota, eta, proof irrelevance, Nat/String literal acceleration), reading Lean's *export* text format | Independent re-checkers of Lean proofs exist in other languages **[recalled]**; the kernel is specified | You get machine-checked trust for `development/formal/lean/*.lean` without the full toolchain, fast and safe |
| L1 | Lean 4 lexer/highlighter in `AemiLexers`-style, then a core-syntax parser | Pure syntax | Tooling, `ask` display |
| L2 | A *small* checked surface language (not Lean-compatible) to author proofs for AemiFormal's own algorithms | Own design | Optional, only if L0 shows demand |
| — | Lean elaborator / `lake` / Mathlib compatibility | Not feasible, not scoped | Keep the Lean binary as the authority; AemiFormal checks its exported terms |

How the `.olean`/export format is versioned, and whether the export format is stable across Lean releases, are **open questions**.

## 4. Architecture (Swift-first, not a port)

### 4.1 Targets (one top-level type per file, ≤250 lines, per ADR-0021 / aemi ADR-0010 style)

```
AemiFormal (package, g-cqd/AemiFormal, products fine-grained; no umbrella that re-exports)
├─ FormalSupport      diagnostics, ByteRange, Budgets, Limits               (kernelSettings)
├─ TLASyntax          bytes → token tape → AST tape                         (kernelSettings, unsafe confined + netted)
├─ TLASemantics       resolution, levels, INSTANCE expansion → TLA Core IR  (strictSettings)
├─ TLACore            desugared, level-annotated, slot-resolved IR; no names at run time
├─ TLAValues          value universe + canonical forms + hashing
├─ TLACompile         Core IR → guarded-assignment plans + flat bytecode
├─ TLAEval            bytecode VM (explicit stack, no recursion, bounded loops)
├─ TLAModules         native standard modules (typed registry, not reflection)
├─ TLCConfig          .cfg parser
├─ TLCEngine          BFS/DFS/simulation, state store, successor generator   (kernelSettings)
├─ TLCLiveness        tableau, iterative SCC, fairness                        (kernelSettings)
├─ TLCStore           fingerprint set, state arena, trace file, checkpoint    (kernelSettings)
├─ TLCReport          text (TerminalKit/AemiMarkdown), JSON (AemiJSON), ITF, Mermaid, SARIF-like for modeler
├─ PlusCal            translator
├─ LeanKernel         (L0) exprs, levels, environment, defeq, inductives
├─ LeanExport         (L0) export-format reader on ByteReader
├─ aemi-tlc, aemi-lean  executables (swift-argument-parser, executable target only)
└─ Plugin: formal-check (swift package formal-check), like ProtobufCheck
```

Layering is checked by `Scripts/check-layers.py` and `dependency-audit.sh` (ask ADR-0009 pattern). TLASyntax/TLAValues are
usable without TLCEngine: an editor tool should not link a model checker (white paper: link weight).

### 4.2 Choices that differ from the reference design, and why

1. **Values are 64-bit words, not objects.** Small ints, booleans, interned strings and model values live *in* the word
   (tag + payload, the `TapeSlot` idea widened to 64-bit payloads; `AemiInterner` symbols for strings/model values). Compound
   values live in arenas as flat, canonical, immutable blocks addressed by index. This removes per-value allocation and
   virtual dispatch from the evaluator. *Trade-off:* canonicalisation cost on construction; measure.
2. **Canonical representation ⇒ cheap equality and hash.** Sets are sorted-unique arrays (or bitsets over a small known
   domain); records are (shape, values) with interned field symbols; functions with finite domains are dense arrays when the
   domain is an integer interval or enumerated set; sequences are contiguous. Equality is `memcmp`-like; hashing is
   `WyHash`/`XXH64` over the canonical bytes. This is *the* place a Swift-native design pays off and must be fuzz-tested hardest.
3. **Lazy sets stay lazy.** `SUBSET S`, `[S -> T]`, set comprehensions, `Seq(S)` bounded: membership and cardinality without
   materialising; enumeration is a bounded iterator. EditResync's cost profile suggests this is where the 141 s goes **[hypothesis]**.
4. **Compile the next-state relation.** Decompose `Next` into disjunct actions, hoist guards, order conjuncts so enabling
   conditions run before assignments, turn `x' = e` / `x' \in S` / `UNCHANGED` into assignment slots, and skip dead
   branches. Output: a plan per action. The semantics reference is the declarative definition of `[A]_v`; the plan must be
   *proved equivalent by differential testing* against a naive interpreter kept in the test target (the "reference evaluator").
5. **Optional static typing as an optimisation only.** TLA+ is untyped. A conservative shape inference picks dense layouts;
   when inference fails the generic representation runs. Semantics (including errors for out-of-domain application, `CHOOSE`
   with no witness, comparisons of unlike values) must not depend on it.
6. **Bounded, non-recursive evaluator.** Explicit stack, depth/size/budget limits reported as errors, never a crash
   (AemiRegex ADR-0003: no recursion, every loop bounded). Deeply nested specs must not overflow the Swift stack.
7. **Fingerprints are an option with a stated risk, not an assumption.** Modes: (a) *exact* — canonical state bytes kept and
   compared; (b) *fingerprint* — 64-bit, reporting the collision-probability bound from the actual state count;
   (c) 128-bit (needs a 128-bit hash: `XXH64` and `WyHash` are 64-bit, so promote one to Aemi, with tests, red first).
   The report states which mode ran. Verdicts "no error found" under (b) say "up to the stated bound".
8. **Search is data-parallel on threads, not actors.** CPU-bound workers on dedicated threads
   (`BlockingOffloadPool`/`ConcurrentMap` from AemiRuntime or a new promoted pool), sharded open-addressing fingerprint set
   on `Atomic` words, per-worker `ScratchPool` arenas, level-synchronous BFS frontiers in `RawFileMap`-backed spill files.
   `Mutex`/`Atomic` only; no `NSLock`, no `DispatchQueue` (white paper). Deterministic mode: fixed-order merge per level so
   counterexamples and counts are reproducible; fast mode: work-stealing, counts equal, trace may differ but is still shortest in BFS.
9. **Reliability as a feature.** Checkpoints written with `AtomicFile.replace` + `DurabilityProfile`; a damaged checkpoint
   loads what is intact and reports the rest (`SessionLog.recover` model); resource limits (memory, disk, wall) end a run with a
   *resumable* state and a named reason; reading a checkpoint never writes. Interrupt (SIGINT/SIGTERM) is a clean stop.
10. **Liveness is built from a written algorithm**, not from remembering one: tableau construction for the negated property,
    product with the behaviour graph, iterative (non-recursive) SCC, fairness as acceptance conditions. Each step has a TLA+
    model of the algorithm (checked by Java TLC first, then by AemiFormal itself) and a Lean statement where finite
    checking cannot reach.
11. **One error model.** Typed `throws`, per-subsystem error enums, byte-range diagnostics. Parser and `.cfg` never trap on
    malformed input; the same property tests as AemiJSON/AemiMarkdown (fuzzers exist in aemi: `AemiKernelsFuzz`).

### 4.3 Reuse map (what exists vs. what must be promoted into Aemi)

| Need | Exists | Gap (promote to Aemi after a second-consumer test) |
|---|---|---|
| Byte scanning, UTF-8, numbers | `AemiKernel`, `AemiKernels` | — |
| Tape slots for syntax | `TapeSlot` (4-bit tag, 28-bit aux, 32-bit offset) | Fine for ≤4 GiB source; **too narrow for state/value tapes** → a 64-bit-payload variant |
| Interning of names/strings/model values | `AemiInterner` (arena + WyHash, merge, freeze) | Check that per-worker intern + merge fits symbol stability across workers |
| 64-bit hash | `WyHash`, `XXH64` | 128-bit hash |
| Concurrent fingerprint set | `SharedAtomic`, `Atomic` use in AemiIO | A lock-free open-addressing set (generic, plausible second consumer: AemiInterner, dolly) |
| Mmap/spill, durable files | `RawFileMap`, `AtomicFile`, `DurabilityProfile` | — |
| Parallel map, scratch, clock seams | `AemiRuntime` | A CPU-bound worker pool with pinned threads, if `BlockingOffloadPool` is not it |
| Lexing for editors | `AemiLexers` (scanners: Code, CSS, Data, HTML) | TLA+ and Lean language syntaxes |
| JSON, protobuf, markdown, mermaid | the Aemi libraries | — |
| Metrics (rate, process probe) | `AemiMetrics` | Memory/allocation counters for states/s and bytes/state |

## 5. Correctness strategy ("scientifically accurate")

1. **Specification before code.** A `docs/semantics/` set, one file per construct group, each stating the denotation used
   (Specifying Systems chapter and manual section cited), the *error* cases (TLA+ leaves some expressions unspecified; TLC
   raises; AemiFormal raises and says which), and a table of reference-tool behaviours. Decisions become ADRs; superseded, never edited.
2. **Three independent oracles**, kept apart: (a) the written semantics, (b) the in-repo naive reference evaluator, (c) Java
   TLC 1.7.4 (swift-ci pin) run as a subprocess in the *test/CI* tier only, never at run time. Disagreement is a finding to
   triage; TLC is not assumed right (as ask learned with `node` and V8, AemiRegex AGENTS "node has bugs").
3. **Conformance contract with TLC**: same verdict; same *distinct* state count and diameter under identical semantics (no
   symmetry/view differences); counterexample is a valid behaviour and, in BFS, of minimal length (traces need not be
   byte-identical); *generated* counts are compared and any difference explained, not forced equal.
4. **Corpus**: AemiMarkdown's 3 models with their `.buggy.cfg` must-fail controls (ground truth today), ask's
   `CredentialRefresh`, plus a larger corpus pinned by hash (to be chosen; Examples repo, **not yet fetched**).
5. **Property and metamorphic tests**: evaluator against the reference evaluator on generated expressions; canonicalisation
   round-trips; renaming/permutation invariance of counts; symmetry-reduced vs full counts; `UNCHANGED` ↔ explicit equality.
6. **Fuzzing** the parser, `.cfg` reader, export reader and value canonicaliser (libFuzzer targets, gated env var like `AEMIJSON_FUZZ`).
7. **Mutation testing with litmus** on evaluator, compiler, store and liveness; surviving mutants fail the gate.
8. **The checker is specified in TLA+ and checked by itself**: BFS dedup, fingerprint-set insertion under concurrency
   (a lock-free protocol is a protocol), checkpoint/resume, SCC. First by Java TLC, later by AemiFormal; a bug found by
   either is a roadmap entry. Lean (L0 checker, or the installed Lean until L0 exists) for the unbounded statements.
9. **Guard-page and poisoned-tail tests** for every `unsafe` read (aemi ADR-0021), ASan/UBSan/TSan runs, debug run as a safety net.
10. **Never `-Ounchecked`.** Speed from less work (§4.2 1–4), not removed checks.

## 6. Standards conformance (checklist, from the actual manifests)

- `swift-tools-version: 6.4`; `.v6`, `treatAllWarnings(as: .error)`, `ExistentialAny`, `InferIsolatedConformances`,
  `InternalImportsByDefault`, `MemberImportVisibility`; `StrictMemorySafety` on kernel targets; no unsafe flags on shipped targets.
- Gated dev tooling behind `AEMIFORMAL_DEV` / `_FUZZ`; benchmarks in `Benchmarks/` as dev-only executable targets.
- Pin `aemi` by full revision (same as AemiJSON/Regex/Markdown); `Package.resolved` agrees.
- Layout: `AGENTS.md`, `docs/WHITE-PAPER.md` (≤200 lines), `docs/adr`, `docs/roadmap` (with `status:`), `docs/diary` (≤256 lines);
  `Scripts/quality.sh`, `.ci/swift-ci`, `.githooks`, `.deadwood.json`, `.swift-format`/`.swiftlint.yml` synced from Aemi.
- Tests: Red TDD, Swift Testing, deterministic (no sleep/yield/polling), release with `--enable-testable-imports`,
  `SourceStructureTests` (one type per file, 250 lines), docs-layout test, hygiene test, deadwood/dolly/arcleak `--strict`.
- Every performance-relevant change benchmarked: median + spread, release build, interleaved; numbers in diary and commit.
- Platform floor to decide (§8): the kernel family uses macOS 15/iOS 18 with Linux support; ask uses macOS 26 for `Span`.
  Model checking is a server/CI workload, so **Linux support is a requirement, not a nicety** (swift-ci runs on Linux).

## 7. Integration plan

1. `swift-ci`: add an AemiFormal runner behind the existing `tla-models` command; keep the Java path as the oracle until parity gates pass.
2. `modeler`: emit TLA+ that AemiFormal parses (`modeler tla` → `aemi-tlc`), and report counterexamples back as findings on the Swift source.
3. `ask`: a `formal_check` tool (in-process; "system APIs before subprocesses") that returns trace + Mermaid, replacing the
   Java subprocess documented in ask's `development/formal/REPORT.md`.
4. `AemiMarkdown`, `ask`, `CSVCoder`'s formal directories become the first real corpus.
5. Docs: DocC for the libraries; `docs/` user guide for the CLIs.

## 8. Decisions I need from you

1. **Name and home**: `g-cqd/AemiFormal` (like AemiJSON/Regex/Protobuf/Markdown) vs `Aemi-Studio/`. Product prefixes `TLA*`/`TLC*`/`Lean*` as above, or all `AemiFormal*`?
2. **Lean scope**: confirm L0 (independent kernel checker) as the Lean deliverable and the elaborator as out of scope.
3. **Platform floor**: macOS 15 + Linux (kernel-family) or 26 (ask).
4. **Fingerprint default**: exact, 64-bit, or 128-bit (needs a new Aemi hash)?
5. **Proofs (TLAPS-like)**: confirm out of scope for v1.

## 9. First roadmap entries (proposed, each a claimable unit)

0001 repo skeleton + gates + white paper (copy-sync, not reinvent) · 0002 probe harness: pinned JVM, TLC corpus runner, states/s,
bytes/state, scaling 1→8 workers (closes §2.2) · 0003 semantics docs for expressions + errors · 0004 TLASyntax lexer (layout rule) ·
0005 parser to tape + fuzz · 0006 resolution/levels · 0007 TLAValues canonical forms + hash + fuzz · 0008 reference evaluator ·
0009 bytecode evaluator, **target: EditResync** · 0010 `.cfg` · 0011 safety BFS single-thread · 0012 fingerprint set (+ TLA+ model of
it) · 0013 parallel BFS · 0014 traces + reports · 0015 checkpoint/resume · 0016 liveness · 0017 modules · 0018 PlusCal · 0019 Lean L0.

## 10. Not verified

- Nothing was built or compiled; no Swift code was written. All speed targets are hypotheses.
- Only three small TLC models were run; there is no large-state-space throughput baseline, no memory-per-state number, no scaling curve.
- Lean, TLAPS and Apalache are not installed; every statement about their internals or formats is **[recalled]**.
- I read the manifests, white papers and AGENTS of ask, AemiRegex, AemiJSON/Protobuf/Markdown, modeler, swift-ci and aemi in part;
  the other repos only at README level (HTTP, MacFS, Atelier, TerminalKit internals, analyzerkit modules, litmus, arcleak, fcheck,
  deadwood, dolly were not opened beyond their headers). I did not read all of `aemi`'s ADRs or API surface; §4.3's "Exists" column is from file and symbol names plus a few headers.
- The AemiProtobuf/AemiJSON `aemi` pin mismatch is an observation from manifests, not a resolved-graph failure.
