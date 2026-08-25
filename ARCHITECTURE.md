# DeNativeRecompiler — one self-contained C++ toolchain for DE "Luau"

**Goal (set 2026-07-24):** collapse the scattered Python RE toolchain into **one folder, one program, C++** that can
(1) **recompile** Luau source → **byte-perfect DE `09 03` bytecode** the game runs, (2) **decompile** DE bytecode →
readable Luau, (3) build/maintain the **corpus**, all against **one local knowledge base** in this folder. No more
files scattered across `Transpiler\` + `NativeDecompiler\` + ~60 loose scripts.

Built **step by step, each stage verified** before the next. The existing Python pipeline STAYS working and is only
retired **once the C++ reaches parity** — so we are never stranded.

---

## 0. The correctness basis (why this actually lands in the game)

- The game ships **no Lua source compiler** — it loads **bytecode only** (`.lua_B` files ARE bytecode). So producing
  correct bytecode is the whole job.
- **Input dialect = Luau** (the game's real language), compiled by the **real Luau compiler**
  (`C:\Users\Bartek\LuauBuild\luau-compile.exe`, modes incl. `binary`). This is the correctness lever — not a
  Lua-5.1 frontend. luau-compile emits **standard Luau bytecode**; the **DE-specific part is our transcoder**
  (opcode renumber + name→FNV + `09 03` container). DE `09 03` = renumbered Luau v9.
- PROVEN this session: recompiled bytecode injected + run in-game (overguard, native calls). The pipeline works;
  this project makes it **clean, unified, and Luau-correct**.

**Note (2026-07-24):** the Luau *source/headers* (`LuauDE/luau`) referenced by `LuauBuild/CMakeCache.txt` are GONE
(dir deleted). We still have the static libs (`LuauBuild/libLuau.*.a`) but not the headers. So **Phase 1 shells out
to `luau-compile.exe`** (real compiler, works now). A later option: re-obtain standard Luau source (Roblox/luau) to
`#include` + statically link libLuau into a single binary. The transcoder is DE-specific and is ours either way.

---

## 1. Pipelines

### RECOMPILE  (Luau source → game bytecode)  — Phase 1, the priority
```
foo.luau
  → luau-compile.exe --mode binary          (real Luau compiler → standard Luau bytecode)
  → [C++ transcoder]                          port of de_luau_reencoder / encode_luab:
        · opcode renumber  (Luau v9 → DE renumbered; validated vs interpreter dispatch table @base+0x1992418)
        · name resolution  (method/field/global names → FNV via de_name_hash; NAMECALL/GETFIELD cache byte)
        · import table / GETIMPORT encoding, const pool, upvalue descriptors
        · emit DE `09 03` container (pool | nps | protos | root-idx)
  → foo.lua_B                                 (drop in CustomScripts\Inject\, runs in-game)
```

### DECOMPILE  (game bytecode → readable Luau)  — Phase 2
```
foo.lua_B  → parse `09 03` → proto tree → CFG → IR → expr/stmt → emit Luau source
```
Port of the Python `offline_decompile` + `NativeDecompiler` (cfg/ir/expr/emit/closures/consts/naming). Big — done
incrementally; until parity the C++ CLI may `--decompile-via-python` (wrap the proven Python) so we always have a
working decompile.

### CORPUS  (batch decompile + name maps)
Batch decompile the game Cache → readable corpus, apply the name knowledge base. Replaces `dump_all_source_*` + the
~60 post-processing scripts with one reproducible command.

---

## 2. Folder layout (everything here)
```
DeNativeRecompiler/
  ARCHITECTURE.md          ← this file (the plan)
  build.bat                ← g++/cmake build → bin/derecomp.exe
  src/                     ← C++ sources
    main.cpp               ← CLI: derecomp compile|decompile|corpus ...
    luau_frontend.*        ← drive luau-compile.exe → Luau bytecode
    transcode/             ← Luau bytecode → DE 09 03  (the DE-specific core)
    de_container.*         ← 09 03 read/write (pool, nps, protos, root)
    namehash.*             ← de_name_hash (port of de_namehash.py; self-test GetConfigBool==0x4aec2dac)
    decompile/             ← Phase 2
  data/                    ← the KNOWLEDGE BASE, local & versioned:
    name_map.json          ← clean hash→name dict (+Pluto names)
    enum_index.json, ability_stats*, native_names*, pluto_names.txt, opcode maps ...
    corpus/                ← latest readable corpus (v15)
  third_party/luau/        ← (future) Luau source to static-link; for now we call luau-compile.exe
  bin/                     ← build output (derecomp.exe)
  tests/                   ← round-trip + golden tests (byte-exact verification gate)
```

---

## 3. Build order (each a verified milestone — DO NOT skip verification)

1. **[M1] scaffold + Luau frontend** — ✅ **DONE.** Drives `luau-compile.exe --mode binary`.
2. **[M2] parse Luau bytecode** in C++ (proto tree, consts, code) — ✅ **DONE** (`src/luau_bc.h`).
3. **[M3] DE container writer** — ✅ **DONE.** Round-trip **5382/5382 byte-exact** over the cache corpus;
   4-lens verified (faithfulness, Python parity, untested paths, adversarial edges).
