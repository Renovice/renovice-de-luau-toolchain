# DEFECTS.md — every defect found, how it was found, and how it was fixed

Companion to `FINDINGS.md` (chronological narrative). This file is the **index**: what was broken,
what class of bug it was, and which check would have caught it earlier.

> **The single most useful lesson on this page:** every defect below was found while the project's
> structural metrics read **100%** — round-trip 5382/5382 byte-exact, de-recode lossless, de-validate
> 0 violations over 5.5M instructions. Those metrics check that bytes survive and that operands are
> IN RANGE. None of them can notice an operand being **interpreted wrongly**, because a bogus index
> is still a valid index. A metric at 100% constrains only what it measures.

---

## Defect log

| # | defect | symptom | how it was found | fix |
|---|---|---|---|---|
| 1 | `MUL` mapped to `0x09` | wrong arithmetic | corpus source↔bytecode correlation | `MUL = 0x22` (`0x09` is the number-typed specialised MUL) |
| 2 | `SETTABLEKS` mapped to `0x0c` | **access violation, crashed a stage load** | in-game | `SETTABLEKS = 0x15` (`0x0c` is a cache variant) |
| 3 | `GETTABLEKS` mapped to `0x17` | field reads returned `nil` | corpus: same field written `0x15`, read `0x3d` | `GETTABLEKS = 0x3d` |
| 4 | `NAMECALL` mapped to `0x36` | wrong dispatch | `0x36` appears **zero** times in the corpus | `NAMECALL = 0x2d`, force `C=0` |
| 5 | field cache slot forced to `255` | corrupted an adjacent register | corpus C values are 0..254 | preserve Luau's `C` |
| 6 | `PREPVARARGS` dropped | `...` was never set up | in-game (`V_ONE` failure) | emit `0x11`; every vararg proto starts with it |
| 7 | `JUMPIFLT`/`JUMPIFLE` **swapped** | every `repeat…until` overshot by one | **boundary** tests (`a<=a`, `a<a`) | `LT=0x21`, `LE=0x23` |
| 8 | `JUMPXEQKNIL` lowered to LOADNIL + reg compare | `x == nil` wrong after `SETUPVAL` (tag-sensitive) | in-game pipeline test | native `0x3a`, aux passthrough |
| 9 | `JUMPIFEQ` mapped to `0x20` | **value-producing `(a==c)` returned `false` for equal values** | generated v10 matrix, first run | `JUMPIFEQ = 0x37`; `0x20` is the number-CONST compare |
| 10 | `build_cfg` did not make a leader after `RETURN` | 501 dead instructions counted live (undercount) | hand-tracing stock-Luau output | RETURN now makes a leader; 1,418 → 2,235 dead |
| 11 | `0x34` treated as a const-index compare | latent wrong operand read | `de-auxhist`: only **2** distinct aux values `{0,1}` over 2,591 uses | `0x34 = JUMPXEQKB`, aux is a boolean **immediate** |
| 12 | import path parts assumed tag-3 strings | **every** import rendered `<import ...?>` | M6a `ir-validate` first run | accept tag-1 FNV hashes too → 326,014/326,014 |
| 13 | **`C_BOOL` missing from the transcoder** | **`{ flag = true }` could not be compiled AT ALL** (`default: throw`) | chasing "why is ANDK 100% name-hashes?" | `tag 1`, 4-byte `0/1` — DE overloads tag 1 |
| 14 | `0x51` named `TESTSET` | 948 constant refs unannotated; wrong decompiler output | `de-fieldaudit` (C is a const index) + `de-ktags` (mixed const types) + patched probe | **`0x51 = ORK`** `R[A]=R[B] or K[C]` |
| 15 | `0x00` named `MODR`, **and** reg-reg `IDIV` declared nonexistent | `a // b` hard-errored on compile | bytecode surgery: `V14_MODR r=3` = `17//5` | **`0x00 = IDIV`** (reg-reg partner of `IDIVK 0x24`) |
| 16 | `0x0b` unnamed (`FORGPREP?`); generic iterators emitted `0x30` | wrong opcode; worked only via the VM's fallback | `de-forgprep`: iterator identity + FORGLOOP aux polarity | **`0x0b` = generic `FORGPREP`**; `0x30` is `FORGPREP_NEXT` |

