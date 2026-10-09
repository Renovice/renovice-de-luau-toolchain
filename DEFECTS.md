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

## 2026-09-30 — cfg-identity class fixes (exitless loops, entry-headed loops, import chains, gate S2)

| # | defect | symptom | how found | fix |
|---|---|---|---|---|
| 35 | region reduction stopped at one live node even when that node kept a self edge | a function whose whole body is an exitless loop (`while true do Sleep(0) end`) was emitted as straight-line code that ran once and returned | cfg-identity class `GETIMPORT -> RETURN` (SpawnCleanDrone WaitRepair) | reduce a remaining self edge as SelfLoop (`RENOVICE_NO_TERMINAL_SELF_LOOP`) |
| 36 | entry-in-loop repair (#31) never accepted the ENTRY as the clean head | `while true do if c then ... end Sleep(0) end` at function start headed at the latch: `Sleep(0)` printed before the first test | class `GETIMPORT -> GETIMPORT` at depth 0 | the entry region may be the clean head when it holds the original-CFG header (`RENOVICE_NO_ENTRY_HEADED_LOOP`) |
| 37 | the entry's only graph predecessor is the outer latch, so `latch -> entry` looked private | `Seq[latch, entry]` rotated an outer loop; the exit test ran before `t = 0` and the inner counter read nil (FlickerOnOff) | class `LOAD -> LOAD` at depth 0 | `npred(entry)` counts the call edge (`RENOVICE_NO_ENTRY_CALLER_EDGE`) |
| 38 | base-temporary folds turned `v2 = _T; v1 = v2.Name` into `_T.Name` | Luau compiles that to ONE two-part GETIMPORT: a load-time snapshot, not a live read of a field the script assigns (`_T[NAME] = ...`) | class `GETIMPORT -> GETIMPORT` (`_T` vs `_T."Name"`); luau.exe prints "stale" instead of "fresh" | reads on a global root keep `root["Name"]` (`RENOVICE_NO_IMPORT_CHAIN_GUARD`) |
| 39 | GATE normalization gap: unread pure loads were placed before a fall-through terminator in one block shape and after it in another; repositioned nodes pruned dispatch state with the wrong liveness | identical programs reported `LOAD -> CALL` / `LOAD -> GETIMPORT` | minimal PostFade shape; legacy gate FAILs an identical round trip | S2 in `cfg_identity_cmd.h` (`RENOVICE_CFGID_LEGACY_TAIL`) |

All five are covered by `cert/cfg_class_fixtures.py` (gates.py Gate 14): each opt-out must fail CFG-ID
(and behavior for #35–#38). Details: `RESEARCH/CFG_CLASS_FIXES_2026-09-30.md`.

## 2026-09-30 — multi-exit loop bodies, loop-carried nil, gate S3/S4

| # | defect | symptom | how found | fix |
|---|---|---|---|---|
| 40 | inside a cycle every node "is a loop header", so no acyclic rule reduced a loop body whose continuation test is a short-circuit chain with a statement operand (`H -> {C, L}`, `C -> {L, exit}`); NaturalLoop collapsed it unreduced and the emitter can only fall through between parts | `while IsNull(g) or not g:GameStarted() do Sleep(1) end` rebuilt as `IsNull(g)` (result discarded) then `g:GameStarted()` on nil (RailjackHudTrackers p2); exitless polling loops lost every interior branch | cfg-identity class `IF TRUTHY -> GETIMPORT / NAMECALL`; luau.exe `attempt to index nil with 'GameStarted'` | reduce the loop body as the DAG it is once its back edge and exits are cut (one latch, ≤1 exit target, every loop-leaving edge a conditional arm outside nested loops/Proper, latch kept out of Proper); exits print as `if c then break end` (`RENOVICE_NO_LOOP_BODY_DAG`) |
| 41 | the implicit-nil canonicalizer put `vN = nil` before the first TEXTUAL read; inside a loop a later-printed definition runs before that read on every later iteration | `local owner = nil; while true do if IsNull(owner) then owner = Find() end ... end` reset `owner` every iteration (AddAscarisNegator re-applied its skins every 0.1 s) — invisible to cfg-identity (LOADNIL is epsilon) | luau.exe behavior of the #40 fixture | a first read inside a loop gets its nil before the outermost enclosing loop, the stock `local x = nil` position (`RENOVICE_NO_LOOP_NIL_HOIST`) |
| 42 | GATE normalization gap: a truthiness test whose two successors reach the same node is unobservable, but stock keeps it for an empty `if a and b then end` and the decompiler prints only the operand calls | identical programs reported `IF TRUTHY -> <next op>` (TradingPostScreenLauncher) | minimal fixture; legacy gate FAILs the identical round trip | S3 in `cfg_identity_cmd.h`; comparisons (EQ/LT/LE, metamethods) are not folded (`RENOVICE_CFGID_LEGACY_TRUTHY_NOOP`) |
| 43 | GATE normalization gap: a value read by a loop op (range A..A+2) was slotted by matching A+1/A+2 against B/C, which are not registers (B is a jump offset) | the unobservable order of `for i = 400, 415` bound loads depended on register allocation: `LOAD -> LOAD` (StreamShipQuestLayers p3) | same | S4: slot = offset from A for FOR*PREP/FOR*LOOP (`RENOVICE_CFGID_LEGACY_LOOP_SLOT`) |

Covered by `cert/cfg_class_fixtures.py` (Gate 14, now 50 checks). #41's fixture records that the
legacy output PASSes cfg-identity while its behavior differs. Details:
`RESEARCH/CFG_MULTI_EXIT_LOOPS_2026-09-30.md`.

## 2026-09-30 — numeric-for structuring, selector residue, gate S5, SETLIST/capture fixes

| # | defect | symptom | how found | fix |
|---|---|---|---|---|
| 44 | `proven_non_for_natural_loop` rejected any header block that ends in a FOR prep; a `while` whose first statements are `local x = nil; for ...` has exactly that header | the outer NaturalLoop lost the loop claim to the region owning the prep and was flattened: `while true` deleted, body ran once | saved repro `nested_for_break_in_while`; class `GETIMPORT -> FORNLOOP` | admit a prep-headed While/Repeat when that for's latch is inside the loop body and does not branch to the header (`RENOVICE_NO_PREP_HEADED_WHILE`) |
| 45 | a NaturalLoop emitted without its own wrapper (for iteration / lost claim) printed its parts in set (region-id) order | `for i = 1, 3 do while c do ... end; print(i) end`: `print(i)` ran before the inner loop | saved repro `numeric_for_body_order`; class `GETIMPORT -> GETIMPORT` | header-first topological part order from the region's head, latch last; refused for FORGLOOP-headed regions and non-DAG part graphs (`RENOVICE_NO_FOR_BODY_PART_ORDER`) |
| 46 | the break arm `idx = i; JUMP exit` cannot reach the latch, so it is outside the for's `loop_blocks`, and the unconditional-break check required membership | `if c then idx = i; break end` lost its `break` inside a `while true` (the search kept going) | same repro; luau.exe | a block whose every predecessor is in the loop body and whose jump is the for's canonical exit prints `do break end`, only when no body block branches to two body blocks (an unreduced body is already mis-rendered; adding the break there only cost compiler closure) (`RENOVICE_NO_FOR_BREAK_ARM`) |
| 47 | the prologue-LOADNIL suppression (`first == 0`) ignored that instruction 0 can be a loop header | `while true do local idx = nil ... end` as the whole function: idx kept the previous iteration's value — invisible to cfg-identity (LOADNIL is epsilon) | luau.exe on the #46 fixture | keep `x = nil` when any branch targets instruction 0 (`RENOVICE_NO_LOOP_ENTRY_NIL`) |
| 48 | a Proper dispatcher dissolved every cyclic child it did not keep whole, and the FORNPREP/FORGPREP of a two-exit or return-arm loop is a separate raw state | raw FORNPREP printed as `<` comparisons (`__renovice_fornprep_zero`), FORNLOOP/FORGLOOP back edges fell through: the loop body ran at most once (MatchTagAndSourceType p2: inlined `IsTagAccepted(t) and IsTypeAccepted(o)`) | class `LOAD -> LOAD` (`LOAD N:1 -> LOAD N:0`) | a child holding a for's latch and whole natural body whose prep is a raw state is emitted as the coalesced `for` state with the escape selector (`RENOVICE_NO_PROPER_PREP_FOR`); rejected acyclic-kind children offer their loop descendants, and a one-block FOR SelfLoop is admitted (`RENOVICE_NO_PROPER_NESTED_LOOP_PARTS`) |
| 49 | the single-pass selector-wrapper canonicalizer kept `if sel == -1 then end` (metamethod argument) although `sel` is a generated integer selector | a compiled compare that each re-decompile printed with a fresh constant register while the re-derived shell left a new residue: +1 variable per round, 15 modules stopped converging after #40 (AlchemistVial p7) | compiler-closure count 5,389 -> 5,375; `tools/closure.sh` | drop the guard for `__renovice_state_N ==/~= <integer>` (`RENOVICE_KEEP_SELECTOR_GUARD_RESIDUE`) |
| 50 | GATE normalization gap: the lowered F3 (MOVE + JUMPIF + LOAD) ended the straight-line block, stock's native ORK does not | a pure GETIMPORT before `x or 0` could not sink past it: `GETIMPORT _T -> GETIMPORT _T.X` for identical programs (DialogTree) | minimal fixture built with `RENOVICE_NATIVE=ORK`; legacy gate FAILs the identical round trip | S5 in `cfg_identity_cmd.h`: a folded F3 does not split the S1/S2 block; its MOVE copies are the OR's operand slots 1/2, so a sunk load read through the alternative anchors at the OR (without that, BindingsUtil p14 compared `NEWTABLE -> OR`) (`RENOVICE_CFGID_LEGACY_OR_BLOCK`) |
| 51 | SETLIST with start index 1 was always rendered as a fresh constructor `vA = {values}`, even when the table already held fields set by SETFIELD (`{ k = v, ..., (f()) }`) | the table was REPLACED: every field lost (EE_Interface_Components_List CreateList p86 pc 143, the list object) | coordinator report (settings-render harness); 23 sites / 9 modules on 44.0.2 | when any instruction reads the table between its NEWTABLE/DUPTABLE and the SETLIST (instruction-order scan, fail safe), store `vA[k] = value` into the existing table; a multret tail keeps the rebuild (0 corpus sites) (`RENOVICE_NO_SETLIST_EXISTING_TABLE`) |
| 52 | a by-value capture (`CAPTURE 0 R`) was bound to the flat per-register local `vR` | a register rewritten after the closure (the next loop iteration, register reuse) changed what the closure read: per-element callbacks all saw the last element (EE_Interface_Components_List Redraw p54 pc 308) — invisible to cfg-identity | same report | when a write to R is reachable from the closure creation, snapshot `local __renovice_capture_<proto>_<capture ordinal> = vR` before it and capture that (450 sites / 143 modules); a copy whose value only CAPTUREs read (our own snapshot, re-decompiled) becomes the snapshot itself, so the output re-decompiles to itself (without that 118 modules stopped converging) (`RENOVICE_NO_CAPTURE_SNAPSHOT`) |

Covered by `cert/cfg_class_fixtures.py` (Gate 14, now 91 checks): `for_body_order`, `nested_for_break`
(+ break-arm and entry-nil opt-outs; #47's legacy output PASSes cfg-identity, recorded as a blind
spot), `proper_prep_for` (compiled at -O2), `selector_residue` (closure within 3 rounds; legacy never
closes within 5), `or_block`, `setlist_existing` and `capture_snapshot` (behavior; #52's legacy output PASSes
cfg-identity, #51's exact output still differs from stock SETLIST). Still open: a call inside the break condition (`s == Target()`) splits
the for body into a two-exit DAG that stays unreduced (`RESEARCH/CFG_FOR_LOOP_FIXES_2026-09-30/repro`).
Details: `RESEARCH/CFG_FOR_LOOP_FIXES_2026-09-30.md`.

## 2026-10-09 — 44.1.1 campaign batch 1: orphan prototypes, input profile, overlap lookup, string guard

| # | defect | symptom | how found | fix |
|---|---|---|---|---|
| 53 | the emitter reaches prototypes only through closure sites; the compiler also compiles function literals inside folded-away code (`if false then ... function ... end`), which leaves a prototype with no closure site (an orphan) | the rebuilt module lost every orphan and every later prototype index shifted: 42 of the 72 44.1.1 PROTO_COUNT modules (ReplayLib p10, Zariman p13-19) | agent protos; `luau-compile` fixture; prototype-count census | each orphan is emitted as a dead literal `if false then local _ = function ... end end` at the end of the lowest-index reachable prototype above it (post-order numbering), upvalues bound to fresh dead locals initialized with `{}` (`RENOVICE_NO_ORPHAN_PROTOS`) |
| 54 | U44 entry points accepted any container and reported downstream errors | 13 modules in the 44.1.1 cache are stale U43 bytecode (byte-identical to the U43 corpus); the U44 walk read U43 GETTABLEKS AUX bytes as "unsupported opcode 86/87/90" or failed with "cfg build failed" — there are no opcodes 86/87/90 | agent protos; structural walk splits 44.1.1 stock 5,465 U44-only / 13 U43-only, U43 corpus control 5,386/5,386 U43-only | the input profile is detected structurally and a mismatch fails with an exact reason (`RENOVICE_NO_INPUT_PROFILE_CHECK`) |
| 55 | four path-proof lambdas in `emit.h` read `while_by_header.at(block)` while the renderer had temporarily removed that entry | `Jade_Abilities_Chaos` aborted with `std::out_of_range map::at` (since U43) | agent protos | treat the shared block as the outer loop only while its entry is present; output of every other module unchanged (`RENOVICE_NO_OVERLAP_ACTIVE_LOOKUP`) |
| 56 | the inline renaming of `v<digit>`/`u<digit>` tokens also rewrote text inside string literals and comments | `"v2.20"` became `"c424v2.20"` (Settings p423; visible once orphans are emitted) | agent protos; CONST-ID | the renaming skips strings, long brackets and comments (`RENOVICE_NO_INLINE_STRING_GUARD`) |

Measured on the full 44.1.1 corpus (`work/u441-r1-49e0683e`, binary `49e0683e`, against baseline `701a2adf`):
decompile 5,464 -> 5,465, CFG-ID 4,174 -> 4,187, CONST-ID 5,343 -> 5,382, prototype-count mismatches 72 -> 30,
equal prototypes 71,234 -> 76,762; no module PASS -> FAIL, no prototype loss. Gate 13 U43 class swaps 6,590 -> 7,245
is an unmasking (control in `cert/gates.py`). Held back: the dead-tail emission (stable registers needed for
compiler closure). Not fixed: 29 modules whose stock shares one prototype between several closure sites (O2 inlining).
Details: `RESEARCH/CFG_CAMPAIGN_U441_2026-10-09.md`.

## 2026-10-09 — 44.1.1 campaign batch 2: dataflow-identity gate, access-order and table fixes

New gate (tooling, CFG-ID/CONST-ID verdicts unchanged): `derecomp dataflow-identity STOCK CAND [--u44]`
(`src/dataflow_identity_cmd.h`, `cert/dataflow_identity_fixtures.py` 92 checks, `cert/u44_rawhash_roundtrip.py
--dataflow`). It compares, along CFG-ID's matching, which value origin each matched operation reads, the live values
and what each closure captures. It FAILs the documented CFG-ID blind spots (#41, #47, #52, read-before-write) and on the
baseline 4,174 CFG-ID PASS modules flagged 97 real defects (open fixtures in `cert/fixtures/dataflow_2026_10_09/
open_defects/`: copy fold of a live destination, table-move of a live source, OR/AND lowering with C == A in the
recompiler, for index read after exit, wrong loop-exit register).

| # | defect | symptom | how found | fix |
|---|---|---|---|---|
| 57 | GATE normalization gap: pass-3 dead-load liveness in `cfg_identity_cmd.h` was path-insensitive; a constant load under a dispatcher looked live through a path the state values rule out | identical programs reported `GETIMPORT -> LOAD` (CorpusAvatarRandomizer p4) | agent accessorder | S6: liveness over (instruction x dispatch environment), state tests decided like the bisimulation, fail closed when unbounded; two live-on-a-real-path mutations still FAIL (`RENOVICE_CFGID_LEGACY_DISPATCH_LIVENESS`) |
| 58 | the composite-tail rule was vetoed by a later-pc RETURN block inside the head, so the condition came from the head's entry block | `if not a then ...; continue end` printed as `if a then` inside `while not IsNull(x)` (IdleBarkMonitor) | agent accessorder; luau.exe | skip such RETURN blocks in the last-instruction check (`RENOVICE_NO_COMPOSITE_TAIL_RETURN_SKIP`) |
| 59 | `local __renovice_unused_condition_N = __renovice_state_K == <int>` residue kept; a generated integer state compare cannot call anything (#49's argument) | an extra compare + LOADB pair stock never had (TransferenceHeal p3) | agent accessorder | drop it (`RENOVICE_KEEP_UNUSED_SELECTOR_CONDITION`); Gate 14's #49 legacy control now sets both knobs |
| 60 | `fold_pure_setup_move` folded `vA = vB` into a call although `vB` was rewritten before the call | `f(..., vB, frame, vB, ...)`: scaleAmount passed twice, the table lost (ShowImpactMessageLocal) | agent accessorder; luau.exe | refuse the fold when the source is redefined before the use (`RENOVICE_NO_CALLCOALESCE_SOURCE_GUARD`) |
| 61 | the #40 loop-body DAG rule rejected a `for` body because its FORNLOOP latch has two successors | `for ... do if a and b() then break end ... end` lost `a`'s test (SpaceTurretMissileAbility) | agent accessorder; luau.exe | admit the FORNLOOP latch whose only leaving edge is the loop exit (`RENOVICE_NO_FOR_LOOP_BODY_DAG`); to be superseded by batch 3's general for/nested version; costs MissileVolley's compiler closure (closes at 2 with the opt-out) |
| 62 | #51's existing-table SETLIST path read item registers whose setup MOVEs `fold_pure_setup_move` had deleted | list elements printed as `vR = nil; vA[k] = vR` (DarkKuvaEximusShootPatternsLib, 18 sites) — invisible to CFG-ID | agent tables; luau.exe (`0 0.75 true nil nil` -> `4 0.75 true x y`) | store the folded item expressions (`RENOVICE_NO_SETLIST_EXISTING_FOLDED_ITEMS`) |

Full 44.1.1 corpus (`work/u441-r2b-b5200665`, binary `b5200665`, vs batch 1 `49e0683e`): CFG-ID 4,187 -> 4,289, CONST-ID
5,382 -> 5,383, equal prototypes 76,762 -> 77,006, no module PASS -> FAIL, no prototype loss; CFG-ID + dataflow PASS
4,187 (baseline 4,077); no baseline CFG-PASS module newly fails dataflow; compiler closure 5,425 -> 5,424
(MissileVolley, #61). `cert/gates.py 300 150`: ALL GATES PASS (ALIGNED 225, NAME-DIFF 0, realtrip 150/150, Gate 14
91/91). Rejected from the batch: the split-exit condition guard (tables agent) — it broke Gate 14's #49 closure
checks and AlchemistVial's closure; kept as `work/agents/tables-runs/split_exit_loop_guard.patch` for rework.

## 2026-10-09 — 44.1.1 campaign batch 3: condition fixes (agent conditions)

| # | defect | symptom | how found | fix |
|---|---|---|---|---|
| 63 | `emit_block` ignored a compare whose true and false successors are the same block | `if a < b then end` vanished; observable because `__lt`/`__le`/`__eq` metamethods no longer ran (202 modules / 267 sites corpus-wide carry the shape) | agent conditions; luau.exe fixture `empty_compare_if.luau` | print the one-line `if X then end` with the polarity reproducing the stock opcode; skipped in Proper dispatcher states, which already print the test (`RENOVICE_NO_EMPTY_COMPARE_IF`) |
| 64 | the While / IfThen(Else) emitters took the test from the head region's FIRST block when the head is several blocks | BirdOfPrey p1: the loop exit tested an earlier IsNull register, the rebuilt loop never ends; GearLib p0: `if _T.prevGearSlots ~= nil then` printed for `IsMaster()` | agent conditions; luau.exe `loop_exit_compare.luau` | take the test from the head block that branches into the body/arm (`RENOVICE_NO_WHILE_TAIL_TEST`, `RENOVICE_NO_IFTHEN_TAIL_DECISION`) |
| 65 | an `if` whose arm contains a loop took ownership of that loop (`COND_LOOP_OWNER`), printing the arm's `for` instead of its own test, then the loop again | the `if` test lost and the loop duplicated (`cmp 2 nil x` in luau.exe) | agent conditions | one general rule replaces three narrow rejections: an `if` may own a loop only when its own decision block is that loop's prep or latch (`RENOVICE_ALLOW_CONDITIONAL_PREP_STEAL`); costs Illusion's compiler closure |
| 66 | `reduce_loop_body_dag` never ran for a loop found inside an outer cut body, and never admitted a FORNLOOP/FORGLOOP latch (two successors) | `if not IsNull(x) then for ... end end` at the end of a for body: the guard dropped ("attempt to get length of a nil value", CombatSoak p2) | agent conditions; luau.exe `for_guarded_inner_loop_in_while.luau` | nested cut bodies stack their header set; a for latch whose only leaving edge is its own exit to the single out is the DAG sink (`RENOVICE_NO_NESTED_LOOP_BODY_DAG`, `RENOVICE_NO_FOR_LOOP_BODY_DAG`); supersedes #61's FORNLOOP-only rule (and restores MissileVolley's closure) |
| 67 | (diagnosed, opt-in only) inside a cut body the entry stayed the function entry, so a nested loop could be headed at its latch | — | agent conditions | `entry = n` for the cut body, now OPT-IN (`RENOVICE_CUT_BODY_ENTRY=1`): on the full corpus it turned Platform PASS -> FAIL, cost KahlOrders p35 and 6 compiler closures (BardMusic, SearchTheDead, EnergyLeech, HealthLeechPatches, AbilityAuraLib, TeshinShadowRemnants) |

Full 44.1.1 corpus (`work/u441-r3b-928298db`, binary `928298db`, vs batch 2 `b5200665`): CFG-ID 4,289 -> 4,465,
CONST-ID 5,383 -> 5,389, CFG-ID + dataflow 4,187 -> 4,351, equal prototypes 77,006 -> 77,326; no module PASS -> FAIL on
CFG-ID, CONST-ID or dataflow, no prototype loss; compiler closure 5,424 -> 5,446 (+23, -1 Illusion #65). `cert/gates.py
300 150`: ALL GATES PASS (ALIGNED 226). Fixtures of this batch: `work/agents/conditions-runs/fixtures/` (to be moved
into the cert gate). Rejected: forcing the semantic-plan terminal-arm check on (NullStar, JuggernautSpawnScript
PASS -> FAIL).

## 2026-10-09 — 44.1.1 campaign batch 4: load-order fixes (agent loadorder)

| # | defect | symptom | how found | fix |
|---|---|---|---|---|
| 68 | (opt-in only) NaturalLoop selection tries the outer header first when the outer body begins with an inner loop's setup; the outer cycle swallows the inner loop and its break arm | a search loop's `found = true; break` ran unconditionally (PickUpArrows p1) | agent loadorder; luau.exe | innermost loops first with true (dominating) back edges, established scan as fallback; OPT-IN `RENOVICE_INNERMOST_LOOP_FIRST=1`: enabled on the full corpus it gained ~95 CFG-ID modules but turned Platform and AmbulasOrbitalLaser PASS -> FAIL, cost KahlOrders p35 and 11 compiler closures (rework in progress, agent loops) |
| 69 | a plain While region had no proven-loop protection, so the scan claimed a nested `for` for it; and a `for` running before the `while` that exits into its header was read as a back edge | VayHekLandslide p0 lost `while t > 0` and its back edge: the body ran once | agent loadorder; luau.exe fixtures | proven-loop protection for While regions; a preceding for's exit edge is not a back edge (`RENOVICE_NO_PROVEN_WHILE_REGION`, `RENOVICE_NO_PRECEDING_FOR_ENTRY`) |
| 70 | the return-guard rotation flipped the first `==`/`~=` anywhere in a compound condition | `not IsNull(p) and a == p` became `not IsNull(p) and a ~= p` (OnSummonHitCondition p0; luau.exe `false true false false` vs `true true false true`) | agent loadorder | flip only a single top-level relation, otherwise wrap in `not (...)` (`RENOVICE_NO_TOPLEVEL_RELATION_INVERSE`) |
| 71 | GATE normalization gap: stock's `local x = a < b` (LOADB with skip) was excluded as a constant definition while the decompiled if/else spelling was not, so only one side decided `x == true` statically | identical programs reported different (InkBlobAbility p0) | agent loadorder; mutation controls (`<` -> `<=`, changed constant) still FAIL | treat both spellings alike in the dispatch-web constant test (`RENOVICE_CFGID_LEGACY_BOOL_SKIP_DEF`); costs ThemedMainMenu p187 (already failing module; the asymmetry flips there) |

The composite-tail terminal-block patch of the same agent is not applied: #58 already fixes its case (EntityScaling
passes). The dataflow open defect `loop_exit_test_register` was fixed by #64 (batch 3); `cert/dataflow_identity_fixtures.py`
now asserts the fixed state with `RENOVICE_NO_WHILE_TAIL_TEST` as the legacy control (94 checks).

Full 44.1.1 corpus (`work/u441-r4b-fd0d4c81`, binary `fd0d4c81`, vs batch 3 `928298db`): CFG-ID 4,465 -> 4,481, CFG-ID +
dataflow 4,351 -> 4,367, no module PASS -> FAIL on CFG-ID, CONST-ID or dataflow, compiler closure unchanged (5,446);
prototype loss only ThemedMainMenu p187 (#71, gate side); closed-bytecode CONST-ID PASS -> FAIL on VolatileAtmosphere
and CoHNarmerPhobiaAura (first pass unchanged). `cert/gates.py 300 150`: ALL GATES PASS; Gate 14 91/91; dataflow
fixtures 94/94.

## 2026-10-09 — 44.1.1 campaign batch 5: liveness-guarded coalescing, OR/AND C == A lowering, SETLIST batch merge (agent coalesce, its #63-#66)

| # | defect | symptom | how found | fix |
|---|---|---|---|---|
| 72 | `fold_pure_setup_move` deleted `vR = vS` and substituted `vS` into the use after checking only the rest of the block; `vR` could be read in later blocks | `local t = p; if t:IsA() then t = t:GetOwner() end` read nil ("attempt to index nil with 'GetOwner'"); CFG-ID blind, dataflow FAIL (55 of the 102 dataflow failures) | dataflow-identity; agent coalesce | fold only when R is dead after the use on every path (new prototype-wide liveness `register_live_after`, unknown effects = live) and not rewritten in between (`RENOVICE_NO_COALESCE_LIVE_DEST_GUARD`) |
| 73 | the table-move retarget (`NEWTABLE R; MOVE A,R`) and the multi-result call retarget (`local b, c = G(); a, d = b, c`) moved a value whose source register was still read later | stale values passed on ("attempt to index number with number"; b, c nil) (18 + 15 of the 102) | dataflow-identity; agent coalesce | retarget only when the source is dead after the MOVE (`RENOVICE_NO_TABLEMOVE_LIVE_SOURCE_GUARD`, `RENOVICE_NO_CALLMOVE_LIVE_SOURCE_GUARD`) |
| 74 | RECOMPILER: `transcode.h` lowered `OR/AND A B C` as `MOVE A<-B; JUMPIF A; MOVE A<-C`, reading the overwritten A when C == A (B != A) | `value = f(value) or value` became `f(value) or f(value)`; 44 stock sites in 26 modules (OR 40/22, AND 4/4) | dataflow-identity; agent coalesce (all aliasing cases tested; only C == A was wrong) | `MOVE scr<-A; MOVE A<-B; JUMPIF/NOT A; MOVE A<-scr` with the scratch at the frame top; every other site byte-identical (`RENOVICE_LEGACY_ORAND_LOWERING`) |
| 75 | constructors with more than 16 items: later SETLIST batches printed as `t[17] = v` (SETTABLEN); a multi-value call tail of a later batch was cut to one value | CFG-ID `SETLIST -> SETTABLEN` / `LOAD -> SETTABLEN`; 37 -> 36 items | agents tables/accessorder/loadorder/coalesce | merge later batches into the one constructor when every item inlines exactly (used once, dead after the SETLIST, side-effect order kept, no closure; no code-running item when the table is captured by reference) (`RENOVICE_NO_SETLIST_BATCH_MERGE`, trace `RENOVICE_SETLIST_TRACE`) |

Fixtures moved out of `open_defects/` and asserted fixed with their legacy controls: copy_fold_live_dest,
table_move_live_source, or_lowering_c_equals_a, orand_alias_cases, call_move_live_multi, setlist_batch_merge, and
loop_exit_test_register (#64). Still open: for_index_after_exit_o2. `cert/dataflow_identity_fixtures.py` 134/134.

Full 44.1.1 corpus (`work/u441-r5-5713df5f`, binary `5713df5f`, vs batch 4 `fd0d4c81`): CFG-ID 4,481 -> 4,515, CFG-ID +
dataflow 4,367 -> 4,501, dataflow FAIL among CFG-ID PASS 114 -> 14, no module PASS -> FAIL on any gate, no prototype or
closure loss. `cert/gates.py 300 150`: ALL GATES PASS. Remaining: 24 SETTABLEN modules (a field store between batches
blocks the merge), 2 truncated multi-value tails (DiegeticUpgradeCards p409, UIUtilities p158).
