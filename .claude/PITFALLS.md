# PITFALLS — every way this project has fooled itself

Each entry below actually happened and cost real time. They are recorded so they are not repeated.
Companion to `.claude/M6_TRUTH.md` (what is true) and `FINDINGS.md` (chronological log).

**The one-line summary:** on this project, the measurement has been wrong more often than the code.
Roughly half the elapsed effort went to acting on numbers that did not mean what they appeared to mean.

---

## A. TOOLING TRAPS — the measurement silently lies

### A1. A tool that cannot run reports SUCCESS
Building with plain `g++` instead of `build.bat` (msys2 ucrt64, `-static`) produces a binary that exits
**3221225785 (0xC0000139, entrypoint not found)** under Python. Every diff came back EMPTY, and empty
diffs read as "no differences — aligned". **Always build with `build.bat`. Treat empty output and any
non-zero exit as FAILURE, never as a clean result.** All `cert/*.py` now exit 2 on a missing corpus for
this reason.

### A2. Relative corpus path breaks in a copied workspace
`cert/*.py` resolved the corpus as `ROOT/../Transpiler/protos2/cache`. Sub-agents that copied the
project to a temp dir silently measured a DIFFERENT (or empty) file set and reported a wrong baseline —
which nearly caused the single largest fix of the project to be discarded as a regression.
**FIXED:** `RENOVICE_CORPUS` env var overrides, and a missing/empty corpus is now a loud FATAL exit 2.

### A3. A too-tight timeout MASKS a real difference
`realtrip` capped each trace subprocess at 20s. One corpus file legitimately needs longer. When BOTH
S' and S'' timed out they were truncated to the SAME prefix and compared EQUAL — a **false SAME**.
Raising the cap to 90s revealed a genuine behavioural difference that had been hidden for the entire
project. **A symmetric cutoff does not make a comparison valid; it can manufacture agreement.**

### A4. Concurrency manufactures failures
Running the oracles concurrently starved `realtrip`, causing timeouts; a timeout truncates ONE trace,
which then reads as a spurious `DIFFERENT`. **Resource contention can create behavioural "failures"
that do not exist.** Mitigated by the larger trace timeout; if it recurs, lower oracle concurrency.

### A5. A TIMEOUT is not a DIFFERENCE
A workflow once concluded "no rule ships — Gate 3 is the universal killer" because it counted a timeout
as a failure. Re-running that one file with a larger budget returned SAME. **Slow is not wrong.**
`gates.py` reports timeouts separately and never counts them as behavioural differences.

### A6. Heredoc backslash collapsing (happened 4+ times)
Writing C++/Python through a bash heredoc mangles `"\n"` into a literal newline, producing
`missing terminating " character`. **Use the Edit/Write tools for any content containing backslash
escapes**, or build the backslash with `chr(92)`.

### A7. TWO ORACLES MEASURING DIFFERENT CONFIGURATIONS
`align.py` always ran in fidelity mode (`RENOVICE_NATIVE=JUMPXEQKN,...`); `realtrip.py` never did.
For the entire project the two headline gates were testing DIFFERENT COMPILER CONFIGURATIONS, so they
could not corroborate each other — and a real fidelity-mode defect (`BindingsUtil`) passed for months
because the behavioural gate was exercising the other mode. It is SAME without `RENOVICE_NATIVE` and
DIFFERENT with it. **Every oracle must pin the SAME environment, and the pinning must be IN the script
— never inherited from the caller's shell** (see also the earlier defect where realtrip inherited the
shell and silently measured `_G`-lowered output).