## Recurring bug classes

1. **"No DE byte exists for X" has been wrong THREE times** — reg-reg `POW`, `IDIVK`, and reg-reg
   `IDIV` were all present in the corpus, mislabelled. Treat that phrase as a red flag, never a
   conclusion.
2. **Cascade contamination.** A dead block preceded by dead code, or a branch *from* dead code, proves
   nothing. Split ROOT from CASCADE. I made this mistake three separate times, including twice inside
   the very audit written to expose it. When a test asks "does X reach Y", condition on X being live.
3. **Testing a suspect construct with a suspect construct.** The first `JUMPIFEQ` harness used `~= true`
   — itself broken — to check comparisons. Harnesses may use only already-proven primitives.
4. **A test that does not exercise the path proves nothing.** An earlier `JUMPIFEQ` calibration came
   back all-green while driving `==` through a lowering that never touched `0x20`. Always confirm with
   `histops` that the opcode is present in the built module, and absent with the knob off.
5. **Small-n masquerading as a signal.** `IDIVK` was flagged "only 4 distinct values" — it has n=5 in
   the whole corpus. Put a minimum-n guard on any "too few distinct values" rule.
6. **A measured undercount can itself be an undercount.** T6 measured 501 dead instructions; the real
   figure after the fix was 2,235 − 1,418 = 817 more than the base, because the probe stopped at the
   first mid-block RETURN. Quote such figures as lower bounds.
7. **An "unmodelled" field with a clean signature is a finding, not a blank.** `de-fieldaudit` printed
   `0x51 C … 38.50% >= maxstack, 0.00% >= nconsts, model=-` in its very first run. I read only the rows
   where the model claimed something, and missed `ORK` for hours.
8. **Never append a trailing `//` comment to a source line that continues.** Done twice: killed a
   `GETUPVAL` table entry, then silently commented out `{"JUMPIF",0x4b},{"JUMPIFNOT",0x18}`.

## The checks that actually find these

| check | what it constrains | what it CANNOT see |
|---|---|---|
| `de-roundtrip-batch` | bytes survive re-encoding | any semantic error |
| `de-recode` | instructions re-encode losslessly | any semantic error |
| `de-validate` | operands in range, branches on-boundary | an operand interpreted wrongly |
| `de-cfg` | control flow is well-formed | what an instruction MEANS |
| **`ir-validate`** | **every operand RESOLVES to a meaning** | whether that meaning is right |
| **`de-ktags`** | **what KIND of constant each op references** | pure-register ops |
| **`de-fieldaudit`** | **register vs const-index vs immediate, per field** | ops absent from the corpus |
| **`de-auxhist`** | index vs immediate, for one opcode | — |
| **in-game cert** | **actual behaviour** | only ops we can emit or patch |

---

## Complete opcode status

77 opcodes appear in the corpus; 61 are emittable. Certification status per byte:

