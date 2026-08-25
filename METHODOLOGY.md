# How to establish an opcode's meaning (and how this project got it wrong)

This is the hard-won part. The opcode *values* in `OPCODE_MAP.md` are cheap to look up; knowing **which
kinds of evidence are trustworthy** is what took the work. Every rule below exists because violating it
produced a real, shipped bug.

---

## 1. The evidence hierarchy

Strongest to weakest:

1. **In-game substitution probe that reports the observed value.** Ground truth. Nothing overrides it.
2. **Corpus source↔bytecode correlation** — a construct in `all_source_v13` matched to the instruction in
   the corresponding `.lua_B`, by statement order. Very strong, but see §5 (the source is lossy).
3. **Corpus dataflow** — is the destination register read afterwards, or written before? Separates reads
   from writes without needing source at all.
4. **Corpus operand statistics** — a field that is *always* 0 across hundreds of instances is structural
   (unused, or a fixed source), not coincidence.
5. **Frequency reasoning** — an op used 468,568 times is not a rare specialised variant.
6. ~~Handler labels in `data/wf_opcode_map.tsv`~~ — **actively misleading.** It labels `0x07` `VEC_SUB`,
   `0x22` `VEC_MUL`, `0x2d` `GETGLOBAL`; the corpus disproves all three.
7. ~~Multi-agent consensus~~ — **not evidence.** See §6.

---

## 2. The substitution probe (the technique that actually works)

**Idea:** emit the unknown opcode *in place of* an op whose correct answer you already know, then have the
script print what came out.

```lua
-- built with: RENOVICE_OP_ADDK=0x3e derecomp recompile probe.luau out.lua_B
function OnInit()
  local function t(three, ten)
    local v = ten + 4                 -- normally ADDK; the override makes this 0x3e
    error("TAG=" .. tostring(v))      -- <- prints the ACTUAL value
  end
  t(3, 10)
end
```

`ten + 4` → `6` means `0x3e` computed `10 - 4`, i.e. it is **`SUBK`**. Done. No inference, no guessing.

### Rules for probe design

* **Report the value, don't bin it.** `error("TAG=" .. tostring(v))` beats a ladder of range checks. Early
  rounds used bins and returned useless `_other` for `0x31`, `0x24`, `0x45` — one of which turned out to be
  the reg-reg `POW` we'd declared unfindable.
* **Never let the op under test be used by the reporting logic.** The reporter uses only ordered compares;
  if you test an equality op *and* report with equality, a broken op corrupts its own measurement.
