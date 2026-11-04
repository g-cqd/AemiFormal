---
status: not-started
blocked-by: [0020 0021]
date: 2026-11-04
---

# 0022 — Lean .olean reader and IR interpreter

Read `.ir` files (IR lives there, not in `.olean`) and `.olean`; the header and exact-build rule are probed (ADR-0008). Measure the interpreter on the elaborator against upstream's. **Done when** the pinned release's elaborator runs a file and its output equals the real binary's.