| byte | name | corpus n | status |
|---|---|---:|---|
| `0x00` | `IDIV` | 2 | emit+decode, cert in-game |
| `0x01` | `GETTABLE` | 54,115 | emit+decode, cert in-game |
| `0x02` | `SETGLOBAL` | 40,270 | emit+decode, cert in-game |
| `0x04` | `LOADB` | 153,625 | emit+decode, cert in-game |
| `0x06` | `SUBRK` | 2,489 | emit+decode, cert in-game |
| `0x07` | `SUB` | 13,076 | emit+decode, cert in-game |
| `0x08` | `POWK` | 132 | emit+decode, cert in-game |
| `0x09` | `MULK` | 11,292 | emit+decode, cert in-game |
| `0x0a` | `FORNLOOP` | 15,249 | emit+decode, cert in-game |
| `0x0b` | `FORGPREP?` | 1,219 | emit+decode, cert in-game |
| `0x0c` | `FASTCALL2K` | 2,671 | decode-only, PROVEN STRUCTURALLY |
| `0x0d` | `LOADNIL` | 52,851 | emit+decode, cert in-game |
| `0x0e` | `MINUS` | 1,618 | emit+decode, cert in-game |
| `0x10` | `FASTCALL` | 6,364 | decode-only, PROVEN STRUCTURALLY |
| `0x11` | `PREPVARARGS` | 5,668 | emit+decode, cert in-game |
| `0x12` | `LOADN` | 339,331 | emit+decode, cert in-game |
| `0x13` | `GETUPVAL` | 351,320 | emit+decode, cert in-game |
| `0x14` | `MOVE` | 364,632 | emit+decode, cert in-game |
| `0x15` | `SETFIELD` | 120,739 | emit+decode, cert in-game |
| `0x16` | `NEWCLOSURE` | 31,495 | emit+decode, cert in-game |
| `0x17` | `GETGLOBAL` | 22,464 | decode-only, CERT IN-GAME |
| `0x18` | `JUMPIFNOT` | 116,307 | emit+decode, cert in-game |
| `0x19` | `FASTCALL1` | 140,927 | decode-only, PROVEN STRUCTURALLY |
| `0x1a` | `DIV` | 4,565 | emit+decode, cert in-game |
| `0x1b` | `FORGPREP_INEXT` | 8,876 | emit+decode, cert in-game |
| `0x1c` | `JUMPIFNOTLT` | 27,974 | emit+decode, cert in-game |
| `0x1e` | `FORGLOOP` | 13,751 | emit+decode, cert in-game |
| `0x20` | `JUMPIFEQ` | 19,213 | decode-only, CERT IN-GAME |
| `0x21` | `JUMPIFLT` | 4,072 | emit+decode, cert in-game |
| `0x22` | `MUL` | 12,915 | emit+decode, cert in-game |
| `0x23` | `JUMPIFLE` | 2,100 | emit+decode, cert in-game |
| `0x24` | `IDIVK` | 5 | emit+decode, cert in-game |
| `0x25` | `JUMPBACK` | 15,678 | decode-only, CERT IN-GAME |
| `0x26` | `FASTCALL2` | 15,115 | decode-only, PROVEN STRUCTURALLY |
| `0x27` | `JUMPIFNOTEQ` | 25,761 | emit+decode, cert in-game |
| `0x28` | `CONCAT` | 23,023 | emit+decode, cert in-game |
| `0x29` | `RETURN` | 140,631 | emit+decode, cert in-game |
| `0x2a` | `SETTABLE` | 11,018 | emit+decode, cert in-game |
| `0x2b` | `OR` | 282 | decode-only, CERT IN-GAME |
| `0x2c` | `NEWTABLE` | 35,781 | emit+decode, cert in-game |
| `0x2d` | `NAMECALL` | 468,568 | emit+decode, cert in-game |
| `0x2e` | `SETTABLEN` | 1,524 | emit+decode, cert in-game |
| `0x2f` | `AND` | 125 | decode-only, CERT IN-GAME |
| `0x30` | `FORGPREP` | 3,656 | emit+decode, cert in-game |
| `0x31` | `ANDK` | 22 | decode-only, CERT IN-GAME |
| `0x32` | `DIVK` | 6,944 | emit+decode, cert in-game |
| `0x33` | `JUMPIFNOTLE` | 11,443 | emit+decode, cert in-game |
| `0x34` | `JUMPXEQKB` | 2,591 | decode-only, CERT IN-GAME |
| `0x35` | `CAPTURE` | 187,957 | emit+decode, cert in-game |
| `0x37` | `JUMPIFEQ2` | 14,076 | emit+decode, cert in-game |
| `0x38` | `ADDK` | 12,773 | emit+decode, cert in-game |
| `0x39` | `CLOSEUPVALS` | 3,095 | emit+decode, cert in-game |
| `0x3a` | `CMPK_A` | 19,571 | decode-only, CERT IN-GAME |
| `0x3b` | `DIVRK` | 590 | emit+decode, cert in-game |
| `0x3c` | `MODK` | 469 | emit+decode, cert in-game |
| `0x3d` | `GETFIELD` | 280,577 | emit+decode, cert in-game |
| `0x3e` | `SUBK` | 7,771 | decode-only, CERT IN-GAME |
| `0x3f` | `SETLIST` | 20,847 | emit+decode, cert in-game |
| `0x40` | `JUMP` | 44,959 | emit+decode, cert in-game |
| `0x41` | `CMPK_S` | 5,519 | decode-only, CERT IN-GAME |
| `0x42` | `DUPCLOSURE` | 45,179 | emit+decode, cert in-game |
| `0x44` | `GETTABLEN` | 8,489 | emit+decode, cert in-game |
| `0x45` | `POW` | 92 | emit+decode, cert in-game |
| `0x46` | `GETIMPORT` | 690,249 | emit+decode, cert in-game |
| `0x47` | `FORNPREP` | 15,249 | emit+decode, cert in-game |
| `0x49` | `ADD` | 19,501 | emit+decode, cert in-game |
| `0x4a` | `FASTCALLX` | 546 | decode-only, PROVEN STRUCTURALLY |
| `0x4b` | `JUMPIF` | 145,131 | emit+decode, cert in-game |
| `0x4c` | `GETVARARGS` | 719 | emit+decode, cert in-game |
| `0x4d` | `LENGTH` | 25,646 | emit+decode, cert in-game |
| `0x4e` | `LOADK` | 239,851 | emit+decode, cert in-game |
| `0x4f` | `DUPTABLE` | 31,996 | emit+decode, cert in-game |
| `0x50` | `NOT` | 7,461 | emit+decode, cert in-game |
| `0x51` | `ORK` | 948 | decode-only, CERT IN-GAME |
| `0x53` | `SETUPVAL` | 59,158 | emit+decode, cert in-game |
| `0x54` | `CALL` | 937,218 | emit+decode, cert in-game |
| `0x55` | `MOD` | 321 | emit+decode, cert in-game |