### A10. Two regex traps that both print a CLEAN number
Building `cert/dropped.py` (the detector for #97) sprang both within ten minutes:
- **`^...$` without `re.M`, used with `findall()` over a whole file** — `^` matches only at offset 0,
  `findall` returns `[]`, and the summary confidently printed **"0 state machines (0.0 %)"** for a
  corpus where 56 % of files have one. The neighbouring count, computed line-by-line, was correct —
  so the report was half right, which is worse than wholly wrong.
- **`\s*$` as a line anchor** — `\s` matches newlines, so the match swallows the following line and
  `findall` skips every other hit: **912 machines instead of 1,011**. Use `[ \t]`, never `\s`, when
  anchoring to a line.
**A measurement bug usually reports a plausible number, not an error.** Cross-check any new count
against a second, differently-implemented path before quoting it.

### A9. `/tmp` is not the same directory in bash and in Windows Python
In this environment bash resolves `/tmp` to `C:\Users\Bartek\AppData\Local\Temp`, but a Windows
Python process resolves it to `C:\tmp`. So `derecomp ... > /tmp/x.luau` succeeds, `ls /tmp/x.luau`
shows the file, and `open('/tmp/x.luau')` in the very next command raises FileNotFoundError.
**Inside Python always use an absolute Windows path or `tempfile.gettempdir()`.** Confirm a path with
`cygpath -w`. This is A1's family: the tool cannot see its input and the failure looks like absence.

### A8. Diagnosing the same failure three times
`BindingsUtil` was attributed to (1) a too-tight timeout, (2) oracle concurrency, and only then to
(3) the environment difference. The first two were plausible and both had SOME supporting evidence —
raising the timeout DID change the verdict, and concurrency DOES starve traces. **A hypothesis that
explains the symptom is not thereby the cause. Change ONE variable at a time and re-measure.**

---

## B. METRIC TRAPS — the number is real but does not mean what you think

### B1. Self-consistency is not fidelity
`recompile` writes back whatever `decompile` misread, so round-trip and behavioural-trace oracles are
blind to a CONSISTENT misreading by construction. Defects #56 (wrong proto bound at every closure site)
and #58 each survived **5386/5386 round-trips and 150/150 traces**. **Only comparison against the
ORIGINAL bytecode can catch that class.**

### B2. A green gate is not proof of correctness
The all-gates-green tree contained emitted source calling `Normalize(nil)` — a register read before
assignment. `realtrip` passed because BOTH sides carried the same defect. **A green gate is the absence
of a DETECTED failure, not the presence of correctness.**

### B3. Oracle agreement is not proof
Two oracles agreed the output was clean while a quadratic-iteration bug sat in it: NAME-DIFF cannot see
a wrapper containing no named access, and `realtrip`'s mocked iterators return nil immediately so a
loop that should run N times runs 0–1 and N² == N. **When both oracles are insensitive to a defect
class, their agreement carries no information.** Pick an oracle chosen to be SENSITIVE to the defect —
for loops that is `cert/backedge.py`.

### B4. `realtrip` wraps bodies in `pcall`
It can therefore MASK a dropped access. It gave a false pass on a path that lost 8 accesses.
**Never use it alone to prove fidelity — use the access count vs the ORIGINAL.**

### B5. NAME-DIFF counts ACCESSES, not structure
Blind to an empty duplicate loop wrapper. Do not read NAME-DIFF 0 as "structurally correct".

### B9. FIRST-MATCH-WINS CLASSIFICATION HIDES EVERY LESSER CATEGORY
`align.py` returns on the first differing category and tests LOOP-DIFF **before** the access check.
So a file with BOTH is reported only as LOOP-DIFF, and `NAME-DIFF` does not mean "files that lost an
access" — it means **"files that lost an access AND had no loop difference."** That set *grows as
loops get fixed*, so the gate reads as a regression precisely when the code improves.
It reported **0** while the honest count was **46 files**, one losing **293 accesses**.
**A per-file classifier that returns one label is a summary, not a gate.** Score each property
independently (`cert/allcats.py`) and gate on the property you actually care about.

### B7. One metric reaching a steady value does not mean the ARTEFACT is stable
Agents measured the state-machine count across repeated round trips, saw `0, 0, 0`, and reported
"collapse is permanent — S'' = S''' = S''''". Re-measured on the artefact itself, the decompiler is
**divergent**: bytecode grows ~20 % *per cycle* (`BindingsUtil` 32,474 → 37,997 → 44,947 bytes) and
source code lines ~50 % (2,285 → 3,739 → 5,367). The metric they chose had simply bottomed out.
**Check the artefact — size, bytes, content — not a statistic computed from it.**

### B8. A fallback that always succeeds absorbs bugs
`M6_PLAN.md:226` said this before it happened; it happened anyway. `sa-validate` honestly reported
**0 protos in the structuring fallback**, while the *emitter's* state-machine fallback ran on **56 %
of the corpus** — because a path that never fails never reports. `M6_PLAN.md:91` had even scheduled
it for deletion as *"provably dead code"*; it was never removed. **Any fallback that cannot fail must
COUNT its own use and surface that count in a gate**, or it is indistinguishable from success.

### B6. A metric moving up is not always a regression
ORDER-DIFF rose 27 → 45 while LOOP-DIFF fell 148 → 123: files MIGRATED from a more severe class to a
less severe one. **Always reconcile the category totals** (they must sum to the file count) before
calling a rise a regression.

---

## C. COMPARISON TRAPS — comparing things that are not comparable

### C1. Block IDs are PER-PROTO and COLLIDE across protos
Counting "132 emissions, 40 distinct block ids" across a file is meaningless — `lid=35` in two protos
is two different blocks. **Always group by proto first.** This wasted three separate attempts.

**It happened again in 2026-07-28**, in the very scan built to measure #97: state machines are named
`p<regionId>`, region ids restart per proto, and `p9` is emitted **5 times** in one file
(`ChatRedux`). Keying state counts by variable NAME merged unrelated machines. **Whenever an
identifier appears in emitted output, ask what scope makes it unique before aggregating on it.**

### C5. Check whether a suspicious pattern is actually a DIFFERENT SCOPE
The same scan flagged "20 name-shadowing sites" — a `local pN` redeclared inside a live `pN` guard
chain, which would misdispatch the outer machine. **All 20 were nested closures**, i.e. a separate
Lua scope, therefore harmless. Retracted before it reached a report. A textual "X inside Y" test
says nothing about scope; confirm the enclosing construct (here: a `function` keyword between the
two) before calling it a defect.

### C2. Proto INDEXES are not stable between emitter variants
Emitting one fewer `for` can reorder protos, so `proto[i]` on two sides is often a DIFFERENT FUNCTION.
Comparing by index produced 18 phantom "defects". **Match protos by CONTENT, not index.**

### C3. Always state which artefact a number came from
ORIGINAL vs our SOURCE vs our RECOMPILE. Conflating them produced several false conclusions — e.g.
"the emitter drops code" (it did not; the SOURCE was complete and the RECOMPILE lost accesses at
compile time, because unwrapping made an in-body `return` unconditional).

### C4. Recursive content hashes AMPLIFY
Hashing a proto's signature including its children turned 5 real findings into 207: one benign leaf
difference rewrites every ancestor's signature. **Do not use recursive signatures for diffing.**

---

## D. REASONING TRAPS — plausible, confidently wrong

### D1. Documentation is not the implementation
Luau's `Bytecode.h` comment implies the numeric-for user variable is at **A+3**. Real DE bytecode reads
**A+2**. "Fixing" it to match the comment would have corrupted EVERY numeric loop, and NO oracle would
have caught it (the skeleton drops register numbers by design). **Verify a documentation claim against
real bytecode before acting on it.**

### D2. Verify a diagnosis's SCALE before implementing it
A high-confidence, adversary-approved diagnosis proposed rewriting the Proper-region emitter. Measuring
first showed only **11 of 1204** Proper regions could exhibit the shape — a 1204-region rewrite to fix
11. Two minutes of counting prevented it. **Mechanism correct ≠ mechanism significant.**

> **But see D7 — that particular count was of the wrong population, and the rewrite it deferred
> turned out to be needed.** The RULE is right; its first application was not.

### D7. Counting the wrong population (the D2 count was a FALSE NEGATIVE)
D2's "11 of 1204" counted Proper regions containing a sub-region **already classified as a loop**.
The actual defect is Proper regions containing a cycle that was **never classified as a loop at all**
— by construction, exactly the population that count excludes. The re-measurement: **168/300 files
(56 %)** emit a Proper state machine and **46 backward transitions silently drop code** (#97).
**Before trusting a frequency count, ask whether the thing you are counting can even exhibit the
defect.** A count that is structurally blind to the defect will always return "rare".

### D8. An unchecked precondition in a comment is a bug with a paper trail
`emit.h`'s Proper case states "a Proper region is a single-entry **ACYCLIC** subgraph" and
"ascending index IS a topological order", then relies on both without asserting either. Both are
false on real corpus data, and the failure is SILENT — code is dropped, nothing errors.
**If correctness rests on a property, assert it in code or test it in a gate. A comment is not an
invariant.** Cheap rule: any emitter that assumes an ordering should verify the ordering.

### D3. Look at the DISTRIBUTION before optimising
183 failing files cluster into **10 shapes**, top 3 = 65%. That clustering takes two minutes and could
have been run twenty turns earlier; instead mechanisms were found one at a time by accident.
**Attack shapes by frequency, never whichever file happens to be open.**

### D4. Fixes do NOT compose
head-level claim alone: ALIGNED 91. mark-before-recurse alone: 99. **Both together: 94.** A three-part
loop fix needed all three parts; part 1 alone sent EXTRA-LOOPS 18 → 108. **Measure every combination
you intend to ship; never assume two independent wins add.**

### D5. Applying a principle without its precondition
"Structure loops before conditionals" is correct in the literature — but it assumes a loop forest
computed UP FRONT (Ghidra's `orderLoopBodies`). Simply reordering greedy rules in a bottom-up reducer
made things worse, because the NaturalLoop rule needs its interior reduced first.

### D6. Ten attempts at the same shape means the DESIGN is wrong
Every attempt to remove a duplicate loop by suppressing an already-placed wrapper lost code
(#60d, #67, #72, #74, #76, #83, #84, #86, #87, #90). The invariant: **unwrapping a body makes its
contents unconditional**, so an in-body `return` kills everything after it. The fix was a phase split
(PLAN/RENDER), not an eleventh rule. **After the third failure of the same shape, stop patching and
question the architecture.**

---

## E. PROCESS TRAPS — how the work itself goes wrong

### E1. Agents are reliable for DIAGNOSIS, not for REPORTING FIXES
- fix-reporting campaign: one agent **fabricated a binary and its metrics** outright; another lost its
  source; a third reported a win that was an artefact of a wrong baseline.
- diagnosis-only campaign: 4 diagnoses, **all survived adversarial review**.
**Let agents diagnose and race rival patches in isolated copies. The orchestrator re-measures every
claimed result in the real tree before believing it.** Twice this is what saved the outcome — including
recovering the project's largest win from a workflow that concluded "no rule ships".

### E2. An adversary can confirm a mechanism and still miss the magnitude
Both the diagnosing agent and its adversary rated the Proper-flattening claim high-confidence. Neither
checked how often the shape occurs (11/1204). **Adversarial review checks reasoning, not relevance.**

### E3. Never write a number before the measurement returns
"Default verified UNCHANGED" was written into a log in the same command that measured it changing.

### E4. Do not redefine a gate to fit a result
A change that regressed `realtrip` was once shipped with a written justification for why the failure
was acceptable. That is exactly what gates exist to prevent. **If a gate fails, the change does not
ship — fix the underlying defect instead.** `gates.py` prints this in its verdict.

### E5. Snapshot before experimenting — and then USE the snapshot as a CONTROL
Keep a copy of the last known-good `src/` + binary. Reverting must be instant and certain, or the
temptation to keep a half-working change grows.

**The snapshot's real value is as an experimental control, not just an undo.** On 2026-07-28 three
successive hypotheses about one apparent regression were all wrong, and each was killed the same
way: run the PRE-CHANGE binary from `.snapshot_pre97/` against the SAME oracle and compare.
That settled in minutes what reasoning about the diff could not settle at all:
- `NAME-DIFF 0 → 1` looked like a regression. Pre-change binary: the file loses the **same** 3
  accesses. An unmasking (B6), not a regression.
- `realtrip 149 < 150` looked like a regression. Pre-change binary: **also** DIFFERENT. A stale
  baseline.
- A genuine regression (one file, 7 accesses) was found only by **diffing the two binaries'
  ACCESS-LOSS file lists** — it was invisible in the summary totals, which moved by ±1.
**Before attributing any metric change to your edit, reproduce the metric with the old binary.**

### E6. Never move a baseline without a control measurement
Two baselines were changed on 2026-07-28 and both were legitimate — but only because the pre-change
binary was measured first and the failure shown to pre-date the change. The rule that keeps E4 from
being rationalised away: **a baseline may move only with a recorded pre/post measurement pinned
beside it in the file.** `gates.py` now carries that proof inline for every changed number, and its
`KNOWN_DIFF` list requires the same evidence for each entry.

---

## F. WORKSPACE / PARALLELISM RULES

**What parallelises well**
- Diagnosis (read-only) — proven.
- Rival implementations of ONE decision, each in an isolated copy, then re-verified centrally — this is
  how the PLAN/RENDER tie-break was found.
- Oracle execution — `cert/gates.py` runs all four gates concurrently: **~1m45s instead of ~15 min**.

**What does NOT parallelise**
- Two people/agents editing `src/emit.h`. Loop, ORDER-DIFF and most structural work all live there, and
  **fixes do not compose** (D4). Concurrent edits give merge conflicts AND invalid measurements.

**Track ownership (only ~2 tracks are genuinely independent)**

| track | files | may run in parallel? |
|---|---|---|
| loops / ordering / structure | `src/emit.h`, `src/structan.h` | **NO — single owner** |
| closure & proto duplication | `src/m6e_cmd.h` (`inline_closures`) | yes |
| oracles & tooling | `cert/*` | yes |

**The rules**
1. **ONE INTEGRATOR** owns `src/emit.h`, runs `cert/gates.py`, and decides what ships.
2. Any isolated workspace MUST set `RENOVICE_CORPUS` to the real corpus (A2).
3. Every claimed result is re-measured by the integrator in the real tree before it is believed (E1).
4. `cert/gates.py` BASELINE is updated only when a change legitimately lands — never to make a failing
   change pass (E4).
