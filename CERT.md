# The cert suite — proving the recompiler in-game

> **Scope:** this file covers the IN-GAME opcode cert, i.e. the **RECOMPILER** direction. It is
> separate from the OFFLINE **decompiler** gates, which need no game at all:
> **`python cert/gates.py 300 150`** runs all four release gates concurrently (~2 min) and prints one
> verdict. Read `.claude/M6_TRUTH.md` for current state and `.claude/PITFALLS.md` before trusting any
> measurement. Set `RENOVICE_CORPUS` when working from a copied workspace, or the oracles see nothing
> and exit 2.
>
> The two suites answer different questions. This one: *"does DE's VM execute our opcodes the way we
> think?"* — `gates.py`: *"does our decompiled source mean what the original bytecode meant?"*

`cert/v9/` is 10 **independent** Luau modules that together exercise **59/59 (100%)** of the DE opcodes the
transcoder can emit. Each module self-checks and signals its verdict through `error()`.

## Why independent modules

One file per module means **one F9 produces 10 separate verdicts**. A failure in one doesn't hide the other
nine. Earlier monolithic certs (`cert_v3`..`cert_v8`) aborted at the first bad opcode and hid everything
downstream — which is exactly how the `JUMPIFLT`/`JUMPIFLE` swap survived six cert generations.

## Modules

| module | covers |
|---|---|
| `c_data`   | `LOADN` `LOADK` `LOADNIL` `LOADB` `MOVE` `CONCAT` `LENGTH` `NOT` |
| `c_arith`  | `ADD` `SUB` `MUL` `DIV` `MOD` `MINUS` + K-forms `ADDK` `MULK` `DIVK` `MODK` `SUBK` `SUBRK` |
| `c_cmp`    | all 6 fused compares, `JUMPIF`/`JUMPIFNOT`, and const-compares (`== 3`, `~= 4`, `== "hi"`, `== nil`, `== true`) |
| `c_table`  | `NEWTABLE` `SETLIST` `DUPTABLE`, reg-key `GETTABLE`/`SETTABLE`, int-key `GETTABLEN`/`SETTABLEN`, field `GETTABLEKS`/`SETTABLEKS`, nested tables |
| `c_loop`   | numeric-for (incl. negative step), `ipairs` (`FORGPREP_INEXT`), `pairs` (`FORGPREP_NEXT`), `FORGLOOP`, `while`, `repeat…until` |
| `c_func`   | `NEWCLOSURE`+`CAPTURE` (mutable upvalue), `DUPCLOSURE`, `GETUPVAL`/`SETUPVAL`, `CLOSEUPVALS`, `NAMECALL` (method def **and** call), varargs, globals, builtins |
| `c_extra`  | `LOADNIL` via multi-assign, `and`/`or` (incl. nil operands), `DIVRK`, `JUMPIFLT` via value-producing compare and `repeat…until` |
| `c_ord`    | **boundary** tests for the jump-if-TRUE compares: `a<=a` must be true, `a<a` must be false |
| `c_va`     | `PREPVARARGS` + `GETVARARGS`: `local a = ...`, `local a,b = ...`, `select("#", ...)` |
| `c_pow`    | reg-reg `POW` (`0x45`), `POWK` (`0x08`), `IDIVK` (`0x24`) |

## Running it

```bash
for f in c_data c_arith c_cmp c_table c_loop c_func c_extra c_ord c_va c_pow; do
  ./bin/derecomp.exe recompile cert/v9/$f.luau cert/v9/$f.spawn.lua_B \
    && cp cert/v9/$f.spawn.lua_B "$INJ/v9_$f.spawn.lua_B"
done
```
Press **F9** in-game, then read the newest tags from `%LOCALAPPDATA%\Warframe\EE.log`.
**Pass = all 10 `V9_*_OK`.** Any other tag names the exact failing construct.

Filter by newest timestamp — stale cached modules from earlier generations keep re-firing and will
otherwise pollute the results.

## Measuring coverage

Coverage is computed by disassembling **our own cert output** and diffing the opcode set against the
emit-set parsed out of `transcode.h` — not asserted by hand:

Run from the `DeNativeRecompiler/` directory (verified working):

```bash
python3 - <<'EOF'
import re,subprocess
from pathlib import Path
EXE=r"bin\derecomp.exe"          # backslash form: needed for CreateProcess on Windows
src=Path("src/transcode.h").read_text()
emit={int(m[1],16) for m in re.findall(r'\{"(\w+)",\s*(0x[0-9a-fA-F]+)\}',src)}
seen=set()
for f in ["c_data","c_arith","c_cmp","c_table","c_loop","c_func","c_extra","c_ord","c_va","c_pow"]:
    p=Path(f"cert/v9/{f}.spawn.lua_B")
    if not p.exists():
        print("  missing (recompile it first):",p); continue
    out=subprocess.run([EXE,"de-disasm",str(p)],capture_output=True,text=True).stdout
    seen|={int(x,16) for x in re.findall(r"op=0x([0-9a-f]{2})",out)}
print(f"{len(seen&emit)}/{len(emit)} covered; missing:", [hex(o) for o in sorted(emit-seen)])
EOF
```

