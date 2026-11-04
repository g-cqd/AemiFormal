---
status: accepted
date: 2026-11-04
---

# 0002 — The family's platform floor, and Linux

## Context

AemiJSON, AemiRegex, AemiProtobuf and AemiMarkdown use macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, with Linux built in CI. ask
uses macOS 26 for `Span`. Model checking is a server and CI workload.

## Decision

The family floor, and Linux supported and tested. This is the maintainer's **default pending the owner's choice** (study §8.3):
supersede this record if the owner picks macOS 26.

## Consequences

`Array.span` is unavailable below macOS 26, so hot paths take `UnsafeBufferPointer` inside a kernel-settings target, as AemiRegex does.
