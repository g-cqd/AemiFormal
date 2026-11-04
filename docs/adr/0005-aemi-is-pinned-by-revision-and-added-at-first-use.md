---
status: accepted
date: 2026-11-04
---

# 0005 — Aemi is pinned by revision and added at first use

## Context

AemiJSON, AemiRegex and AemiMarkdown pin `Aemi-Studio/aemi` by full revision; SwiftPM rejects one package identity at two
revisions in a graph (aemi ADR-0030). AemiProtobuf's manifest was observed pinning a different revision (not yet resolved together).

## Decision

`Package.swift` does not declare Aemi until a target imports it: the first of roadmap 0033 (limits, through the `AemiRuntime` clock seam) and 0043 (the oracle runner). Then it pins the revision the AemiJSON family pins, and `Package.resolved` agrees. Depending on AemiProtobuf or AemiJSON adds a `swift package resolve` probe first.

## Evidence

Probed 2026-11-04 in a throwaway package with `platforms: [.macOS(.v26)]`: `aemi` at `4879ca7522a6` and `AemiJSON` at `61a8b82` resolve together, and a target importing `AemiKernel`, `AemiKernels`, `AemiInterner`, `AemiIO`, `AemiRuntime`, `AemiMetrics`, `AemiDigest` and `AemiJSONRPC` builds, with `AemiTestKit` in its test target. Pairing AemiJSON `61a8b82` with AemiProtobuf `4e7756e` does not resolve (two `aemi` revisions).

## Consequences

No unused dependency in the manifest, and the dependency audit has nothing to excuse. Which Aemi products each layer uses is in `docs/research/shared-components-2026-11.md`.
