---
status: accepted
date: 2026-11-04
---

# 0009 — Extensions and distribution: a plugin protocol and a transport

## Context

TLC loads Java classes as module overrides and distributes work over RMI. This project offers the same two capabilities in Swift terms.

## Decision

Standard modules are native. User extensions go through a plugin protocol (a Swift package product linked at build, or a subprocess speaking a
framed protocol on AemiProtobuf). Distribution uses a transport chosen by ADR when its roadmap entry starts.

## Consequences

A specification that overrides a module in Java ports the override to the plugin protocol; the error for an unported one names the override.
