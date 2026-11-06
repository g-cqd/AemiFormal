# AemiFormal and aemi: report for the aemi owner and developer

Date: 2026-11-06. Written against `Aemi-Studio/aemi` `e30aad82377cbea62171cc722a88041e97021db2` (main on that day). Prepared by the coding agent working for
the AemiFormal owner. This document stands alone: the AemiFormal repository is local and not yet published, so nothing here needs it to be read.

**Nothing in aemi has been changed, and no pull request or issue has been opened.** Everything below is a request, a question or an observation for you to
accept, reshape or decline.

Evidence tags: **[read]** source read at the revision above; **[probed]** something was run; **[recalled]** from memory, not checked.

## 1. In short

- AemiFormal is a new Swift package (TLA+ and TLC, PlusCal, a Lean 4 kernel checker, later a Lean runtime, TLAPS and SAT/SMT) built on aemi's kernels. Platforms: macOS 26 and Linux.
- **It uses aemi as it is** for most of what it needs (section 3). Every product I would use resolves and builds at the revision above [probed].
- **Nine items** need your decision (section 4). Four are real kernels that AemiFormal would otherwise write itself: **graph kernels** (R1), a **writable shared mapping** (R2), a **compute work pool** (R3) and **big integers** (R4). Five are short questions: a 128-bit hash (Q5), the stability of `KeyedHash` output (Q5b), a Lexers language (Q6), a shipped PRNG (Q7), and capacity and interning (Q8).
- **No defect in aemi was found.** One small suggestion about ADR 0030 and one note on what worked are in section 5.
- AemiFormal builds each generic kernel in its own target, written to move into aemi unchanged, and offers it to you through an ADR in your own format (aemi ADRs 0018, 0020, 0022 and 0031 are the model). You decide what to take and when.

## 2. Why this concerns aemi

AemiFormal's design rule (its ADR-0011) is *reuse first; write a kernel only for a recorded gap; share a piece only when two consumers need it; promote to aemi by
moving a target, decided by you.* Its roadmap has 46 entries; 13 are shared kernels, and of those only the ones in section 4 touch what aemi owns or could own.
The first dependency on aemi arrives with the first of two entries: a limits type that reads time through `AemiRuntime`'s clock seam, and an oracle runner. The
minimum revision AemiFormal needs is `9fc215c`, where `KeyedHash` and `HashIndex` arrived [read].

## 3. What AemiFormal will use as it is

| aemi piece | Used for | State |
|---|---|---|
| `AemiKernel`: `Varint`/zigzag, `CheckedMath`, `ByteReader`, `TapeSlot`, `WyHash`, `XXH64` | canonical value bytes, parser tape, non-adversarial hashing | [read]. `TapeSlot` offsets cap at 4 GiB and `aux` at 2^28, fine for sources, too small for a term store, which will not use it |
| `AemiKernel.KeyedHash` | hashing anything an attacker may shape (a specification is one) | [read], used in a probe. 64-bit output |
| `AemiKernel.HashIndex` | likely base of the intern table for hash-consed terms | [read], used in a probe. `Int32` values: capacity to be checked (question Q8) |
| `AemiInterner` | identifiers, module names, strings | [read], `merge(workers:)` run in a probe at `4879ca7` |
| `AemiIO`: `SharedAtomicU64`, `RawFileMap`, `AtomicFile`, `DurabilityProfile` | lock-free set core; zero-copy reading of Lean `.olean` and `.ir` files; checkpoints | [read]; `compareExchangeAcqRel` run in a probe. `RawFileMap` is read-only (R2) |
| `AemiKernels.crc32c`, `AemiDigest` SHA-256 | checkpoint and file integrity | [read] |
| `AemiRuntime`: clock seams, `ScratchPool`, `ResourcePool`, `mapConcurrently` | time into limits; scratch buffers; coarse parallel work | [read] |
| `AemiMetrics.ProcessProbe` | benchmark harness: wall and CPU time, resident and footprint bytes, instructions, cycles, children's CPU and peak RSS | [read] |
| `AemiTestKit`: `Generator`/`forAll`, `ByteMutator`/`fuzzNeverTraps`, `SeededRNG`, `ReferenceComparison`, `expectAllocations`, `recordBenchmark` | all testing; AemiFormal adds no test framework | [read] |
| `AemiJSONRPC` (in AemiJSON) | editor services and a plugin transport | [read]; builds [probed] |
| `AemiLexers`, `AemiMermaid` (separate repo) | highlighting; trace and state diagrams | [read] (Q6 for Lexers) |

