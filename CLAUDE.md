> **END GOAL (user, 2026-10-09):** make the decompiler 99-100% accurate across the CURRENT build's
> corpus, failure class by failure class (measured by CONST-ID + CFG-ID against the original
> bytecode, plus a dataflow check for what CFG-ID cannot see). No per-script VERIFIED/UNVERIFIED
> labelling layer: fix the decompiler instead. Then the modding API. Build on this repo's existing
> research, tools, gates and DEFECTS.md; do not restart. See the workspace `AGENTS.md`.
>
> **READ FIRST: `.claude/M6_TRUTH.md`** (what is true / what is not) and
> **`.claude/PITFALLS.md`** (every way this project has fooled itself — measurement traps, metric
> traps, comparison traps, process traps, and the parallel-workspace rules).
> **Verify with one command: `python cert/gates.py 300 150`.**
>
> `M6_TRUTH.md` is the distilled state: verified bytecode facts, the beliefs that were measured and
> DISPROVEN (several cost days each), the standing rules, the four release gates, and the current
> target. `PITFALLS.md` is why you should not trust a number until you know how it was produced.
> `FINDINGS.md` remains the chronological log.
>
> **Current: ALIGNED 112/300 · NAME-DIFF 0 · realtrip 149/150 (1 REAL failure, `BindingsUtil`) ·
> 5386/5386 recompile.** The remaining 183 failures are **10 shapes / ~3 mechanisms**, not a long tail.
>
> Two known defects the gates CANNOT see, kept visible on purpose:
> `BindingsUtil` was hidden for the whole project by a 20s trace timeout truncating BOTH sides to the
> same prefix; `SetVortexWindPerZone` emits register reads before their assignment (`Normalize(nil)`)
> while passing every gate. **A green gate is the absence of a detected failure, not correctness.**

# ⚠ STANDING CAVEAT — M6 IS STRUCTURALLY VERIFIED, SEMANTICALLY UNCONFIRMED

Every M6 number below is a **COMPLETENESS** metric. Not one of them is a **CORRECTNESS** metric.

| stage | metric | what it actually proves |
|---|---|---|
| M6a IR | 5,529,086 / 5,529,086 operands resolved | every operand has *a* meaning |
| M6b CFG | 82,042 / 82,042 protos | the graph is well-formed |
| M6c expr | 0 unhandled instructions | every instruction was *dispatched* |
| M6d structuring | 82,042 / 82,042, 0 missing/dup blocks | every block is placed exactly once |

**None of these can tell whether the recovered code MEANS what the bytecode means.**

That is not a theoretical worry. On 2026-07-25 THREE separate bugs sat behind these metrics reading
100% while output was being silently deformed:
- the **phantom `FORGPREP` edge** — ~9,000 protos misclassified, ~15,700 loops misshaped;
- **duplicate loop registrations** — ~450,000 constructs shifted;
- **SETLIST / multret** in M6c — `{1,2,3}` decompiled to `{}`, `return math.max(a,b)` to a bare `return`.
In every case an A/B produced IDENTICAL success counts with DIFFERENT output.

## Therefore, until the round-trip oracle passes:
1. **Do NOT publish or regenerate the corpus for reading.** Wrong-but-plausible source is worse than
   no source: it gets read, believed, and edited against.
2. **Do NOT describe M6 output as "verified", "correct", or "clean"** — say *structurally complete*.
3. **Do NOT delete `all_source_v13/v14/v15` yet.** They are contaminated and unusable as an oracle,
   but they are the only existing reference until ours is proven.

## What lifts the caveat
`decompile -> emit -> luau-compile -> lbc-cmp` against the original Luau bytecode. If S' compiles to
the same bytecode as S, it IS the same program. The harness exists and is self-tested (it catches
`ADD` vs `SUB` and `<=` vs `<`); it needs M6e emission to have anything to chew on. 142 generated
ground-truth pairs are ready, plus 5,386 real scripts for the compilability sweep.

---

# CLAUDE.md — DeNativeRecompiler working protocol

Project-level rules. These ADD to the global `~/.claude/CLAUDE.md` (ask-first / read-only) and never
relax it.

---

## ★ AFTER EVERY WARFRAME UPDATE — RE-CERTIFY BEFORE TRUSTING ANYTHING

