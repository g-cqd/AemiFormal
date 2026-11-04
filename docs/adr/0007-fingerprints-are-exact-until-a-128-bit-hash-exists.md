---
status: accepted
date: 2026-11-04
---

# 0007 — Fingerprints: exact until a 128-bit hash exists, 64-bit only on request

## Context

A fingerprint collision makes the search skip a state and its subtree, so a clean run can be wrong. The birthday bound is about n^2 / 2^(b+1):
for 64 bits, n = 10^9 gives about 0.027 and n = 10^10 about 2.7 (arithmetic, not a measurement); for 128 bits, n = 10^10 gives about 1.5e-19.
`WyHash` and `XXH64` in Aemi are 64-bit.

## Decision

Modes: exact (canonical state bytes kept), 128-bit, and 64-bit. Until Aemi has a 128-bit hash (roadmap 0037), the default is exact and 64-bit needs an
explicit option. Every report names the mode, and a fingerprint run prints its collision bound from the actual state count.

## Consequences

The 128-bit hash is promoted into Aemi with tests, red first, once a second consumer is plausible (the interner and dolly qualify).
