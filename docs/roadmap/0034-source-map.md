---
status: not-started
phase: shared
milestone: M0
target: FormalSupport
blocked-by: []
date: 2026-11-04
---

# 0034 — Source map and positions

Line index over bytes, byte offset to line and column, UTF-8 to UTF-16 conversion (LSP counts UTF-16), and snippet extraction for messages. Builds on `ByteRange`.

**Consumers:** lexer and parser, PlusCal, TLAPS, reports, editor services, Lean export errors.
**Done when** conversions round-trip on a generated corpus including multi-byte text and CR, LF and CRLF endings, and `AemiLexers`' `UTF16Offsets` agrees on the shared inputs.
