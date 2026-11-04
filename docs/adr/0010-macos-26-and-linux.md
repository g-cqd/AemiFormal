---
status: accepted
date: 2026-11-04
supersedes: ADR-0002
---

# 0010 — The floor is macOS 26 and Linux

## Context

The owner's choice: macOS 26 and Linux. `ask` declares `platforms: [.macOS(.v26)]` and nothing else; the Apple platforms other than macOS are not targets.
Model checking is a workstation and CI workload.

## Decision

`Package.swift` declares `.macOS(.v26)`. Linux is supported and built in CI. `Span` and `RawSpan` are available to hot paths on macOS, and Linux
gets them from the toolchain; a hot path written against them needs no `UnsafeBufferPointer` fallback for older systems.

## Consequences

Dependencies with a lower floor are fine. Linux cannot be exercised on the development machine here, so a Linux claim rests on CI having run, and
there is no remote yet (roadmap 0002 records the first run).