4. **[M4] transcoder** — ✅ **DONE + IN-GAME CERTIFIED.** **17/17** cert modules pass (11 hand-written v9
   + 6 generated v10 = **133 assertions**), **59/59** emittable opcodes exercised, **0 unmapped** ops over a
   250-file real-source sample. See `OPCODE_MAP.md` and `CERT.md`.
   *Bonus:* the **decode** map (what a reader must understand) is complete for all **77** corpus opcodes —
   M6's prerequisite, already done.
   > The generated v10 matrix caught `JUMPIFEQ 0x20 → 0x37` **after** M5 was green on every offline metric.
   > Offline parity does not imply behavioural correctness; see `CERT.md` § "Why generated beats hand-written".
5. **[M5] parity sweep** — ✅ **DONE.** 100.0000% on all three bytecode-grounded metrics: container
   round-trip **5382/5382** byte-exact, decode validation **0 violations / 5,529,086** instructions,
   instruction round-trip **82042/82042** (offsets recomputed, not copied). See `M5_PARITY.md`.
6. **[M6] decompiler** (Phase 2) — 🔶 **IN PROGRESS — the real remaining work.**
   **M6a (annotated IR) ✅ done** (`src/ir.h`, `derecomp ir` / `ir-validate`): **5,529,086 / 5,529,086
   instructions annotate with ZERO unresolved operands (100.0000%)**; constants 1,622,341/1,622,341;
   import paths 326,014/326,014; name-hashes 632,534/695,590 real (90.93%, rest lossless
   `Name__aabbccdd`). It is read-only and separate from the byte-exact writer. On its first run it
   caught two wrong assumptions — import components are tag-1 hashes not strings, and **`0x34` is a
   boolean immediate, not a const-index compare** — neither of which any structural metric could see.
   **M6c (expression reconstruction) DONE** (`src/expr.h`, `derecomp expr` / `expr-validate`):
   **5,529,086 / 5,529,086 instructions consumed, 0 unhandled** (expr 3,343,963 | stmt 1,310,444 |
   ctrl 512,366 | skip 362,313), and 0 unhandled across all three ground-truth sets. NOTE this is a
   COMPLETENESS metric, not correctness — spot-checking against known sources still found three
   real defects it could not see (SETLIST dropped every array element; multret RETURN/CALL dropped
   values). Correctness waits on M6e + the round-trip oracle.
   **M6d (control-flow structuring) ✅ DONE** (`src/structan.h`, `derecomp sa-validate`):
   **82,042 / 82,042 protos = 100.0000% reduced to a single region, with ZERO duplication and no
   fallback.** Adversarial coverage check: every reachable block appears EXACTLY once — 0 missing,
   0 duplicated. Ground truth 294/294 on all three generated sets; deterministic across runs.
   Implemented as STRUCTURAL ANALYSIS (bottom-up graph reduction, Muchnick ch.7.7) after a
   recursive-descent pattern pile plateaued at 92.32% honest / 99.9976% with ~15,700 block copies.
   M6b (CFG) ✅ done:
   82042/82042 protos, 0 errors, **820,789** blocks, 1,131,910 edges, 44,678 back-edges.
   **Unreachable blocks: 1,607 in 1,343 protos (2,235 instructions) — CLASSIFIED and CLEARED**
   (`derecomp de-unreach`, `derecomp de-deadaudit`). All 1,514 *root* dead blocks follow a
   non-fall-through op (JUMPBACK 799 / RETURN 470 / JUMP 245); **zero follow a fall-through op**, so the
   decode map is not implicated. All four dead-code shapes reproduce under stock `luau-compile.exe`.
   The audit also *found* a CFG defect (RETURN did not make a leader, hiding 500+ dead instructions),
   now fixed — see FINDINGS.md 2026-07-25. Decompiler must DROP dead blocks; document as intentional
   lossiness, which the idempotence oracle tolerates but byte-identity would not.
   The ~21% "recompile v13" figure is
   *decompiler output quality*, not an opcode gap: v13 text has `unk`/`UNNAMED_*` and mis-renderings
   (e.g. `unk[unk]` where the bytecode was `t[1]`), so it isn't valid Luau. Build on the 77-opcode decode
   map. Suggested oracle: **round-trip idempotence** (decompile → recompile → decompile, require
   source₁ == source₂) rather than byte-identity, which is unreachable because DE emits instrumentation
   (`0x19`/`0x25`) and chooses its own register allocation / PIC cache slots.
7. **[M7] consolidate data + retire Python** — ⬜ only after C++ parity is proven.

> **Editing real scripts does NOT require byte-identity.** The VM executes whatever valid bytecode it is
> given. For surgical mods, `de_container` preserves every proto as a raw byte span, so only the edited
> proto needs re-emitting — the rest stays byte-identical, shrinking the trust surface to the code changed.

Verification is the point (user: "step by step so carefully, 100% certainty"). Byte-exact golden tests gate each
stage. Nothing lands in the game until it's proven byte-correct.

---

## 4. What we reuse vs. rewrite
- **REUSE (as-is):** `luau-compile.exe` (real Luau compiler); the *knowledge* (name maps, opcode maps, enum index,
  ability stats) — copied into `data/`.
- **PORT to C++:** the transcoder (`de_luau_reencoder`, `encode_luab`, `luab_assemble`), `de_namehash`, the
  container r/w, and (Phase 2) the decompiler.
- **RETIRE (only at parity):** the scattered Python entrypoints (`dump_all_source_*`, `recompile.py`, rb2, the ~60
  post-process scripts). Kept as reference until the C++ matches them byte-for-byte.