---

## M6c defects (2026-07-25) — found by SPOT-CHECKING, invisible to the metric

| # | defect | symptom | fix |
|---|---|---|---|
| 17 | `SETLIST` left as a placeholder comment | `{1,2,3}` decompiled to `{}` — **every array element lost** | append values `B..B+C-2` into the table expression |
| 18 | multret `RETURN` (`B==0`) read as zero values | `return math.max(a,b)` decompiled to a bare `return` | return registers `A..top` |
| 19 | multret `CALL` args (`B==0`) read as zero args | `math.floor(math.abs(a))` → `math.floor()` | args `argbase..top` |
| 20 | `top` used as a block-wide high-water mark | dead argument registers resurfaced as extra values: `math.floor(math.abs(v0), v0)` | a call COLLAPSES the stack to its base: after `CALL A B C`, `top = A+nres-1`, or `A` for multret, `A-1` for none |

**All four share one root cause:** Luau encodes *"everything up to the top of the stack"* as `B==0` /
`C==0`. Reading that as ZERO silently deletes arguments and return values — no crash, no error, and
the acceptance metric stays at 0 unhandled the whole time because every instruction *was* dispatched.

**The lesson, restated:** `expr-validate` proves the DISPATCH is complete. It cannot prove the
resulting expression is right. Completeness metrics and correctness metrics are different things, and
100% on the first says nothing about the second.

---

## M6d defects (2026-07-25) — the structuring push, 69.36% -> 100.0000%