**A cert is valid only for the binary it ran against.** Opcode numbers are DE's, not upstream Luau's,
and nothing stops a patch from renumbering them. After any game update, the entire opcode map is
UNVERIFIED until re-run.

Procedure — one build, one F9:

```bash
cd DeNativeRecompiler
./build.bat                      # or: g++ -O2 -std=c++17 -static ... -o bin/derecomp.exe src/main.cpp
./cert/rebuild_all.sh            # rebuilds ALL cert modules from source with the current map,
                                 # applies the native-emission knobs + bytecode patches, deploys
```
Then ask the user to press **F9** in-game and read `%LOCALAPPDATA%\Warframe\EE.log`.

**Expect 28 tags.** 17 `_OK` suites (v9 ×11, v10 ×6) plus 11 value-reporting modules:

| tag | expected value |
|---|---|
| `V11_THIN` | `idivk=3 powk=1024 subrk=6 divrk=2.5 pow=1024` |
| `V11_BOOL` | `on=true off=false n=3` |
| `V11_ANDK` | `t_and_t=true t_and_f=false f_and_t=false n_and_t=nil num_and_t=true` |
| `V12_ANDOR` | `t_and=5 f_and=false n_and=nil t_or=true f_or=6 n_or=6` |
| `V12_SUBK` | `subk=7 subk2=-15` |
| `V12_CMPK` | `n_eq=true n_ne=false n_no=false s_eq=true s_no=false b_eq=true b_no=false` |
| `V12_JBACK` | `sum=15 guard=3` |
| `V13_FORGPREP` | `sum=60 count=3 calls=4` |
| `V14_MODR` | `r=3` (this module tests `IDIV`; the name is historical) |
| `V15_ORK` | `t=7 f=5 n=5` |
| `V16_FASTCALL` | `floor=3 ceil=4 max=9 min=2 abs=5 sqrt=4 maxk=10 type=number` |

A **wrong value names the opcode we actually have** — the operands are chosen so every rival op gives
a different answer. Do not treat these as pass/fail.

Also re-run the offline suite, which needs no game at all:
```bash
./bin/derecomp.exe de-roundtrip-batch <cache>   # expect 5382/5382 byte-exact
./bin/derecomp.exe de-recode          <cache>   # expect LOSSLESS
./bin/derecomp.exe de-validate        <cache>   # expect 0 violations / 5,529,086
./bin/derecomp.exe ir-validate        <cache>   # expect 100.0000%, 0 unresolved operands
./bin/derecomp.exe de-ktags           <cache>   # expect 0 suspects
./bin/derecomp.exe de-fieldaudit      <cache>   # read the UNMODELLED rows too (see below)
./bin/derecomp.exe de-fastcall        <cache>   # expect 165,605/165,605
./bin/derecomp.exe de-cfg             <cache>   # expect 82042/82042, 0 errors
```

---

## ★ THE OLD DECOMPILED CORPUS IS NOT AN ORACLE

`all_source_v13` / `v14` / `v15` were produced with the OLD, WRONG opcode map (`0x51`=TESTSET,
`0x00`=MODR, `0x34` as a const-index compare, `MUL`=`0x09`, generic `FORGPREP`=`0x30`, …).

**Never validate the decompiler against them.** "Our output matches v13" would mean we are wrong in
the SAME WAY. The old "~21% recompiles" figure is meaningless — it measured self-consistency of a
flawed pipeline. Those numbers must never be quoted as progress.

The real corpus is still valuable, but **as BYTECODE only** — for coverage and idempotence, never as
a source reference.

### Generate ground truth instead
```
  Luau source S  (known by construction)
     -> luau-compile.exe   (real upstream compiler)  -> Luau bytecode
     -> our transcoder     (27/27 certified)         -> DE bytecode
     -> decompiler                                   -> source S'
     -> compare S' with S
```
Every pair is known-correct with zero dependency on the old corpus, and pairs can be generated
COMBINATORIALLY — the same technique that found the `JUMPIFEQ` bug ten green metrics had missed.

### What each M6 oracle actually proves
| oracle | proves |
|---|---|
| self-generated round-trip | **correctness** — output means what the input meant |
| compilability (`luau-compile.exe` accepts our output) | validity — it is real Luau |
| idempotence (decompile -> recompile -> decompile) | consistency |
| coverage over 5,386 real files | completeness — nothing is silently dropped |

None of these reads the old sources. If a proposed metric requires them, the metric is wrong.

