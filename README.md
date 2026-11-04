# AemiFormal

TLA+, TLC and Lean in Swift: a front end, an explicit-state model checker, a PlusCal translator, an independent Lean kernel checker, and the road to
the rest of the toolchain. Written for the Aemi ecosystem on its kernels (`aemi`, AemiJSON, AemiProtobuf), not as a port of the Java or C++ tools.

**Status: skeleton.** Only `FormalSupport` (source ranges and diagnostics) exists. Nothing checks a model yet, and every speed target in `docs/` is a hypothesis.
The measured starting point is the Java TLC 1.7.4 baseline in `docs/diary/2026-11-04-01.md`.

```sh
swift test -c release --enable-testable-imports
```

Read `docs/WHITE-PAPER.md`, then `docs/research/scope-reassessment-2026-11.md` and `docs/research/shared-components-2026-11.md`. Work is in `docs/roadmap/` (46 entries, milestones M0 to M8).

[MIT](LICENSE)
