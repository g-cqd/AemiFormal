---
status: not-started
phase: shared
milestone: M3
target: FormalStore
blocked-by: ["0033"]
date: 2026-11-04
---

# 0041 — Container format and writable mapping

A versioned file container: magic, version, sections, per-section integrity (`AemiKernels.crc32c`, `AemiDigest` SHA-256), atomic replace (`AemiIO.AtomicFile`, `DurabilityProfile`), and recovery that loads the intact sections and names the damaged ones. Plus a writable, growable shared mapping: `RawFileMap` is read-only (`PROT_READ`), which suits reading `.olean` and `.ir` but not a disk-backed set.
**Consumers:** the disk spill of the search (0013), checkpoints (0015); parse and IR caches and trace files when they exist.
**Done when** a file damaged at every byte offset loads what is intact or fails with a typed error, never a trap.