## Writing a good cert check

* Pass values in as **parameters**, not literals, or the Luau optimiser folds the operation away and you
  test nothing.
* `if <expr> then else error("TAG") end` emits the jump-if-**NOT** compare forms. To reach the
  jump-if-**TRUE** forms you need a value-producing compare (`local x = a < b`) or `repeat…until`.
* Test comparisons at **boundaries** — `3 < 5` cannot distinguish `<` from `<=`.
* Give every module a unique sentinel tag; two modules sharing a tag makes the run unreadable.

See `METHODOLOGY.md` for probe design when you're identifying an *unknown* opcode rather than certifying a
known one.

---

## v10 — Generated Behavioural Matrix (2026-07-25) — **6/6, 133/133 PASS**

`cert/gen_v10.py` GENERATES the suite instead of hand-writing it. Axes enumerated:

| axis | values |
|---|---|
| form | branching (`if c then`) **and value-producing (`local v = c`)** |
| polarity | `==` `~=` `<` `<=` `>` `>=` and their negations |
| operands | reg/reg, reg/const, const/reg |
| values | boundaries (`a<=a`, `a<a`), `nil`, `false`, `0`, `""`, negatives |
| storage | local, captured upvalue (pre- and post-`SETUPVAL`) |

| module | assertions | covers |
|---|---:|---|
| `c_cmpx`   | 34 | all 6 compares x both forms x both polarities x boundaries |
| `c_nilx`   | 20 | nil/false discrimination, post-SETUPVAL tags |
| `c_arithx` | 25 | all arith, K-forms, negatives, precedence |
| `c_ctrlx`  | 13 | while / repeat / numeric-for / generic-for / break / nested |
| `c_funcx`  | 17 | closures, upvalues, varargs, multiple returns, recursion |
| `c_tabx`   | 24 | field r/w, reg-key r/w, array part, length, `pairs`/`ipairs` |

**Found on its first run:** `JUMPIFEQ = 0x37` (was `0x20`) — value-producing `(a == c)` returned
`false` for equal values. See FINDINGS.md 2026-07-25.

Deployed alongside the 11 v9 modules = **17 independent verdicts per F9**. No cascade: each module is
its own `.spawn.lua_B` and terminates in `error("<TAG>_OK")`, so one failure cannot mask another.

### Why generated beats hand-written
Hand-written certs test what you already believe works. v9 was 11/11 green with 59/59 opcode coverage,
5382/5382 byte-exact round-trip and 82042/82042 lossless recode — and still shipped a broken `==`.
`(a == c) == true` is not a line anyone writes by hand; it exists only because the generator enumerates
*value-producing* x *boundary* systematically.

### Cert validity
A cert is valid **only for the binary it ran against**. Re-run after any Warframe update before trusting
the opcode map.

---

## v11 — Thin-Evidence Ops + Boolean Constants (2026-07-25) — **2/2 PASS**

Targets the ops whose CORPUS evidence was too sparse to trust, plus the boolean constant whose
absence from the transcoder was discovered while writing this cert.

Modules report **values**, not pass/fail, so a wrong answer NAMES the opcode we actually have:

```
V11_THIN idivk=3 powk=1024 subrk=6 divrk=2.5 pow=1024      <- all correct
V11_BOOL on=true off=false n=3                              <- all correct
```

| op | corpus n | expected | a rival opcode would give |
|---|---:|---:|---|
| `IDIVK 0x24` | **5** | 3 | MODK 1 · DIVK 3.5 · MULK 14 · SUBK 5 |
| `POWK 0x08` | 132 | 1024 | MULK 20 · ADDK 12 · MODK 2 |
| `SUBRK 0x06` | 2,489 | 6 | reversed operands −6 |
| `DIVRK 0x3b` | 590 | 2.5 | reversed operands 0.4 |
| `POW 0x45` | — | 1024 | |

**Verify the path is exercised before deploying.** `derecomp histops <module>.spawn.lua_B` must show
each target opcode actually present. The JUMPIFEQ calibration earlier the same day returned all-green
while testing a path that never executed — a cert that doesn't reach the code proves nothing.

**Not certifiable in-game:** `ANDK 0x31`. We lower AND/ANDK, so no compilable source emits it.

### v11 addendum — `c_andk`, and the native-emission technique

`V11_ANDK t_and_t=true t_and_f=false f_and_t=false n_and_t=nil num_and_t=true` — **PASS**.

**Technique worth reusing:** an opcode we only ever DECODE cannot be certified, because nothing we
compile emits it. Add an env-gated native emission (`RENOVICE_NATIVE_ANDK=1`) so a cert can reach it,
keep the proven lowering as the default, and verify with `histops` that the opcode is actually present
in the emitted module. This applies to all 18 decode-only opcodes (261,028 corpus instructions).

