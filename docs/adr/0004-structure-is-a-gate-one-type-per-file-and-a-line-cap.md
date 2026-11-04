---
status: accepted
date: 2026-11-04
---

# 0004 — Structure is a gate: one type per file and a line cap

## Context

ask ADR-0021 and AemiRegex ADR-0010: the file listing is the map.

## Decision

One top-level type per file, named for it (or `Type+Feature.swift` for extensions); no file past 250 lines, tests included;
generated files exempt. `SourceStructureTests` runs inside `swift test`.

## Consequences

The file listing shows the types the project owns. Splitting a file is not mechanical: an unused `public import` is a compile error.
