# DE `09 03` Opcode Map — authoritative reference

**Status:** EMIT map complete + in-game certified (10/10 cert modules). DECODE map complete for all
**77** opcodes that occur in the 5386-file game corpus. Generated from `src/transcode.h` + corpus census
(`derecomp histops`), not from memory — every row is re-derivable with the commands in `METHODOLOGY.md`.

Corpus basis: **5386 files · 82059 protos · 5,529,447 instructions**.

### Counting — three different quantities, don't mix them up

| # | counts | note |
|---|---|---|
| **69** | Luau opcode **names** with a mapping | includes **7 dropped** (`-1`): `FASTCALL`, `FASTCALL1/2/2K/3`, `COVERAGE`, `NOP` |
| **62** | …of those, names mapping to a real DE byte | |
| **59** | distinct **DE bytes** we emit | `62 − 3` shared: `CALL`/`CALLFB`→`0x54`, `JUMP`/`JUMPBACK`→`0x40`, `FORGPREP`/`FORGPREP_NEXT`→`0x30` |
| **+14** | Luau ops handled by **lowering** (no byte of their own) | `AND` `OR` `ANDK` `ORK` `SUBK` `LOADKX` `JUMPXEQKN/KS/KB` `GETGLOBAL` `SETGLOBAL` `GETTABLEKS` `SETTABLEKS` `NAMECALL` |
| **77** | distinct DE bytes present in the **corpus** | the **decode** target — includes ops we never emit (§2) |

Cert coverage is quoted as **59/59** because it is measured in *DE bytes*, not Luau names.

---

## 0. How to read this

DE bytecode word (little-endian u32): `op = byte0`, `A = byte1`, `B = byte2`, `C = byte3`,
`Bx = B | C<<8` (u16). Some ops are **8 bytes**: the op word followed by a raw `aux` u32.

**Branch offsets**: `Bx` is a *signed* 16-bit **word** offset and the base is **op+4** — i.e.
`target_byte = own_offset + 4 + (int16)Bx * 4`. The aux word is **excluded** from the base even for
8-byte branch ops. (Proven: over 24568 real corpus fused compares, op+4 lands on a valid instruction
boundary 24568/24568; op+8 produces 7841 impossible mid-instruction targets.)

**8-byte (WIDTH8) set**:
`0x02 0x03 0x0c 0x0f 0x15 0x17 0x1c 0x1e 0x20 0x21 0x23 0x26 0x27 0x2c 0x2d 0x33 0x34 0x36 0x37 0x3a 0x3d 0x3f 0x41 0x43 0x46 0x4a`
Everything else is 4 bytes. Exception: `NEWCLOSURE 0x16` is 4 bytes **plus one `CAPTURE 0x35` (4B)
per upvalue**, emitted as separate instructions immediately after it.
Walking the corpus with this table lands exactly on every proto's code end: **82059/82059 clean walks**.

**Constant tags**: `0`=nil · `1`=FNV name hash (u32) · `2`=number (f64) · `3`=string (1-based pool index)
· `4`=import descriptor · `5`/`8`=table template · `6`=closure · `7`=vector3 · `9`=int64.

**Name-key rule (crash-critical).** A *write*/field key must be a **tag-3 STRING**; only `NAMECALL`
resolves its method name by **tag-1 FNV hash**. Getting this backwards produces an access violation
(0xc0000005) at runtime, not a clean error. See `METHODOLOGY.md` §4.

---

## 1. EMIT map — Luau op → DE byte

What `derecomp` produces. 59 distinct DE bytes; all exercised by the cert suite and verified in-game.

### Loads / moves
| Luau | DE | W | Semantics | corpus freq |
|---|---|---|---|---|
| `LOADN` | `0x12` | 4B | `R[A] = Bx` (immediate int) | 339,331 |
| `LOADK` | `0x4e` | 4B | `R[A] = K[Bx]` | 239,851 |
| `LOADKX` | →`0x4e` | 4B | lowered: const index taken from `aux` | — |
| `LOADNIL` | `0x0d` | 4B | `R[A] = nil` | 52,851 |
| `LOADB` | `0x04` | 4B | `R[A] = bool(B)`; `C` skips next insn | 153,625 |
| `MOVE` | `0x14` | 4B | `R[A] = R[B]` | 364,632 |
| `GETVARARGS` | `0x4c` | 4B | `R[A..] = ...` | 719 |
| `PREPVARARGS` | `0x11` | 4B | **vararg prologue — MUST be emitted**, `A` = #fixed params | 5,668 |