## 4. Requests and questions

Ordered by how much AemiFormal depends on the answer. For each: what is needed, the evidence, a shape I would suggest (a sketch, not a design), and what would
show it is done. "Done" follows your own standard: exhaustive or fuzzed tests, mutation testing (ADR 0027) and guard-page tests where memory is mapped (ADR 0021).

### R1. Graph kernels: iterative strongly connected components and union-find

- **Need.** TLC's liveness checking is SCC over a state graph that lives on disk, so storage must be a `Span` of edges or successors computed on demand, not `[[Int]]`. Also name resolution cycles, Lean declaration order, and congruence closure in a SAT/SMT core.
- **In the family today [read].** `arcleak` `StronglyConnectedComponents`: iterative Tarjan over `[[Int]]`, 63 lines, `internal`. `dolly` `EmbeddingCloneDiscovery.swift`: a private `UnionFind` whose `find` recurses (depth bounded by union-by-rank, so not a bug, but AemiFormal forbids recursion). A second copy I saw earlier in `SwiftStaticAnalysis` is gone.
- **Suggestion.** A target (or `AemiKernel` files) with a small adjacency protocol, iterative Tarjan, iterative union-find, cycle reporting; `arcleak` and `dolly` could move onto it, as ADR 0031 moved the parsers.
- **Done when** results equal a naive reachability-based reference on generated graphs, a 10^6-node chain and ring run in linear time with a flat stack, and `arcleak`'s own fixtures give the same components.

### R2. A writable, growable shared file mapping

- **Need.** A disk-backed fingerprint set and state queue: a `MAP_SHARED` mapping that can be written, with the same reserve-and-grow trick `RawFileMap` documents (no `mremap` on Darwin, map more than the file and let the file grow underneath).
- **Evidence [read].** `RawFileMap` is "Read-only shared memory mapping of a file" and calls `mmap` with `PROT_READ`. That is right for AemiFormal's other use, reading `.olean`/`.ir`, and should stay.
- **Suggestion.** A sibling type in `AemiIO` that hands out `Span`/`MutableRawSpan`-style views, plus a durability call through `DurabilityProfile`; `SharedAtomicU64` already supplies the atomics.
- **Question.** Do you want it in `AemiIO`, or should AemiFormal keep it in its own `FormalStore`? Either is fine; it should not exist twice.

### R3. A compute work pool and sharded frontier

- **Need.** Dedicated threads running compute loops (one per core), a sharded work frontier, termination detection, and an insert-only lock-free table.
- **Evidence [read].** `BlockingOffloadPool` is documented as running *blocking* calls off the cooperative pool, with a bounded `run` queue; that is a different job. Nothing else in `AemiRuntime` is a compute pool.
- **Probed.** At `e30aad82`, 8 threads offered 1,000,000 keys 8,000,000 times to a table built on `SharedAtomicU64.compareExchangeAcqRel`, and it counted exactly 1,000,000 insertions (hashed with `KeyedHash`). The earlier run at `4879ca7` was 2,000,000 keys offered 16,000,000 times, exactly 2,000,000. This shows the protocol works, not that it is fast: the load average was 27 and 69 on the two days, so no timing is claimed.
- **Offer.** AemiFormal will specify its termination and insertion protocols in TLA+ and check them with Java TLC first (its roadmap 0042). Once its own checker works it could also check protocols in aemi, for example `BlockingOffloadPool`'s wakeup accounting, if you want that. That is an offer, not a commitment.
- **Question.** Is a compute pool in scope for `AemiRuntime`, or should it live in AemiFormal's `FormalParallel`?