## Non-negotiable cert rules

1. **Verify the code path is exercised.** Before deploying, `derecomp histops <module>.spawn.lua_B`
   must show the target opcode PRESENT, and a knob-off build must show it ABSENT. A green cert that
   never ran the code proves nothing — this has happened.
2. **Report VALUES, not pass/fail.** `error("TAG=" .. tostring(v))`. A wrong number identifies the
   opcode; a "FAIL" identifies nothing.
3. **Choose operands where every rival opcode differs.** `10 % 4` and `10 // 4` both give 2 — useless.
   `17` and `5` separate MUL/MOD/DIV/IDIV/ADD/SUB cleanly.
4. **Test both polarities and at boundaries.** `a<=a` and `a<a` are what distinguish `<` from `<=`.
5. **One risky probe per batch.** A crash during load can destroy every other module's result.
6. **Harnesses may use only PROVEN primitives.** Never test a suspect construct with a suspect
   construct.
7. **Never crash-probe table/store ops.** Establish them offline against the corpus first — a wrong
   table op is an access violation, and one already took down a stage load.

## Certifying an opcode we never emit

Two techniques, both in place:

- **Native-emission knob** — `RENOVICE_NATIVE=AND,OR,ORK,SUBK,JUMPBACK,JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,FORGPREP,ANDK`
  makes a normally-lowered op emit natively so a cert can reach it. Production output keeps the
  proven lowering.
- **Bytecode surgery** — `derecomp de-patchop <in> <out> <proto> <findop> <nth> <newop> [A B C]`
  for ops no Luau source can produce (upstream dropped `TESTSET`; there is no reversed-operand `MOD`).
  Emit a carrier with the same operand layout, rewrite one opcode byte. It REFUSES width mismatches.
  **The carrier must supply valid operands** — a probe once died silently because `C` was a const
  index and the carrier's proto had zero constants.

## When a probe reports NOTHING

Do not theorise. **Bisect**, with two modules:
1. the same source **unpatched** → does the carrier/harness work at all?
2. patched, but with the target proto **never called** → does the module LOAD?

That splits load-time from run-time failure in one F9 and points straight at the cause.

## Reading the audits

`de-fieldaudit` prints a row per (opcode, field) with `%>=maxstack`, `%>=nconsts`, and `distinct`.
**Read the rows marked `model=-` too.** An unmodelled field with a clean const-index signature is a
finding, not a blank — `ORK` sat in that output unread for hours.

Signatures: a **register** never exceeds maxstack · a **const index** never exceeds nconsts and
spreads widely · an **immediate** is confined to a tiny set (`0x34` had exactly `{0,1}` over 2,591
uses). Put a **minimum-n guard** on any "too few distinct values" rule — `IDIVK` has n=5 corpus-wide.

## Evidence hierarchy

1. **In-game behaviour** — the only thing that settles semantics for ops we can emit or patch.
2. **Corpus structure** — source↔bytecode correlation over 5,386 real scripts. Use for field
   semantics, operand classes, and anything crash-prone.
3. **Stock `luau-compile.exe`** — the real upstream compiler, in `bin/`. If it emits the same shape,
   the shape is compiler-normal. This settled the dead-code question outright.
4. **Reasoning** — a hypothesis, never a verdict. Agent consensus is NOT evidence: a 10-agent workflow
   once contradicted itself on ~12 opcodes and "refuted" a correct answer.

## Editing this codebase

- **Never append a trailing `//` comment to a line that continues** — it swallows the rest. Done
  twice, once silently commenting out `JUMPIF`/`JUMPIFNOT`.
- After touching `OPMAP` or `opinfo`, re-run `de-roundtrip-batch` + `ir-validate` + rebuild the v10
  matrix. A broken table entry is invisible until something executes.
- Build to a **temp exe name** — `derecomp.exe` is often locked by a running probe. Promote after.
- `src/ir.h` is read-only analysis and must stay separate from the byte-exact writer in
  `de_container.h`. Nothing in the decompiler may perturb the 5382/5382 round-trip.

## Read these first

`DEFECTS.md` — every defect found, its bug class, and which check catches it.
`OPCODE_MAP.md` — authoritative emit + decode reference. `CERT.md` — cert suites and results.
`METHODOLOGY.md` — evidence rules. `FINDINGS.md` — chronological log. `ARCHITECTURE.md` — milestones.