### Arithmetic — all `R[A] = R[B] op R[C]` unless noted
| Luau | DE | Semantics | corpus freq |
|---|---|---|---|
| `ADD` | `0x49` | `R[B] + R[C]` | 19,501 |
| `SUB` | `0x07` | `R[B] - R[C]` | 13,076 |
| `MUL` | `0x22` | `R[B] * R[C]` | 12,915 |
| `DIV` | `0x1a` | `R[B] / R[C]` | 4,565 |
| `MOD` | `0x55` | `R[B] % R[C]` | 321 |
| `POW` | `0x45` | `R[B] ^ R[C]` | 92 |
| `MINUS` | `0x0e` | `-R[B]` (unary) | 1,618 |
| `ADDK` | `0x38` | `R[B] + K[C]` | 12,773 |
| `MULK` | `0x09` | `R[B] * K[C]` | 11,292 |
| `DIVK` | `0x32` | `R[B] / K[C]` | 6,944 |
| `MODK` | `0x3c` | `R[B] % K[C]` | 469 |
| `POWK` | `0x08` | `R[B] ^ K[C]` | 132 |
| `IDIVK` | `0x24` | `R[B] // K[C]` (floor div) | 5 |
| `SUBRK` | `0x06` | `K[B] - R[C]` (**const in B**) | 2,489 |
| `DIVRK` | `0x3b` | `K[B] / R[C]` | 590 |
| `SUBK` | *lowered* | `LOADK scratch,K[C]` + `SUB 0x07` (DE has no SUBK) | — |

### Comparison & control flow
Fused compares are 8B: `A` = lhs register, `aux` = rhs **register**, `Bx` = branch offset.
When `aux` has **bit31 set**, the rhs is the **constant** `K[aux & 0x7fffffff]` instead.

| Luau | DE | Meaning |
|---|---|---|
| `JUMPIFEQ` | `0x37` | jump if `R[A] == rhs` |
| `JUMPIFNOTEQ` | `0x27` | jump if `R[A] ~= rhs` |
| `JUMPIFLT` | `0x21` | jump if `R[A] < rhs` |
| `JUMPIFNOTLT` | `0x1c` | jump if `R[A] >= rhs` |
| `JUMPIFLE` | `0x23` | jump if `R[A] <= rhs` |
| `JUMPIFNOTLE` | `0x33` | jump if `R[A] > rhs` |
| `JUMP`, `JUMPBACK` | `0x40` | unconditional (`Bx` signed) |
| `JUMPIF` | `0x4b` | jump if `R[A]` truthy |
| `JUMPIFNOT` | `0x18` | jump if `R[A]` falsy |
| `JUMPXEQKN/KS/KB/KNIL` | *lowered* | `LOAD<const> scratch` + reg-reg `0x27`/`0x37` |