### R4. Arbitrary-precision integers

- **Need.** `Nat` and `Int` for TLA+ `Integers`, Lean's `Nat` and `Int` (the kernel accelerates literals; the runtime needs them), and SMT arithmetic.
- **Evidence.** None in aemi or any sibling repository (name-based search over all of them, build directories excluded; a differently named implementation would be missed). `DecimalLiteral` keeps the first nineteen digits and converts to `Double`; it is not an integer type.
- **Oracles available [probed].** Python 3.15 and Homebrew GMP are installed; Lean's `.olean` format records whether persisted bignums use GMP.
- **Plan.** AemiFormal writes it in `FormalNumeric` with differential tests against Python. **Question:** do you know of another consumer (JSON or TOML integers beyond 64 bits, for instance)? If so, it belongs in aemi from the start.

### R5. Small questions

- **Q5. 128-bit fingerprints.** `KeyedHash` gives a 64-bit output. For 10^9 states a 64-bit fingerprint has a collision probability of about 0.027 by the birthday bound (arithmetic, not measured), which is why AemiFormal defaults to exact states and wants a 128-bit option. SipHash defines a 128-bit output mode **[recalled]**. Would you take a `hash128` on `KeyedHash`, or should AemiFormal keep its own?
- **Q5b. Stability.** AemiFormal will persist fingerprints in checkpoints, with the key stored beside them (the default key is random per process, so a resumed run must restore it). Is the output of `KeyedHash(k0:k1:)` for a given key a stable contract across aemi versions? A checkpoint format depends on the answer.
- **Q6. Lexers.** `Language` is a closed `CaseIterable` enum with no TLA+ or Lean, and `LexicalLineLexer` switches over it. Is it closed by design? Would you take `tla` and `lean` scanners, or an open way to register one? The per-line `LexState` model suits editors.
- **Q7. A shipped PRNG.** `SeededRNG` (SplitMix64) lives in `AemiTestKit`. TLC's `Randomization` module and simulation mode need one in shipped code. Could SplitMix64 move to `AemiKernel`, with `AemiTestKit` re-exporting it so no existing sequence changes?
- **Q8. Capacity and interning.** `Symbol` is `UInt32` (maximum `UInt32.max - 1`) and `HashIndex` holds `Int32`. How many names a Lean environment holds is not counted; Mathlib is large (103 MB of source). Is a 64-bit variant in your plans? And for a search whose workers meet new strings mid-run: ADR 0019 chose per-worker tables merged by shard because lock-striping was slower and numbered keys in thread order. AemiFormal intends never to let symbol numbers into a state's identity (identity comes from content bytes) and to merge at barriers. Does that match your intent for `merge`?

## 5. Observations on aemi

None is a defect. Both are about the family's pins and not about any API.

1. **A full hash is required, and ADR 0030 does not say so.** SwiftPM treats an abbreviated revision and the full hash of the same commit as two requirements: a probe with `revision: "e30aad8"` beside dependencies that name the full hash failed with "aemi is required using two different revision-based requirements (e30aad8 and e30aad82377c…)" [probed]. ADR 0030 says consumers "name the same hash"; saying *the full 40-hex hash* would spare the next contributor.
2. **What worked.** At `e30aad82`, `aemi`, `AemiJSON` `aec8895`, `AemiProtobuf` `4492e96` and `AemiRegex` `e07516d` resolve together and build under `platforms: [.macOS(.v26)]` [probed]. The family's repin since 2026-11-04 cleared a conflict I had found that day (AemiProtobuf and AemiJSON naming two aemi revisions).

## 6. How to reproduce

A throwaway package; the hashes must be full:

