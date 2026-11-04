# Working in `aemiformal`

TLA+/TLC/Lean tooling in Swift. **Read [`docs/WHITE-PAPER.md`](docs/WHITE-PAPER.md) first**; it leads with the evidence rule and the rule that this is not a port.
This file records what an agent cannot derive from the source.

## Commands

```sh
swift test -c release --enable-testable-imports      # the suite, in release (what ships)
.ci/swift-ci run quality                             # what CI's quality runs (format, SwiftLint, discipline, analyzers); the hooks' gate
git config core.hooksPath .githooks                  # once per clone: pre-commit lint, pre-push release run
```

Build and test in **release**. Debug runs are a safety net for `unsafe` code (bounds checks live there).

## Gates

`DocumentationLayoutTests`, `SourceStructureTests` (one type per file, 250 lines), `NoRecursionTests` (ADR-0003), `RepositoryHygieneTests`. Each was seen
to fire. A new gate is broken on purpose once.

## Traps

- **The PATH `java` is Android Studio's JBR.** Pin the JVM in any TLC baseline (`/opt/homebrew/opt/openjdk/bin/java` was used for the first one).
- **TLC prints `x86_64` in its banner on Apple Silicon** while `os.arch` is `aarch64`. A banner quirk, probed.
- **A roadmap entry needs `phase`, `milestone` and `blocked-by`**; the gate rejects cycles and an entry earlier than its blocker.
- **Check `uptime` before timing anything**: load was 21 to 28 on 8 cores during the first baselines (diary 02).
- **A small model measures the JVM start-up**, not TLC. Use models that run for tens of seconds at least.
- **Fingerprint-only runs can be wrong** (ADR-0007). Report the mode and the bound.
- **AemiJSON HEAD and AemiProtobuf HEAD do not resolve together** (aemi pins differ). Probe with `swift package resolve` before adding either.
- **Another writer may share the working tree.** Check `git status`; do not `git add -A` under changes you did not make.

## Dependencies

None yet. Aemi is added at the first target that imports it, pinned by revision (ADR-0005).

## Commit discipline

Atomic and buildable; the message states why. Never mix a refactor and a behaviour change. A pre-existing problem found on the way is a roadmap entry.

## Current state

`FormalSupport` only. The roadmap has 46 entries in milestones M0 to M8; ready now: 0033 limits, 0034 source map, 0035 graph kernels, 0036 big integers,
0037 128-bit hash, 0038 term store (spike), 0043 oracle runner. The Lean kernel checker (0020) is two steps from ready and independent of the TLA+ line.
Roadmap numbers are never reused. Layers and the sharing rule: ADR-0011; what is shared and why: `docs/research/shared-components-2026-11.md`.