* **One data point is not enough when candidates coincide.** `10 + 4` returned `2`, consistent with *both*
  `MODK` (10%4) and `IDIVK` (10//4). A second probe with `10 + 3` (`MODK`→1, `IDIVK`→3) separated them.
  **Always pick operands where the candidate semantics differ.**
* **Always ship a control.** Run the same probe with the known-good opcode. If the control fails, the
  harness is broken, not the opcode.
* **Test at boundaries.** `3 < 5` is true for both `<` and `<=`. Only `a < a` / `a <= a` distinguish them.
* **Test both polarities.** `if c then … else … end` only ever emits the jump-if-**NOT** forms.
* **Give every module a unique tag.** Two modules built from one source file share a tag and the result is
  unreadable. (This happened; the run had to be repeated.)
* **Deploy modules independently.** One file per probe → one F9 yields N independent verdicts with no
  cascading failure.

---

## 3. Falsify your own hypothesis first, cheaply

Before running anything in-game, ask what the hypothesis *forbids*.

> Hypothesis: `0x17` reads a field from an **upvalue** table (`R[A] = upval[B][K[aux]]`).
> Then every proto containing `0x17` must have `nups > 0`, and `B` must be `< nups`.
> Measured: **77 of 177 instances occur in protos with `nups == 0`.** Refuted in one command.

The correct answer (`0x17` = `GETGLOBAL`) came from a different cheap test: does any proto write a name
with `SETGLOBAL 0x02` and read the *same const* with `0x17`? Yes — `mPurchaseParams` in
`Lotus_Interface_Background.lua_B` p12/p13.

---

## 4. Crash-class vs error-class mistakes

A wrong **arithmetic** opcode gives a wrong number. A wrong **table/name** opcode, or a key with the wrong
const tag, dereferences garbage and raises an **access violation (0xc0000005) that can take the game down**.

* **Never crash-probe table/store ops.** Establish them offline from the corpus first.
* Writes/field keys must be **tag-3 STRING**; only `NAMECALL` uses a **tag-1 FNV hash**.
* Inline-cache slot `C` must be a real slot (0–254). Forcing `255` corrupts an adjacent register — that
  bug presented as a *comparison* failure three instructions later.
* If a probe crashes the game, remove that `.lua_B` from `Inject/` immediately — it re-fires on every
  region load.

---

## 5. Traps specific to this corpus

* **`all_source_v13` is lossy.** It contains `unk`, `UNNAMED_*`, and outright mis-renderings: one file
  showed `unk[unk]` where the bytecode was really `t[1]` (`GETTABLEN`). Treat source as a *hint*;
  **bytecode is truth**. This is also why only ~21% of v13 re-parses as valid Luau — a **decompiler
  quality** number, not an opcode gap.
* **Grep the operator, not the character.** `//` looked like it appeared in 10 files; all 45 matches were
  URLs inside string literals (`https://…`). It occurs **zero** times as an operator.
* **`require` caches modules by name.** Redeploying under the same name runs the *stale* bytecode. The
  injector appends a reload generation (`Renovice.<name>_g<N>`) to defeat this; old generations still
  re-fire, so expect stale tags in `EE.log` — always filter by newest timestamp.
* **`EE.log` only flushes while the game is focused.** "No tag" ≠ "didn't run"; check the injector log for
  enrollment first.
* **Don't build while probes are running.** Concurrent `derecomp.exe` use causes a link failure; build to a
  temp name and swap.

---

## 6. On multi-agent RE

A 10-agent workflow (976k tokens) decoded the remaining opcodes. It produced two genuinely useful results
(the FASTCALL family, `JUMPBACK`) — and **contradicted itself on twelve**:

* two agents assigned `0x2b`/`0x2f` **opposite** meanings (`AND` vs `OR`);
* one agent confidently "refuted" `0x17 = GETGLOBAL`, which was **correct**.

Agent agreement is not evidence, and agent disagreement is not noise to average out — it is a signal that
the question needs an experiment. Every one of the twelve was settled by a single substitution probe.

Use agents for **breadth** (surveying, extracting, generating candidate hypotheses). Use probes for
**truth**.

---

## 7. A cert result is only valid for the binary it ran against

M4 was marked complete, then the emitter changed twice (`POW=0x45`, `IDIVK=0x24`), and the old green result
kept being cited. Any change to `transcode.h` invalidates every previous cert run.

**Workflow:** change → rebuild → `de-roundtrip-batch` (container regression) → redeploy the full cert suite
→ F9 → confirm *all* modules green → only then claim it works.

---

## 8. Commands

```bash
derecomp compile   <in.luau> <out.luaubc>    # Luau source -> Luau bytecode
derecomp dump      <in.luaubc> [proto]       # Luau ops (names + operands)
derecomp recompile <in.luau>  <out.lua_B>    # full pipeline -> DE 09 03
derecomp de-disasm <file.lua_B> [proto]      # DE ops + const table + proto header
derecomp histops   <dir|file>                # opcode census (+ clean_walk %)
derecomp histcsv   <dir> <out.csv>           # per-file opcode counts (for correlation)
derecomp de-roundtrip[-batch] <file|dir>     # byte-exactness regression
derecomp namehash  <name>                    # FNV name hash

RENOVICE_OP_<LUAUOP>=0xNN derecomp recompile …   # substitute one opcode (probing)
RENOVICE_NATIVE_GLOBALS=1 derecomp recompile …   # native 0x02/0x17 globals
```

Cert suite: `cert/v9/*.luau` — 10 independent modules covering **59/59** emittable opcodes.
Deploy to `OpenWF/CustomScripts/Inject/`, press **F9**, read `%LOCALAPPDATA%\Warframe\EE.log`.