| # | defect | symptom | how found | fix |
|---|---|---|---|---|
| 21 | loop KIND read from the header | generic-for loops misclassified | for-gen count vs FORGPREP count | read the kind from the LATCH |
| 22 | for-loops invisible to natural-loop detection | 50 generic for-loops found in a corpus with ~13,750 | comparing counts | detect for-loops by PATTERN (prep -> loop op) |
| 23 | `build_cfg` made no leader after RETURN | 501 dead instructions counted live | hand-tracing stock-Luau output | RETURN makes a leader |
| 24 | sweep skipped blocks registered as a `stop` | 8,908 candidates dropped, never placed | instrumenting the skip path | an ancestor only places ITS OWN follow; do not skip |
| 25 | `mine` omitted loop-path placements | blocks dominated by a loop header invisible to the sweep | same instrumentation | record loop preps/headers/latches |
| 26 | duplication followed BACK EDGES | 1,999,316 copies on a 75-block proto | per-proto shape histogram | never duplicate across a back edge |
| 27 | **PHANTOM EDGE: `FORGPREP` treated as conditional** | **~9,000 protos measured irreducible; ~15,700 loops MISSHAPED** | dumped the smallest generic-for CFG | `FORGPREP` is UNCONDITIONAL (`FORNPREP` is not) |
| 28 | numeric-for prep detector was DEAD CODE | `prep_num` never fired once | reading the two preps' targets | `FORNPREP` targets the EXIT, not the FORNLOOP |
| 29 | duplicate loops from two finders | same loop with two kinds and two bodies | dumping the loop list | de-duplicate per header: specific kind + union body |
| 30 | **recursive descent architecture** | plateaued at 92.32% honest; 6,296 protos needed COPYING | zero-duplication rung exposed the real number | **replaced with STRUCTURAL ANALYSIS** |

**#27 is the one to remember.** A single missing opcode in one boolean invented an edge that made
~9,000 protos look irreducible AND silently deformed ~15,700 loops — while every metric read 100%.
It was found only by dumping the smallest possible failing case and reading it.

**#30 is the architectural lesson.** Heuristic piles have infinite residue by construction. Five
rounds of patches went 69% -> 99.9976% and could not close; switching to bottom-up graph reduction
reached 100.0000% with zero duplication and fewer moving parts.

### The check that makes this trustworthy
`sa::verify_coverage` — walk the final region tree and require every reachable block to appear
**exactly once**. Catches silent loss AND silent duplication, the two modes that hid #27.
Result: 82,042 clean, 0 missing, 0 duplicated, deterministic across runs.

---

## 2026-09-29 — natural loop headed inside its own body (SyndicateScarves NewLokaScarfUpdate)

| # | defect | symptom | how found | fix |
|---|---|---|---|---|
| 31 | NaturalLoop rule took the first cycle edge in region-id order as a back edge | loop headed at a body test; its "body" swallowed the function prologue; output printed the loop body first, the prologue last, no `while` | hand IR order comparison (CONST-ID passed 17/17) | skip a candidate whose body holds the entry when a clean candidate of the same cycle, headed by the original loop header, exists |
| 32 | Proper growth refused every loop-body node (`reaches(c, n)` via the back edge) | non-series-parallel loop body (`a ~= nil and b[k] ~= nil` with statement operand) left unreduced; internal branches dropped | same | for a dominance loop header, acyclicity = no direct edge back to the header |
| 33 | outer while taken for its nested `for` (greedy interior-PREP scan, `is_for_body`) | `while` wrapper lost; parts emitted in set order | same | `proven_non_for_natural_loop` (authoritative While/Repeat header): parts ordered from the header; the PREP overrides only for a prep nested in a composite part of a loop with at most one outside exit |
| 34 | FOR-latch cycle flattened in a Proper dispatcher (certified profile disables whole promotion) | FORNLOOP back edge becomes a fallthrough; the `for` disappears | same | single-exit, terminal-free child closed by a FOR latch stays whole |

Caught by the new `cfg-identity` gate and `cert/natural_loop_nested_for.py` (gates.py 12/13).
Details: `RESEARCH/CFG_IDENTITY_GATE_2026-09-29.md`.
