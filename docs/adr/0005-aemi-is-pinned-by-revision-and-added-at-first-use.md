---
status: accepted
date: 2026-11-04
---

# 0005 — Aemi is pinned by revision and added at first use

## Context

AemiJSON, AemiRegex and AemiMarkdown pin `Aemi-Studio/aemi` by full revision; SwiftPM rejects one package identity at two
revisions in a graph (aemi ADR-0030). AemiProtobuf's manifest was observed pinning a different revision (not yet resolved together).

## Decision

`Package.swift` does not declare Aemi until a target imports it (roadmap 0007: hashing and interning). Then it pins the revision
the AemiJSON family pins and `Package.resolved` agrees. Depending on AemiProtobuf or AemiJSON adds a `swift package resolve` probe first.

## Consequences

No unused dependency in the manifest, and the dependency audit has nothing to excuse.
