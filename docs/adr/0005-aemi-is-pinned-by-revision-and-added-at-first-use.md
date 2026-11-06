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

Probed 2026-11-06 in a throwaway package with `platforms: [.macOS(.v26)]`: `aemi` `e30aad82377cbea62171cc722a88041e97021db2`, `AemiJSON` `aec8895f1bc9`, `AemiProtobuf` `4492e961a533` and `AemiRegex` `e07516ddd7ea` (the heads of all four on that day) resolve together, and a target importing `AemiKernel`, `AemiInterner`, `AemiJSONRPC`, `AemiProtobuf` and `AemiRegex` builds, with `AemiTestKit` in its test target.

On 2026-11-04 the same probe at `AemiJSON` `61a8b82` with `AemiProtobuf` `4e7756e` failed (two `aemi` revisions, `4879ca7` and `b31f499`); the family's repin since then (aemi ADR 0030) cleared it. SwiftPM also treats an abbreviated and a full hash of one commit as two requirements, so every pin here is a full 40-hex hash.

## Consequences

No unused dependency in the manifest, and the dependency audit has nothing to excuse. Which Aemi products each layer uses is in `docs/research/shared-components-2026-11.md`.