---

## v12 — Decode-Only Opcodes via Native Emission (2026-07-25) — **4/4 PASS**

Certifies opcodes the decompiler must READ but the transcoder never emits, by making them
temporarily emittable with `RENOVICE_NATIVE=<comma list>`.

| module | opcodes | result |
|---|---|---|
| `c_andor` | `AND 0x2f`, `OR 0x2b` | `t_and=5 f_and=false n_and=nil t_or=true f_or=6 n_or=6` |
| `c_subk`  | `SUBK 0x3e` | `subk=7 subk2=-15` |
| `c_cmpk`  | `JUMPXEQKN 0x20`, `JUMPXEQKS 0x41`, `JUMPXEQKB 0x34` | all 7 comparisons correct |
| `c_jback` | `JUMPBACK 0x25` | `sum=15 guard=3` |

**Two mandatory gates before deploying a native-emission cert:**
1. `derecomp histops <module>.spawn.lua_B` shows each target byte PRESENT.
2. The same source built with the knob OFF shows ZERO of those bytes.

Without both, the cert may be testing the lowering it was written to bypass.

**Keep risky probes in their own batch.** `FORGPREP? 0x0b` was deliberately excluded: a wrong guess in
a loop-prep position can crash the load, which would destroy the other modules' results too.

---

## FULL-SUITE REGRESSION (2026-07-25) — **27/27 modules, 0 failures**

`cert/rebuild_all.sh` rebuilds EVERY module from source with the current binary and current opcode
map, applies the right native-emission knobs and bytecode patches, and deploys all of them. One F9
runs the lot.

**Why this is a real regression test, not a formality:** v9 and v10 were originally built and
certified BEFORE three map changes landed — `FORGPREP` default `0x30`->`0x0b`, `IDIV 0x00` added to
the emit map, and `ORK`'s C declared a const index. Rebuilding them proves those changes broke
nothing.

| suite | modules | result |
|---|---:|---|
| v9  hand-written coverage | 11 | all `_OK` |
| v10 generated matrix (133 assertions) | 6 | all `_OK` |
| v11 thin ops + booleans | 3 | `idivk=3 powk=1024 subrk=6 divrk=2.5 pow=1024` · `on=true off=false n=3` · ANDK all 5 |
| v12 native decode-only ops | 4 | AND/OR, SUBK, all 3 const-compares, JUMPBACK |
| v13 generic FORGPREP | 1 | `sum=60 count=3 calls=4` |
| v14 patched IDIV | 1 | `r=3` |
| v15 patched ORK | 1 | `t=7 f=5 n=5` |

**71 distinct opcodes exercised**, verified by disassembling the DEPLOYED bytecode rather than
assuming — every certified opcode is provably reached.

### Opcode status: complete
- **59 emittable opcodes** — certified in-game.
- **18 decode-only opcodes** — 13 certified in-game via the native-emission knob or bytecode patching;
  5 (the FASTCALL family) proven structurally over all 165,605 corpus instances.

Nothing the decompiler depends on rests on inference.

### Why FASTCALL was NOT certified in-game (deliberate)
A fastcall that does not recognise its builtin silently falls through to the slow path and returns the
correct answer, so a PASS would prove nothing; only a FAILURE would be informative. DE's builtin-ID
numbering is also unverified, which would make a pass doubly uninformative. `derecomp de-fastcall`
instead proves the property M6 actually needs — every skip offset lands exactly on a `CALL`, so the
skipped span is pure call setup — across every instance rather than one sample.

---

## v16 — FASTCALL emission (2026-07-25) — **PASS**, and now the DEFAULT

`V16_FASTCALL floor=3 ceil=4 max=9 min=2 abs=5 sqrt=4 maxk=10 type=number`

We used to DROP fastcalls, which produced correct but SLOWER code — every recompiled script ran
`math.*`, `table.insert` and `tostring` through the slow path. Emission is now default;
`RENOVICE_NO_FASTCALL=1` opts out.

**Why this test is discriminating** (it initially looks like it should not be): a fastcall whose
builtin id is unrecognised falls through to the slow path and returns the RIGHT answer, so a wrong
OPCODE is invisible. A wrong BUILTIN ID is not — it calls a real but different builtin and returns a
plausible wrong NUMBER. Hence `math.max` (id 18) and `math.min` (id 19) are used as an ADJACENT pair:
an off-by-one in the numbering would report `max=2 min=9`.

**Prerequisite established offline:** `derecomp de-builtins` recovered DE's builtin table from the
corpus (165,557/165,605 resolved). Every id matches upstream `LuauBuiltinFunction`; DE additionally
EXTENDED it (id 133 = `IsNull`, 79% of all fastcalls in the game).

**Full-suite regression: 28/28** with 12 modules newly containing fastcalls.
