# AemiFormal — Project White Paper

The rules this project runs on. **Paste this at the start of every iteration.** An iteration that cannot satisfy a rule below stops and
fixes the rule, or asks to change it in writing. It does not quietly proceed. Principles live here and never a log: the log is the diary.

## What this is

Formal-methods tooling in Swift for the Aemi ecosystem: a TLA+ front end (SANY's job), an explicit-state model checker (TLC's job), a
PlusCal translator, and an independent Lean 4 kernel checker. Consumers are named: `modeler` (emits TLA+), `swift-ci` (runs the models),
`ask` (a tool that checks a model and shows the trace), and the `formal/` directories of AemiMarkdown, ask and CSVCoder. The
study that scopes this is `docs/research/aemiformal-study-2026-11.md`.

## Not a port

The Java TLC and SANY, TLAPS and Lean 4 are **oracles**, never sources (ADR-0001). The contract is the language's semantics
(*Specifying Systems*, the TLA+ manual; Lean's kernel theory) written down in `docs/semantics/` with its error cases, and the
reference tools' observable behaviour. Every design starts from what Swift and the Aemi kernels make cheap, not from what the
reference did. A disagreement with an oracle is a finding to triage, not a defect by definition: the oracle has bugs too.

## The evidence rule

Every claim is named, given a probe that could fail, run, and recorded in the diary before it is acted on.

- **A probe that cannot fail is not a probe.** The first baseline suspected Rosetta from a banner; `os.arch` said otherwise.
- **A test that has never failed proves nothing.** A new gate is broken on purpose once. A model checked by this tool has a
  `.buggy.cfg` that must fail, so a green run means something.
- **Unprobed claims are written as open questions, never as facts.** A speed target is a hypothesis until measured.

## Order of goals

Correctness, then safety, then speed. Speed never buys back either. A verdict is only as strong as its stated mode: an exact
search says "no error"; a fingerprint search says "no error, up to a collision bound printed in the report" (ADR-0006 when written).

**No recursion, every loop bounded** (ADR-0003). Specifications are attacker-shaped input: deep nesting, huge sets, divergent
recursion. Work goes on explicit stacks with limits, and exceeding a limit is a typed error, never a crash or a hang.

**Malformed input is a case.** The parser, the configuration reader and the export reader never trap on any bytes. Each is fuzzed.

**`unsafe` is confined, justified and netted**; no `-Ounchecked`, no disabled bounds or overflow checks, ever.

**Reliable by default.** Damage costs only what is damaged. A damaged checkpoint loads what is intact and reports the rest;
reading never writes; a run that hits a resource limit ends resumable with the limit named.

## Speed is a number

Every change that can affect performance is benchmarked: before and after, same harness, release build, median and spread, units.
The baseline is the pinned Java TLC (1.7.4), on a corpus fixed by hash, with the JVM pinned explicitly (the PATH `java` here is
Android Studio's). Measured so far: the heavy model in the ecosystem is evaluator-bound (diary 2026-11-04-01). "Fastest" is not
a word this project uses until the numbers say it.

## Compliance is measured against oracles

Three kept apart: the written semantics, a naive in-repository reference evaluator, and Java TLC in the test and CI tier only. The
contract with TLC: same verdict; same distinct-state count and diameter under identical semantics; a counterexample that is a valid
behaviour (minimal length in BFS); generated counts compared and any difference explained, not forced.

## Dependencies and sharing

Aemi supplies the kernels, at one pinned revision (ADR-0005); nothing else without an ADR that compares the alternatives. Reuse before writing: an
Aemi piece is used as it is, and a kernel is written here only for a recorded gap. A piece is shared when two consumers need it, otherwise it stays in
its engine (ADR-0011). Targets sit in three layers and import only downward. A generic piece found here belongs in Aemi, with its tests, red first;
the owner moves it, because that changes another repository.

## Documentation law

Enforced by `DocumentationLayoutTests`.

| Path | Rule |
|---|---|
| `docs/WHITE-PAPER.md` | Principles, never a log. Capped at 200 lines. |
| `docs/adr/NNNN-title.md` | One decision per file, `accepted` or `superseded`; a new ADR supersedes, and the chain names itself both ways. |
| `docs/roadmap/NNNN-title.md` | One claimable unit per file with `status:` and `blocked-by:`. |
| `docs/diary/YYYY-MM-DD-NN.md` | The working log and where probe history lives. 256 lines; roll over. |

`docs/research/` holds dated notes with their probe sources. `docs/semantics/` holds the language contract.

## Process

**Test first, and see it fail for the right reason.** Red is a run: a stub that returns the wrong answer.
**Mutation against a proven-green baseline** (litmus). **Atomic commits that say why**; a pre-existing problem found on the way is
a roadmap entry, not a silent repair. One top-level type per file, named for it; no file past 250 lines (ADR-0004).
