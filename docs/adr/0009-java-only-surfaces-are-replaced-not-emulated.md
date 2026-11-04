---
status: accepted
date: 2026-11-04
---

# 0009 — Java-only surfaces are replaced, not emulated

## Context

TLC loads Java classes as module overrides and distributes work over RMI. Neither exists in Swift.

## Decision

Standard modules are native. User extensions go through a plugin protocol (a Swift package product linked at build, or a subprocess speaking a
framed protocol on AemiProtobuf). Distribution uses a transport chosen by ADR when its roadmap entry starts.

## Consequences

A specification that needs a Java override cannot run unchanged; the error names the override and the replacement.
