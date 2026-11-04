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

`FormalSupport` only. Next claimable entries: 0002 (baseline corpus and harness), 0003 (semantics), 0020 and 0021 (Lean, independent of the TLA+ line).