> **`JUMPIFEQ` was documented here as `0x20` until 2026-07-28 (FINDINGS #98) — that was STALE.**
> `transcode.h:107` emits `{"JUMPIFEQ", 0x37}`, and `CERT.md:111` recorded the correction
> (*"JUMPIFEQ = 0x37 (was 0x20)"*) without this table ever being updated. `0x20` is **`JUMPXEQKN`**
> (compare against a NUMBER constant) — see §2, 19,213 corpus occurrences. The two sections
> contradicted each other for months. Two comments in `transcode.h` are still stale in the same way
> and are kept only as history: `:100` (*"NOTEQ=0x20 (cert)"*, and *"JUMPIFEQ (0x3a)"*) and `:464`
> (*"0x27 NOTEQ / 0x20 EQ"* — the code beside it emits `0x37`).

> **`0x21` and `0x23` were swapped for most of this project's life.** They are only distinguishable at a
> **boundary** (`a <= a` must be true, `a < a` must be false) *and* only in the jump-if-TRUE polarity,
> which `if c then … else … end` never emits. Symptom was every `repeat…until` overshooting by one
> iteration. See `METHODOLOGY.md` §2.

### Loops
| Luau | DE | Notes |
|---|---|---|
| `FORNPREP` | `0x47` | numeric-for prep |
| `FORNLOOP` | `0x0a` | numeric-for back-edge |
| `FORGPREP`, `FORGPREP_NEXT` | `0x30` | generic-for prep (`pairs`/custom iterator) |
| `FORGPREP_INEXT` | `0x1b` | generic-for prep (`ipairs`) |
| `FORGLOOP` | `0x1e` | 8B back-edge; `aux` = #loop vars, **bit31 = inext flavour**. Luau's aux passes through **verbatim** (`pairs`→`0x00000002`, `ipairs`→`0x80000002`, identical in Luau and corpus). |

### Tables
| Luau | DE | Semantics | note |
|---|---|---|---|
| `GETTABLE` | `0x01` | `R[A] = R[B][R[C]]` | register key |
| `SETTABLE` | `0x2a` | `R[B][R[C]] = R[A]` | register key |
| `GETTABLEKS` | `0x3d` | `R[A] = R[B][K[aux]]` | tag-1 hash **or** tag-3 string key; source metadata preserves the original class, `C` = inline-cache slot |
| `SETTABLEKS` | `0x15` | `R[B][K[aux]] = R[A]` | **tag-3 string** key, `C` = cache slot |
| `GETTABLEN` | `0x44` | `R[A] = R[B][C+1]` | integer literal key |
| `SETTABLEN` | `0x2e` | `R[B][C+1] = R[A]` | integer literal key |
| `NEWTABLE` | `0x2c` | 8B | |
| `DUPTABLE` | `0x4f` | from a const template | |
| `SETLIST` | `0x3f` | 8B array fill | |

> The inline-cache slot `C` must be a **real slot (0–254)**; forcing `255` corrupts an adjacent register.
> Preserve the value Luau assigns.

### Calls, closures, upvalues, globals
| Luau | DE | Notes |
|---|---|---|
| `CALL`, `CALLFB` | `0x54` | 937,218 — the most common opcode |
| `NAMECALL` | `0x2d` | 8B; method name = **tag-1 FNV hash** in `aux`; DE `C` byte forced to **0**; always immediately followed by `0x54` |
| `RETURN` | `0x29` | |
| `NEWCLOSURE` | `0x16` | + one `CAPTURE 0x35` per upvalue |
| `CAPTURE` | `0x35` | `A` = capture type (0 VAL / 1 REF / 2 UPVAL), `B` = source |
| `DUPCLOSURE` | `0x42` | closure with no captures |
| `CLOSEUPVALS` | `0x39` | |
| `GETUPVAL` | `0x13` | read upvalue |
| `SETUPVAL` | `0x53` | write upvalue |
| `GETIMPORT` | `0x46` | 8B; `aux` = packed import descriptor |
| `SETGLOBAL` | `0x02` | 8B, tag-1 hash **or** tag-3 string key |
| `GETGLOBAL` | `0x17` | 8B, `R[A] = env[K[aux]]`, tag-1 hash **or** tag-3 string key, `B`=0 unused (see §3) |

### Misc
| Luau | DE |
|---|---|
| `CONCAT` `0x28` · `LENGTH` `0x4d` · `NOT` `0x50` | |
| `AND`/`OR`/`ANDK`/`ORK` | *lowered*: `MOVE A,B` + `JUMPIF/JUMPIFNOT` + `MOVE A,C` \| `LOADK A,K[C]` |
| `FASTCALL`, `FASTCALL1`, `FASTCALL2`, `FASTCALL2K`, `FASTCALL3`, `COVERAGE`, `NOP` | **dropped** (mapped to `-1`) — pure optimization hints; the complete slow path (arg setup + `GETIMPORT` + `CALL`) always follows, so dropping them yields correct code |

### Deliberately NOT emitted (hard-error, never silently wrong)
| Luau op | why it's safe to omit |
|---|---|
| `IDIV` (reg-reg `a//b`) | `//` occurs **0 times as an operator** in the corpus (all apparent matches are URLs in string literals). DE's Luau v9 predates `IDIV`. |
| `JUMPX` | needs a jump > ±32767 words; largest corpus proto is **17,520 words**. Unreachable. |
| `NATIVECALL`, `GETUDATAKS`, `SETUDATAKS`, `NAMECALLUDATA`, `NEWCLASSMEMBER`, `CMPPROTO`, `BREAK` | stock `luau-compile` never emits these for plain Lua source |

---

## 2. DECODE map — the extra opcodes a *reader* must understand

Real game bytecode contains ops we never emit. A decompiler (M6) must handle these or it will silently
mis-read shipped scripts. **All 77 corpus opcodes are accounted for; 0 unexplained.**

| DE | meaning | freq | decompiler action |
|---|---|---|---|
| `0x19` | `FASTCALL1` — builtin hint, `A`=builtin id, `B`=arg reg, `C`=distance to `CALL` | 140,927 | **skip** |
| `0x10` | `FASTCALL` (no explicit arg reg) | 6,364 | **skip** |
| `0x0c` | `FASTCALL2K` (2nd arg = const) | 2,671 | **skip** |
| `0x26` | `FASTCALL2` (2 register args) | 15,115 | **skip** |
| `0x4a` | `FASTCALL` variant, 8B | 546 | **skip** |
| `0x25` | **`JUMPBACK`** — unconditional backward jump, `Bx` always negative | 15,678 | **real control flow**, emit a loop back-edge |
| `0x17` | **`GETGLOBAL`** `R[A] = env[K[aux]]` | 22,464 | global read |
| `0x3e` | `SUBK` `R[A] = R[B] - K[C]` | 7,771 | `b - k` |
| `0x00` | `MOD` with **swapped** operands `R[A] = R[C] % R[B]` | 2 | `c % b` |
| `0x2b` | `OR` `R[A] = R[B] or R[C]` | 282 | short-circuit or |
| `0x2f` | `AND` `R[A] = R[B] and R[C]` | 125 | short-circuit and |
| `0x31` | `ANDK` `R[A] = R[B] and K[C]` | 22 | |
| `0x37` | `JUMPIFEQ` (jumps when **equal**) | 14,076 | equality branch |
| `0x20` `JUMPXEQKN`, `0x41` `JUMPXEQKS` | compare `R[A]` against **`K[aux & 0x7fffffff]`** (number / string const); bit31 = polarity | 19,213 / 5,519 | equality-vs-const branch |
| `0x34` `JUMPXEQKB` | compare `R[A]` against a **boolean IMMEDIATE** — `aux & 1` *is* the value; there is **no const index** | 2,591 | `x == true` / `x ~= false` |
| `0x3a` `JUMPXEQKNIL` | compare `R[A]` against **nil**; aux carries polarity **only** (low bits always 0) | 19,571 | `x == nil` |

> **`0x34` was previously documented here as a const-index compare — that was WRONG.** Corrected
> 2026-07-25 by M6a. `derecomp de-auxhist <dir> 0x34` shows exactly **two** distinct low-aux values
> `{0,1}` across all 2,591 instances, and 20 of them are out of range as a const index. Contrast
> `0x20`/`0x41`, which spread over 64+ distinct values with **zero** out-of-range — that is what a real
> const index looks like. `de-auxhist` is the general tool for separating "aux is a const index" from
> "aux is an immediate"; reach for it before assuming an aux payload is an index.
| `0x51` | `TESTSET` — copies `R[B]`→`R[A]` when `R[B]` is truthy, else skips (leaving `R[A]`'s prior value) | 948 | and/or chain |

**Absent from disk** — 11 in-range bytes occur **zero** times in all 5386 files, so no shipped script
contains them and a decompiler needs no support:
`0x03 0x05 0x0f 0x1d 0x1f 0x36 0x43 0x48 0x52 0x56 0x57`.

> `0x36` being absent is the same fact that exposed `NAMECALL=0x36` as wrong — we had been emitting an
> opcode that exists **nowhere** in the game's own code.

---

## 3. Globals — native module environment and key kinds

`SETGLOBAL 0x02` writes the **private module environment**, which is **not** the same table as `_G`
(proven: set via `0x02`, read via `_G` → nil).

Production recompilation emits native `SETGLOBAL 0x02` + `GETGLOBAL 0x17`. The retired `_G` mirror
route generated an invalid cache slot and caused live register corruption/GPFs; it is not a production
fallback.

The key constant is not universally a string. Full-corpus measurement finds both tag-1 hashes and
tag-3 strings, with no mixed module/name identity for globals. Semantic source therefore records
hashed globals using `-- RENOVICE_HASH_GLOBAL: <name>` and `recompile` restores only those accesses.
The remaining globals stay string-keyed (for example loader-visible exports such as `OnInit`).

---

## 4. Provenance

Every non-obvious entry above was established by one of:
1. **Corpus source↔bytecode correlation** — find a construct in `all_source_v13`, disassemble the matching
   `.lua_B`, correlate by statement order.
2. **Dataflow analysis** — is the destination register read afterwards (produces a value) or written before
   (consumes it)? This is how `GETTABLE 0x01` / `SETTABLE 0x2a` were separated.
3. **In-game substitution probes** that *report the observed value* — the decisive method. See
   `METHODOLOGY.md`.

Do not trust the legacy `data/wf_opcode_map.tsv` handler labels: they mislabel `0x07` as `VEC_SUB`,
`0x22` as `VEC_MUL`, and `0x2d` as `GETGLOBAL`, all of which the corpus disproves.