```swift
// swift-tools-version: 6.4
import PackageDescription
let package = Package(name: "P", platforms: [.macOS(.v26)],
  products: [.library(name: "P", targets: ["P"])],
  dependencies: [
    .package(url: "https://github.com/g-cqd/AemiJSON.git", revision: "aec8895f1bc9bdaf2104b0d0ebe91e4a93b3c374"),
    .package(url: "https://github.com/g-cqd/AemiProtobuf.git", revision: "4492e961a533d46783ff7b433b075451856055af"),
    .package(url: "https://github.com/g-cqd/AemiRegex.git", revision: "e07516ddd7ea3bcedd055dfe66f67ffb06fb5a82"),
    .package(url: "https://github.com/Aemi-Studio/aemi.git", revision: "e30aad82377cbea62171cc722a88041e97021db2")],
  targets: [
    .target(name: "P", dependencies: [
      .product(name: "AemiKernel", package: "aemi"), .product(name: "AemiIO", package: "aemi"),
      .product(name: "AemiInterner", package: "aemi"), .product(name: "AemiJSONRPC", package: "AemiJSON"),
      .product(name: "AemiProtobuf", package: "AemiProtobuf"), .product(name: "AemiRegex", package: "AemiRegex")]),
    .testTarget(name: "PTests", dependencies: ["P", .product(name: "AemiTestKit", package: "aemi")])])
```

The concurrent set (the core of R2 and R3), about thirty lines:

```swift
import AemiIO
import AemiKernel

final class ProbeSet: @unchecked Sendable {
    let slots: UnsafeMutableRawPointer, mask: Int
    init(log2: Int) {
        let n = 1 << log2
        slots = .allocate(byteCount: n * 8, alignment: 64)
        slots.initializeMemory(as: UInt8.self, repeating: 0, count: n * 8)
        mask = n - 1
    }
    deinit { slots.deallocate() }
    /// true when this call inserted `fp` (non-zero by construction)
    func insert(_ fp: UInt64) -> Bool {
        let fp = fp == 0 ? 1 : fp
        var i = Int(truncatingIfNeeded: fp >> 7) & mask
        for _ in 0...mask {
            let p = slots + i * 8
            let cur = SharedAtomicU64.loadAcquire(p)
            if cur == fp { return false }
            if cur == 0 {
                if SharedAtomicU64.compareExchangeAcqRel(p, expected: 0, desired: fp) { return true }
                if SharedAtomicU64.loadAcquire(p) == fp { return false }
            }
            i = (i + 1) & mask
        }
        preconditionFailure("table full")
    }
}
```

Run it from `DispatchQueue.concurrentPerform(iterations: 8)`, each iteration offering the same key range from a different start, and sum the `true` returns: it must equal the distinct key count. There is no resize and no disk, which is what R2 and R3 are about.

## 7. How AemiFormal proposes to work with aemi

1. Each generic kernel is built in AemiFormal, red first, in a target with no TLA+ or Lean types, using aemi's test kit.
2. When one is ready, AemiFormal drafts the promotion ADR in your format and the code as a patch you can take or leave; the move changes your repository, so it is your call.
3. If you would rather own a kernel from the start, say so before it is built and AemiFormal will wait on it (it has no kernel blocked on aemi today; the earliest aemi use is the clock seam).
4. Questions Q5 to Q8 are not blocking. R1 and R4 are the ones where an early answer saves duplicate work.

## 8. Not verified

- No timing of any kernel on a quiet machine; the load average was 27 to 69 during these probes.
- Nothing has been built or run on Linux. AemiFormal's CI plan includes Linux jobs (Swift 6.4.1 containers) and a `macos-26` job, but CI has not run (no remote).
- The graph and bignum searches are by name across the repositories checked out locally; a differently named implementation, or one in a repository not checked out, would be missed.
- `HashIndex` was exercised only with one insert and two lookups; its behaviour at Lean-scale inputs is unknown.
- I did not read `KeyedHashTests` or `HashIndexTests` for what they cover beyond their existence.
- Pins were checked against the remote `main` only for AemiJSON, AemiProtobuf, AemiRegex, AemiMarkdown and swift-search (all name `e30aad82`). Other repositories were not compared with their remotes, and AemiHTML has none.
