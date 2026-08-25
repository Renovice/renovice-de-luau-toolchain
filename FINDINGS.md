# DeNativeRecompiler — FINDINGS

Chronological log of every investigation, with hypothesis / evidence / outcome.
**Append-only**: older entries keep the numbers that were true when written, so a stale figure in an
old entry is a record, not an error. For current state see `OPCODE_MAP.md` / `README.md`.

## Index

- [2026-07-24 — M3: DE 09 03 container round-trip in C++ (byte-exact, adversarially verified)](#2026-07-24--m3-de-09-03-container-round-trip-in-c-byte-exact-adversarially-verified)
- [2026-07-24 — M4c in-game certification: our C++ recompiler's output RUNS in-game (3 bugs caught + fixed)](#2026-07-24--m4c-in-game-certification-our-c-recompilers-output-runs-in-game-3-bugs-caught--fixed)
- [2026-07-24 — M4c: fused compare calibration MEASURED in-game (recompiler proven)](#2026-07-24--m4c-fused-compare-calibration-measured-in-game-recompiler-proven)
- [2026-07-24 — ARITH OPMAP re-derived FROM THE CORPUS (Fable pivot: stop probing, read the map we own)](#2026-07-24--arith-opmap-re-derived-from-the-corpus-fable-pivot-stop-probing-read-the-map-we-own)
- [2026-07-24 — ARITH map CONFIRMED in-game (isolated bracket-probes); the one real bug was MUL](#2026-07-24--arith-map-confirmed-in-game-isolated-bracket-probes-the-one-real-bug-was-mul)
- [2026-07-24 — Full opcode audit (workflow) + verified fixes: 5 crash-class bugs found & fixed](#2026-07-24--full-opcode-audit-workflow--verified-fixes-5-crash-class-bugs-found--fixed)
- [2026-07-24 — Completeness pass: 3 of 4 remaining gaps closed + verified in-game](#2026-07-24--completeness-pass-3-of-4-remaining-gaps-closed--verified-in-game)
- [2026-07-24 — GETGLOBAL FULLY FIXED via _G routing; all 4 completeness gaps closed](#2026-07-24--getglobal-fully-fixed-via-g-routing-all-4-completeness-gaps-closed)
- [2026-07-24 — M4 COMPLETE: 100%-coverage cert suite catches 2 long-standing bugs](#2026-07-24--m4-complete-100-coverage-cert-suite-catches-2-long-standing-bugs)
- [2026-07-24 — DECODE RE for M6: 77 real opcodes, disputes resolved by value-reporting probes](#2026-07-24--decode-re-for-m6-77-real-opcodes-disputes-resolved-by-value-reporting-probes)
- [2026-07-24 — DECODE MAP COMPLETE (all 77 corpus opcodes) + 2 "impossible" gaps closed](#2026-07-24--decode-map-complete-all-77-corpus-opcodes--2-impossible-gaps-closed)
- [2026-07-24 — M4 COMPLETE (verified against the CURRENT build)](#2026-07-24--m4-complete-verified-against-the-current-build)

---
## 2026-07-24 — M3: DE 09 03 container round-trip in C++ (byte-exact, adversarially verified)

Hypothesis: A C++ port of the Python DE-container reader/writer (parse_luab + _flat_loader + encode_luab)
can round-trip every real `.lua_B` byte-exact, with consts reconstructed from parsed form (not copied).

Finding: **True** (with one robustness gap found + fixed).

Evidence:
- `src/de_container.h` (port) + `derecomp de-roundtrip-batch` over the on-disk corpus:
  **5386/5386 files byte-exact, 0 mismatch, 0 walk-error** (82,059 protos; consts re-encoded from parsed form).
- `derecomp de-stats`: const tags 0–8 all exercised (incl. 14 vec3, 74 non-empty inline source-names — the
  case that broke the old `o+6` header model); tag 9 int64 = 0 and pool name-table flag = 0 (never on disk).
- 4-lens verification workflow (wl8c5rcmy): faithfulness = PASS (every fn byte-faithful on valid input;
  4 divergences all unreachable); Python-parity = PASS (402/402 both toolchains byte-exact, nps Σ 6366=6366);
  untested-paths = PASS (tag-9 + name-table proven byte-exact by byte-enumeration + synthetic round-trip in
  both toolchains, both dead-on-disk); adversarial-edges = found a SIGSEGV on a malformed oversized
  string-pool length.
- Fix: `parse_pool_and_nps` now bounds-checks the string skip + uses `rd_u8`; also widened `sizek` to uint32_t
  (the auditor's one residual `int`-narrowing caution). Re-verified: crash input → clean exit 1
  ("string length past end"); corpus regression still 5386/5386 byte-exact.

Reason: every offset advance in the C++ port matches the Python branch-by-branch, so the consts/post
boundaries land identically; header/code/post are preserved as raw spans and only consts are structurally
rebuilt (rebuild == original span on valid input).

What changed: M3 complete. The DE container layer of the recompiler is proven correct on the whole corpus and
hardened against malformed input. `derecomp.exe` is static (no external DLLs) and fully in-folder.

Next Step: M4 — the transcoder (Luau v12 bytecode → DE `09 03`: opcode remap + name→FNV + GETIMPORT/import
encoding), diff vs Python `recompile.py`, then inject + run in-game (deploy needs user OK per ASK-FIRST).

## 2026-07-24 — M4c in-game certification: our C++ recompiler's output RUNS in-game (3 bugs caught + fixed)

Hypothesis: byte-diff-vs-Python offline verification is enough to trust the recompiler.
Finding: **False** — the game is the only oracle. The self-checking in-game cert (cert_all/cert_diag, deploy via
the Route C-prime injector as `Renovice.<name>` OnInit modules, read INST+0x30 + EE.log `error("TAG")`) caught
THREE real bugs the offline byte-diff could NOT (because the ported luau_to_de.py was never actually deployed):
  1. **Chunk return**: the module chunk must RETURN NOTHING (0 values); `return function() end` trips require's
     -2==function assert (rva 0x113206b). Match gc_loop: `function OnInit()...end` with NO chunk return.
  2. **Name-key tag**: SETGLOBAL/SETTABLEKS (WRITE name-ops) must use a **tag-3 STRING** key (the loader does
     getfield(T,"OnInit") by string); a tag-1 FNV hash key is NOT found (load-ret=0). READ name-ops
     (GETGLOBAL/NAMECALL/GETTABLEKS/imports) still use tag-1 hash. Fixed classify_names -> is_read_name_op only.
  3. **Fused-compare jump base**: the DE fused compares (CMP_*_JMP) measure the branch offset from **op+4**
     (after the OP WORD, aux excluded), NOT op+8. PROVEN offline: over 24568 real corpus fused compares, op+4
     targets land on an instruction boundary 24568/24568 (0 invalid), op+8 gives 7841 impossible mid-instruction
     targets. Layout is A=lhs, offset in D(hi16), aux=rhs (same as Luau). Op polarity = EXT mapping (0x20=EQ etc).
Also: **require CACHES modules by name** — redeploying under the SAME name does NOT reload (stale bytecode keeps
running from _MODULES); use a FRESH module name or restart the game to load new bytecode. Old cached modules
re-fire even after their files are removed.
Evidence: EE.log tags (ADD->JEQ_INVERTED diag), real-bytecode boundary tally, gc_loop vs cert const-tag diff.
Next Step: fresh-named cert_v3 (all fixes) + game restart -> CERT_V3_PASS = whole implemented opcode map certified.

## 2026-07-24 — M4c: fused compare calibration MEASURED in-game (recompiler proven)

Our C++ recompiler's output runs in-game and is CERTIFIED for: all arithmetic (ADD/SUB/MUL/DIV/MOD/POW/MINUS),
ORDERED compares, calls/CALLFB, closures (nups=0), NEWTABLE/SETTABLEKS/GETTABLEKS, numeric FORNPREP/FORNLOOP,
CONCAT/LENGTH/NOT, SETGLOBAL/GETGLOBAL, MOVE/LOADN/LOADK. ~15+ opcodes proven via self-checking cert.

Fused compares: layout A=lhs, offset in D(hi16), aux=rhs; **jump base = op+4** (proven: 24568/24568 real corpus
targets land on boundaries with op+4, op+8 gives 7841 impossible). Op = DE compare whose x86 jump-condition
matches the Luau branch, MEASURED via a 6-probe in-game truth table (< / == / > cases):
  0x1c = jae (>=)  ->  JUMPIFNOTLT (jump-if->=)
  0x33 = ja  (>)   ->  JUMPIFNOTLE (jump-if->)
  0x23 = jb  (<)   ->  JUMPIFLT
  0x21 = jbe (<=)  ->  JUMPIFLE
(EXT's CMP_LT/CMP_GE names were MISLEADING for polarity; the measured jXX behavior is authoritative. The equal
boundary is where wrong mappings show: `5<5`->true or `5<=5`->false flags a swapped op.)

OPEN GAP — EQUALITY BRANCHES (JUMPIFEQ `~=`, JUMPIFNOTEQ `==`): the tag-based equality ops 0x20 (CMP_EQ,
"tag 9/3") and 0x3a (CMP_NE, "xor tag") BOTH never jump for our LOADN'd number operands (measured: `5==3`
reported equal). They compare tags, not values, with our encoding. Real value-equality likely needs the disp2
variants 0x27 (CMP_EQ_disp2 @2nd-table 0x1990f60) or 0x37 (CMP_EQ_disp @0x1990f30) -- untested, deeper RE.
WORKAROUND: avoid `==`/`~=` BRANCHES in source; equality is expressible via ordered compares
(a==b <=> not(a<b) and not(b<a)), which are all working. Rare in real ability logic anyway.

Also fixed the injector (wtsapi32 DLL) so F9/region rescans + suffixes module names with a reload-generation
counter -> no more game restarts to load new bytecode. Deployed (backup wtsapi32.dll.bak-20260724-150526).

## 2026-07-24 — ARITH OPMAP re-derived FROM THE CORPUS (Fable pivot: stop probing, read the map we own)

Hypothesis: the in-game byte-sweep probes (sub06 BAD/sub07 OK, mul09 OK, mod45 BAD/mod55 OK) correctly
calibrated the arithmetic opcodes.
Finding: **False** — the probe methodology was contaminated. A vector/typed op emitted for scalar operands
reads/writes ADJACENT registers (R[B],R[B+1],R[B+2]), corrupting the register file nondeterministically
(the mulmin BAD->OK flip on IDENTICAL bytecode = the tell). The real map is in the 5386-file cache corpus.

Method (offline, no game): new derecomp commands `histops`/`histcsv`/`de-disasm` over protos2/cache (82059
real protos, **100.00% clean_walk** => WIDTH8 table proven correct corpus-wide). Then SOURCE<->BYTECODE
proto-level correlation vs all_source_v13 (Fable's rule: correlate with source, never trust handler labels):
  - EasingLib proto[0] `unk*unk2/unk3+unk4` => bytes `0x22 0x1a 0x49` => **MUL=0x22, DIV=0x1a, ADD=0x49**
    (definitive: 3 ops, 3 arith, left-to-right).  DIV normal order R[A]=R[B]/R[C] (proto[0] [1]: R5=R6/R3).
  - proto[39] `[7] 0x06 A=7 B=0 C=8` = R0-R8 (generic reg-reg sub) => **SUB=0x06**. proto[2] `-unk3` => UNM=0x0e.
  - `v4 % global` (EmpoweredAttack) => exactly one **0x55** => MOD=0x55.  `^` Pearson corr **0.997** => POW=0x08.
CORRECTIONS to transcode.h OPMAP: **MUL 0x09->0x22, SUB 0x07->0x06** (0x09/0x07 are the number-TYPED
specialized ops the DE compiler emits under type inference; stock luau-compile emits GENERIC untyped arith,
which real untyped corpus code encodes as 0x22/0x06/0x1a/0x49/0x55/0x08/0x0e). DIV/MOD/POW/MINUS were already
right. Handler-RE tsv labels (0x07=VEC_SUB, 0x22=VEC_MUL, 0x09=MUL) were UNRELIABLE — corpus overruled them.
Verified: `derecomp de-disasm` of our OWN emitted cert_v4 body now shows 0x49/0x06/0x22/0x1a/0x55/0x08 — a
bytecode-level proof the map is corpus-faithful BEFORE any in-game run.
Next Step: single in-game confirmation of cert_v4 (Fable: in-game = confirmation, not discovery). Then audit
the fused-compare bytes (0x27/0x1c/0x21/0x23/0x33/0x20) the same corpus way, then the Mallet mod.

## 2026-07-24 — ARITH map CONFIRMED in-game (isolated bracket-probes); the one real bug was MUL

Correction to the prior entry: SUB=0x06 was WRONG. Isolated per-op probes (each `r=a OP b` bracketed by two
reg-reg ORDERED compares, distinct tags, deterministic 3x with ZERO flip-flop) settled every arith op:
  SUB07_OK / SUB06_hi -> **SUB=0x07**   MUL22_OK / MUL09_lo -> **MUL=0x22**   DIV1a_OK / DIV32_hi -> **DIV=0x1a**
  MOD55_OK / MOD45_hi -> **MOD=0x55**   MINUS0e_OK -> **UNM=0x0e**   POW08_lo -> 0x08 is POWK (pow-by-CONST),
  so `two ^ 10` (POWK) works; reg-reg `a^b` POW is a separate byte (TBD, rare).
THE ONLY REAL ARITH BUG WAS **MUL 0x09 -> 0x22** (0x09 = number-typed specialized MUL; stock luau emits the
GENERIC op which real untyped corpus code encodes as 0x22). SUB/DIV/MOD/MINUS were already correct; my brief
SUB->0x06 "fix" (from a single misread proto) was disproven in-game. Lesson: trust the AGGREGATE corpus signal +
in-game isolated confirmation, not a single cherry-picked proto. cert_v5 then passed ALL arith + ALL 6 compares +
CONCAT/LEN/NOT + numeric-for.
NEW BUG FOUND (cert_v5): table-field WRITE `r.a=v` (SETTABLEKS 0x0c) CRASHES (access violation 0xc0000005) —
the field-name key is shared with the read (GETTABLEKS 0x17) and encoded tag-1 hash, but a WRITE needs a tag-3
STRING key. Fix offline in transcode_consts (emit separate string+hash key consts). Field READ untested alone.
Next: bank the win (cert_v6, no field writes), then fix field-key encoding from corpus, then Mallet (damage/10=DIV).

## 2026-07-24 — Full opcode audit (workflow) + verified fixes: 5 crash-class bugs found & fixed

A 7-agent corpus audit (offline, source<->bytecode over 82059 protos) + my own verification found the OPMAP had
several WRONG bytes that either crashed or silently misran. VERIFIED + FIXED (each confirmed in-game or byte-vs-corpus):
  * NAMECALL 0x36 -> 0x2d. 0x36 appears ZERO times in the corpus; 0x2d is the method op (every 0x2d is followed by
    0x54 CALL, e.g. AttachMovie `gFlashMgr:FindMovie()`). Also force DE C byte = 0 (Luau leaves junk there).
  * GETGLOBAL 0x2d -> UNMAPPED. 0x2d is NAMECALL, not a global read -> reading a global executed as NAMECALL =
    "index number with boolean" (the cert_v6 crash). DE lowers globals to GETIMPORT; bare GETGLOBAL is TODO.
  * SETTABLEKS (t.field=v) 0x0c -> 0x15. 0x0c is a PIC cache-variant (impossible A-regs, tag-2 aux) -> the field-
    write access-violation crash. 0x15 = R[B][K[aux]]=R[A], key tag-3 STRING, cache-slot in C.
  * GETTABLEKS (t.field read) 0x17 -> 0x3d GETFIELD_c. PROVEN by a corpus proto that writes+reads the same field:
    `0x15 ... aux=0x2e` (write) paired with `0x3d ... aux=0x2e` (read), same key+slot. 0x17 returned nil for us.
    Also the key must be tag-3 STRING (removed GETTABLEKS from is_read_name_op; only NAMECALL keeps tag-1 hash).
  * Field cache-slot C: PRESERVE Luau's C (corpus uses 0..254; forcing 255 = out-of-range slot). NAMECALL C=0.
  * CAPTURE 0x35 ADDED (was unmapped -> any closure with an upvalue hard-errored). Emitted 4B ABC after
    NEWCLOSURE/DUPCLOSURE (matches corpus SetSunLights 0x16 then 0x35). Confirmed in-game (CAP_OK).
  * DIVK 0x32 ADDED (x/const). SETTABLE reg-key (t[reg]=v) UNMAPPED (0x15 is const-key only; reg-key byte unknown).
In-game confirmed: CAP_OK, FIELD_OK (0x15 write + 0x3d read).
STILL-OPEN completeness gaps (hard-error safely, not crash): JUMPXEQK* family (`if x==<literal>`, ~59% of ==,
maps to 0x20 aux-bit31), method-definition shared-const (SETTABLEKS 'm' + NAMECALL 'm' share a const: write needs
tag-3 string, read needs tag-1 hash -> need to duplicate the const), GETGLOBAL->GETIMPORT lowering, SUBK/SUBRK.

## 2026-07-24 — Completeness pass: 3 of 4 remaining gaps closed + verified in-game

After cert_v7 PASS (full common opcode set), worked the 4 completeness gaps ("finish all 4"):
  1. JUMPXEQK* (`if x==<literal>`, ~59% of ==): LOWERED to `LOAD<const> scratch` + reg-reg 0x27/0x20 (proven ops;
     DE has no jump-if-not-equal-to-const). is_jumpxeqk in transcode_code; scratch reg = p.mx, maxstack bumped.
     Handles KN/KS/KNIL/KB and both == (notbit=1->0x27) and ~= (notbit=0->0x20). VERIFIED in-game: XEQK_OK.
  2. Method-DEFINITION shared-const (`function o:m()` SETTABLEKS 'm' + `o:m()` NAMECALL 'm' share one Luau const):
     transcode_consts now keeps the const tag-3 STRING (for the write) and APPENDS a tag-1 hash duplicate for the
     NAMECALL, filling namecall_remap (NAMECALL aux rewritten to the dup). VERIFIED in-game: MDEF_OK.
  4. SUBK (`x-const`): LOWERED to LOADK scratch + reg-reg SUB(0x07) (DE has no SUBK op). SUBRK (`const-x`) = 0x06
     R[A]=K[B]-R[C] (const in B, direct map). DIVK=0x32, MULK=0x09 already mapped. VERIFIED in-game: KV_OK.
  3. GETGLOBAL (bare global read): NOT closed — entangled with the pre-existing import-resolution-blocker. Luau
     emits GETIMPORT for READ-ONLY globals (Engine/error/etc. — already handled) and GETGLOBAL only for globals
     ASSIGNED in-chunk; the corpus shows DE's compiler emits NO bytecode getglobal for read-back (keeps the value
     in a register / uses GETIMPORT). A GETGLOBAL->GETIMPORT lowering would be stale for runtime-assigned globals,
     AND GETIMPORT resolution in the injected sandbox returns nil (the known import-resolution-blocker). Left
     UNMAPPED (safe hard-error). Real ability logic reads globals via GETIMPORT, which works at load for real
     scripts; the injected-sandbox resolution is the separate deep-RE milestone.
NET: the recompiler now faithfully compiles arbitrary Luau EXCEPT bare chunk-assigned-global read-back and reg-key
`t[reg]=v` writes and reg-reg `a^b` pow (all hard-error safely, not crash). All confirmed in-game via isolated probes.

## 2026-07-24 — GETGLOBAL FULLY FIXED via _G routing; all 4 completeness gaps closed

The GETGLOBAL->GETIMPORT lowering worked for load-time globals but NOT set-then-read (imports resolve at load).
Root cause proven in-game: SETGLOBAL 0x02 writes the private module env, which is a DIFFERENT table than `_G`
(SG2G probe: set via 0x02, read via _G -> nil). But `_G` IS the live mutable shared table (RG probe: write _G.x,
read _G.x -> works). FIX (transcode.h): route globals through `_G` --
  * SETGLOBAL -> DOUBLE-WRITE: keep 0x02 (loader reads OnInit from the private env) AND mirror `_G[key]=val`
    (GETIMPORT _G + SETTABLEKS). No OnInit special-case needed.
  * GETGLOBAL -> GETIMPORT _G + GETTABLEKS(0x3d) `_G[key]`.
  * Per-proto synthesized `_G` import descriptor (hash '_G' + tag-4). Global names are tag-3 STRING keys. Scratch=p.mx.
VERIFIED in-game: GG_OK (GTESTX=42 set-then-read = 42) AND CERT_V7_PASS (OnInit registration + full cert intact,
double-write broke nothing). Corpus round-trip still 5382/5382 byte-exact.
ALL 4 GAPS DONE: (1) JUMPXEQK* const-compares [XEQK_OK], (2) method-def shared-const [MDEF_OK], (3) GETGLOBAL via
_G routing [GG_OK], (4) SUBK/SUBRK [KV_OK]. The recompiler now faithfully compiles arbitrary Luau. Remaining
hard-error-safe (not crash, rare): reg-key `t[reg]=v` write (byte unknown), reg-reg `a^b` pow (use math.pow).

## 2026-07-24 — M4 COMPLETE: 100%-coverage cert suite catches 2 long-standing bugs

Built a 9-module cert suite (cert/v9/) that provably exercises **56/56 = 100%** of the DE opcodes our transcoder
can emit (measured by disassembling our OWN cert output and diffing against the OPMAP emit-set). Modules are
INDEPENDENT files so one F9 yields 9 separate verdicts with no cascade. It immediately found two real bugs that
every previous cert (v3..v8) had missed:

1. **JUMPIFLT / JUMPIFLE WERE SWAPPED.** Correct: **JUMPIFLT=0x21, JUMPIFLE=0x23** (we had 0x23/0x21).
   Why it hid so long: prior certs only ever used the `if <cond> then else error() end` shape, which emits the
   jump-if-NOT forms (0x1c/0x33 — those are correct). The jump-if-TRUE forms only appear in value-producing
   compares (`local x = a < b`) and in `repeat ... until`. And non-boundary data can't tell < from <=, so the
   BOUNDARY cases are what proved it: `3 <= 3` returned FALSE with 0x21 => 0x21 is strict `<`.
   Symptom: every `repeat ... until` overshot by exactly one iteration (L_REPEAT + X_REPEAT_LT).
   Measured via env-override battery: LE23_OK + LT21_OK pass all 3 checks (boundary/true/false); LE1c, LE33, LT23 fail.
2. **PREPVARARGS must be EMITTED as 0x11, not dropped.** We mapped it to -1 (drop). The corpus shows every
   vararg proto begins with 0x11 (SpatialLib p2, CheckSourceObjectType p1; 5668 occurrences corpus-wide).
   Without the prologue `...` is never set up, so GETVARARGS(0x4c) read nothing -> `local a = ...` was nil (V_ONE).
   Fix: {"PREPVARARGS",0x11}; A = number of fixed params (direct passthrough). Verified: our vararg proto now
   emits `0x11` then `0x4c`, byte-identical in shape to the corpus. V9_VA_OK in-game.

Also completed in this pass (all corpus-derived, offline):
  * generic-for: FORGPREP/FORGPREP_NEXT=0x30, FORGPREP_INEXT=0x1b, FORGLOOP=0x1e(8B, aux=nvars|bit31 inext) —
    Luau's aux passes through VERBATIM (pairs 0x00000002 / ipairs 0x80000002 identical in Luau and corpus).
  * reg-key table ops by DATAFLOW: GETTABLE(read t[k])=0x01, SETTABLE(write t[k]=v)=0x2a. NOTE 0x2a had been
    mis-mapped as GETTABLE (i.e. a WRITE emitted for every read); unused until now so nothing shipped broken.
  * FASTCALL/FASTCALL1/2/2K/3 + COVERAGE -> DROP (pure optimization hints; the complete slow path follows them).
  * AND/OR/ANDK/ORK -> LOWERED (MOVE + JUMPIF/JUMPIFNOT + MOVE/LOADK) using a new intra-lowering jump-target
    mechanism (DI.jt_dei = absolute DE index) so branches internal to a lowering resolve correctly.
  * DIVRK=0x3b, LOADKX->0x4e(aux), NOP->drop.
Corpus round-trip regression after ALL of the above: 5382/5382 byte-exact.
Unmapped-by-design (hard-error, never silent): reg-reg POW (no corpus byte; real code uses math.pow), IDIV/IDIVK
(`//` postdates DE's Luau v9), JUMPX, and the native-codegen/userdata ops stock luau-compile never emits.

RESULT: full v9 suite re-run after both fixes -> **9/9 modules PASS, 0 fail** (V9_DATA/ARITH/CMP/TABLE/LOOP/
FUNC/EXTRA/ORD/VA all _OK). M4 (transcoder) is COMPLETE: 100% of emittable opcodes exercised and correct in-game,
0 unmapped ops over a 250-file real-source sample, corpus round-trip 5382/5382 byte-exact.
NEXT MILESTONE: M5 (full corpus parity sweep) then M6 (C++ decompiler) — M6 is what actually gates round-tripping
real game scripts; the ~21% "recompile v13" figure is decompiler output quality, not an opcode gap.

## 2026-07-24 — DECODE RE for M6: 77 real opcodes, disputes resolved by value-reporting probes

Scope correction: the corpus uses exactly **77 distinct opcodes** (0 unaccounted). Eleven byte values in range
never appear on disk at all: 0x03 0x05 0x0f 0x1d 0x1f 0x36 0x43 0x48 0x52 0x56 0x57 — no shipped script contains
them, so the decompiler needs no support for them. (0x36 being absent is the same fact that proved NAMECALL=0x36
was wrong; we had been emitting an opcode that exists nowhere in the game's own code.)

A 10-agent workflow decoded them but CONTRADICTED ITSELF on ~12 (two agents assigned 0x2b/0x2f opposite meanings).
Resolved empirically with substitution probes that REPORT THE OBSERVED VALUE in the error tag (reporter uses only
ordered compares, never the op under test, so a broken op cannot corrupt its own measurement):
  * **0x17 = GETGLOBAL** (R[A] = env[K[aux]], B=0 unused, aux = tag-3 STRING, C = inline-cache slot).
    Corpus proof: Background.lua_B p12/p13 write `mPurchaseParams` with SETGLOBAL 0x02 and read it back with 0x17,
    sharing the same tag-3 const. In-game proof: NAT_OK (native 0x02 write + 0x17 read) == GRT_OK (_G routing).
    This is the getglobal we could never find; it also explains why substituting 0x17 for a field read returned nil
    (it looked up a GLOBAL named "f"). Earlier guesses "cached field-read variant" and "upvalue table read" were
    both REFUTED (the latter in seconds: 77/177 instances occur in protos with nups==0).
  * **0x3e = SUBK**  R[A] = R[B] - K[C]   (probe: `10 + 4` via 0x3e returned 6)
  * **0x00 = MOD with SWAPPED operands** R[A] = R[C] % R[B]  (`10 % 3` returned 3)
  * **0x2b = OR**   R[A] = R[B] or R[C]   (`10 * 3` slot returned 10 = lhs)
  * **0x2f = AND**  R[A] = R[B] and R[C]  (`10 * 3` slot returned 3  = rhs)   [the misc agent had 2b/2f BACKWARDS]
  * **0x37 = JUMPIFEQ** (jumps when EQUAL; behaved inverted vs JUMPIFNOTEQ)
  * **0x34 / 0x3a / 0x41 = CONSTANT-comparing branches** — never branched when given a register in aux, i.e. they
    read K[aux] not R[aux] (matches corpus: aux indexes a const, bit31 often set).
  * **0x51** returns R[B] (a table came out where a field value was expected) — NOT a field read.
STATUS: decode coverage 99.08% settled; remaining 0x31/0x24/0x45/0x51 in a round-2 probe that prints the exact
value via tostring(). FASTCALL family (0x19,0x10,0x0c,0x26,0x4a = 3.00%) agreed by both agent groups -> decompiler
SKIPS them (they are hints; the real GETIMPORT+CALL follows). 0x25 = JUMPBACK (real control flow, not a hook).

## 2026-07-24 — DECODE MAP COMPLETE (all 77 corpus opcodes) + 2 "impossible" gaps closed

Round-2/3 probes REPORT THE OBSERVED VALUE via tostring(), so semantics are read off directly:
  * **0x45 = reg-reg POW**  (2^10 -> 1024 in-game; POWK control agreed).  I had previously declared reg-reg POW
    UNSUPPORTABLE ("no corpus byte exists, real code uses math.pow"). WRONG — the byte was in the corpus at 92
    occurrences, mis-bucketed as a "MOD variant". Now MAPPED: {"POW",0x45}.
  * **0x24 = IDIVK** R[A]=R[B]//K[C]  (10//4 -> 2 AND 10//3 -> 3; ANDK would have given 4 then 3, so ruled out).
    `//` was previously declared unsupported ("postdates DE's Luau v9"). Now MAPPED: {"IDIVK",0x24}.
  * **0x31 = ANDK** R[A]=R[B] and K[C]  (10+4 slot -> 4 = K[C]; IDIVK would have given 2, so ruled out).
  * **0x51 = TESTSET**: copies R[B] into R[A] when R[B] is truthy, otherwise skips (leaving R[A]'s prior value).
    Explains all three observations: B=10 -> 10 ; B=table -> the table ; B=false -> stale `true` left in R[A].
CROSS-CHECK METHOD NOTE: 0x24 vs 0x31 were BOTH ambiguous on a single probe (10+4 -> 2 or 4) and were separated
only by running a SECOND probe with different operands (10+3). One data point per opcode is not enough when two
candidate semantics can coincide on a given input — pick operands where the candidates DIFFER.
STATUS: decode coverage = 77/77 corpus opcodes (100%). Emission unchanged except the two new mappings above;
corpus round-trip still 5382/5382 byte-exact. Remaining emit-side hard-errors (safe, rare): reg-reg IDIV (`a//b`
with both operands registers - byte not yet identified), JUMPX, and the native/userdata ops stock luau never emits.

## 2026-07-24 — M4 COMPLETE (verified against the CURRENT build)

Caught a real bookkeeping error: M4 had been marked "complete" while the emitter was later modified (POW=0x45,
IDIVK=0x24 added after the decode RE), so the green result no longer applied to the shipped binary. Re-ran the
full suite against the CURRENT build: **10/10 modules PASS** (DATA, ARITH, CMP, TABLE, LOOP, FUNC, EXTRA, ORD, VA,
POW). Corpus round-trip 5382/5382 byte-exact; 0 unmapped ops over a 250-file real-source sample.
LESSON: a cert result is only valid for the exact binary it ran against. Any emitter change invalidates it.

Remaining Luau ops NOT handled, each proven unreachable rather than assumed:
  * **IDIV (reg-reg `a//b`)** — `//` occurs ZERO times as an OPERATOR in the whole corpus. (A grep suggested 10
    files, but all 45 matches were URLs inside string literals, e.g. "https://warframe.com/...". DE's Luau v9
    predates IDIV.)  Hard-errors safely if hand-written.
  * **JUMPX** — needs a jump offset > ±32767 words; the LARGEST proto in the corpus is 17520 words
    (Lotus_Interface_Settings), so it can never trigger.
  * NATIVECALL / GETUDATAKS / SETUDATAKS / NAMECALLUDATA / NEWCLASSMEMBER / CMPPROTO / BREAK — stock
    luau-compile never emits these for plain Lua source.
=> M1-M4 DONE. Decode map complete for all 77 corpus opcodes. Next: M5 (corpus parity sweep), then M6 (C++ decompiler).

## 2026-07-25 — CORRECTNESS BUG: nil comparison after SETUPVAL (found by an in-game pipeline test)

Hypothesis: the cert suite (10/10 green, 59/59 opcode coverage, 5382/5382 byte-exact round-trip) means the
transcoder is correct.
Finding: **False.** A real correctness bug survived all of it.

SYMPTOM: `x == nil` / `x ~= nil` returned the WRONG answer when x had been assigned nil by a closure
(SETUPVAL). `type(x)` and `tostring(x)` both reported nil, yet every equality form disagreed.

ROOT CAUSE: we LOWERED Luau's JUMPXEQKNIL to `LOADNIL scratch` + reg-reg fused compare (0x20/0x27). Those
compares are TAG-sensitive. A value written through SETUPVAL does not carry the same tag as a freshly
LOADNIL'd register, so the comparison failed even though the value is semantically nil.

FIX (corpus-derived, not guessed): **DE has a dedicated nil-compare opcode `0x3a`**, with the polarity in
aux bit31 — the SAME encoding Luau's JUMPXEQKNIL uses, so aux passes through VERBATIM.
  corpus: `p2 == nil` -> `0x3a A=0 aux=0x80000000` ; `_T[..] ~= nil` -> `0x3a A=3 aux=0x00000000`
JUMPXEQKNIL is now mapped natively to 0x3a and removed from the generic JUMPXEQK lowering. Verified in-game
5/5 (direct, via-closure, vs-nil-local, truthiness, capture-read-only). Regressions clean.

WHY THE SUITE MISSED IT (the important part):
  * Every cert check used `if cond then else error() end`, which only ever emits the jump-if-NOT compare
    forms. The plain (jump-if-TRUE) forms appear only in `x ~= nil` / `x ~= k`, which nothing exercised.
  * `c_func` captured `acc` but only ever observed it via `bump()`'s RETURN VALUE — never read/compared the
    captured variable directly, so the broken path was never touched.
  * => **Opcode COVERAGE is not behavioural coverage.** The suite proved every opcode gets EMITTED, not that
    each is exercised in BOTH polarities with DISCRIMINATING values. Same class as the earlier 0x21/0x23 swap.
New cert module `cert/v9/c_nil.luau` closes both gaps (SETUPVAL-written nils + jump-if-TRUE polarities).

PROCESS NOTE: three hypotheses (JUMPIFEQ 0x20 wrong; DE boxes REF-captured registers; scratch-register
collision) were each DISPROVED by a probe within one round, and a MOVE-normalisation fix also failed. What
finally worked was reading DE's own codegen out of the corpus for the exact source construct. Guessing at a
cause cost ~5 F9 cycles; correlating with the corpus cost one.

## 2026-07-25 — M6b: CFG construction (100% of corpus)

`derecomp de-cfg <dir>` builds basic blocks from the index-resolved instruction IR (the one proven lossless
in M5). Leaders = entry + every branch target + every instruction after a branch. Edges = branch-taken +
fallthrough (suppressed after JUMP 0x40 / JUMPBACK 0x25 / RETURN 0x29). Self-validating: an edge that did not
land on a block START, or a fallthrough into a non-leader, is a hard error.

RESULT over the whole cache: **82042/82042 protos (100.0000%) form a well-formed CFG, 0 build errors.**
  820,321 basic blocks (avg 10.0/proto) | 1,131,910 edges | 44,678 back-edges (loops)
This independently corroborates the branch model (op+4 base, widths, branch classification) across 1.13M edges.

OPEN: 1,090 unreachable blocks across 982 protos (1.2%). Expected causes are benign (dead code after RETURN,
`while true` with no exit edge), but this is NOT yet verified — unreachable blocks would silently disappear
from decompiled output, so classify them before M6c.
Also passed: full 11-module cert suite 11/11 (incl. the new c_nil module), round-trip 5382/5382 byte-exact,
recode 82042/82042 lossless.

## 2026-07-25 — v10 BEHAVIOURAL MATRIX: found JUMPIFEQ (2nd correctness bug in one session)

Built `cert/gen_v10.py`, a GENERATOR that emits a combinatorial behavioural matrix (6 modules, 133
assertions) instead of hand-written cases: every operator x both polarities x boundary values x
reg/const operands x captured/uncaptured x discriminating values (nil/false/0/""/negatives).

FIRST RUN: 5/6 modules passed. The failure was `C_eq_eq` = `(a == c) == true` with a==c==3 — i.e. the
**value-producing** equality form (store the comparison, don't branch on it). It returned FALSE for equal
values.

ROOT CAUSE: **JUMPIFEQ was 0x20, which is NOT a reg-reg equality op at all.** The corpus dispatches
const-compares BY CONSTANT TYPE: 0x20 = number-const (aux bit31 + const idx), 0x41 = string-const,
0x3a = nil. Handing 0x20 a REGISTER index in aux makes it compare against an arbitrary constant -> it never
matches. That is exactly the "0x20/0x3a are tag-only and never jump" note from the very start of the project.
FIX: **JUMPIFEQ = 0x37** (corpus: 0x37 appears with aux=REGISTER in value-producing position x44).
Calibrated with a harness that uses ONLY truthiness, so the harness cannot be the thing under test:
  K37=ok | K20=never_jumps | K34=never_jumps | K41=never_jumps.
Applied to OPMAP and to the JUMPXEQK lowering (which uses 0x37/0x27 for the EQ/NOTEQ senses).
RESULT: v10 matrix 6/6 (133/133 assertions). Round-trip 5382/5382, recode 82042/82042 unchanged.

TWO METHODOLOGICAL ERRORS I MADE (worth more than the bug):
 1. **I "calibrated" JUMPIFEQ earlier today and declared all four candidates correct.** That test was
    worthless: it drove `==` through the JUMPXEQK lowering, which uses 0x27 — the 0x20 path never ran.
    A calibration that does not exercise the code path proves nothing.
 2. **I tested a suspect construct WITH a suspect construct**: the first JE harness used `y ~= true`
    (a boolean-const compare, itself broken) to check comparison results, and used last-failure-wins
    reporting so 4 checks collapsed into 1 uninformative tag. Harnesses must use only PROVEN primitives.
KNOWN DIVERGENCE (recorded, not a bug): we lower all const-compares to LOADK+reg-reg 0x37/0x27 rather than
DE's native per-type forms (0x20 number / 0x41 string / 0x3a nil). Semantically correct and verified, but the
M6 DECOMPILER must still READ those native forms.

## 2026-07-25 — UNREACHABLE-BLOCK AUDIT: decode map cleared, but the CFG has a real defect

**Hypothesis:** the 1,090 unreachable CFG blocks (982 protos, 1.2%) are benign compiler dead code,
not evidence that our opcode decode map mis-models control flow.

### The trap, and how it was avoided
The raw "preceding instruction" histogram looked ALARMING — 32 dead blocks followed ops that MUST fall
through (CALL 7, JUMPIF 6, SETFIELD 2, SETUPVAL 2, ...). That histogram is CONTAMINATED by cascade:
a dead block preceded by dead code says nothing. Splitting ROOT (predecessor block reachable) from
CASCADE changed the picture completely:
    ROOT = 1046, and **every single root is preceded by an unconditional jump** (JUMPBACK 799, JUMP 247).
    CASCADE = 44  <- all 32 "alarming" cases live here.
**ZERO roots follow a fall-through op.** Dead code exists only where dead code CAN exist.
(I made the identical contamination mistake twice more while writing the audit itself — T1 and T2 below
both fired until I conditioned them on the *branching* instruction being reachable. Same bug class as
the "last-failure-wins" harness from the JUMPIFEQ hunt. Always ask whether the SOURCE is live.)

### Falsification tests (`derecomp de-deadaudit`) — designed to break the verdict, all passed
| test | result |
|---|---|
| T1 does any branch **from live code** target a block we called dead? | **0** |
| T2 do the unmodelled skip-offsets (LOADB C!=0, FASTCALL C) reach dead blocks from live code? | **0** |
| T2b do FASTCALL implied targets land on instruction boundaries? | **165,600 / 165,600** |
| T3 does JUMPBACK 0x25 ever jump forward? | **0 / 15,678** (always backwards) |
| T4 does any proto end on an unconditional jump? | **0** |

T2b is a bonus result: it independently CONFIRMS the FASTCALL `C` encoding is
`target_byte = insn_off + 4 + C*4` (C counts 4-byte words, matching upstream Luau's word-wise pc).

### Upstream-compiler oracle — 4 of 4 top shapes reproduced by STOCK Luau
Compiled hand-written Luau with `bin/luau-compile.exe` (the real upstream compiler) and got the same
dead-code shapes, proving they are ordinary compiler output, not decoder artifacts:
| corpus shape | count | reproduced by |
|---|---:|---|
| `JUMPBACK -> [RETURN]` | 543 | `while true do f() end` at end of function -> dead trailing implicit RETURN |
| `JUMP -> [JUMP]` | 225 | if/else in a loop, one arm `return`, other `break` -> dead join-jump |
| `JUMPBACK -> [JUMP]` | 213 | same family, inside an infinite loop |
| `JUMP/JUMPBACK -> [FORNLOOP]` | ~9 | `for i=1,10 do while true do g() end end` -> dead FORNLOOP |
Also confirmed real *source-level* dead code: `Lotus_Levels_1999_AA1999CarGym_PatrolScript` p0 is
`while true do ...patrol... end` followed by cleanup statements a DE developer wrote that can never run
(insns 38..44: LOADB/NAMECALL/CALL/GETIMPORT/LOADK/CALL/RETURN). That accounts for the 135
side-effecting dead instructions and the 53 dead blocks of >=4 instructions. 0 dead NEWCLOSURE/DUPCLOSURE.

### Finding
**Partially true.** BENIGN on the question asked — the decode map is NOT indicted, and 100% of root
dead blocks are explained. But the audit found a **separate, real CFG defect**:

**T6 — `build_cfg` does not create a leader after RETURN.** RETURN is correctly denied a fallthrough
edge when it *terminates* a block, but a RETURN in the MIDDLE of a block leaves the instructions after
it marked reachable when they are not. Measured: **501 dead instructions in 387 protos are counted
live.** The true dead-instruction count is 1418 + 501 = **1,919**, not 1,418. Found only because
hand-tracing the stock-Luau `o8` output showed `LOADB/RETURN/JUMP` sharing one block.

### What changed
1090 unreachable blocks are explained and the decode map is cleared. The headline dead-code number is
wrong (undercount) and `build_cfg` needs a one-line fix. Numbers unaffected: CFG built cleanly
82042/82042, de-recode 82042/82042, round-trip 5382/5382.

### Next step
Add `RETURN` to the leader-making set in `build_cfg`, re-baseline the CFG numbers, then M6c.

### FOLLOW-UP (same day): T6 fixed, numbers re-baselined — and my own estimate was too low

Added RETURN to the leader-making set in `build_cfg` (one line). Re-baseline:

| metric | before | after |
|---|---:|---:|
| basic blocks | 820,321 | **820,789** |
| edges | 1,131,910 | 1,131,910 *(unchanged — no new edges, only new boundaries)* |
| unreachable blocks | 1,090 | **1,607** |
| protos with dead code | 982 | **1,343** |
| dead instructions | 1,418 | **2,235** |

**I predicted 1,919 and was wrong — the real figure is 2,235.** My T6 probe `break`s after the FIRST
mid-block RETURN, so blocks with several RETURNs were undercounted, and splitting at RETURN then
exposes further whole blocks downstream. The 501 figure was a LOWER BOUND, not the answer. Recording
this because "measured undercount" was itself an undercount, which is the exact failure mode this
project keeps hitting.

**The classification survives its own correction** — that is the real test:
    ROOT = 1514, predecessors JUMPBACK 799 / RETURN 470 / JUMP 245 — all three non-fall-through.
    **Still ZERO roots following a fall-through op.** CASCADE = 93.
T1/T2/T3/T4 all still pass against the LARGER dead set, and T6 is now 0.

**Emission is byte-for-byte unaffected** (de-recode 82042/82042 lossless, round-trip 5382/5382
byte-exact). This was a read-side model fix only, so there is nothing an in-game F9 test could confirm
or refute — verified offline, deliberately not deployed.

## 2026-07-25 — M6a ANNOTATED IR: 100.0000%, and it found a wrong opcode on its first run

**Hypothesis:** every operand in the corpus can be resolved offline — constants materialised,
name-hashes looked up, import ids expanded to dotted paths, branch offsets turned into indices.

**Built:** `src/ir.h` (read-only; deliberately separate from the byte-exact writer so it cannot
perturb the 5382/5382 round-trip) + `derecomp ir <file> [proto]` and `derecomp ir-validate <dir>`.

### Result
```
files=5382 protos=82042 instructions=5529086
  instructions fully annotated : 5529086  (100.0000%)   unresolved operands: 0
  constants resolved           : 1622341 / 1622341 (100.0000%)
  import paths expanded        :  326014 /  326014 (100.0000%)
  name-hashes with a real name :  632534 /  695590 (90.93%)   rest = lossless Name__aabbccdd
```
Regressions all unchanged: round-trip 5382/5382 byte-exact, de-recode lossless, de-validate 0
violations / 5,529,086, CFG 82042/82042.

### TWO wrong assumptions of mine, both caught by the validator (not by inspection)
1. **Import path components are tag-1 FNV name-hashes, not tag-3 strings.** DE substitutes hashes for
   import name strings. My first run rendered `<import 40000000?>` for every import in the corpus.
   Fixed by accepting Str *or* NameHash (both carry text in `.str`) -> 326,014/326,014.
2. **`0x34` is NOT a const-index compare.** It was documented as one (alongside `0x3a`/`0x41`). It is
   `JUMPXEQKB`: **`aux & 1` IS the boolean value**, there is no const index. Proven with a new tool,
   `derecomp de-auxhist <dir> <op>`, which histograms an opcode's aux payload:
   | op | instances | distinct low-aux values | aux >= nconsts |
   |---|---:|---:|---:|
   | `0x34` | 2,591 | **2** (`{0,1}`) | **20** |
   | `0x20` | 19,213 | 64+ | 0 |
   | `0x41` | 5,519 | 64+ | 0 |
   | `0x3a` | 19,571 | **1** (`{0}`) | 0* |
   A const index spreads and never goes out of range; an immediate is confined to a tiny set. The 20
   out-of-range cases are protos with <=1 const, where the boolean happened not to alias a valid index
   — i.e. this bug was *invisible* in any proto with 2+ constants. (*the 62 "oob" for 0x3a are protos
   with zero constants, consistent with aux always being 0.)

### Finding
**True**, after two corrections. 100.0000% of 5,529,086 instructions annotate with zero unresolved
operands, and the run produced a genuine decode-map fix as a side effect.

### Why this matters beyond the number
Every earlier metric (round-trip, recode, de-validate, CFG) was **structural** — they check that bytes
survive and that operands are in range. None of them can notice that `aux` is being *interpreted*
wrongly, because a bogus const index is still a valid index. M6a is the first metric that forces us to
say what each operand MEANS, which is why it found `0x34` immediately. Semantic checks catch what
structural checks cannot.

### Next step
M6c: expression reconstruction (build expression trees over the annotated IR + CFG).

## 2026-07-25 — SYSTEMATIC BUG HUNT: generalised the 0x34 bug into three audits, found one more

The `0x34` bug had a *class*: an operand can be INTERPRETED wrongly while remaining structurally
valid, so no range check can see it. Three new corpus-wide audits generalise it.

### 1. `derecomp de-fieldaudit <dir>` — does each field behave like what we claim?
Sweeps every (opcode, field) pair and compares its empirical distribution against our decode model.
Discriminators: `%>=maxstack` (a register can't exceed the stack), `%>=nconsts` (a const index can't
exceed the const count), `distinct` (an immediate is confined, an index spreads).
**2 suspects, both resolved:**
- `0x0c FASTCALL2K` aux — unmodelled, 0% out of const range over 2,671 uses, 174 distinct. TRUE
  POSITIVE and benign: upstream Luau's FASTCALL2K aux IS the 2nd argument's const index. We skip the
  whole FASTCALL family (the real GETIMPORT+CALL slow path follows), so nothing is lost. Now modelled
  in `de-ktags` for completeness.
- `0x24 IDIVK` field C — flagged "only 4 distinct values, looks like an immediate". **FALSE POSITIVE
  from my own threshold: IDIVK has n=5 in the entire corpus.** I wrote the rule without a minimum-n
  guard. Real residual risk though: **our IDIVK model rests on 5 examples corpus-wide.**

### 2. `derecomp de-ktags <dir>` — what KIND of constant does each op reference?
Range checks prove an index is in bounds; this asks what it points AT. **0 suspects:**
all 9 arithmetic-with-constant ops -> 100% numbers (incl. IDIVK's 5); `NAMECALL` -> 100% namehash
(468,528); `GETIMPORT` -> 100% import (690,210); `DUPCLOSURE` -> 100% closure (45,166); `DUPTABLE` ->
100% table templates; `SETFIELD` -> 100% string. Independently reconfirms **`0x20` is the NUMBER-const
compare (100% numbers)** — which is exactly why it never worked as reg-reg equality.

### 3. NEW BUG — `derecomp de-tag1audit <dir>`: **DE's const tag 1 is OVERLOADED**
`ANDK` was seen referencing a tag-1 const whose payload is literally `1`, and the corpus's only two
sub-256 "unresolvable hashes" are `0x00000000` and `0x00000001` — the signature of false/true.
Upstream Luau's tag 1 is **BOOLEAN**; DE reused the same tag for 4-byte FNV name hashes (round-trip
proves the payload is 4 bytes, not 1) and **disambiguates BY POSITION**:

| position | tag-1 refs | payload 0 or 1 | payload > 1 |
|---|---:|---:|---:|
| NAME (NAMECALL, field, global, import path) | 1,263,066 | **0** | 1,263,066 |
| VALUE (LOADK, ANDK) | 42 | **42** | **0** |

Perfect bimodal separation over 1.26M references. **Impact:** we rendered `true`/`false` as
`Name__00000001` / `Name__00000000`. That is not cosmetic — emitted as source, `x and Name__00000001`
reads a nil global instead of `true`, so it would have produced WRONG recompiled code at M6e.
Fixed via `ir::value_text()`, applied at every value position (LOADK / arith-K / SUBRK / DIVRK).
Bonus: 2 of the 14,563 "unresolved name hashes" were never names, so that count is very slightly
overstated.

### Post-fix state (all re-verified)
IR 5,529,086/5,529,086 annotated (100.0000%); constants 1,622,341/1,622,341; de-ktags 0 suspects;
de-recode lossless; round-trip 5382/5382 byte-exact.

### Finding
**Partially true** — the hunt was worth doing. One genuine correctness bug (tag-1 overload), one true
positive that is benign (FASTCALL2K aux), one false positive from a badly-written rule of mine, and
one quantified residual risk (IDIVK, n=5).

### Residual risk, explicitly NOT closed
- **`0x24 IDIVK`: 5 instances corpus-wide.** Tag audit says all 5 reference numbers, which is
  consistent, but 5 samples cannot distinguish `//` from a near neighbour. UNCONFIRMED.
- **`0x08 POWK` (132), `0x31 ANDK` (22), `0x3b DIVRK` (590), `0x06 SUBRK` (2,489)** are all
  low-frequency and rest on correspondingly thin evidence.
- The audits check operand *semantics*, not opcode *behaviour*. An op that reads the right constant
  and still computes the wrong thing would pass all three. Only the in-game cert can catch that.

## 2026-07-25 — RESIDUAL RISKS CLEARED IN-GAME (cert v11) + a bug found while clearing them

The user declined to move to M6c with an open risk list. That was the right call: working the list
turned up a real emission bug that every prior cert had missed.

### The bug: BOOLEAN CONSTANTS COULD NOT BE COMPILED AT ALL
`transcode_consts` handled Luau const tags NIL/NUM/INT/IMPORT/VEC/CLOSURE/TABLE/TABLEK/STR — but NOT
`C_BOOL`, which fell through to `default: throw`. So **any script containing `{ flag = true }`
hard-failed to recompile.** That is one of the commonest shapes in real game scripts, and no cert had
ever used one (they all built booleans with LOADB via comparisons, never as a table VALUE).
Found by chasing "why does ANDK reference 100% name-hashes?" -> tag-1 overload -> apply to the emitter.
Fix: `case luau::C_BOOL: d.tag = 1; d.raw = pack_u32(c.bval ? 1 : 0);` — using exactly the overload
proven by `de-tag1audit`. Fails safe either way: it threw, exit 1, no file written.

### In-game verdict (F9, 2 new modules, VALUE-reporting not pass/fail)
```
V11_THIN idivk=3 powk=1024 subrk=6 divrk=2.5 pow=1024
V11_BOOL on=true off=false n=3
```
Every operand was chosen so each RIVAL opcode yields a different number:
| op | corpus n | got | would have been |
|---|---:|---:|---|
| `IDIVK 0x24` | **5** | **3** | MODK->1, DIVK->3.5, MULK->14, SUBK->5 |
| `POWK 0x08` | 132 | **1024** | MULK->20, ADDK->12, MODK->2 |
| `SUBRK 0x06` | 2,489 | **6** | operands reversed -> -6 |
| `DIVRK 0x3b` | 590 | **2.5** | operands reversed -> 0.4 |
| `POW 0x45` reg-reg | — | **1024** | |
| boolean const (new) | — | `on=true off=false` | threw before today |
Before deploying I confirmed with `histops` that all five opcodes are actually PRESENT in the emitted
bytecode, one each — my earlier JUMPIFEQ calibration failed precisely by testing a path that never ran.

### Also closed offline
Reg-reg `IDIV` (no DE mapping) hard-errors: message printed, **exit 1, no output file written**. It
cannot silently miscompile.

### STILL OPEN — not closable, stated plainly
- **`ANDK 0x31` (n=22): cannot be certified in-game, ever.** We LOWER AND/ANDK to MOVE+JUMPIF, so we
  never emit `0x31`; nothing we can compile will exercise it. It is DECODE-only. Evidence is offline
  consistency alone: 100% of its K refs are tag-1 booleans, matching `x and true/false`.
- **Semantics != behaviour for every decode-only op.** The three audits check what an operand POINTS
  AT, never what the op COMPUTES. In-game closes this only for ops we emit.
- **Table-template values still render as `Name__00000001`** — a tag-1 boolean inside a DUPTABLE
  template has no operand position to disambiguate it. Cosmetic today; **must be fixed for M6e**, or
  reconstructed table constructors will emit a nil global instead of `true`.
- Const-compare divergence (we lower to `LOADK`+reg-reg rather than native `0x20`/`0x41`/`0x3a`):
  verified working, but the M6 decompiler must still READ the native forms.
- Every cert is valid only for the binary it ran against.

### Finding
**True** — all in-game-closable risks are closed, with the exact predicted values. Cert suite is now
**19 modules** (11 v9 + 6 v10 + 2 v11).

## 2026-07-25 — BOTH "UNFIXABLE" ITEMS FIXED. I was wrong about both.

I closed the previous session by declaring one item a "permanent gap" and another a "cosmetic" M6e
task. The user asked whether either could actually be fixed. Both could, and neither claim survived
five minutes of looking.

### #7 table-template booleans — CLOSED OFFLINE, no game needed
I claimed "a table template gives no operand position to disambiguate a tag-1 boolean." **I had not
read the parser.** A tag-8 template entry is `(key const index, 4-byte payload)` and the payload IS
the VALUE's const index — so a template provides a perfectly good value position.
Verified against known ground truth, then on real corpus data:
```
source :  { on = true, off = false, n = 3 }
IR     :  k[6] { on = true, off = false, n = 3 }
corpus :  { ShowInMarket = false, ..., UsePremium = false, UsePrice = 0, ... }   <- real shipped booleans
```
Bonus structural finding: payload **0xFFFFFFFF is a "no constant value" sentinel** — the key is
pre-allocated by DUPTABLE and the value is assigned at runtime by a later SETFIELD.
**62,347 template entries expanded, 17,834 sentinels, ZERO other out-of-range payloads.** That is
proven rather than assumed: any other bad payload marks its const unresolved, and constant resolution
is still 1,622,341/1,622,341 (100%).

### #4 ANDK 0x31 — CERTIFIED IN-GAME. "Permanent gap" was self-inflicted.
I claimed 0x31 "can never be certified in-game because we lower AND/ANDK, so no source we can compile
emits it." That is true only because **WE CHOSE to lower it** — our decision, not a constraint.
Added `RENOVICE_NATIVE_ANDK=1`, which emits the native opcode purely so a cert can reach it. Default
path still lowers (verified: 0x31 count = 0 with the knob off), so production output is unchanged.
```
V11_ANDK t_and_t=true t_and_f=false f_and_t=false n_and_t=nil num_and_t=true
```
All five correct for `R[A] = R[B] and K[C]`. The discriminators are `f_and_t=false` and `n_and_t=nil`
— Lua's `and` returns the LEFT operand when falsey; an op that merely returned `K[C]` would have given
`true`/`true`. **0x31 is now certified, not inferred from 22 corpus instances.** No crash: the first
opcode we have ever emitted that we had only ever decoded.

### THE GENERALISATION — this technique unlocks 18 opcodes
Every op we currently LOWER or skip is untestable *only* because we never emit it. A native-emission
knob fixes that for any of them. Current decode-only set (in real scripts, never emitted by us):

| op | name | corpus n | | op | name | corpus n |
|---|---|---:|---|---|---|---:|
| 0x19 | FASTCALL1 | 140,927 | | 0x0c | FASTCALL2K | 2,671 |
| 0x17 | GETGLOBAL | 22,464 | | 0x34 | JUMPXEQKB | 2,591 |
| 0x3a | JUMPXEQKNIL | 19,571 | | 0x0b | FORGPREP? | 1,219 |
| 0x20 | JUMPXEQKN | 19,213 | | 0x51 | TESTSET | 948 |
| 0x25 | JUMPBACK | 15,678 | | 0x4a | FASTCALLX | 546 |
| 0x26 | FASTCALL2 | 15,115 | | 0x2b | OR | 282 |
| 0x3e | SUBK | 7,771 | | 0x2f | AND | 125 |
| 0x10 | FASTCALL | 6,364 | | 0x31 | ANDK | **CERTIFIED** |
| 0x41 | JUMPXEQKS | 5,519 | | 0x00 | MODR | 2 |

**18 opcodes / 261,028 corpus instructions rest on inference alone.** They are what the M6 decompiler
must READ, so their meanings matter as much as the ones we emit. `0x0b FORGPREP?` still has a literal
question mark in its name.

### Finding
**False** — both of my "can't fix" claims were wrong, and the second was wrong in an instructive way:
I mistook a decision we had made for a law of nature. Worth watching for: "we can't test X" often
means "we haven't chosen to make X reachable."

### Next step
Optional but high value: extend the knob technique to the remaining 17 decode-only opcodes and certify
them in one or two F9 rounds, BEFORE M6c builds expression reconstruction on top of them.

## 2026-07-25 — DECODE-ONLY OPCODES CERTIFIED (cert v12): 7 more, 4/4 PASS

Applying the native-emission technique to the ops the M6 decompiler must READ but that we never emit.
```
V12_ANDOR t_and=5 f_and=false n_and=nil t_or=true f_or=6 n_or=6
V12_SUBK  subk=7 subk2=-15
V12_CMPK  n_eq=true n_ne=false n_no=false s_eq=true s_no=false b_eq=true b_no=false
V12_JBACK sum=15 guard=3
```
| op | corpus n | certified meaning | discriminator used |
|---|---:|---|---|
| `AND 0x2f` | 125 | `R[A]=R[B] and R[C]`, returns an OPERAND | `f_and=false`, `n_and=nil` (LEFT operand, not a bool) |
| `OR 0x2b` | 282 | `R[A]=R[B] or R[C]` | `f_or=6`, `n_or=6` (RIGHT operand) |
| `SUBK 0x3e` | 7,771 | `R[A]=R[B]-K[C]` | `7` and `-15`; reversed operands give `-7`/`+15` |
| `JUMPXEQKN 0x20` | 19,213 | compare vs NUMBER const | `n_eq/n_ne/n_no` = true/false/false |
| `JUMPXEQKS 0x41` | 5,519 | compare vs STRING const | `s_eq/s_no` = true/false |
| `JUMPXEQKB 0x34` | 2,591 | compare vs BOOLEAN IMMEDIATE | `b_eq/b_no` = true/false |
| `JUMPBACK 0x25` | 15,678 | unconditional BACK jump | loop terminates: `sum=15`, `guard=3` |

**`0x34` closes a loop opened this morning.** M6a's validator proved from the corpus that 0x34 carries a
boolean immediate rather than a const index; `b_eq=true b_no=false` now confirms that against the VM.
Likewise `0x20` behaving as the NUMBER-const compare is exactly why it never worked as reg-reg equality.
And `0x25` being a true unconditional back-jump retroactively supports the dead-code audit, which
assumed precisely that when classifying 799 root dead blocks.

Method, unchanged and non-negotiable: `histops` must show each target byte PRESENT in the built module,
and ZERO present with the knob off. Both verified before deploying.

### Running tally — 10 of 18 decode-only opcodes now certified
Certified: `0x31 ANDK`, `0x2f AND`, `0x2b OR`, `0x3e SUBK`, `0x20`, `0x41`, `0x34`, `0x25 JUMPBACK`,
plus `0x17 GETGLOBAL` (earlier) and `0x3a JUMPXEQKNIL` (already emitted natively).

Remaining 8, and why:
- **FASTCALL x5 (165,623 instrs) — DELIBERATELY NOT CERTIFIED.** The decompiler skips them entirely
  (the real GETIMPORT+CALL slow path follows), so their semantics cannot affect M6 output. Emitting
  them would also require recomputing the `C` skip-offset in DE instruction space, since DE widths
  differ from Luau's. Real work and real risk for zero benefit. A judgement, not an oversight.
- **`TESTSET 0x51` (948) and `MODR 0x00` (2) — UNREACHABLE from Luau source.** Luau dropped TESTSET
  (a Lua 5.1 op) and has no reversed-operand MOD, so no source we can compile emits them. Certifying
  these needs hand-assembled bytecode — a different technique, not this one.
- **`FORGPREP? 0x0b` (1,219) — held back on purpose.** The only op whose name still carries a question
  mark, and it affects loop reconstruction. Testing it means substituting a guess into a loop-prep
  position where being wrong plausibly crashes, so it was kept out of this batch to avoid invalidating
  the other four results.

**Excluding the FASTCALL family, only 2,169 instructions (0.04% of the corpus) still rest on inference.**

### Finding
**True.** All 7 targeted opcodes behave exactly as the decode map claims.

### Process note — I repeated a known mistake
While adding the JUMPBACK knob I appended a `//` comment to a table line and swallowed the rest of it,
**commenting out `{"JUMPIF",0x4b},{"JUMPIFNOT",0x18}`**. This is the SECOND time this exact error has
happened in this project (the first killed a GETUPVAL entry). Caught on read-back, fixed, and the v10
matrix + full round-trip were re-run to confirm. Rule: never append a trailing comment to a line that
continues; put it on its own line above.

## 2026-07-25 — TWO MISLABELLED OPCODES FOUND BY BYTECODE SURGERY (cert v14/v15)

`TESTSET 0x51` and `MODR 0x00` cannot be reached by compiling Luau — upstream dropped TESTSET (a Lua
5.1 op) and has no reversed-operand MOD — so the native-emission knob had nothing to switch on. Built
`derecomp de-patchop <in> <out> <proto> <findop> <nth> <newop> [A B C]`: emit a CARRIER instruction
with the same operand layout, rewrite one opcode byte, re-encode byte-exactly. It REFUSES a patch when
the two ops differ in width (verified), since that would shift everything after it.

### `0x00` is reg-reg **IDIV**, not MODR — a DOUBLE error
`V14_MODR r=3` for operands 17 and 5. Discriminators: MUL 85 / MOD 2 / MOD-swapped 5 / DIV 3.4 /
ADD 22 / SUB 12 / **IDIV 3**. Two independent things were wrong at once:
1. the decode map called it `MODR` (`R[C]%R[B]`);
2. we ALSO declared reg-reg `IDIV` "unmapped, no DE byte exists", so `a // b` hard-errored on compile.
It is simply the reg-reg partner of `IDIVK 0x24`, sitting in the corpus mislabelled. **Third time** an
op was declared unsupportable and turned out to be present-but-mislabelled (after reg-reg POW and
IDIVK). `{"IDIV",0x00}` is now mapped and `a // b` compiles.

### `0x51` is **ORK** (`R[A] = R[B] or K[C]`), not TESTSET
First probe DIED SILENTLY — no output, no error, no load record, while every other module ran.
**That failure was mine, not the game's.** I patched a MOVE and set `C=0` as a Lua-5.1-style boolean
flag, but `C` is a CONST INDEX and the probe's proto had **zero constants**, so it indexed an empty
table.

A two-module BISECT localised it without guessing:
| module | result | conclusion |
|---|---|---|
| `V15_CTRL` (same source, UNPATCHED) | reported | carrier + harness are fine |
| `V15_REACH` (patched, but proto never CALLED) | reported | the patched module LOADS fine |
=> failure is at EXECUTION, not load => the OPERANDS were wrong, not the tool.

`de-fieldaudit` then showed `0x51`'s C is a const index (110 distinct, max 250, **38.5% exceed
maxstack but 0% exceed nconsts** — identical to ADDK's C), and `de-ktags` showed those constants are
MIXED (number 70.4%, string 19.7%, namehash 8.1%, nil 1.8%) = a DEFAULT VALUE, not an arithmetic
operand. That is ORK, the partner of `ANDK 0x31` (and 948 vs 22 instances matches how common
`x or default` is versus `x and true`).
Re-probed with an **ADDK carrier**, which already holds a valid const index in a proto that has the
constant: `V15_ORK t=7 f=5 n=5` — truthy returns the LEFT operand, false and nil both return `K[C]`.
Exactly ORK. `TESTSET` was never plausible: upstream Luau does not have the op at all.

### Post-fix, all re-verified
round-trip 5382/5382 byte-exact | de-recode LOSSLESS | de-validate 0 violations / 5,529,086 |
IR 5,529,086/5,529,086 (100.0000%) | constants 1,622,341/1,622,341 | de-ktags 0 suspects |
CFG 82042/82042. `0x51`'s 948 constant references are now annotated by the IR for the first time.

### Finding
**False** on both labels. Two opcodes were misnamed in the decode map, and one of them had ALSO been
declared nonexistent.

### Lesson
`de-fieldaudit` had ALREADY flagged the answer — it printed `0x51 C ... 38.50% >= maxstack, 0.00% >=
nconsts, model=-` in the very first sweep. I read that table looking only at ops the model CLAIMED
something about, and skipped the unmodelled ones. **An "unmodelled" field with a clean const-index
signature is a finding, not a blank.**

## 2026-07-25 — FASTCALL FAMILY: SKIPPABILITY PROVEN OVER THE WHOLE CORPUS (18/18 closed)

The last 5 uncertified opcodes were the FASTCALL family (165,605 instructions). I had twice said they
were "not worth certifying — the decompiler ignores them". That framing was WRONG, and the user
pushing back on it exposed a real risk: **M6 DROPS 0x19/0x26/0x10/0x0c/0x4a.** If any of those is not
actually a FASTCALL, the decompiler silently DELETES REAL CODE and emits plausible wrong source. The
question was never "are they worth emitting" — it was "is dropping them safe", which is decidable.

### `derecomp de-fastcall <dir>` — a structural proof, stronger than a probe
A genuine FASTCALL is defined by where its skip offset lands: the span it jumps over IS the call
setup. So test `target = off + 4 + C*4` against the instruction at the landing site.

```
0x0c FASTCALL2K   n=2671     target IS a CALL: 2671   (100.0000%)
0x10 FASTCALL     n=6364     target IS a CALL: 6364   (100.0000%)
0x19 FASTCALL1    n=140909   target IS a CALL: 140909 (100.0000%)
0x26 FASTCALL2    n=15115    target IS a CALL: 15115  (100.0000%)
0x4a FASTCALLX    n=546      target IS a CALL: 546    (100.0000%)
total 165,605 / 165,605   off-boundary 0   backwards 0   C==0 0
VERDICT: every FASTCALL skips exactly a call sequence -> DROPPING THEM IS PROVABLY SAFE
```
This is *better* than an in-game cert for this property: a probe samples a handful of cases, whereas
this covers every instance in the corpus. It also re-confirms the `off + 4 + C*4` encoding.

### I got the structure wrong first, and the test caught me
My first run reported **0 / 165,605** and printed "the decompiler may be deleting real code". The
opcodes were fine — my model was off by one. I asserted the target lands ONE PAST the CALL; it lands
exactly ON the CALL (hand-checked: AnchorMgr p5 `FASTCALL1 C=2`, `GETIMPORT` 8B = 2 words, `CALL`).
Worth noting the failure mode: had I written the test to be lenient, it would have passed for the
wrong reason. A test that fails loudly on a wrong hypothesis is doing its job.

### ALL 18 DECODE-ONLY OPCODES ARE NOW CLOSED
Certified in-game (13): `0x00 IDIV`, `0x0b FORGPREP`, `0x17 GETGLOBAL`, `0x20 JUMPXEQKN`,
`0x25 JUMPBACK`, `0x2b OR`, `0x2f AND`, `0x31 ANDK`, `0x34 JUMPXEQKB`, `0x3a JUMPXEQKNIL`,
`0x3e SUBK`, `0x41 JUMPXEQKS`, `0x51 ORK`.
Proven structurally corpus-wide (5): the FASTCALL family.

**Every opcode M6 depends on is now verified — nothing rests on inference.**
Two of the 18 were MISNAMED (`0x51` TESTSET->ORK, `0x00` MODR->IDIV) and one was UNNAMED
(`0x0b` "FORGPREP?" -> generic FORGPREP, and our emitter had been using the pairs-specialised `0x30`
for generic iterators). None of that would have surfaced without working the list.

### Finding
**True**, after correcting my own off-by-one. 165,605/165,605.

## 2026-07-25 — FULL-SUITE REGRESSION: 27/27, and the opcode map is CLOSED

`cert/rebuild_all.sh` rebuilds all 27 cert modules from source with the current binary/map (applying
the native-emission knobs and bytecode patches), deploys them, and one F9 runs everything.

**Result: 27/27, every value exact, zero failures, zero unexpected tags.**

This mattered because v9/v10 were certified BEFORE three map changes landed today (`FORGPREP`
`0x30`->`0x0b`, `IDIV 0x00` added, `ORK` C declared a const index). Their passing proves no regression.
Coverage was verified by disassembling the DEPLOYED bytecode: 71 distinct opcodes exercised, every
certified opcode provably reached.

### Final opcode status
- 59 emittable opcodes: certified in-game.
- 18 decode-only opcodes: 13 certified in-game, 5 (FASTCALL) proven structurally 165,605/165,605.
- Offline metrics unchanged: round-trip 5382/5382 byte-exact, de-recode lossless, de-validate 0
  violations / 5,529,086, IR 5,529,086/5,529,086, de-ktags 0 suspects, CFG 82042/82042.

### The day's score, for the record
Working the "residual risk" list instead of documenting it found SEVEN real defects:
1. `JUMPIFEQ 0x20`->`0x37` (value-producing `==` returned false for equal values)
2. `build_cfg` missed 501 dead instructions (RETURN did not make a leader)
3. `0x34` was not a const-index compare but a boolean IMMEDIATE
4. import path components are tag-1 hashes, not tag-3 strings
5. **boolean constants could not be compiled AT ALL** (`{flag=true}` threw)
6. `0x51` was misnamed TESTSET -> is `ORK`
7. `0x00` was misnamed MODR -> is reg-reg `IDIV`, which we had ALSO declared nonexistent
   (+ `0x0b` was unnamed "FORGPREP?" -> generic `FORGPREP`, and we were emitting the pairs-specialised
   `0x30` for generic iterators)

Every one was invisible to the structural metrics that read 100%. The lesson worth keeping: **a metric
at 100% constrains only what it measures.** Round-trip, recode and de-validate check that bytes survive
and operands are in range — none of them can notice an operand being INTERPRETED wrongly, because a
bogus index is still a valid index.

## 2026-07-25 — M6 GROUND TRUTH BUILT *BEFORE* THE DECOMPILER

User's point, and it reframes M6: the old sources are not merely unusable INPUT, they are an
unusable ORACLE. "Our decompiler matches v13" would mean being wrong in the SAME WAY, since v13
encodes `0x51`=TESTSET, `0x00`=MODR, `0x34`-as-const-index, `MUL`=`0x09`, generic `FORGPREP`=`0x30`.

So the oracle was built FIRST — before a line of decompiler exists — so there is no output to be
flattered by. Given a day where seven defects hid behind metrics reading 100%, writing 4,000 lines
and only then asking "how would we know if it is right?" was not acceptable.

### The generated ground truth
`cert/gen_rt.py` -> **137 cases** across arith(27) cmp(31) ctrl(16) func(16) tbl(15) logic(8) imp(7)
str(5) konst(5) mix(4) glob(3). Each case is SMALL and single-purpose so a failure localises — the
property that let the v10 matrix pinpoint JUMPIFEQ.

`derecomp rt-build cert/rt/src`:
```
cases 137 | compiled (Luau) 137 | transcoded (DE) 137
distinct Luau opcodes exercised: 75
```
The generated DE bytecode is itself clean: de-validate 0 violations / 1,557 instructions,
ir-validate 1,557/1,557 (100.0000%), constants 677/677, imports 152/152, CFG 284/284.

### The correctness oracle: compare PROGRAMS, not text
```
S --luau-compile--> LBC1 --transcode--> DE1 --decompile--> S' --luau-compile--> LBC2
                     |                                                          |
                     +-------------------- lbc-cmp -----------------------------+
```
If S' compiles to the same Luau bytecode as S did, S' IS the same program — regardless of
formatting, identifier names or register allocation. Fully offline; no game needed.
`derecomp lbc-cmp` grades: byte-identical > same opcode sequence per proto > same operands too,
and names the FIRST divergence.

### I TESTED THE TEST (4 cases) — a comparator that always says "equivalent" is worse than none
| case | expected | got |
|---|---|---|
| file vs itself | IDENTICAL | IDENTICAL |
| renamed + reformatted + commented | equivalent | IDENTICAL (Luau `--binary` keeps no names -> naming/formatting insensitive for free) |
| `a + b` vs `a - b` | DIFFER | `proto 0 insn 0: ADD vs SUB` |
| `a <= b` vs `a < b` | DIFFER | `proto 0 insn 0: JUMPIFNOTLE vs JUMPIFNOTLT` |

The last case matters most: it is exactly the `JUMPIFLT`/`JUMPIFLE` swap that once made every
`repeat…until` overshoot by one. The oracle detects that class before M6c writes a line.

### Finding
**True.** 137/137 ground-truth pairs built; the comparator provably detects real differences and
provably ignores cosmetic ones.

### Next step
M6c, with 137 known-correct cases and a working correctness oracle already in place.

### Ground-truth coverage: measured the ORACLE's blind spots before trusting it

An oracle you have not measured is an assumption. Compared DE-opcode coverage of the generated set
against the real corpus:

| | opcodes | instruction coverage of real corpus |
|---|---:|---:|
| first attempt (default transcoder) | 61/77 | 95.63% |
| **+ SETTABLEN cases + native-knob set** | **72/77** | **97.00%** |

Two distinct causes, and the distinction matters:
- **`0x2e SETTABLEN` (1,524) was a plain GENERATOR GAP** — we emit it, but no case wrote `t[1] = v`.
  Fixed by adding three cases. This is the kind of hole only a coverage comparison finds.
- **The other 10 were STRUCTURAL**: decode-only opcodes are absent from ground truth *precisely
  because* our transcoder lowers or drops them. Fixed by building a SECOND set with
  `RENOVICE_NATIVE=AND,OR,ORK,ANDK,SUBK,JUMPBACK,JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,FORGPREP` +
  `RENOVICE_NATIVE_GLOBALS=1`. `rt-build <src> [tag]` writes to `de_<tag>`.
  This works because `lbc-cmp` compares LUAU bytecode: the DE representation may differ between the
  two sets, but the PROGRAM is what is being compared.

**Remaining blind spots: exactly the 5 FASTCALL opcodes** (165,605 instructions, 3.00%) — the family
we drop by design and have already proven skippable 165,605/165,605. So every opcode the decompiler
must actually RECONSTRUCT now has generated test cases.

Both sets verified well-formed: de-validate 0 violations, ir-validate 100.0000%, CFG clean.

## 2026-07-25 — FASTCALL EMISSION: 100.0000% GROUND-TRUTH COVERAGE (and a perf win we were leaving on the floor)

User: *"But why? we shouldn't drop them we should get full coverage."* Correct — and it is the SAME
error I made with ANDK this morning: treating OUR OWN CHOICE as if it were a constraint. "We drop
FASTCALLs" is not a property of DE.

Dropping them cost three things, and I had only counted the first:
1. the 3% ground-truth hole,
2. output shape diverging from what DE's own compiler produces,
3. **performance** — every recompiled script ran `math.*`, `table.insert`, `tostring` through the
   SLOW path. For a per-frame mod like Mallet that is a real, ongoing cost for no benefit.

### The gate: does DE use upstream Luau's builtin numbering?
This is the one thing that could make emission dangerous. A wrong builtin id does not crash — it
calls a REAL but DIFFERENT builtin and returns a plausible wrong number.

`derecomp de-builtins <dir>` recovers the table offline: every fastcall is followed by its own slow
path, so the function that slow path calls IS the builtin. **165,557/165,605 resolved (99.97%)**:
```
1=assert  2=math.abs  7=math.ceil  9=math.cos  12=math.floor  18=math.max  19=math.min
40=type   41=string.byte  45=string.sub  52=table.insert  62=tonumber  63=tostring ...
```
**Every id matches `LuauBuiltinFunction` exactly — DE did NOT renumber.** Two bonus findings:
DE *extended* the table (**id 133 = `IsNull`, 130,895 uses = 79% of all fastcalls in the game**), and
the 3 "ambiguous" rows are just `local floor = math.floor` aliases resolving via GETUPVAL.

### Emission
FASTCALL's `C` is a skip offset and MUST be recomputed in DE instruction space (DE widths differ from
Luau's; copying Luau's C verbatim would land mid-instruction). Added `ct`/`has_ct` to `DI`, mirroring
the existing jump-target fixup: `C = (target_byte - (insn_byte + 4)) / 4`.
Offline proof BEFORE deploying: our own emitted fastcalls satisfy the same structural law as DE's —
16/16 skip targets land exactly on a `CALL`, 0 off-boundary, 0 backwards.

### In-game (v16) — and why this test IS discriminating
I had argued an in-game FASTCALL test was near-worthless because an unrecognised builtin falls
through to the slow path and returns the right answer. True for a wrong OPCODE; **false for a wrong
builtin ID**, which returns a wrong NUMBER. So the values were chosen accordingly —
**`math.max` is id 18 and `math.min` is id 19, ADJACENT**, so an off-by-one is immediately visible.
```
V16_FASTCALL floor=3 ceil=4 max=9 min=2 abs=5 sqrt=4 maxk=10 type=number
```
All correct. `max=9 min=2` (not `2`/`9`) confirms the numbering behaviourally.
**FASTCALL emission is now the DEFAULT** (`RENOVICE_NO_FASTCALL=1` opts out).

### The last opcode: `0x4a` = FASTCALL3
Not a mystery opcode — a 3-ARGUMENT builtin call. Corpus `ImageSlideShow` p50 has
`FASTCALLX A=45 B=1 C=4` = `string.sub(s, 1, -7)`, and our luau-compile emits `FASTCALL3 A=45 ... C=4`
for the identical source. Same builtin id, same operand shape, both 8B. My generator simply had no
3-arg builtin call. Mapped `FASTCALL3 -> 0x4a`, added `string.sub(s,1,-7)` / `math.clamp(a,0,10)`
cases, and our emitted `0x4a` obeys the law 3/3.

### GROUND-TRUTH COVERAGE IS NOW COMPLETE
```
ground-truth opcode coverage : 77/77
instruction coverage         : 5,529,086 / 5,529,086 = 100.0000%
blind spots                  : NONE
```
Every opcode in every shipped script now has a generated, known-correct test case. Regressions
unchanged: round-trip 5382/5382, IR 100.0000%, all 27 cert modules rebuild.

### Finding
**False** — "we must drop FASTCALLs" was never true. Twice in one day I mistook a decision for a
constraint (ANDK, then this). The tell is the phrasing: *"we can't test X"* almost always means
*"we haven't chosen to make X reachable."*

### Full-suite regression under the new FASTCALL default — 28/28

Making FASTCALL emission the default changed the bytecode of every module that calls a builtin, so
the whole suite was rebuilt and re-run. **12 of 28 modules newly contain fastcalls** (v9_c_func, all
three v11, all four v12, v13, and both PATCHED modules) — 54 fastcall instructions in total.

**Result: 28/28, every value exact, zero failures, zero unexpected tags.**

Worth noting the patched modules: `v14_c_modr` and `v15_c_ork` have carriers whose layout SHIFTED
under the new default, yet both still carry `IDIV` and `ORK`. That works only because `de-patchop`
locates its target by (opcode, nth occurrence) rather than by instruction index — an index-based
patcher would have silently patched the wrong instruction and the modules would have tested nothing
while still reporting.

Pre-flight, all passed before deploying: 54/54 emitted fastcalls land exactly on a `CALL`,
`de-validate` clean over 2,725 instructions, both patches verified present.

## 2026-07-25 — M6c EXPRESSION RECONSTRUCTION: metric met, and spot-checks found 3 defects it could not see

`src/expr.h` + `derecomp expr <file> [proto]` / `expr-validate <dir>`. Abstract interpretation over
registers: each instruction DEFINES a register (expression tree), EMITS a statement, is CONTROL FLOW
(recorded for M6d), or is SKIPPED (hints/prologue). Anything else is COUNTED and NAMED.

### Acceptance metric
```
files=5382 protos=82042 instructions=5,529,086
  expressions 3,343,963 | statements 1,310,444 | control flow 512,366 | skipped 362,313
  UNHANDLED 0 (0.0000%)
```
Plus 0 unhandled across all three ground-truth sets. Upstream regressions untouched.

### THE METRIC WAS GREEN AND THE OUTPUT WAS STILL WRONG — 3 defects found by SPOT-CHECKING
"Every instruction consumed" proves the DISPATCH is complete. It says nothing about whether the
resulting expression is right. Checking output against sources I knew found three real bugs:

| source | before | cause |
|---|---|---|
| `{1, 2, 3}` | `return {}` | SETLIST was a placeholder comment — **every array element was lost** |
| `math.max(a, b)` | `return ` *(empty!)* | multret `RETURN` (B==0 = "all values to stack top") treated as ZERO values |
| `math.floor(math.abs(a))` | `math.floor()` | multret CALL args (B==0) likewise dropped |

All three are the same root cause: **Luau encodes "up to the top of the stack" as `B==0`/`C==0`**, and
I was reading that as zero. Fixed by tracking a stack top in `RegEnv`.

Then I OVERCORRECTED — using the block-wide high-water mark produced `math.floor(math.abs(v0), v0)`
and `return math.max(v0,v1), v0, v1`, i.e. dead argument registers resurfacing as values. The real
rule: **a call COLLAPSES the stack to its own base.** After `CALL A B C`, top = `A+nres-1`, or `A` for
multret, or `A-1` when no results. With that, all cases reconstruct exactly:
```
math.floor(math.abs(v0))            v0(), v0(v1), v0(v1, v2)        math.max(v0, v1)
{1, 2, 3}                           "x=" .. v0 .. "!"               { on = true, off = false, none = nil }
return v0 + v1 * v2 - v0 / v1       return v0.a.b.c                 return v1.n or 10, v1.name or "anon"
```
Precedence renders with no spurious parentheses, and right-associativity of `^`/`..` is respected.

### Finding
**Partially true.** The M6c metric (0 unhandled) is met corpus-wide, but it is a COMPLETENESS metric,
not a correctness one — exactly as warned when it was chosen. Correctness needs the round-trip oracle,
which cannot run until M6e emits compilable source.

### Known-incomplete (deliberately deferred, not hidden)
- Values crossing block boundaries render as `v<N>` with no `local` declarations — M6d/M6e.
- `and`/`or` chains that span blocks stay as raw `[ctrl]` — M6d.
- `{1, 2, x = 3}` emits the constructor then separate field assignments instead of folding them.
- Single-use temporaries are not yet inlined into their use sites.

## 2026-07-25 — M6d CONTROL-FLOW STRUCTURING: 69.4% structured. IN PROGRESS, not done.

**Luau has NO `goto`** (verified: `::label::` is a syntax error). So there is no escape hatch — an
unstructured residue is not a readability problem, it is source we CANNOT EMIT AT ALL. That makes
M6d a hard prerequisite for M6e, and therefore for the round-trip oracle that would confirm the four
outstanding M6c items.

`src/structur.h` + `derecomp struct-validate`: dominators -> natural loops -> if-regions via
immediate post-dominators, recursive descent, with every failure COUNTED and NAMED.

### Current state (honest)
```
protos=82042   FULLY STRUCTURED 56,901 (69.3559%)   with residue 25,141
recovered: if=407,779 while=15,330 repeat=200 for-num=15,339 for-gen=13,584
ground truth: 285/294 (96.94%)
```

### Two bugs found and fixed by measurement
1. **Loop KIND was read from the header; it lives at the LATCH.** For `for k,v in pairs(t)` the
   natural-loop header is the BODY start (that is what the back edge targets) while `FORGLOOP` sits
   at the latch. for-num 4,753 -> 15,221 once corrected.
2. **For-loops are invisible to natural-loop detection entirely.** The prep instruction jumps FORWARD
   to the loop instruction, so a path reaches the loop while SKIPPING the body — the body therefore
   does NOT dominate the loop instruction and the back edge is never recognised. Dominance-only
   detection found **50** generic for-loops in a corpus containing ~13,750 `FORGPREP`s. Fixed with
   PATTERN detection (prep -> matching LOOP opcode): **for-gen 50 -> 13,584**, which matches the
   instruction count almost exactly.

### What is NOT done
**~30% of protos retain unstructured residue** (23,524 "revisit of block" + 1,617 unplaced). The
dominant remaining shape is short-circuit `and`/`or` and shared tails, where one arm of a diamond
jumps INTO the other rather than to a common join — the recursive descent reaches a block twice and
bails. That needs either explicit short-circuit recognition before if-structuring, or node splitting.

### Consequence for the four outstanding M6c items
They cannot be confirmed yet, and I will not claim otherwise:
- `local` declarations for cross-block values — needs M6d complete, then M6e
- `and`/`or` chains spanning blocks — IS the dominant M6d failure above
- table-constructor folding — needs M6e
- single-use temporary inlining — needs M6e
All four are confirmed by the SAME oracle (emit -> luau-compile -> lbc-cmp), which cannot run until
emission exists, which cannot exist until structuring is complete.

### Finding
**Partially true.** M6d exists and works on 69.4% of real protos; two real detection bugs were found
and fixed by measurement. It is not finished, and nothing downstream can be confirmed until it is.

### M6d, second pass: short-circuit collapse — 69.4% -> 81.0%

The dominant residue was one shape, not scattered difficulty. `if a and b then` compiles to TWO
conditional blocks that branch to the SAME target:
```
   B: JUMPIFNOT a -> L
   F: JUMPIFNOT b -> L
```
so L is reached from both arms of what only LOOKS like a diamond. A recursive descent emits L inside
the inner `if`, then tries to emit it again for the outer one — the 23,524 "revisit of block" nodes.

Collapsing the pair back into ONE condition (merge F into B when F is private to B and B's branch
target coincides with one of F's exits; `and` when it matches F's target, `or` when it matches F's
fallthrough):
```
FULLY STRUCTURED  66,425 / 82,042 = 80.9646%   (was 69.3559%)
if 292,289 (was 407,779)  -> 115,490 conditions merged back into short-circuit chains
ground truth 289/294 = 98.30%
```
That single change also closes the `and`/`or`-chains-span-blocks item from the M6c list: those chains
are now recovered as expressions rather than left as raw control flow.

**A trap the merge introduced, fixed before it could do damage:** the merged block keeps only the
LAST condition's terminator, so `if a and b then` would have emitted as `if b then` — correct control
flow, WRONG PROGRAM, and exactly the class of silent error that survives every structural metric.
`Node` now records the whole chain (`chain` + `chain_and`) so emission can rebuild the full condition.

### Still open: 15,617 protos (19.0%) with residue
13,543 "revisit" + 2,074 unplaced. These are shapes short-circuit collapse does not cover — shared
tails and cross-arm jumps where one branch genuinely enters the other. Since Luau has no `goto`,
these cannot be emitted at all and must be reduced, not worked around.

### M6d, third pass: 69.4% -> 93.7%. Diagnostics first, then four fixes.

Rather than guessing at the residue I made the structurer RECORD what shape defeated it. The histogram
named the causes immediately:
```
revisit preds=2/3/4 term=0x1e (FORGLOOP)   10,606   <- largest single cause
revisit preds=2/3/4 term=0x29 (RETURN)      7,160
unplaced preds=1 term=0x54 / 0x40           2,272
```

**Fix 1 — a FOR-PREP block IS the loop entry (10,606).** For-loops were detected at the body header,
but the descent reaches the PREP block first, sees a two-way branch, and builds a bogus `if` whose
else-arm walks straight into the loop body. Recognising the prep as the loop entry fixed it.
**80.96% -> 93.73%.**

**Fix 2 — shared tails are not unstructured control flow (7,160).** When several arms fall into one
straight-line block (overwhelmingly a lone `return`), Lua cannot express the join — but DUPLICATING
the block is exactly equivalent. Only blocks that do NOT branch qualify: duplicating a branch would
duplicate a decision, which is a different program.

**Fix 3 — loop exit priority.** The exit is the edge leaving from the HEADER (`while` test fails) or
the LATCH (`for`/`repeat` finishes); a body-wide scan is only a fallback for `while true ... break`.
Getting that order wrong measured **92.94% vs 93.73%** — the body-wide scan picks a `break` target and
mis-sites the loop end.

**Fix 4 — rejected on cost.** Letting duplication CHAIN through successors reached 94.14%, but took
duplications from 7,921 to **73,560** — an order of magnitude of code bloat for 0.44pp. Kept the
non-chaining version at 93.70%; a decompiler that emits 10x the code is not a better decompiler.

```
REAL CORPUS   76,876 / 82,042 = 93.70%   (was 69.36%)
GROUND TRUTH     293 /    294 = 99.66%   (was 96.94%)
```

### NOT 100% — 5,166 protos (6.3%) still have residue
`revisit outside-loop` 3,823, `revisit inside-loop` 3,389, `revisit non-terminal` 2,001,
`unplaced preds=1` 2,263. These are genuine cross-arm jumps and multi-exit loops, where one branch
enters the other rather than joining. Luau has no `goto`, so they cannot be emitted and must be
properly reduced — node splitting or loop normalisation, not another heuristic.

### M6d COMPLETE: 100% representable — 93.70% readable, 6.30% via state-machine fallback

The last 6.3% are not a pattern I had failed to spot. They are genuine cross-arm jumps and multi-exit
loops — one branch ENTERING another rather than joining it. In a language with no `goto` those cannot
be written with if/while/for AT ALL, so no further heuristic reaches them.

The standard exact solution is a DISPATCH LOOP:
```lua
local state = 0
while true do
    if state == 0 then <block 0>  state = <succ>
    elseif state == 1 then ...
    end
end
```
Each block runs, then names its successor. This is semantically exact for ANY control flow graph,
reducible or not, and it covers every reachable block by construction.

```
REAL CORPUS    naturally structured 76,876 / 82,042 = 93.70%   (readable if/while/for)
               state-machine fallback 5,166 = 6.30%  (181,790 states — correct but UNREADABLE)
               UNREPRESENTABLE 0
GROUND TRUTH   293/294 natural = 99.66%, 1 fallback, 0 unrepresentable
```

**The fallback is counted SEPARATELY on purpose.** Folding it into a "100% structured" headline would
hide the fact that 6.3% of the corpus decompiles to something correct but unreadable. Both numbers
matter and both are printed.

Regressions unchanged: round-trip 5382/5382, IR 100.0000%, expr 0 unhandled, de-ktags 0 suspects.

### What this unblocks
Emission (M6e) is no longer blocked on structuring: EVERY proto now has a valid representation, so
the round-trip oracle can finally run over the whole corpus rather than a subset. The four open M6c
items become empirically testable at that point, not before.

### The 6.3% is NOT all irreducible — 60% of it is a STRUCTURER BUG (user pushed back, correctly)

I was ready to accept the state-machine fallback for 6.3% of the corpus as "genuinely impossible".
The user refused that. Testing the claim rather than asserting it:

**A REDUCIBLE CFG can ALWAYS be expressed with if/while/for — no `goto` needed.** So any proto we
punted to the fallback that turns out to be reducible is a bug in the STRUCTURER, and the fallback
was hiding it. `st::is_reducible` tests it directly: every retreating edge's target must dominate its
source.

```
state-machine fallback                    5,166
  fallback BUT REDUCIBLE (structurer bug) 3,123   (3.81% of corpus) <- FIXABLE, my fault
  fallback, genuinely irreducible         2,043   (2.49% of corpus)
```

**This makes 100% natural structuring genuinely reachable**, in two distinct pieces:
1. **3,123 reducible protos** — fix the structurer. These need no duplication at all; the graphs are
   already expressible and the descent is simply mishandling them.
2. **2,043 irreducible protos** — NODE SPLITTING. Irreducible flow can still be structured by
   duplicating the nodes reachable by more than one path, so each path owns its copy. That is
   standard, semantically exact, and bounded in practice because these graphs are small.

Neither requires `goto`, and neither requires the dispatch loop. The fallback stays in the codebase as
a safety net, but it should end up used ZERO times.

**The lesson, again:** a fallback that always succeeds will happily absorb bugs. It reported "0
unrepresentable" while 3,123 protos were being mangled for no reason. Any catch-all path needs a
check that says whether it SHOULD have been needed.

### Two more structuring steps: 93.70% -> 94.51%. Did NOT reach 100%.

**Step 1 — active stop-point SET (kept).** A single `stop` parameter only knows the innermost region,
so an arm that legitimately ran to an OUTER region's join looked like a revisit and was rejected.
Every enclosing follow-point is now a clean stop. **93.70% -> 94.51%**, reducible-but-failed
3,123 -> 2,612.

**Step 2 — node splitting during traversal (REVERTED).** Erasing a block from `emitted` mid-descent so
it can be re-emitted gave only **+0.29pp for 113,088 splits**, and `revisit non-terminal` rose to
55,999 — the budget exhausts before converging, because the same block re-splits over and over.
Disabled with the reason recorded in the source.

**Node splitting must be a GRAPH PRE-PASS, not a traversal trick**: materialise duplicate nodes with
their own indices until every node has a single structural parent, THEN structure the enlarged graph.
Doing it during the descent cannot converge, which is what the measurement showed.

```
REAL CORPUS   naturally structured 77,535 / 82,042 = 94.51%
              fallback 4,507 = 5.49%  (2,612 REDUCIBLE = still my bug | 1,895 irreducible)
GROUND TRUTH  293/294 = 99.66%
```
Regressions unchanged: 5382/5382 byte-exact, expr 0 unhandled.

### Honest state
100% is still not reached and I am not going to present 94.51% as if it were. The remaining work is
now precisely scoped rather than vague:
- **2,612 REDUCIBLE protos** — structurer bugs. These need no duplication; the graphs are expressible.
- **1,895 irreducible protos** — need the graph-level node-splitting pre-pass described above.

### Dominator-tree structuring: 94.51% -> 95.03%. Half the idea was right, half was wrong.

**The theory is not in doubt:** a REDUCIBLE CFG is always structurable with if/while/for and no
duplication, and an irreducible one always becomes reducible under node splitting. So 100% IS
reachable and every remaining reducible failure is a bug. The user was right to keep pushing.

The textbook algorithm follows the DOMINATOR TREE rather than edges, because each block has exactly
one immediate dominator, so each is emitted once by construction. I implemented that and MEASURED it:

| variant | natural |
|---|---:|
| edge-following (previous) | 94.51% |
| + gate if-ARMS on dominance | **89.55%** |
| + place dom-tree children (joins) | 91.33% |
| **arms by edge + dom-child sweep** | **95.03%** |

So the two halves of the rule are NOT equally valuable:
- **Placing dominator-tree CHILDREN is right (+0.5pp).** A block whose immediate dominator is `cur`
  must be emitted inside cur's region even when it is not a direct successor — the join of a nested
  `if` is exactly that. Without the sweep those joins are simply never placed.
- **Gating the ARMS on dominance is wrong here (-3pp).** It refuses to descend into arms that the
  ad-hoc loop/short-circuit machinery already handles correctly, so it removes more than it fixes.
  The pure dominator algorithm would need loop handling reformulated in the same terms; half-migrating
  to it is worse than either endpoint.

```
REAL CORPUS   naturally structured 77,962 / 82,042 = 95.03%
              fallback 4,080 = 4.97%  (2,339 REDUCIBLE = bugs | 1,741 irreducible)
GROUND TRUTH  293/294 = 99.66%
```

### The route to 100% — precise, not hand-waving
1. **2,339 reducible protos.** Complete the migration to dominator-tree structuring *including loops*
   (loop bodies = blocks dominated by the header and reaching the latch; exits = dominated blocks
   outside that set). Half-migration measured worse than either endpoint, so this must be done whole.
2. **1,741 irreducible protos.** Graph-level node-splitting PRE-PASS: materialise duplicate nodes with
   their own indices until every node has one structural parent, then structure the enlarged graph.
   Doing this during traversal cannot converge (measured: 113,088 splits, +0.29pp).

### GROUND TRUTH REACHES 100% — real corpus 95.33%

Applying the dom-child sweep after LOOPS as well as after `if`s: **95.03% -> 95.33%**, and the ground
truth hits **294/294 = 100.0000% naturally structured, zero fallback**.

That last number matters more than the delta. Every construct expressible in hand-written Luau now
structures naturally with no dispatch loop anywhere. The remaining real-corpus residue is confined to
shapes DE's compiler emits that stock `luau-compile` does not — which is precisely why the generated
ground-truth corpus could never have found them, and why the real corpus is still needed as bytecode.

```
REAL CORPUS   naturally structured 78,213 / 82,042 = 95.33%
              fallback 3,829 = 4.67%  (2,141 REDUCIBLE = bugs | 1,688 irreducible)
GROUND TRUTH  294 / 294 = 100.0000%, 0 fallback
```

Session total for M6d: **69.36% -> 95.33%**, 0% unrepresentable throughout.
Regressions untouched: round-trip 5382/5382, IR 100.0000%, expr 0 unhandled.

**`M6_PLAN.md` now carries the remaining work**: the two structuring steps with the measurement table
that rules out the wrong approaches, then emission, then the four checks in cost order ending with the
in-game test. Four dead ends measured and recorded today so they are not retried: dominance-gated
arms (-3pp), chained tail duplication (10x code for +0.44pp), in-traversal node splitting (113,088
splits for +0.29pp), and body-wide loop-exit scanning (-0.8pp).

### The next target is now identified precisely: 3,324 `unplaced preds=1` blocks

After the loop dom-child sweep, the failure histogram shifted. The largest bucket is no longer
revisits — it is blocks with exactly ONE predecessor that were never placed:
```
unplaced preds=1  term=0x54 CALL 1,164 | 0x40 JUMP 1,007 | 0x18 JUMPIFNOT 705 | 0x4b JUMPIF 448
```
**A block with one predecessor is ALWAYS dominated by that predecessor**, so it is always placeable —
no duplication, no irreducibility, no theory required. All 3,324 are pure traversal bugs, and they are
now the biggest single bucket.

Suspected cause: the dominator-child sweep runs at only three sites (after `if`, after straight-line
flow, after a loop). When a region ends any other way — hitting a `stop`, emitting `Break`/`Continue`,
or returning from a nested call — the sweep never runs, and a child that block owns is abandoned.
Fix to try first: hoist the sweep into one helper and run it at EVERY exit from `structure_seq`.

This is a clean target because theory says the count MUST reach zero. Written up as STEP 0 in
`M6_PLAN.md`, ahead of the dominator-migration and node-splitting work, because it is both the largest
bucket and the cheapest.

### STEP 0 done: 95.33% -> 97.13%. The sweep was blind to loop-placed blocks.

Chasing the 3,324 `unplaced preds=1` blocks (a block with ONE predecessor is always dominated by it,
so it is always placeable — every one was a bug). Two causes, both found by instrumenting rather than
guessing:

1. **The sweep skipped anything registered as a `stop`** (8,908 candidates). I assumed the enclosing
   region would place them, but an ancestor only places ITS OWN follow — a block registered by a
   *different* enclosing region falls through the gap and is never placed at all. `C.emitted` already
   prevents double-placement, so skipping bought nothing and lost code.
2. **`mine` only recorded straight-line placements.** The loop paths (`for`-prep, loop header, latch)
   insert into `C.emitted` WITHOUT recording into `mine`, so the sweep could not see them and every
   block dominated by a loop header was invisible to it. Three one-line additions.

```
REAL CORPUS   naturally structured 79,684 / 82,042 = 97.13%   (was 95.33%)
              fallback 2,358 = 2.87%  (1,538 REDUCIBLE | 820 irreducible)
GROUND TRUTH  294 / 294 = 100.0000%, 0 fallback
```
`unplaced` has dropped out of the failure histogram entirely. Irreducible protos more than halved
(1,688 -> 820) purely as a side effect: many graphs only *looked* irreducible because blocks were
missing from the traversal.

Session total for M6d: **69.36% -> 97.13%**. Regressions untouched: 5382/5382, IR 100%, expr 0
unhandled.

Remaining shapes are now all revisits: outside-loop 1,610, inside-loop 1,251, non-terminal 1,150.

### Bounded node splitting re-enabled: 97.13% -> 97.51%

The unbounded version was disabled earlier (113,088 splits for +0.29pp, budget exhausting before
convergence). Re-enabled with a SMALL FIXED allowance instead of one proportional to graph size:

| budget | natural | splits |
|---:|---:|---:|
| disabled | 97.13% | 0 |
| 12 | 97.5098% | 5,730 |
| **24** | **97.5147%** | **6,609** |
| 48 | 97.5147% | 7,494 |

It plateaus at 24 — beyond that the extra duplication buys literally nothing. The earlier failure was
never "splitting doesn't work", it was an allowance large enough to let the same block re-split
indefinitely. A tight cap turns the same mechanism from a thrash into a clean +0.4pp.

```
REAL CORPUS   naturally structured 80,003 / 82,042 = 97.51%
              fallback 2,039 = 2.49%  (1,339 REDUCIBLE | 700 irreducible)
GROUND TRUTH  294 / 294 = 100.0000%, 0 fallback
```
Regressions untouched: 5382/5382 byte-exact, IR 100.0000%, expr 0 unhandled.

**Session total for M6d: 69.36% -> 97.51%.** Irreducible protos fell 2,043 -> 700 purely as a side
effect of placing blocks correctly: most graphs only LOOKED irreducible because the traversal was
losing blocks.

Also measured and reverted this round: gating the JOIN on `dominates(cur, follow)` costs 2.1pp
(97.13 -> 95.03). That is the THIRD dominance-gating variant to lose to plain edge-following; the
ad-hoc loop/short-circuit machinery already sets region boundaries that dominance-gating overrides
incorrectly. Recorded in the source so it is not tried a fourth time.

## 2026-07-25 — M6d: 69.36% -> 99.9963%. THREE protos left out of 82,042.

The user refused to accept the state-machine fallback and kept pushing. That was right every time:
each round the residue turned out to be bugs, not limits.

### What closed it
1. **Non-terminal shared blocks were refused duplication** (5,064 = the dominant shape at 97.5%).
   A straight-line block containing no branching decision is as safe to duplicate as a tail; the only
   reason to refuse was the unbounded chaining that once produced 73,560 copies. With a budget in
   place that risk is capped. **97.51% -> 99.82%.**
2. **Enclosing loops were invisible.** `loop_hdr`/`loop_exit` tracked only the INNERMOST loop, so
   reaching an OUTER loop's header or exit was not recognised as a loop edge. Added stacks.
   46 fallback protos instead of 59 at equal budget — a shape fix, not brute force.
3. **ADAPTIVE BUDGET.** Duplication is exact but bloats output, and the cost is wildly uneven — most
   protos need none, a handful need thousands. A single global budget forces a bad choice:

   | uniform budget | natural | duplications |
   |---:|---:|---:|
   | 200 | 99.944% | 24k |
   | 2,000 | 99.972% | 74k |
   | 20,000 | 99.992% | 274k |
   | 200,000 | 99.996% | 887k |

   Escalating 24 -> 200 -> 2,000 -> 20,000 -> 200,000 and stopping at the first success keeps the
   common case cheap while still paying whatever the hard protos need. Same 99.9963% as the flat
   200,000 budget, without charging every proto for it.

```
REAL CORPUS   naturally structured 82,039 / 82,042 = 99.9963%
              fallback 3  (1 reducible | 2 irreducible)
GROUND TRUTH  294 / 294 = 100.0000%, 0 fallback
```
Regressions untouched throughout: round-trip 5382/5382 byte-exact, IR 100.0000%, expr 0 unhandled.

### The pattern across this whole push
Every single time I concluded "this is a genuine limit", instrumenting proved otherwise:
- "6.3% genuinely irreducible" -> 60% of it was a structurer bug (the reducibility test showed it)
- "splitting during traversal cannot converge" -> the MECHANISM was fine, the ALLOWANCE was too large
- "3,324 unplaced blocks need theory" -> two one-line omissions (stops skip, `mine` missing loop sites)
- "non-terminal blocks can't be duplicated" -> they can, they just needed the cap that already existed

The lesson is not "try harder". It is that **a fallback which always succeeds hides the evidence**.
Every one of these was found by making the code REPORT WHY it gave up, then reading the histogram.

### The last 3 protos — named, and the reducibility question answered

`RENOVICE_NAME_FALLBACKS=1 derecomp struct-validate <cache>` names them:
```
Lotus_Scripts_Nemesis_NemesisMission.lua_B        proto=25  169 blocks  irreducible
Lotus_Scripts_PlayerShip.lua_B                    proto=48  156 blocks  irreducible
Lotus_Scripts_Restoratives_SpawnEntratiTech.lua_B proto=14   75 blocks  REDUCIBLE
```

**The user's challenge — "I don't believe in irreducible protos" — was worth testing properly**, and it
produced a real argument: Luau compiles goto-less structured source, so its output CANNOT be
irreducible. If a graph measures irreducible, WE built it wrong. The prime suspect was the
short-circuit merge, which rewrites edges. **Tested: reducible 73,474/82,261 BEFORE the merge and
73,474/82,261 AFTER — the merge creates none.** So the irreducibility is inherent to how the CFG is
derived from the bytecode, not manufactured by our rewriting. That does not prove DE's compiler emits
irreducible flow; it narrows the remaining suspects to block-boundary and branch-target derivation.

Also fixed while there: `is_reducible` held `auto& [u, ei] = stk.back()` across a `push_back`, a
dangling reference (the vector can reallocate). Numbers were unchanged, but it was UB.

### Two ideas tested and rejected, both with numbers
- **Raising the recursion depth guard** (200 -> 20,000): no change. Depth was never the limit.
- **Per-block duplication cap.** One 75-block proto burned 199,928 duplications, which looked exactly
  like duplicating around a cycle. It is not — every finite cap measured WORSE:
  | cap | fallback protos |
  |---:|---:|
  | 4 | ~150 |
  | 64 | (worse) |
  | 512 | 23 |
  | 4,096 | 12 |
  | **off** | **3** |
  Those 199,928 duplications are genuine, not a loop. Cap left effectively disabled with the table
  attached so it is not "fixed" again.

### Final state
```
REAL CORPUS   naturally structured 82,039 / 82,042 = 99.9963%   (3 protos in fallback)
GROUND TRUTH  294 / 294 = 100.0000%, 0 fallback
```
Regressions untouched: round-trip 5382/5382 byte-exact, IR 100.0000%, expr 0 unhandled.

**Session total for M6d: 69.36% -> 99.9963%.** The remaining 3 are now individually named, so the next
step is reading their CFGs directly rather than statistics — at n=3 that is the only sensible method.

### The last 3: four more configurations tried, ALL give exactly 3. It is not a tuning problem.

The user's argument stands — 3 irreducible protos out of 82,042 is not a plausible property of
compiler output, so something in our handling is wrong. Four attempts to reach them, all measured:

| attempt | result |
|---|---|
| escalate cap ALONGSIDE budget (7-rung ladder) | still exactly 3 |
| add LARGE-budget + TIGHT-cap rungs (2M budget x cap 2/6/16/64) | still exactly 3 |
| raise per-region iteration guard 4,000 -> 4,000,000 | **WORSE** (5+ fallbacks) |
| raise recursion depth guard 200 -> 20,000 | no change |

Every knob is now ruled out. The number does not move with budget, cap, depth or iteration limits,
which means **the failure is structural in how these three graphs are built or traversed, not a
resource limit.** That is a much sharper statement than "irreducible".

Also established this round: the short-circuit merge does NOT create irreducibility (73,474/82,261
reducible both before and after), so the remaining suspects are block-boundary derivation and
branch-target resolution in `build_graph`/`build_cfg`.

### Where to look next (concrete, no guessing)
```
RENOVICE_NAME_FALLBACKS=1 derecomp struct-validate <cache>
  Lotus_Scripts_Nemesis_NemesisMission.lua_B        proto=25  169 blocks  irreducible
  Lotus_Scripts_PlayerShip.lua_B                    proto=48  156 blocks  irreducible
  Lotus_Scripts_Restoratives_SpawnEntratiTech.lua_B proto=14   75 blocks  REDUCIBLE
```
Start with SpawnEntratiTech proto 14: it measures REDUCIBLE, so by the theorem it is structurable
with no duplication at all, and it is the smallest of the three. Dump its CFG (blocks, succ_true,
succ_false, terminators) and read it by hand — at n=3 that is the only sensible method, and every
statistical approach has now been exhausted.

### Final state for the session
```
REAL CORPUS   naturally structured 82,039 / 82,042 = 99.9963%   (3 in fallback)
GROUND TRUTH  294 / 294 = 100.0000%, 0 fallback
```
M6d this session: **69.36% -> 99.9963%.** Regressions untouched throughout: round-trip 5382/5382
byte-exact, IR 100.0000%, expr-validate 0 unhandled.

## 2026-07-25 — THERE ARE NO IRREDUCIBLE PROTOS. It was a PHANTOM EDGE all along.

The user refused to accept "3 of 82,042 happen to be irreducible" as plausible. Fable said stop
pulling resource levers (the count was identical across every budget/cap/depth setting — a flat
deterministic signal, not a near-miss) and **verify the GRAPH before blaming the traversal**, because
a single mis-resolved edge turns a fine graph unstructurable and would hit exactly the few protos
containing that encoding. Both were right.

### The bug
`build_graph` treated only `JUMP (0x40)` and `JUMPBACK (0x25)` as unconditional, so it added a
FALLTHROUGH edge to every `FORGPREP` block. **`FORGPREP` (0x30 / 0x1b / 0x0b) is an UNCONDITIONAL
jump to the FORGLOOP — it never falls through.** That invented edge gave every generic-for loop a
SECOND ENTRY, which is the textbook definition of irreducible.

Visible in the smallest possible case — ground-truth `for k,v in pairs(t) do end`:
```
before:  0  FORGPREP  true=2  false=1     <- phantom edge 0->1 into the loop body
         loop {1,2} has TWO entries  =>  reducible = NO
after:   0  FORGPREP  true=2  false=-1
         loop {1,2} entered only at 2 =>  reducible = YES
```

`FORNPREP (0x47)` is genuinely conditional — it jumps to the loop EXIT when the loop will not run and
otherwise falls through to the body — so it correctly keeps both edges. The two preps are NOT
symmetric, which is exactly why this hid for so long.

### Result
```
reducible BEFORE short-circuit merge: 82,446 / 82,446 = 100%   (was 73,474 / 82,261)
reducible AFTER  short-circuit merge: 82,446 / 82,446 = 100%
fallback: 3, and ALL THREE are now classified REDUCIBLE (was 1 reducible + 2 "irreducible")
```
**Every proto in the corpus is reducible.** ~9,000 protos that measured irreducible were an artifact
of one invented edge. The remaining 3 failures are therefore ALL provably fixable bugs with no theory
required — a reducible graph is always structurable with if/while/for and no duplication.

Structuring is unchanged at 99.9963% (the duplication machinery was already compensating for the
phantom edges), and all regressions hold: round-trip 5382/5382, IR 100.0000%, expr 0 unhandled,
ground truth 294/294.

### The lesson
Two sessions of work rested on a classification that was simply wrong. "Genuinely irreducible" was
quoted as a hard floor in the plan, in three separate FINDINGS entries, and in the reasoning for the
state-machine fallback — all of it downstream of one missing opcode in one boolean. **When a
measurement supports "we've hit a fundamental limit", verify the measurement before believing it**,
especially when a user says the number looks implausible. Implausible numbers usually are.

### "The other protos resolved fine, so were they OK?" — NO. A/B proves ~15,700 loops were MISSHAPED.

The user asked the sharp question: the phantom edge misclassified reducibility, but those protos still
STRUCTURED successfully — did they structure CORRECTLY?

Controlled A/B, same binary, only the phantom `FORGPREP` fallthrough differing:

| construct | A: phantom edge | B: fixed | delta |
|---|---:|---:|---:|
| if | 1,588,308 | 1,588,154 | -154 |
| **while** | **250,173** | **260,238** | **+10,065** |
| repeat | 200 | 200 | 0 |
| for-num | 21,886 | 21,841 | -45 |
| **for-gen** | **39,192** | **33,526** | **-5,666** |

**Both report the IDENTICAL success count (82,039 / 99.9963%) while producing DIFFERENT control flow.**
With the phantom edge, ~5,666 loops were recovered as generic-for that are not, and ~10,065 while
loops were missed or misattributed. Roughly 15,700 loop classifications were wrong across the corpus.

This is the exact failure mode this project keeps hitting, in its purest form yet: **the metric said
100% success in BOTH cases.** "It structured" and "it structured correctly" are different claims, and
no structuring metric can tell them apart — only comparing against a second implementation, or the
round-trip oracle, can.

It also means the phantom edge was not merely a classification curiosity affecting 3 protos. It was
silently deforming the decompiled shape of thousands of loops, and every one of those would have gone
into the regenerated corpus as plausible, wrong source.

### Two more runaways found and fixed: 3 -> 2 fallbacks (99.9976%)

With reducibility finally measured correctly, the remaining failures stopped being mysterious and
became visible as RUNAWAYS — one proto consuming a 2,000,000 duplication budget by itself.

**Fix A — never duplicate ACROSS A BACK EDGE.** A block ending in `JUMPBACK` is not a branch, so it
fell into the non-terminal duplication path, which then followed its BACK EDGE: duplicate the loop,
arrive at the same block, duplicate again, forever. Measured 1,999,316 duplications on a 75-block
proto. A loop latch must be handled as a loop edge, never copied. **3 -> 2 fallbacks.**

**Fix B — the numeric-for prep detector was DEAD CODE.** It required the prep's target to be the
`FORNLOOP`, but the two preps are not symmetric:
```
FORGPREP  jumps TO the FORGLOOP     (target IS the loop instruction)
FORNPREP  jumps to the loop EXIT    (target is PAST the FORNLOOP)
```
So `prep_num` never once fired, and numeric for-loops were found only by the dominance finder.
Corrected to locate the FORNLOOP by its back edge into the body: **for-num 21,841 -> 24,227**
(+2,386 loops now recognised at the prep).

**Rejected, with numbers:** blanket-refusing to split loop headers/latches costs 6.6pp
(99.998 -> 93.40) AND breaks ground truth (294 -> 290) — legitimate splits frequently land on them.
A per-block split cap tied to the escalation ladder is neutral and keeps ground truth at 294/294;
a fixed cap of 8 costs 0.07pp.

```
REAL CORPUS   naturally structured 82,040 / 82,042 = 99.9976%   (2 fallbacks, BOTH REDUCIBLE)
GROUND TRUTH  294 / 294 = 100.0000%
```
Regressions untouched: round-trip 5382/5382, IR 100.0000%, expr 0 unhandled.

### The 2 that remain
```
Lotus_Scripts_Nemesis_NemesisMission.lua_B proto=25  169 blocks  REDUCIBLE
Lotus_Scripts_PlayerShip.lua_B            proto=48  156 blocks  REDUCIBLE
```
Both still show a split runaway (1,128,310 splits on NemesisMission p25) on the final uncapped ladder
rung, plus ~19 unresolved revisits. Since both are REDUCIBLE they are structurable with NO duplication
at all — which says the duplication machinery is compensating for a descent bug rather than fixing
anything. The next move is to read these two graphs directly (`struct-dump`), not to add a sixth
duplication heuristic.

### Fable's overlapping-loops hunch was RIGHT — it only became visible after the phantom-edge fix

Reading `NemesisMission` p25's loops (rather than adding a sixth heuristic) showed the pattern finder
and the dominance finder BOTH claiming the same loops, with conflicting kinds AND bodies:
```
loop1  ForNum header=83 body={83}         loop7  While header=83 body={83}
loop3  ForNum header=98 body={98,99,100}  loop11 While header=98 body={98,100}
loop9  While  header=92 body={..6 blocks} loop10 While header=92 body={..7 blocks}
```
**Six duplicate headers in one proto.** `loop_for_header` picks whichever body is larger while the
rest of the descent may follow the other, so the two disagree about which blocks are in the loop —
the structural cause of the split runaways.

Fixed by de-duplicating: one loop per header, keeping the more specific KIND (a for-loop knows its
shape) and the UNION of bodies (never lose a block; two latches into one header is legitimate, e.g.
multiple `continue` paths). Construct counts shifted enormously — **if +449,697, while +65,741** —
confirming the duplicate loops had been deforming output at scale, exactly like the phantom edge.

Fallbacks stayed at 2. Ground truth stayed 294/294 on BOTH generated sets.

### VERIFIED STATE
```
structuring   82,040 / 82,042 = 99.9976%   (2 fallbacks, both REDUCIBLE)
reducibility  82,318 / 82,318 = 100%       (no irreducible protos exist)
ground truth  294/294 = 100% on de AND de_native
round-trip    5382/5382 byte-exact
de-recode     LOSSLESS
IR            5,529,086 / 5,529,086 (100.0000%)
expr          0 unhandled
de-ktags      0 suspects
```

### WHAT I CANNOT VERIFY YET — the honest limit
The user asked to triple-check the protos are not "fucked". Everything above checks **completeness**
(every block placed, every instruction consumed, every operand resolved). **NONE of it checks that
the recovered STRUCTURE MEANS THE SAME THING as the bytecode.**

That was proved emphatically today: the phantom edge and the duplicate loops BOTH left every metric
at 100% while silently deforming ~15,700 loops and shifting ~450,000 constructs. Two separate bugs,
neither visible to any structural check.

The only instrument that can settle it is the round-trip oracle, which needs M6e emission:
`decompile -> emit -> luau-compile -> compare bytecode`. Until that runs, "the protos are good" is an
unproven claim, and I will not make it. The harness and its self-tests are already built and waiting.

## 2026-07-25 — THE REAL NUMBER: 92.32% honest, 7.67% papered over by duplication

The user rejected the fallback as "a cope" and was right about something bigger than the fallback.
Added a ZERO-DUPLICATION rung to the head of the escalation ladder to ask an honest question: how much
of the corpus does the descent structure WITHOUT copying any blocks?

```
structured with ZERO duplication : 75,744  (92.3234%)
needed duplication               :  6,296  (7.6741%)
state-machine fallback           :      2  (0.0024%)
```

**A REDUCIBLE CFG NEEDS NO DUPLICATION — that is a theorem, and every proto in the corpus is now known
reducible (82,318/82,318).** So the honest reading of "99.9976% structured" is:

- **92.32% genuinely structured.**
- **7.67% (6,296 protos) structured only because blocks were COPIED to route around a descent bug.**
- 0.002% not structured at all.

The headline number was flattering itself. Duplication is doing the same job the state-machine
fallback was doing — absorbing bugs and reporting success — just less visibly, because copied blocks
still produce plausible output. That is the same trap as the phantom edge and the duplicate loops:
correct-looking output, wrong reason.

**The real defect count is ~6,300 protos, not 2.** And duplication is not free even when it "works":
it inflates the emitted source (one proto consumed 2,000,000 copies), and every copy is a place where
a later pass can diverge.

### Revised goal
Not "2 fallbacks -> 0". The target is **6,296 duplication-dependent protos -> 0**, with the fallback
deleted rather than tuned. `needed duplication` is now printed every run so this cannot be
re-flattered.

### Adversarial checking (user's request) — what it will need
Once M6e emits, "are the protos clean" must be attacked, not assumed:
1. **Round-trip equivalence** on all 5,386 — `decompile -> emit -> luau-compile -> lbc-cmp`.
2. **Differential structuring** — run with duplication ENABLED vs DISABLED and require identical
   emitted source. Any proto whose output changes was being papered over. (This works TODAY at the
   structure level and should be built first.)
3. **Idempotence** — decompile -> recompile -> decompile, require source1 == source2.
4. **In-game** on a real script.
Metrics that only count completeness (blocks placed, instructions consumed) have now failed to catch
three separate corruption bugs in one day and must not be treated as evidence of correctness.

## 2026-07-25 — STRUCTURAL ANALYSIS: 99.03% with ZERO DUPLICATION (descent managed 92.32%)

The user rejected fallbacks as "a cope" and told me to go all out. Fable had already diagnosed the
architecture: patching a pattern pile has infinite residue BY CONSTRUCTION — there is always one more
shape — which is exactly why five rounds of fixes asymptoted at 2-3 protos without closing.

Web reference confirmed the right algorithm: **structural analysis** (Muchnick ch.7.7; Schwartz et al.,
*Native x86 Decompilation using Semantics-Preserving Structural Analysis*). It is BOTTOM-UP GRAPH
REDUCTION, not top-down traversal: repeatedly match a region shape, collapse it to one abstract node,
repeat. A reducible graph is GUARANTEED to reduce to a single node, so "did it reach one node?" is a
complete success test **with no duplication available as a crutch**.

`src/structan.h` + `derecomp sa-validate`. Progress as patterns were added, all at ZERO duplication:

| pattern set | ground truth | corpus |
|---|---:|---:|
| seq / if-then / if-then-else / self-loop / while | 91.50% | 60.38% |
| + arms that TERMINATE (`if c then return end`) | 96.94% | 80.53% |
| + general NATURAL LOOPS | **100.00%** | 97.85% |
| + multi-exit loops (breaks are just `break`) | **100.00%** | **99.03%** |

```
GROUND TRUTH  294 / 294  = 100.0000%  reduced to ONE region, zero duplication
REAL CORPUS   81,247 / 82,042 = 99.0310%  zero duplication (795 protos left, stalling at 4-6 regions)
```

**Compare honestly against the recursive descent**, which needed copying for 6,296 protos:
```
descent, zero duplication   : 92.32%
structural analysis, zero dup: 99.03%
```
The reduction算法 recovers 6.7 points that the descent could only reach by copying blocks — i.e. ~5,500
protos the descent was papering over are structured HONESTLY here.

Two of the four pattern additions were things I had refused for bad reasons:
- **arms that terminate**: I required an `if` arm to HAVE a successor, so `if c then return end` never
  matched — 11,723 protos were stalling at exactly 3 regions because of it.
- **multi-exit loops**: I skipped any loop with more than one exit, but extra exits are `break`s and
  Lua writes them directly. That refusal alone accounted for 971 protos.

### Next
795 protos still stall (4-6 regions each). The missing shapes are proper/improper regions — acyclic
subgraphs that match no simple template. Muchnick's answer is a `Proper` region node; Schwartz et al.
use iterative refinement. Neither needs duplication, and the fallback should be DELETED, not tuned,
once they land.

## 2026-07-25 — ★ M6d COMPLETE: 82,042 / 82,042 = 100.0000%, ZERO duplication, NO fallback ★

```
fully reduced to ONE region : 82,042 / 82,042  (100.0000%)
irreducible residue         : 0
ADVERSARIAL coverage check  : 82,042 clean, 0 BAD, 0 missing blocks, 0 duplicated blocks
ground truth (all 3 sets)   : 294 / 294 = 100.0000%, 0 BAD
deterministic across runs   : identical output
```

The user refused every intermediate excuse — "no world 3 protos happened to be irreducible", "fallbacks
are a cope", "protos are a must fix, just like opcodes". Every refusal was correct. Fable's diagnosis
was the turning point: **patching a pattern pile has infinite residue BY CONSTRUCTION**, so five rounds
of heuristics asymptoted near 3 without ever closing. The answer was to change algorithm, not to add
a sixth patch.

### The four patterns that closed it, all at ZERO duplication
| added | ground truth | corpus |
|---|---:|---:|
| seq / if-then / if-else / self-loop / while | 91.50% | 60.38% |
| + arms that TERMINATE (`if c then return end`) | 96.94% | 80.53% |
| + general NATURAL LOOPS | 100.00% | 97.85% |
| + multi-exit loops (breaks are just `break`) | 100.00% | 99.03% |
| + generalised IF-THEN for >2 successors | 100.00% | 99.68% |
| + N-WAY CONVERGENCE (if/elseif chains) | 100.00% | 99.76% |
| + **PROPER REGIONS** (single-entry single-exit DAGs) | **100.00%** | **100.0000%** |

Each was found by DUMPING THE RESIDUAL GRAPH and reading it — never by tuning. The residuals named
their own shapes: a 3-successor node whose arms converge, a DAG with cross edges.

### For comparison, the recursive descent it replaces
```
descent, honest (zero duplication) : 92.32%     6,296 protos needed COPYING
descent + duplication + fallback   : 99.9976%   2 protos still unstructured
structural analysis, zero dup      : 100.0000%  0 protos unstructured, 0 copies
```
The descent's 99.9976% was bought with ~15,700 block copies and a dispatch-loop fallback. Structural
analysis needs neither.

### The adversarial check (user's explicit request)
"Reduced to one region" is worthless if that region does not CONTAIN everything. `verify_coverage`
walks the final region tree, collects every Basic block, and requires each reachable block to appear
**exactly once** — catching both silent loss and silent duplication, the two failure modes that hid
the phantom edge and the duplicate loops earlier today.
**Result: 82,042 clean, 0 missing, 0 duplicated.** Plus determinism confirmed by identical output
across runs, and all three independently-generated ground-truth sets at 294/294.

### Everything else still green
round-trip 5382/5382 byte-exact | de-recode LOSSLESS | de-validate 0 violations / 5,529,086 |
IR 5,529,086/5,529,086 | expr 0 unhandled | de-ktags 0 suspects | de-fastcall 165,605/165,605

### What this does NOT prove
Coverage and reduction are STRUCTURAL guarantees: every block placed exactly once, every graph fully
reduced. They do NOT prove the recovered nesting MEANS what the bytecode means. Twice today a metric
sat at 100% while output was being deformed. The remaining instrument is the round-trip oracle
(decompile -> emit -> luau-compile -> compare bytecode), which needs M6e. The state-machine fallback
should be DELETED as part of that work — it is now provably dead code.

## 2026-07-25 — STANDING CAVEAT RECORDED: structurally complete != semantically correct

M6a/b/c/d now all read 100%. Before treating that as done, the caveat is written into `CLAUDE.md`
(top banner) and `M6_PLAN.md`: **every one of those is a COMPLETENESS metric.**

Operands resolved, blocks placed exactly once, instructions dispatched, graphs fully reduced — none of
it demonstrates the recovered code MEANS what the bytecode means. Today gave three proofs of that gap,
all with identical 100% scores on both sides of an A/B:
- phantom `FORGPREP` edge: ~9,000 protos misclassified, ~15,700 loops misshaped
- duplicate loop registrations: ~450,000 constructs shifted
- SETLIST / multret: `{1,2,3}` -> `{}`, `return math.max(a,b)` -> bare `return`

**Practical consequences, recorded so they are not forgotten under time pressure:**
1. Do NOT publish or regenerate the corpus for reading until the round-trip passes. Wrong-but-plausible
   source is worse than none — it gets read, believed, and edited against.
2. Do NOT call M6 output "verified"/"correct"/"clean". Say STRUCTURALLY COMPLETE.
3. Do NOT retire `all_source_v13/v14/v15` yet. Contaminated and useless as an oracle, but still the
   only existing reference until ours is proven.

The caveat lifts when `decompile -> emit -> luau-compile -> lbc-cmp` passes. Harness is built and
self-tested (catches ADD-vs-SUB and `<=`-vs-`<`); it needs M6e to have input.

## 2026-07-25 - M6e emission: 45.58% -> 100% compilable, and two SILENT correctness holes

Hypothesis: the M6e emitter was structurally complete, so the remaining gap to valid Luau was
cosmetic rendering (closures printed as `function<0>`).

Finding: **Partially true.** The closure placeholder was indeed the largest single cause, but fixing
it exposed two defects that were NOT cosmetic - both produced code that COMPILED CLEANLY and MEANT
THE WRONG THING. Compilability rose 45.58% -> 92.52% -> 94.56% -> 96.94% -> **294/294 = 100.0000%**
on the 142 generated ground-truth files (0 emit failures, 0 compiler rejections).

Evidence: `derecomp emit-validate cert/rt/de` (the compilability oracle - our text is handed to the
real `luau-compile.exe`), plus `de-disasm` on `ctrl_fornum` / `ctrl_forpairs` read against their
known source.

### DEFECT #31 - no end-of-block flush; cross-block values silently read nil
`ex::reconstruct_block` propagated each defining EXPRESSION into a register and emitted it only where
it was consumed **within the same block**. A value defined in one block and read in another was
therefore NEVER ASSIGNED. Because `emit_function` declares every register as a local at function top,
`return v3` still PARSED AND COMPILED - it just returned nil. Invisible to every metric we had.

### DEFECT #32 - identity-bearing values re-materialised at each use
The same propagation re-rendered a table constructor at every read, so
`local t = {a,b}; t[a] = b; return t` decompiled to `{v0,v1}[v0] = v1; return {v0,v1}` - THREE
distinct tables instead of one aliased table. Here syntax accidentally saved us (`{}` cannot begin a
statement), but had the shape been `t.f = b` it would have compiled and been silently wrong.

**Fix for both: MATERIALISE every register definition as `vA = <expr>` at its definition point.**
That is a literal translation of a register machine and cannot be wrong. The single exception is a
multret CALL result, which must stay propagated because a stack-top range cannot cross a block
boundary anyway. Re-inlining single-use temporaries is now a READABILITY pass that must be proven
separately - it is no longer load-bearing for correctness.

### DEFECT #33 - `maxreg` counted only WRITTEN registers
Generic-for loop variables are read but never appear as an `A` operand, so `v6` was used without
being declared - making it a **global read of nil**, which compiles. Fixed to `ip->maxstack - 1`.

### The two for-loop layouts are ASYMMETRIC (measured, not assumed)
- numeric `FORNPREP A`: `A+0`=limit, `A+1`=step, `A+2`=index, **and the loop variable IS the index at
  A+2** - `ctrl_fornum` has `maxstack=5`, so no `A+3` exists at all.
- generic `FORGLOOP A`: `A+0`=generator, `A+1`=state, `A+2`=control, **loop vars at `A+3`..**, `aux`=#vars.

I had assumed A+3 for BOTH (from upstream Luau's `setnvalue(ra+3, idx)`). The disassembly refuted it
for the numeric case. Same trap as the FORGPREP/FORNPREP conditionality asymmetry - **the two for
families never match; check each one against bytecode.**
A for-loop also reaches emission as an `IfThen` (FORNPREP is conditional), not as a loop region, so
the head block's terminator must be checked BEFORE asking `cond_of` for a boolean that does not exist.

Verified against known source: `for i=1,n do s=s+i end` -> `for v4 = v4, v2, v3 do v1 = v1 + v4 end`
(v4=1, v2=n, v3=1); `for k,v in pairs(t) do s=s+v end` -> `v2,v3,v4 = pairs(t); for v5,v6 in
v2,v3,v4 do v1 = v1 + v6 end`. Both correct.

### What this does and does NOT prove
**Compilability is VALIDITY, not CORRECTNESS.** Defects #31 and #32 are the proof: both compiled at
100%. The STANDING CAVEAT is unchanged - `all_source_v13/v14/v15` stay, the corpus is not
regenerated, and no output is called "verified".

Reason: every check so far asks "is this well-formed?". None asks "does it mean the same thing?".

Next Step: the round-trip oracle. Blocker found - **there is no Luau interpreter on this machine**,
only `luau-compile.exe`, so behavioural equivalence is not reachable offline yet. Building the `luau`
REPL target from the existing `C:\Users\Bartek\LuauBuild` tree would supply it and is the highest
-value next move. Exact-bytecode equality will NOT work as an oracle now: materialisation introduces
temporaries, so recompiled bytecode legitimately differs in register allocation.

## 2026-07-25 - DEFECT #34: EVERY `if` IN THE PROGRAM WAS INVERTED (found at 100% compilability)

Hypothesis: with 294/294 emitting and 294/294 compiling, the remaining risk was readability, not
meaning.

Finding: **FALSE, and this is the most important defect of the project so far.**

Evidence: ground truth `ctrl_if` - source `function f(a) if a then return 1 end return 0 end`
decompiled to `if not v0 then v1 = 1 return v1 end v1 = 0 return v1`. **The exact opposite program.**
Same inversion in `ctrl_ifelse` and `ctrl_elseif`, and in real shipped code
(`Deck12GlyphTransmissions`) where all three guard clauses came out backwards.

Reason: `cond_of` renders "the branch is TAKEN". Luau compiles `if a then BODY end` as
`JUMPIFNOT a -> past the body`, so the THEN region is the **fallthrough** and its guard is the
NEGATION of the taken-condition. `emit_region` called `cond_of(hb, false)` unconditionally - the
`negate` parameter existed and was never once passed `true`.

Fix: ask the graph which successor the then-region actually is. `st::Node` already distinguished
`succ_true` (taken) from `succ_false` (fallthrough); the emitter simply never consulted it.
`negate = (thenblk == succ_false && thenblk != succ_true)`. Also added `invert_cond`, which negates by
INVERTING the comparison (`==` <-> `~=`, `<` <-> `>=`) instead of emitting `not (not a)` - applied only
when there is a single test, because negating a short-circuit chain needs De Morgan on the connectives.

**This is the definitive proof of the STANDING CAVEAT.** The bug survived: 100% IR operand resolution,
100% CFG, 0 unhandled instructions, 100% structuring with 0 missing/duplicated blocks, AND 100%
compilability. Every metric was green while every branch in every script was backwards. Compilability
is VALIDITY, not CORRECTNESS - it was found by reading four lines of decompiled output against four
lines of known source, which no automated metric we had was asking.

### DEFECT #35 - `maxreg` scanned operand `A` of every instruction
`A` is not always a destination register. **FASTCALL's `A` is a BUILTIN ID** - and DE's `IsNull` is
id 133, so every proto calling `IsNull` declared 134 phantom locals (against Luau's 200-local limit).
The same scan also MISSED registers that are only ever read - generic-for loop variables - which then
silently became **nil global reads**. Fixed: `maxstack` is the frame size by definition, so registers
are exactly `v0..maxstack-1`; it is authoritative and the scan is not.

### DEFECT #36 - the oracle harness could not run twice at once
`emit-validate` wrote a fixed `_emit_probe.luau` in the CWD. Two concurrent runs clobbered each other
and reported **27.55% instead of 100%** - a harness that silently produces garbage rather than
failing. Fixed to a process-unique probe filename. Noted because a corpus sweep was running in the
background at the time and its numbers were contaminated; it was killed and restarted.

Next Step: the polarity class is not necessarily exhausted. Loop exit conditions, `while` headers, and
the short-circuit `chain_and` connectives have the SAME taken-vs-fallthrough ambiguity and are NOT yet
checked against ground truth. Check each against known source the same way - by reading output against
input, not by counting.

## 2026-07-25 - DEFECT #37: `while` AND `repeat` LOOPS ARE EMITTED AS PLAIN `if` - THE LOOP IS GONE

Hypothesis (follow-up to #34): the taken-vs-fallthrough polarity class might also affect loop headers.

Finding: **True, and far worse than polarity** - the loop construct itself is lost.

Evidence, ground truth read against known source:
- `while i < n do i = i + 1; s = s + i end` -> `if v2 < v0 then v2 = v2 + 1 v1 = v1 + v2 end`
  The back edge is GONE; the body executes ONCE instead of looping.
- `repeat i = i + 1 until i >= n` -> body once, then an EMPTY `if v0 > v1 then end`.

The back edge is unambiguously present in the bytecode (`ctrl_while` proto 0):
`[2] 0x1c` (>=) exits forward to the RETURN, and `[5] 0x40` JUMP has `Bx=65531` = **-5 words**,
landing back on `[2]`. Note the back edge here is a **backward `JUMP` 0x40, not `JUMPBACK` 0x25** -
both forms occur and both must be treated as loop edges.

**NOT a regression from today.** Binaries `e2` and `e6` (before today's region-case merge) lose the
loop identically. Today's fixes corrected the condition polarity (`>=` -> `<`) and restored the body
statements, which made the defect legible - the loop was never emitted in the first place.

Reason: `emit_region` only produces a loop for region kinds SelfLoop / While / NaturalLoop. These
protos arrive as **IfThen**, so the structural analyzer is classifying a cyclic region as an acyclic
one.

### THE METRIC THAT MISSED IT
M6d reported **82,042/82,042 = 100.0000% structured, 0 missing / 0 duplicated blocks**. That metric
asks "did the graph REDUCE, and is every block placed exactly once?" - it never asks "is the region
the RIGHT KIND?". A loop mislabelled IfThen still reduces, still covers every block exactly once, and
still passes the adversarial coverage check. **Reduction is not classification.**

Next Step: audit `sa::Analyzer` region KINDS, not just reduction. Concretely: for every region, assert
that a region containing a back edge is classified as a loop kind, and that no IfThen region contains
one. That is a cheap corpus-wide falsification test in the same style as `de-deadaudit` T1-T4, and it
should be written BEFORE any further emission work. Then re-check `while`, `repeat`, and loops with
`break`/`continue` against known source.

## 2026-07-25 - THE BEHAVIOURAL ORACLE EXISTS. 75.35% -> 85.92% correct.

Hypothesis: a real Luau interpreter would turn "does it compile?" into "does it MEAN the same?", and
would catch the defect classes that 100% compilability missed.

Finding: **True.** Downloaded the open-source Luau CLI 0.731 (`luau.exe`, luau-lang/luau) to `bin/`.
Deliberately did NOT take the bundled `luau-compile.exe` - ours is the build the whole opcode map and
the 5382/5382 round-trip are certified against, and silently swapping it would invalidate all of it
(verified unchanged by SHA256 before/after).

**`cert/behave.py`** runs known source S and our decompiled S' under the real interpreter with 20
argument tuples and compares observable results. Deterministic table dumper (tostring on a table is an
ADDRESS), error messages stripped of "chunk:line:", and a TIMEOUT because a wrongly-recovered loop
spins forever.

### Score, honestly
| stage | behaviour |
|---|---|
| start | 107/142 = 75.3521% |
| + #37 loops recovered | 108/142 = 76.0563% |
| + LOADB skip edge | 113/142 = 79.5775% |
| + arm-swap instead of negation | **122/142 = 85.9155%** |
Compilability stayed 294/294 = 100% and structuring 82,059/82,059 = 100% (0 missing/0 dup) throughout.

### DEFECT #37 FIXED - loops were absorbed as if-arms
`src/structan.h` generalised-IfThen had `if (!succ[n].count(x) && x != n)`. That `x != n` EXEMPTION
absorbed a BACK EDGE as an if-arm, so `while i<n do ... end` became `if ... then ... end`. Dropped the
exemption; also added `is_loop_header(n)` (a predecessor reachable FROM n) to guard both greedy
absorption patterns, and moved the WHILE pattern AHEAD of the acyclic 2-successor patterns - otherwise
IfThen absorbs the loop EXIT arm and destroys the loop just as surely.
`src/emit.h` then emitted `while true do <parts> break end`, whose trailing unconditional break caps
every loop at ONE iteration - structurally a loop, behaviourally a straight line. Now emits the real
exit test. `ctrl_while` is now EXACT against source:
  `local s=0 local i=0 while i<n do i=i+1 s=s+i end return s`
  -> `v1=0 v2=0 while v2 < v0 do v2=v2+1 v1=v1+v2 end return v1`

### DEFECT #38 - LOADB's `C` IS A SKIP COUNT and was never modelled as an edge
`LOADB A B C` sets R[A]=B then SKIPS the next C instructions. It is how Luau compiles a
VALUE-producing comparison: `return a < b` is
  `JUMPIFLT -> true-arm ; LOADB R,false,skip 1 ; LOADB R,true ; RETURN`
Unmodelled, the false arm falls straight into the true arm, so **`a < b` decompiled to a constant
`true`** - and compiled perfectly. Fixed in BOTH places it matters: `build_cfg` now makes leaders at
the skip target and the fallthrough, and `build_graph` emits it as an unconditional edge.
**This was previously recorded as a benign "unmodelled skip-offset" by the dead-code audit (T2). It
was not benign.** T2 only asked whether the skip could reach a DEAD block; it never asked whether the
missing edge corrupted LIVE code.

### DEFECT #39 - negating a comparison is not equivalent
For a two-armed if, inverting the test (`<` -> `>=`) is wrong under **NaN** (`a<b` and `a>=b` are BOTH
false) and changes evaluation order - Lua implements `a >= b` as `b <= a`, so operands come out
REVERSED. Caught because the interpreter's error text read `attempt to compare nil <= number` where
the original said `number < nil`. Fixed by SWAPPING THE ARMS instead of negating, which preserves the
original operator exactly. Negation now only remains where there is a single arm and nothing to swap.

### Remaining 20 failures (for the next session)
cmp_eq_knil cmp_ne_knil | ctrl_break ctrl_forgeneric ctrl_repeat ctrl_whiletrue |
func_closure1 func_closure3 func_closure_mut func_method func_nested2 func_recurse func_vararg
func_vararg_fwd | imp_tostring | logic_chain logic_guard | mix_guardcall | tbl_bigarray tbl_dynamic

Next Step: the `func_*` cluster is now the largest (8). Prime suspect: UPVALUES - the emitter renders
them as `u0`, `u1`, which is not bound to anything in the emitted text, so a closure reading an upvalue
reads a nil GLOBAL. Same shape as defect #35. Then `logic_*` (short-circuit chains + De Morgan) and
`tbl_*` (SETLIST).

## 2026-07-25 - AUDITING THE ORACLE ITSELF: 11 vacuous passes, and a mutation audit

Hypothesis: the 122 "SAME" verdicts are real evidence that those cases are correctly decompiled.

Finding: **Partially true - 11 of them were VACUOUS**, and the mutation audit initially looked far
worse than it was because of a flaw in the audit, not the decompiler.

### Vacuous passes (fixed)
A match is only evidence if the probe OBSERVED something. Where `f` was never defined, or every
argument tuple raised, S and S' agreed on nothing but failure - and the case would still "pass" after
arbitrary corruption. `behave.py` now reports these separately. Found **11**, from two causes, both in
the PROBE rather than the decompiler:
- argument tuples that did not fit the functions (3-4 args, `(table, key, value)` shapes were absent),
- **side effects were never observed at all** - `glob_write` returns nothing; its entire behaviour is a
  global assignment. Now the probe diffs the function environment before/after each call and dumps any
  table argument after the call, catching in-place mutation too.
Vacuous count **11 -> 2** (`func_callargs`, `tbl_field_chain`, both still needing better arguments).
Honest score with vacuous excluded: **120/142 = 84.51%**.

### MUTATION AUDIT - `python3 cert/behave.py --mutate`
Corrupts the decompiled source (`+`->`-`, `<`->`<=`, `==`->`~=`, `true`->`false`, drop `not`) and
requires the oracle to NOTICE. A pass that survives mutation is passing by luck and would not catch a
regression either. Result: **68 cases with an applicable mutation, 68 DETECTED, 0 SURVIVED.**

**The first run reported ~20 survivors - and that was the AUDIT's bug.** The emitted text contains each
function TWICE: the standalone `function proto_N` and the copy INLINED into the module chunk, which is
the one the probe actually runs. Mutating only the first occurrence corrupted the dead standalone copy,
so nothing changed. Mutating ALL occurrences took survivors to zero. Same lesson as the LOADB/T2 case:
**verify the harness before believing its verdict** - and prefer the harness explanation first, since
here it was the harness both times.

### DEFECT #40 (open) - UPVALUES ARE EMITTED UNBOUND
`func_closure1`: source `function f(a) local function g() return a end return g() end` emits
`v0 = u0`. **`u0` is bound to nothing** - it is a free name, so it reads a nil GLOBAL. Exactly the
shape of #35. Because closures are INLINED lexically into the parent, an upvalue can simply be replaced
by the PARENT's register name; the `CAPTURE` opcodes (0x35, currently skipped as "part of closure")
say precisely which parent register or upvalue each one comes from. This is the root cause of most of
the 8-case `func_*` cluster.

Next Step: implement #40 (map `u<i>` -> parent register via the CAPTURE list at each closure site),
then `logic_*` (short-circuit chains, De Morgan on the connectives) and `tbl_*` (SETLIST).

## 2026-07-25 - Harness 9.5x faster; DEFECT #40 (unbound upvalues) fixed

### Why iteration was slow (measured, not guessed)
`emit-validate` spawns `luau-compile.exe` ONCE PER PROTO at ~0.5s of process-spawn overhead. Over
82,042 corpus protos that is **~11 hours** - the background corpus sweep was never going to finish, and
it silently died (0 bytes output, no process). It was mis-sized when launched. The corpus sweep is
DROPPED: it only measures VALIDITY, which is already 100% on ground truth, and the behavioural oracle
is strictly better evidence at a fraction of the cost.

`behave.py` now evaluates cases through a thread pool (cases are independent processes; subprocess
releases the GIL). **1m42s -> 10.8s, identical results.** Batching many chunks into ONE `luau.exe`
invocation would be faster still, but chunks would share global state and contaminate each other -
isolation is worth more than the extra speed.

### DEFECT #40 FIXED - upvalues were emitted UNBOUND
`function f(a) local function g() return a end return g() end` emitted `v0 = u0`, where **`u0` was
bound to nothing** - a free name reading a nil GLOBAL. The `CAPTURE` instructions FOLLOWING a closure
say exactly where each upvalue comes from (`CAPTURE A B`: A = 0 VAL / 1 REF, B is a register;
A = 2 UPVAL, B is one of our own upvalues). They were being skipped as "part of closure".
Fix: record the capture list into the placeholder (`function<N|v0,u1,...>`) and have the inliner bind
`u<i>` to the parent's name. Recursion runs BEFORE substitution, so a nested closure has already
reduced its own captures to this proto's names and a whole capture CHAIN resolves correctly.

**A second defect surfaced underneath it: NAME COLLISION.** The inlined body declares its own
registers as locals, so the sub-proto's `local v0` SHADOWED the parent's `v0` and the capture read the
inner nil - `v0 = v0`. Each inlined body now gets a unique register prefix (`c<serial>v<i>`), applied
BEFORE capture substitution so parent names stay parent-scoped. Verified:
`v1 = function() local c1v0 c1v0 = v0 return c1v0 end`.

Score 84.5070% -> **85.9155% (122/142)**, compilability still 294/294.

Next Step: `logic_*` (short-circuit chains; negating one needs De Morgan on the connectives),
`tbl_*` (SETLIST), `ctrl_break`/`ctrl_repeat`/`ctrl_whiletrue`, `cmp_*_knil`. Also still owed: the
standalone corpus-wide "no IfThen region contains a back edge" assertion, and parallelising
`mutate_audit` (still sequential, ~5x the oracle's cost).

## 2026-07-25 - DEFECT #41: DUPCLOSURE inlined the WRONG FUNCTION. 85.92% -> 90.14%

Hypothesis: after binding upvalues (#40), the remaining `func_*` failures were more capture problems.

Finding: **False - the closure IDENTITY was wrong.** `NEWCLOSURE` (0x16) takes the sub-proto index
DIRECTLY, but **`DUPCLOSURE` (0x42) takes a CONSTANT index whose tag-6 payload holds the proto index**
(`ir::KVal.sub`). We used `Bx` as a proto index for both.

Evidence: `func_closure1` (`function f(a) local function g() return a end return g() end`). The module
chunk emitted `f = function() local c2v0 c2v0 = u0 return c2v0 end` - that is **`g`, the inner closure,
being installed as `f`**. Const 0 happened to point at proto 0 in simpler cases, which is why it went
unnoticed: the bug only shows when the const index and the proto index DIVERGE.

It compiled perfectly at 100% the whole time, because any sub-proto is syntactically a valid function.
Only running it revealed that the wrong one was being called.

Fix: resolve `Bx` through the constant table when `op == 0x42` and the const is `KKind::Closure`.

### Also fixed: harness normalised table VALUES but not table KEYS
Three `tbl_*` cases reported a false mismatch because a table used as a dict KEY renders through
`tostring` as an ADDRESS, which differs every run - and it was also the SORT key, so ordering was
unstable too. Canonicalised keys the same way as values (`<tbl>` / `<fn>`). **These were never
decompiler bugs.**

Score: 85.9155% -> **90.1408% (128/142)**, compilability still 294/294, structuring 100%.

Running total of defects the behavioural oracle caught that 100% compilability did NOT:
#34 inverted ifs · #37 lost loops · #38 LOADB skip edge · #39 comparison negation · #40 unbound
upvalues + inlined-body name collision · #41 DUPCLOSURE wrong proto. **Six, all of which compiled.**

Next Step: 11 left. `logic_guard`/`mix_guardcall` (short-circuit `a and a.x` emitted WITHOUT the guard,
so it indexes nil - needs the chain/chain_and rendering), `ctrl_break`/`ctrl_repeat`/`ctrl_whiletrue`,
`func_vararg`/`func_vararg_fwd`, `cmp_*_knil`, `imp_tostring`.

## 2026-07-25 - ★ 142/142 = 100.0000% BEHAVIOURAL, 0 VACUOUS, 0 MUTATIONS SURVIVED

Hypothesis: the remaining failures were several unrelated bugs.

Finding: **True**, and all are fixed. Ground truth is now 100% behaviourally identical under the real
Luau interpreter. Four gates pass SIMULTANEOUSLY:

| gate | result |
|---|---|
| behavioural (S vs S' in real luau.exe, 33 arg tuples) | **142/142 = 100.0000%, 0 vacuous** |
| compilability (real luau-compile.exe) | 294/294 = 100.0000% |
| structuring (82k REAL corpus protos) | 82,059/82,059, 0 missing / 0 duplicated |
| mutation audit (does the oracle detect corruption?) | 77/77 detected, **0 survived** |

### Defects fixed in this final run
- **#42 JUMPXEQKNIL polarity inverted.** aux bit31 is the NOT flag: SET = "branch when NOT nil". We
  had it backwards, so `if a == nil then return 1 else return 2 end` returned the WRONG branch.
- **#43 GETVARARGS assigned only ONE register.** `A B` produces B-1 values into A..A+B-2, so
  `local a, b = ...` left `b` permanently nil.
- **#44 comparisons rendered in the wrong operand order.** Lua's VM has ONLY LT and LE - `a > b` IS
  `b < a`. Rendering `>`/`>=` preserves truth but reverses the operands the VM evaluates, diverging in
  error text and under NaN. Now only `<` / `<=` are emitted, in the VM's own order. Related: loop
  EXIT tests are emitted directly instead of negating the enter-body test.
- **#45 short-circuit merge hoisted guarded statements.** The chain merge folded a successor block
  into its predecessor even when that block held a STATEMENT before its test, so `t and t.x and t.x.y`
  ran `v1 = v0.x` BEFORE the `t` check and indexed nil. A chain is only sound when the later tests are
  PURE TEST (`F.first == F.last`).
- **#46 SETLIST batches overwrote each other.** A constructor with >16 array elements is emitted as
  several SETLIST batches, each with its own start index in `aux`. Rebuilding the constructor per
  batch REBOUND the register, so `{1..20}` decompiled to `{17,18,19,20}`. Only the batch starting at
  index 1 is the constructor; later batches are appends.
- **#47 `break` was never emitted.** A branch inside a loop whose target LEAVES the loop is a `break`;
  `SK::Branch` was dropped on the assumption a region template owned the control flow, which is false
  for a block sitting directly in a loop body. `for i=1,n do if i>3 then break end ... end` became an
  INFINITE loop - caught by the oracle as a TIMEOUT, which is exactly why the timeout exists. Also: a
  NaturalLoop CONTAINING a for-latch IS the for's iteration and must not get a second `while true`.
- **#48 Proper regions emitted with ALL CONTROL FLOW DROPPED.** `RK::Proper` fell through to
  `default:` and emitted its parts sequentially, so `a and b or c` decompiled to `v3 = v1  v3 = v2
  return v3` - straight-line code with the logic deleted. Now emitted as a flag-guarded topological
  linearisation: each block sets its successors' entry flags, every non-entry block runs under its own
  flag. Exact, and needs NO block duplication (the region is acyclic, and code order IS a topological
  order).

### Harness defects fixed (these were never decompiler bugs)
- table used as a dict KEY rendered as an ADDRESS (and was the sort key, so ordering was unstable too);
- `tostring(table)` RETURNS a string containing a pointer - canonicalised `0x%x+` to `<addr>`;
- argument tuples that did not fit the functions (callable arg, nested field chain, object with a
  method), which had left 11 cases agreeing only about failure.

### WHAT 100% DOES AND DOES NOT MEAN
It means: on 142 generated cases covering all 77 opcodes, our decompiled source is behaviourally
INDISTINGUISHABLE from the original, the comparison observed real values (0 vacuous), and the oracle
provably detects corruption (77/77 mutations killed).
It does NOT yet mean the decompiler is correct on the 5,386 REAL scripts. Those cannot be run offline
(`Engine.*`, `gRegion`, `IsNull` do not exist outside the game), so for them we still have only
structural + compilability evidence. Closing that needs either a stub environment or an in-game test.

## 2026-07-25 - FULL EDIT ROUND-TRIP: 141/142 = 99.2958% behavioural

`cert/behave.py --roundtrip` now tests the WHOLE loop, not just the read direction:
  DE bytecode -> decompile-mod -> recompile -> DE' -> decompile -> run against the ORIGINAL source.
New command `derecomp decompile-mod` emits the chunk proto's BODY with closures inlined - that alone
IS the module. (`decompile` prints each proto standalone for READING; recompiling that would produce a
different proto layout.)

Result: **141/142 = 99.2958%**, read-direction still 142/142.

### DEFECT #49 - `recompile` used a FIXED temp filename
`compile_luau` wrote `_derecomp_luaubc.tmp`, so 16 parallel workers overwrote each other's compiler
output. The parallel round-trip reported **30.99% when the real answer was 99.30%** - and a serial
single-case run was 100%. **This is the THIRD time a fixed temp filename has produced a bogus number**
(#36 `_emit_probe.luau`, and the killed corpus sweep). Any temp path in this codebase must be
process-unique; treat a suspiciously bad parallel result as a harness race until proven otherwise.

### The one remaining round-trip case, stated precisely
`cmp_boundary` (`return a <= a, a < a, a >= a, a > a`). Our pass-1 source is CORRECT - all four
comparisons recover exactly, including `a >= a` -> `a <= a` and `a > a` -> `a < a`. The divergence is
ONLY which comparison raises FIRST when the argument is not comparable: the evaluation order of four
INDEPENDENT comparisons shifts when our source is recompiled. Every non-error input agrees. Real but
minor; worth fixing for exactness, not a semantic hazard.

### Idempotence is the WRONG oracle for this pipeline - do not chase it
Textual idempotence fails on 59/60 real scripts, and that is EXPECTED, not a bug:
- our `local v0, v1, ...` declarations compile to real LOADNIL, which we then faithfully decompile
  back as `v0 = nil` statements;
- materialising every definition turns Luau's argument-setup MOVEs into named temporaries, so each
  pass adds a layer.
The text therefore GROWS per pass and never reaches a fixed point (0/60 stable). This is a QUALITY
issue (output inflation over repeated round-trips), not a correctness one - the behavioural oracle
puts the round-tripped module at 99.30%. Re-inlining single-use temporaries would shrink it; that is a
readability optimisation and must be proven against the oracle, not assumed.

## 2026-07-25 - ★★ 142/142 BOTH DIRECTIONS + stub environment for the real corpus

### THE HEADLINE
| gate | result |
|---|---|
| behavioural, READ direction (S vs S') | **142/142 = 100.0000%** |
| behavioural, **FULL EDIT ROUND-TRIP** (S vs decompile(recompile(S'))) | **142/142 = 100.0000%** |
| compilability | 294/294 = 100% |
| structuring, 82k REAL protos | 82,059/82,059, 0 missing / 0 dup |
| mutation audit | 77/77 detected, 0 survived |
| DE container round-trip (emission side untouched) | 5,386/5,386 byte-exact |

### DEFECT #50 - if/else polarity did not match the OPCODE's polarity
The last round-trip failure (`cmp_boundary`). With two arms there is a CHOICE: swap the arms, or negate
the condition. Both are semantically correct, but they differ observably - negating reverses the
operand order Lua evaluates, so `a <= a` was rewritten as `a < a` and a DIFFERENT comparison raised
first on a non-comparable argument.
Established from a recompile whose source I controlled: **0x33 = JUMPIFNOTLE, 0x1c = JUMPIFNOTLT** -
these are inherently NEGATED tests, so the source-level comparison is the inverted one and its `then`
arm is the FALLTHROUGH. Rule now applied: pick the form matching the opcode's own polarity -
positive test (JUMPIF/JUMPIFEQ/JUMPIFLT/JUMPIFLE) -> then-arm is the TARGET; NOT test -> then-arm is
the FALLTHROUGH. Only applied when the block is a single test; a merged short-circuit chain needs
De Morgan and is left alone.

### THE STUB ENVIRONMENT (`cert/realtrip.py`)
Real scripts have NO known source, so S-vs-S' is impossible. The answerable question is S' vs S''
(the round-tripped module) under a mocked engine, comparing execution TRACES.
**Luau REMOVED `loadstring`, `setfenv`, `getfenv` and `dofile`**, so the environment cannot be swapped
at runtime. Instead the stub globals are pre-declared TEXTUALLY - our emitter declares every register
as a local (`vN`/`cNvM`/`pN_M`), so any other bare identifier is provably a global. Every engine value
is a proxy with total, deterministic metamethods (stable path names, never addresses; `__lt`/`__le`
return false rather than raising, or the trace truncates at a meaningless point).
Two harness bugs found and fixed on the way: the module body ends with `return`, which must be the LAST
statement in a block (wrap it in a function, or the appended entry calls parse as the return
EXPRESSION); and the entry list must be SHARED between both sources or the comparison is not
apples-to-apples.

**Current real-corpus result: 40 files -> 24 SAME, 14 DIFFERENT, 2 timeout.**

### HONEST STATUS OF THE 14 - a HARNESS limitation, not yet a proven decompiler bug
Every one differs at the same place: S'' emits a traced `SET _G.X = ...` where S' does not. A plain
global assignment (`X = 1`, SETGLOBAL) fires NO metamethod, so the stub CANNOT observe it, while a
`_G.X = 1` field write goes through the proxy and IS traced. So the two sources may be writing the same
values by different mechanisms and only one is visible. **This is not yet evidence of a defect, and it
must not be reported as 24/40 "correct" either** - the harness is under-observing.
Next step: make global writes observable. Since the environment cannot be given a metatable, the
practical route is to rewrite plain global assignments in BOTH drivers into `_G.X = ...` form
textually before tracing, so both mechanisms are traced identically. Then re-run and re-classify.
The 2 timeouts also need triage (likely a loop whose exit depends on a proxy comparison that always
returns false).

## 2026-07-25 - DEFECT #51 (OPEN): closure inlining absorbs following MODULE-LEVEL statements

Hypothesis: the 14 real-corpus trace differences were a harness limitation (plain global assignments
being invisible to the proxy).

Finding: **False — the harness limitation was real but was NOT the cause.** Fixed the harness first by
SNAPSHOTTING every stub global after the body (`FINAL <name> = <value>`), which observes the RESULT
rather than the mechanism, so `X = 1` and `_G.X = 1` are equally visible. The count did not move
(24 SAME / 14 DIFFERENT), which is what promoted this from "under-observation" to a real defect.

Evidence, `EE_Interface_AnchorMgr.lua_B`:
  S'  line 7 : `ANCHOR_V_TOP = v0`          (module level)
      line 21: `c12v3 = ANCHOR_V_TOP`       <- c12 prefix = INSIDE an inlined closure
      line 22: `c12v2.ANCHOR_V_TOP = c12v3`
  S'' line 13: `ANCHOR_V_TOP = v0`          (module level)
      line 14: `v6 = _G`
      line 15: `v6.ANCHOR_V_TOP = v0`       <- module level, as it should be

So the `_G.X = v0` export write, which belongs at MODULE level, is emitted INSIDE the inlined closure
in pass 1. It is not lost (pass 2 recovers it at the right level, which is why the round-trip on
GENERATED ground truth is still 142/142) but its SCOPE is wrong, so the trace order differs and — more
importantly — the statement executes at the wrong time.

Why ground truth missed it: the 142 cases each export exactly ONE function and their module chunks are
tiny, so a boundary slip has nothing to absorb. This needs a ground-truth case with SEVERAL exports and
statements INTERLEAVED between them.

Suspects, in order: `inline_closures` substituting the closure text (the placeholder is replaced
in-line, so a mis-sized body swallows what follows); `decompile_proto_anon`'s header rewrite; and
`cmd_decompile_mod`'s `src.rfind("end")` wrapper-strip, which finds the LAST `end` in the file and is
wrong whenever the chunk's final statement is itself a nested `function ... end`.

Next Step: add a ground-truth case with multiple exports and interleaved module-level statements, which
should reproduce it inside the fast oracle; then fix and re-run `realtrip.py`. Do NOT quote 24/40 as a
correctness figure until this is closed.

## 2026-07-25 - RETRACTION of #51, and the real cause: `_G` global routing

### ★ #51 IS WITHDRAWN — I MISDIAGNOSED IT
I claimed closure inlining absorbed module-level statements, based on a GREP that showed
`c12v2.ANCHOR_V_TOP = c12v3` with a closure prefix. **Reading the surrounding block disproves it**:
lines 21-22 are legitimately INSIDE the closure opened at line 18, and `c12v2` is a LOCAL TABLE
(`c12v2 = {}`), not `_G`. There is no scope leak. A constructed ground-truth case with multiple
exports and interleaved module-level statements (`A=1; function f; B=2; function g; _G.f=f; C=3; ...`)
decompiles CORRECTLY - every statement at the right level, both closures properly bounded.
**Lesson: a grep shows a line, not its SCOPE. Confirm the enclosing block before naming a defect.**

### THE ACTUAL CAUSE - and it is by design, not a bug
Minimal case: source `A = 1` alone recompiles to bytecode containing BOTH a `SETGLOBAL` AND a
`GETIMPORT _G` + `SETFIELD` mirror. Real DE bytecode has no such mirror.
`src/transcode.h:367` does this deliberately: DE runs a chunk in a TRANSIENT sandbox env, so a plain
SETGLOBAL would not persist, and globals are routed through the mutable shared `_G` table instead.
The knob already existed: **`RENOVICE_NATIVE_GLOBALS=1`** emits native `0x02`/`0x17` instead.

With it set, `A = 1` round-trips to exactly `A = v0`, and the real-corpus trace comparison goes
**24/40 -> 37/40 SAME** (2 timeout, 1 different). So the earlier 14 divergences were neither a
decompiler bug nor a harness artefact - they were the injection-oriented `_G` routing doing exactly
what it was built to do. **For FIDELITY work set RENOVICE_NATIVE_GLOBALS=1; for INJECTION leave it off.**

### NEW REAL LIMIT - Luau's 200-local cap
`Lotus_Interface_1999_RetroMessenger` fails to recompile: *"Out of local registers when trying to
allocate v200: exceeded limit 200"*. Our emitter declares EVERY register as a local at function top
(`maxstack` of the proto), and a large proto exceeds Luau's hard 200-local limit. This is a genuine
ceiling on the edit-and-recompile workflow for big scripts, and the fix is the readability pass that
was deferred: re-inline single-use temporaries so fewer registers need names. Must be proven against
the oracle, not assumed.

Remaining on the real-corpus harness: 2 timeouts (a loop whose exit depends on a proxy comparison that
always returns false), and `require` of an engine module, which stock Luau rejects unless the path
starts with `./`, `../` or `@`.

## 2026-07-25 - Declare only USED registers; real corpus reaches 142/150

Hypothesis: declaring every register up to `maxstack` was the cause of the 200-local ceiling.

Finding: **True.** The emitter declared `v0..maxstack-1` unconditionally, but a proto rarely names
every slot. Now it scans the emitted body and declares ONLY the registers actually mentioned - exact,
because the emitter is the only thing that writes those names.
`Lotus_Interface_1999_RetroMessenger` previously could not be recompiled AT ALL
("Out of local registers ... exceeded limit 200"); it now recompiles to 147,152 bytes / 298 protos.
Ground truth unaffected: **142/142 read, 142/142 round-trip**.

### Real-corpus behavioural round-trip, `RENOVICE_NATIVE_GLOBALS=1`, 150 files
| outcome | n |
|---|---|
| SAME | **142 (94.67%)** |
| DIFFERENT | 5 |
| timeout | 2 |
| recompile-fail | 1 |

Progress on this metric: 24/40 -> 37/40 -> **142/150**.

### The remaining 8, triaged
- **RetroMessenger** still exceeds 200 locals on the SECOND pass (its 298-proto recompile contains a
  proto that still names >200 registers). The used-only fix raised the ceiling but did not remove it;
  re-inlining single-use temporaries is the real fix. Its S' side ALSO fails in the harness on
  `require("EE.Interface.Utilities")` - stock Luau rejects a path without `./`, `../` or `@`, which is
  a stub limitation, not a decompiler one.
- **Lotus_Interface_BindingsUtil**: S' reaches `IDX gPlayerProfileMgr.GetPlayerProfile` where S'' does
  `CALL IsNull(gRegion)` - a genuine ordering/behaviour divergence and the best next lead, because it
  is NOT explained by either known harness limitation.
- 2 timeouts: a loop whose exit depends on a proxy comparison that always returns false.

Next Step: (1) diagnose BindingsUtil - the only unexplained real divergence; (2) re-inline single-use
temporaries, which fixes the residual 200-local ceiling AND the per-pass output growth; (3) make the
stub `require` return a proxy instead of raising.

## 2026-07-25 - DEFECT #52 (OPEN, localised): a closure binds the WRONG sub-proto

Hypothesis: the `Lotus_Interface_BindingsUtil` divergence - the only real-corpus difference NOT
explained by a known harness limitation - was a control-flow problem.

Finding: **False. It is a closure-IDENTITY problem**, the same class as #41.

Evidence (traces diverge at index 487 of ~496, both 150-file runs deterministic):
```
486  S' -- entry ResetCustomBindings        | S'' -- entry ResetCustomBindings
487  S' IDX gPlayerProfileMgr.GetPlayerProf | S'' CALL IsNull(gRegion)
```
The SAME entry point runs a DIFFERENT function body. Both bind it identically (`ResetCustomBindings =
v6`), and the engine-call sequences are otherwise in the same relative order, so it is not a branch
divergence. The last module-level assignment to `v6` before the binding is:
  S'  line 1618: `v6 = function()`        <- ZERO parameters
  S'' line 3155: `v6 = function(c10v0)`   <- ONE parameter
Different ARITY proves a different sub-proto is being bound; one of the two passes resolves the
closure constant to the wrong proto.

#41 fixed exactly this for `DUPCLOSURE` (0x42), whose `Bx` is a CONSTANT index whose tag-6 payload
holds the proto index, while `NEWCLOSURE` (0x16) takes the proto index DIRECTLY. This file must be
hitting a residual case - candidates, in order: a constant reused by two closure sites; NEWCLOSURE and
DUPCLOSURE mixed in one proto; or a register reused across many closure definitions so the tracked
"last assignment" is not the one the bytecode actually binds.

Next Step: disassemble the module chunk of `Lotus_Interface_BindingsUtil.lua_B` around the SETGLOBAL
for `ResetCustomBindings`, read which opcode loads the closure and which proto index it truly resolves
to, and compare against what `ex::EK::Closure` recorded. Then build a GROUND-TRUTH case with several
closures sharing one register (which the current 142 do not have - each exports exactly one function),
so the fast oracle can hold the fix.

## 2026-07-25 - FULL VERIFICATION MATRIX (all 7 gates, one run)

| # | gate | what it proves | result |
|---|---|---|---|
| 1 | behavioural, READ (S vs S') | output MEANS the same as known source | **142/142 = 100.0000%**, 0 vacuous |
| 2 | behavioural, FULL EDIT ROUND-TRIP | decompile->recompile->decompile preserves meaning | **142/142 = 100.0000%**, 0 vacuous |
| 3 | mutation audit | the ORACLE ITSELF detects corruption | **77/77 killed, 0 survived** |
| 4 | compilability (real luau-compile) | output is valid Luau | 294/294 = 100% |
| 5 | structuring, 82k REAL protos | every block placed exactly once | 82,059/82,059, 0 missing / 0 dup |
| 6 | DE container byte-exactness | the writer is untouched | 5,386/5,386 byte-exact |
| 7 | IR operand resolution | every operand resolves | 0 unresolved, corpus-wide |

### #52 REFINED - simple register reuse is NOT the cause
Built the ground-truth case the corpus lacked (four closures of DIFFERENT ARITY assigned through the
SAME register, then exported): `zero/one/two/three` each bind the CORRECT arity. So closure identity
under plain register reuse is proven sound, and #52 needs something a 4-line module does not have.
Module-chunk disassembly of `Lotus_Interface_BindingsUtil` (19 protos) shows DUPCLOSURE at const
indices 63/64/66 loading into DIFFERENT registers (A=0 then A=1), with the A=0 closure NOT stored
immediately - it is consumed later. That deferred-use pattern, not register reuse, is the next suspect.
Narrowing note: S'' is decompiled from OUR OWN recompiled bytecode, and the decompiler is 142/142 on
exactly that kind of input, so the fault is more likely introduced by the TRANSCODER on a large module
than by the decompiler. Verify by disassembling the recompiled module at the same site and comparing
which proto each DUPCLOSURE constant resolves to.

### WHAT IS AND IS NOT PROVEN - state this precisely, do not round it up
PROVEN, with an oracle that is itself mutation-tested:
  on 142 generated cases covering all 77 opcodes, our decompiled source is behaviourally
  INDISTINGUISHABLE from the original in BOTH directions.
NOT PROVEN:
  fidelity on the 5,386 REAL scripts. Their original sources DO NOT EXIST, so no offline test can
  compare against them - the 142/150 real-corpus figure is SELF-CONSISTENCY (S' vs S''), not fidelity,
  and one of those 8 (#52) is a real open defect. Absolute certainty on the real corpus is not
  attainable offline; it needs an in-game test.

## 2026-07-25 - RETRACTION: `bindmap.py`'s 153/300 is a MEASUREMENT ARTIFACT

Hypothesis: exported globals bind different closures across a round-trip (#52), measurable by
comparing the ARITY of the closure each export binds.

Finding: **The measurement is invalid. 153/300 "ARITY-MISMATCH" is an artifact of my harness.**

`bindmap.py` identified module-level statements by indentation (`^  vN = function(`, exactly two
spaces). **That assumption is false: `inline_closures` does NOT re-indent an inlined closure body**, so
a nested body's statements sit at the SAME two-space indent as module level:
```
  v0 = function(...)
  local c1v0, c1v1      <- inside the closure, still 2 spaces
```
So the regex matched assignments INSIDE nested closures and tracked the wrong "last assignment".

**The contradiction was the tell and should have been checked first:** the behavioural oracle found
5 differences in 150 files; bindmap claimed 153 in 300. Two measurements of the same property
disagreeing by 30x means one is broken - and it was the NEW, unvalidated one. Verified by a minimal
case: `function f(...) return select("#", ...) end` round-trips with `vararg=1` intact and decompiles
back to `function(...)`, so vararg is NOT being lost.

**This is the FOURTH harness artifact today** (#36 fixed probe filename, #49 fixed temp filename,
the tbl_* address keys, now this). Standing rule, earned four times over:
**when a new harness disagrees with an established one, suspect the NEW harness first, and verify a
single case by hand before believing any aggregate.**

### A REAL (cosmetic-but-consequential) defect this exposed
`inline_closures` splices a closure body in at column 0 of its own emission rather than at the call
site's indent. The output is still CORRECT Luau - indentation is not semantic - but it is
significantly harder to read, and it makes any indentation-based scope analysis impossible. Worth
fixing: re-indent each inlined body by the placeholder's current depth.

### #52 STATUS: still open, still localised to `Lotus_Interface_BindingsUtil`, NOT shown to be
widespread. The only evidence remains the behavioural trace divergence at entry `ResetCustomBindings`
(1 file out of 150). Do not quote bindmap's numbers.

## 2026-07-25 - #52 IS REAL AND WIDESPREAD - and the trace harness was UNDER-DETECTING it

Correction to the retraction above: after fixing the inlining indent (so indentation is finally
meaningful), `bindmap.py` still reports **152/300 ARITY-MISMATCH**. The artifact explanation was wrong
- or rather, it was only PART of the story, and the残 real signal survived the fix.

Hand-verified on `EE_Interface_Components_Grid.lua_B`, checking EVERY module-level assignment to the
register (not just function literals, which was the earlier flaw):
```
S'  line 12: v2 = function(c43v0, c43v1, c43v2, c43v3, c43v4)   -- 5 params, ~2450-line body
    line 2465: CreateGrid = v2
S'' line 24: v2 = function(c1v0)                                 -- 1 param, ~29-line body
    line 53:  CreateGrid = v2
```
In both, that function literal IS the last module-level write to `v2` before the binding. So the
round-trip binds a COMPLETELY DIFFERENT function to the same export. That is a severe correctness
defect, not a cosmetic one.

### THE IMPORTANT METHODOLOGICAL POINT
`realtrip.py` reported only 5 differences in 150 files while this affects ~half. **The behavioural
trace harness is UNDER-DETECTING**: it calls each entry point with three generic proxy arguments, so a
function whose real signature takes five parameters still "runs" and produces a similar-looking trace,
and a shallow entry that errors immediately produces an identical trace either way.
**Therefore the earlier "142/150 SAME" OVERSTATES real-corpus correctness and must not be quoted.**
Two harnesses disagreed; last time the new one was wrong, this time the ESTABLISHED one was. The
lesson is not "trust the old one" - it is that a disagreement must be resolved by HAND-VERIFYING A
SINGLE CASE, which is what settled it both times.

### Suspect
`decompile-mod` emits only the LAST proto as the module chunk. `EE_Interface_Components_Grid` has many
protos, and the closure inlined at a given site is chosen by `ex::EK::Closure`'s recorded index. The
5-param vs 1-param split points at the DUPCLOSURE/NEWCLOSURE constant-vs-proto index resolution (#41's
area) failing on modules with many protos, OR at `inline_closures` picking the wrong sub-proto when
several placeholders appear in one statement stream.

Next Step: for `EE_Interface_Components_Grid`, disassemble the module chunk, find the closure load
feeding the `CreateGrid` SETGLOBAL, print the constant index, the tag-6 payload it resolves to, and
that proto's nparams - then compare against what our IR recorded. That single comparison names the bug.

## 2026-07-25 - ★ #52 ROOT CAUSE: the TRANSCODER cannot emit NEWCLOSURE with upvalues (known TODO)

Hypothesis: #52 was a DECOMPILER defect resolving a closure constant to the wrong proto.

Finding: **False. The decompiler is not at fault — the RECOMPILE direction is.**

Decisive comparison on `EE_Interface_Components_Grid.lua_B`, module chunk (proto 43 of 44):
```
ORIGINAL   [11] op=0x42 A=2 Bx=9    DUPCLOSURE via const k[9] (tag=6)  -> [13] SETGLOBAL CreateGrid
RECOMPILED [23] op=0x16 A=2 Bx=0    NEWCLOSURE, DIRECT proto index 0   -> [25] SETGLOBAL CreateGrid
```
Recompiled `proto[0]` has **nparams=1**. The function that should be bound is **`proto[42]`:
nparams=5, nups=1** (sizecode 2288 — the ~2450-line body S' correctly recovered).

`src/transcode.h:108` already documents it:
    "NOTE STILL TODO: variable-width NEWCLOSURE (nups>0, needs DE upvalue-descriptor format)"
and the mis-bound proto has **nups=1**. So the transcoder cannot emit a closure that CAPTURES
UPVALUES, and silently writes a wrong proto index instead of failing.

### WHY THIS MATTERS MORE THAN THE NUMBER
- The DECOMPILER (`DE -> Luau`) is vindicated: S' recovered the correct 5-parameter, 2450-line
  function. Every read-direction figure stands - 142/142 behavioural, 294/294 compile, 82,059/82,059
  structured, 5,386/5,386 byte-exact, 0 unresolved operands.
- The RECOMPILER (`Luau -> DE`) is UNSOUND for any script whose closures capture upvalues, which is
  most real code. The 142/142 ROUND-TRIP figure held only because generated ground-truth closures
  mostly have nups=0.
- **It fails SILENTLY.** A wrong proto index is structurally valid bytecode, so every structural gate
  passed. This is the same lesson as #34/#37/#48: a check that cannot distinguish "valid" from
  "correct" will certify a wrong program.

### THEREFORE: the in-game test is BLOCKED, and the blocker is NOT the decompiler
Deploying a recompiled real script today would install a module whose exports point at the wrong
functions. Reading/decompiling the corpus is safe and correct; WRITING it back is not.

Next Step (this is now the top of the list):
1. Implement DE's upvalue-descriptor format for NEWCLOSURE with nups>0 in the transcoder.
2. Make the transcoder HARD-FAIL on any construct it cannot emit faithfully, instead of writing a
   plausible-but-wrong index. Silence is what let this reach a "142/150" report.
3. Add ground-truth cases with upvalue-capturing closures at MODULE level (the current 142 exercise
   captures only inside nested functions, with nups=0 at the export site).

## 2026-07-26 - #52 FIXED. NO SILENTLY-WRONG OUTPUT REMAINS.

### DEFECT #52 FIXED - NEWCLOSURE proto index was never remapped
Luau's `NEWCLOSURE D` indexes THIS PROTO'S CHILD LIST (`p->p[D]`); DE uses a FLAT module-wide proto
index. The transcoder copied `D` verbatim, binding whatever module proto sat at that position.
Fix: remap through `p.kids[D]`, and THROW if the index is out of range rather than guessing.
**Export binding mismatches across a round-trip: 152/300 -> 0.**

### DEFECT #53 FIXED - a failed closure became `function() end`
`inline_closures` substituted an empty function when a sub-proto failed to decompile. That is
syntactically valid, semantically a DELETED FUNCTION, and invisible to every gate - `ToggleFocus`
exported a 7-parameter function in one pass and an empty one in the other. Now the failure is recorded
and `decompile-mod` REFUSES to emit. Unmasking it immediately named the real gap:
`proto 275: unrenderable condition op 0x47` - a FORNPREP reaching `cond_of`, i.e. a numeric-for whose
block is not the head of its region (Proper-region linearisation calls `cond_of` on every branching
block, including for-ops).

### THE STATE THAT MATTERS: nothing is silently wrong any more
| harness | before | after |
|---|---|---|
| export binding map, 300 files | 152 ARITY-MISMATCH | **0 mismatch**, 243 ok, 54 decompile-fail, 1 recompile-fail |
| behavioural trace, 150 files | 5 DIFFERENT (under-detecting) | **0 DIFFERENT**, 126 SAME, 22 decompile-fail, 2 timeout |
| ground truth, both directions | 142/142 | **142/142** (unchanged) |

Every file now either decompiles CORRECTLY or FAILS LOUDLY. The 54/300 that fail were previously
emitting a plausible lie. **A lower "success" number that is honest is worth far more than a higher one
that is not** - the whole 142/150 and 152/300 confusion came from harnesses and emitters that
preferred to produce something rather than nothing.

### REMAINING BEFORE AN IN-GAME TEST
1. `unrenderable condition op 0x47` (FORNPREP) - the single cause of the 54 decompile-fails. The
   Proper-region linearisation and the loop-break emitter both call `cond_of` on any branching block;
   a for-op has no boolean condition, so those paths need the for-header treatment `emit_region`
   already does at region heads.
2. The 2 timeouts (stub-fidelity: a loop exit depending on a proxy comparison that is always false).
3. `recompile-fail` x1.
Only after those: deploy `Lotus_Scripts_Teleport` and F9.

## 2026-07-26 - CLEANUP PASS: 54 decompile-failures -> 0, real corpus 292/300

Ground truth held at **142/142 in BOTH directions** through every change below; any change that moved
it was reverted on the spot.

### Fixed
- **#52 NEWCLOSURE proto index** (transcoder): Luau's operand indexes the proto's CHILD LIST, DE uses a
  FLAT module index. Remapped via `p.kids[D]`; THROWS on out-of-range instead of guessing.
  Export binding mismatches **152/300 -> 0**.
- **#53 masked closure failure** (decompiler): a failed sub-proto became `function() end` — valid Luau,
  semantically a DELETED function. Now recorded and `decompile-mod` REFUSES to emit.
- **#54 for-LATCH treated as a condition**: FORNLOOP (0x0a) / FORGLOOP (0x1e) have no boolean test —
  their back edge is consumed by the enclosing loop region, so inside an acyclic region they merely
  fall through. Added `renderable_cond()` (real conditional branch AND not a for-latch) and applied it
  at EVERY `cond_of` call site: Proper linearisation, loop-break emitter, While, SelfLoop, and the
  IfThen/IfThenElse head. **Decompile failures 54 -> 0.**
- **FORNPREP as a condition**: expressible exactly — the branch is taken when the range is already
  exhausted: `(step > 0 and idx > limit) or (step < 0 and idx < limit)`.
- **inf/nan literals**: `%g` emits `inf`/`nan`, which are not Luau literals. Now `math.huge` / `(0/0)`.
- **wrapper strip**: `rfind("end")` matched an `end` belonging to a nested `function` that ended the
  chunk, truncating real code. Now strips the last LINE only when it is exactly `end`.

### REVERTED - a fix that regressed ground truth
Rewriting a non-identifier global (`899c4c`) to `_G["899c4c"]` fixed 5 real-corpus files but dropped
ground truth **142 -> 136**: `_G` is NOT always the same table as the global environment (the oracle
shadows it; DE routes globals through a sandbox env). Reverted and left a comment. **The correct fix is
a sanitised IDENTIFIER, not a table index.** Shipping the regression to gain 5 files would have traded
a proven invariant for an unproven one.

### STATE
| gate | result |
|---|---|
| ground truth, read | **142/142** |
| ground truth, full round-trip | **142/142** |
| real corpus binding map, 300 files | **292 ok**, 0 mismatch, 6 recompile-fail, 2 no-exports |
| real corpus behavioural trace, 150 files | **143 SAME**, 3 DIFFERENT, 2 timeout, 2 recompile-fail |

### REMAINING (all understood, none silent)
1. 5x "Malformed number" — non-identifier global names; needs the identifier-sanitising fix above.
2. 2x "Out of registers" / 1x "Out of local registers (pN_N)" — the 200-local ceiling again, now from
   Proper-region flag variables too. Needs single-use temporary re-inlining.
3. 2x "Expected 'end'/<eof>" — a remaining brace-matching case in the module wrapper.
4. 3 behavioural DIFFERENT + 2 timeouts.

## 2026-07-26 - ALL FOUR ITEMS CLOSED. 0 recompile failures, 0 behavioural differences.

### Fixed this pass
- **Non-identifier global names** (5x "Malformed number"). A name-hash resolving to e.g. `899c4c`
  emitted bare kills the FILE. First attempt used `is_ident`, which REGRESSED ground truth 142->136:
  `EK::Global` also carries IMPORT PATHS (`math.floor`), legitimately dotted. Added `is_dotted_path`
  (every dot-separated component a valid identifier) and quote only what is genuinely unusable.
  **The regression was caught because ground truth runs after every single change.**
- **`return` not last in block** (4x "Expected 'end' / <eof>"). A Seq region emits a returning block
  followed by a subsequent (unreachable) one at the same level, which Lua rejects outright. Now emits
  `do return ... end`, the idiomatic form that stays valid with code after it.
- **Proper-region flags exhausted locals** (1x "Out of local registers pN_N"). One boolean PER BLOCK
  blew the 200-local limit. Control follows exactly ONE path through a DAG, so "which block are we in"
  is a SINGLE value: replaced N booleans with one integer state variable.
- **Protos naming >200 registers** (3x "Out of registers"). Luau's limit is hard, so stop using locals:
  when a proto needs more than 150 register names, spill to a register TABLE `vT[N]`, which has no
  limit. Parameters stay real locals (they are the signature); only registers >= nparams are rewritten.

### VERIFIED - all seven gates, one run
| gate | result |
|---|---|
| ground truth, read | **142/142 = 100%**, 0 vacuous |
| ground truth, FULL EDIT ROUND-TRIP | **142/142 = 100%**, 0 vacuous |
| mutation audit (can the oracle fail?) | **77/77 detected, 0 survived** |
| compilability | 294/294 = 100% |
| structuring, 82k real protos | 82,059/82,059, 0 missing / 0 dup |
| DE container byte-exactness | 5,386/5,386 |
| IR operand resolution | 0 unresolved |
| **real corpus binding map, 300** | **298 ok, 0 mismatch, 0 recompile-fail** |
| **real corpus behavioural trace, 150** | **148 SAME, 0 DIFFERENT**, 2 timeout |

### A harness correction made in the same pass
The `vT` spill renames `NAME = vN` to `NAME = vT[N]`, which bindmap's regex did not match - it
reported `no-exports` 2 -> 12 and would have READ AS A REGRESSION. Verified it was the spill (not a
real change) before touching anything, then taught the regex about `vT[N]`: 298 ok.
**Fifth time a harness has moved a number without the code being wrong. Always confirm what a metric
change MEANS before reacting to it.**

## 2026-07-26 - The last two residues were BOTH harness noise, proven not assumed

### "2 timeouts" -> 150/150 SAME
Both S' AND S'' timed out IDENTICALLY, which pointed at the stub rather than the decompiler - but
pointing is not proving. Settled it by BOUNDING the trace instead of timing out (`BUDGET = 20000`
operations, then `error('TRACE_BUDGET')`): a cutoff is symmetric, so it cannot favour either side, and
if two programs agree for 20,000 operations they are behaving identically as far as anything
observable. A loop whose exit depends on a proxy comparison cannot terminate, because the stub must
answer SOME fixed value - that is a property of the mock, not of the recovered code.
Two further layers of noise had to come off before the comparison meant anything:
- the uncaught error makes luau print a stacktrace containing the TEMP FILENAME (differs per run);
- and the LINE NUMBER within it (S'' is legitimately longer, so positions shift).
Both normalised. **Result: 150/150 SAME, 0 DIFFERENT.** Position is not behaviour.

### "2 no-exports" -> correct, and confirmed by inspection
`EE_Types_ScriptCommands_JSON` and `Lotus_Interface_Components_BoosterInfo` assign ONLY registers at
module level (`v0`, `v1`, ...) and no global names - they genuinely export nothing via globals
(module-return style). Not a defect; the classification is right.

### Harness hardening
`subprocess(text=True)` decoded with the console codec (cp1252) and died mid-sweep on a real script
containing byte 0x90 - `UnicodeDecodeError` killed the WHOLE full-corpus run. Now decodes UTF-8 with
`errors='replace'` in all three harnesses. A sweep that dies at file 3,000 reports nothing about the
other 2,386.

### FULL CORPUS (5,386 files) - first complete run
  ok 5227 | no-exports 154 | recompile-fail 4 | decompile-fail 1
300-file samples had shown ZERO failures, so these 5 live in the tail the samples never reached.
**A sample proves nothing about what it did not sample** - the same lesson as the ground-truth cases
that each exported exactly one function. Identifying and fixing those 5 is the remaining work.

## 2026-07-26 - FULL CORPUS 5386/5386 CLEAN. Native-globals verified. Import drift found.

### ITEM 1 DONE - full corpus scan
**5,386 files, 0 failures.** Every shipped script decompiles AND recompiles. Previous run had 8
failures; all fixed:
- Windows LONG PATH in `read_file` (4 files reported "not a 09 03 container" while the bytes were
  fine — the reader could not open a 241-char path; now uses the `\?\` prefix)
- double `else` for 3+ arm regions
- `break` emitted outside a lexical loop (now guarded by `loop_depth`, tracking real emitted nesting
  rather than block-set membership)

### ITEM 2 DONE - RENOVICE_NATIVE_GLOBALS=1 verified EMPIRICALLY, not by flag name
`Lotus_Scripts_Teleport`   ORIGINAL 1x0x02 + 2x0x46 | NATIVE=1 IDENTICAL | default adds a 3rd 0x46
`DarkSectorBeacon`         ORIGINAL 1x0x02 + 3x0x46 | NATIVE=1 IDENTICAL | default adds a 4th 0x46
The default `_G` routing exists for INJECTED code (DE runs those in a transient sandbox env). For
REPLACING a shipped script, DE loads it through its normal path, so the native `SETGLOBAL`/`GETGLOBAL`
form is the faithful one. **Fidelity work MUST set RENOVICE_NATIVE_GLOBALS=1.**

### NEW FINDING (open, not blocking a single-file test) - GETIMPORT drift on larger scripts
Across 150 scripts, SETGLOBAL/GETGLOBAL counts match the original exactly, but 114/150 have MORE
GETIMPORTs after a round-trip. Characterised on `EE_Interface_Components_DragScroll`:
- proto count matches exactly (6 = 6) — so it is NOT closure duplication;
- protos 0,1,2,3,5 have IDENTICAL import counts (1,2,1,3,3);
- ALL 8 extra imports are in ONE proto.
So it is localised, not systemic. Most likely our source re-resolves a global PATH where the original
held it in a register/upvalue. Behaviour-preserving in the normal case (re-resolving a path yields the
same value) and the behavioural traces are 150/150 SAME — but it IS a fidelity gap and must be
understood before trusting round-tripped output broadly.
**`Lotus_Scripts_Teleport` matches the original signature EXACTLY**, so it is unaffected.

## 2026-07-26 - ★★★ IN-GAME CONFIRMED: a decompiled+recompiled script RUNS IN WARFRAME

`Lotus_Scripts_Effects_HarnessEffects` (632 b) -> decompile-mod -> Luau source -> recompile (697 b)
-> deployed as `69d6ef081657ce9a (HarnessEffects - decompiler roundtrip test).lua_B`.

Live log proof:
```
loaded replacement key=69d6ef081657ce9a (697 bytes) <- 69d6ef081657ce9a (HarnessEffects ...).lua_B
MATCH fnv=69d6ef081657ce9a len=632 first=09 -> replacing with 697 bytes
```
The game requested the original, the DLL substituted OUR bytes, `undump` accepted them and the module
chunk executed. No fault, no crash. **The full loop DE bytecode -> readable Luau -> DE bytecode -> the
real DE VM is closed.**
(The `FAULTED` lines in the same log are `v14_c_testset.spawn.lua_B` on the [spawn] INJECTION path -
a separate experiment, not this replacement.)

### TWO PROCESS ERRORS ON THE WAY - both caught by checking, not by luck
1. **Deployed to the WRONG GAME FOLDER.** I assumed `C:\Program Files (x86)\Steam\steamapps\common\
   Warframe` because it had an OpenWF/CustomScripts tree with mods and a log. The LIVE install is
   `C:\Users\Bartek\OneDrive\Dokumenter\Warframe`. The tell was there and I read it too late: the
   Steam copy had **zero DLLs** and its log had not been written since Jul 23, while the real one had
   `wtsapi32.dll` and a log written minutes earlier. **An install that looks complete is not
   necessarily the one running.** File removed from the Steam tree.
2. **Picked a target that never loads.** `Lotus_Scripts_Teleport` appears **0 times** in 30,702 load
   records - the test could never have fired, and a silent non-result would have looked like failure.
   Fixed by mining the log: `load  fnv=<hash>` lines are a COMPLETE INVENTORY of what actually loads.
   1,540 distinct scripts loaded, 1,293 identified in the corpus. Chose the most-loaded small
   cosmetic script (105 loads, 632 b) whose round-trip signature matched the original exactly
   (protos 2->2, globals/imports 9->9).

**Reusable technique:** `grep "^load  fnv=" wf_lua_redirect.log` maps every script the game really
loads. Never pick a deploy target without checking it against that list.

### WHAT THIS DOES AND DOES NOT PROVE
PROVES: our emitted bytecode is structurally valid to DE's `undump` and its chunk runs in the real VM.
DOES NOT PROVE: that all 5,386 scripts are correct, nor that this script's FUNCTION
(`CopySuitEnergyColors`) produces identical results - it is called situationally. The open
GETIMPORT-drift item (114/150 scripts gain imports on round-trip) is still unexplained and unaffected
by this result.

## 2026-07-26 - DEFECT #55 (OPEN, REAL): unbound upvalues `u<N>` survive into the output

Hypothesis: the GETIMPORT drift (114/150 scripts gain imports on round-trip) was a code-quality
artefact of re-resolving a path the original cached.

Finding: **Partially true, and it uncovered a genuine CORRECTNESS bug underneath.**

### The drift itself, characterised precisely (`EE_Interface_Components_DragScroll`)
Protos align 1:1 (nparams/nups/nconsts identical for protos 0-4; only the module chunk gains one const
— the synthesized `_G`). So NO new import constants are invented. `proto[4]`: ORIGINAL has **0
GETIMPORT and 0 import constants** and reaches values through its **upvalue** (`nups=1`); ours has 8
GETIMPORT and 2 import constants, both **single-component** (`0x40400000`, `0x40600000` — the form
Luau uses for a BARE GLOBAL READ). So we emit a global read where the original used `GETUPVAL`.

### DEFECT #55 - the cause, and it is worse than the drift
**42 of 120 modules still emit a raw `u<N>` in `decompile-mod` output.** An unbound `u<N>` is not a
variable — it is a **nil GLOBAL READ**, and it COMPILES, so every gate stayed green. This is the same
class as #40 (which fixed the common case) and #35 (registers that are only ever read).
Concrete: `Lotus_Interface_ArchonIntro` emits `c8v4 = u1`, `c8v7 = u2`, `c8v0 = u3`.

Mechanism: `inline_closures` binds `u<i>` from the CAPTURE list scanned immediately after the closure
op. When a proto declares MORE upvalues than CAPTUREs appear at that site, every index beyond the list
is left as the literal `u<N>`. Bytecode evidence from `ArchonIntro`:
```
[14] NEWCLOSURE A=5 Bx=3
[15] CAPTURE            <- only two captures follow
[16] CAPTURE
[17] NEWCLOSURE A=6 Bx=4
```
while `proto[5]` declares `nups=5`. Either the capture scan is stopping early / mis-associating sites,
or a DUPCLOSURE-created closure inherits upvalues that are not re-captured at the use site.

**Note this is NOT what broke DragScroll** — that file emits ZERO raw `u<N>` yet still gains imports,
so there is a SECOND path to the same symptom. Do not assume one fix closes both.

### Why every gate missed it
`u1` is valid Luau. It compiles, it runs, it silently reads nil. Ground truth never caught it because
the 146 cases have at most ONE upvalue per closure, so the capture list is never shorter than the
upvalue count. **A new ground-truth case is needed FIRST: a closure with 3+ upvalues, and nested
closures that capture from two levels up.**

Next Step: (1) add those ground-truth cases; (2) make an unbound `u<N>` a HARD FAILURE in
`decompile-mod` rather than emitting it — silence is exactly how this survived; (3) then fix the
capture association. Do NOT deploy anything decompiled from a module containing a raw `u<N>`.

## 2026-07-26 - DEFECT #56 (OPEN, STRUCTURAL): DE's NEWCLOSURE operand may be a CHILD index, not flat

Hypothesis (from #55): unbound `u<N>` came from the CAPTURE scan stopping early.

Finding: **False — the scan is fine. The capture counts genuinely do not match the target protos.**

`Lotus_Interface_ArchonIntro`, proto[9], raw sequence:
```
[11] DUPCLOSURE A=4 Bx=7   [12] CAPTURE  [13] CAPTURE        -> 2 captures
[14] NEWCLOSURE A=5 Bx=3   [15] CAPTURE  [16] CAPTURE        -> 2 captures, proto[3] declares nups=1
[17] NEWCLOSURE A=6 Bx=4   [18][19][20] CAPTURE              -> 3 captures, proto[4] declares nups=2
[22] NEWCLOSURE A=6 Bx=5   [23] CAPTURE                      -> 1 capture,  proto[5] declares nups=5
```
Upstream Luau emits **exactly one CAPTURE per upvalue**, so if `Bx` were a FLAT module proto index
these would match. They do not — and not by a constant offset either (2v1, 3v2, 1v5).

**Therefore `Bx` is probably an index into the ENCLOSING PROTO'S CHILD LIST**, exactly as upstream
documents for `LOP_NEWCLOSURE` ("child proto index"), and our decompiler has been treating it as a flat
module index. If so we have been **INLINING THE WRONG FUNCTION** at NEWCLOSURE sites — the mirror of
#52, which was the same confusion in the TRANSCODER direction.

This single cause would explain all three open symptoms:
- unbound `u<N>` (206/400 modules) — wrong target proto declares more upvalues than the site captures;
- the GETIMPORT drift (114/150) — wrong body, so different global access;
- why our own round-trips are clean: `recompile` writes what `decompile` read, so a consistent
  MISREADING round-trips perfectly. **Self-consistency cannot detect a misread index.**

### WHY EVERY GATE STAYED GREEN
`de::Proto` has NO kids list — the DE container parser never modelled a child list, so nothing could
contradict the flat assumption. Ground truth cannot catch it either: our generated modules are small
and their child order coincides with flat order, which is why the four new upvalue cases
(func_up3/up5/up_nested2/up_shared) all emit ZERO raw `u<N>`.

### NEXT STEP - do NOT guess, resolve it from the container format
1. Determine whether a DE proto stores a CHILD/kids list (parse the per-proto `postconst` region;
   `de-fieldaudit` and the byte-exact writer already round-trip these bytes, so the data is present
   even if unmodelled).
2. If a kids list exists, resolve `NEWCLOSURE Bx` through it and re-measure raw `u<N>` and the import
   drift — the prediction is BOTH collapse to ~0.
3. If it does not exist, the flat reading stands and the capture mismatch means something else.
**Until resolved: do not deploy anything decompiled from a module with multiple closures.**
The deployed `HarnessEffects` is unaffected (2 protos, 1 closure, signature matched exactly).

## 2026-07-26 - ★ DEFECT #56 FIXED: NEWCLOSURE's operand is a CHILD index. We were inlining the WRONG FUNCTION.

Hypothesis: DE's `NEWCLOSURE Bx` indexes the enclosing proto's CHILD LIST, not the flat module proto
table, and our decompiler's flat reading was inlining the wrong function.

Finding: **TRUE, and the fix is one line of resolution.**

The child list was in the container all along — `de_container.h` even documents the layout in a
comment: `post-const region: [nsub vi][nsub*kid vi][linedefined vi]...`. The parser READ AND DISCARDED
those `nsub` kid indices, so nothing could ever contradict the flat assumption. Now captured into
`de::Proto::kids`, threaded through `ir::IProto`, and used to resolve `NEWCLOSURE` (0x16).
`DUPCLOSURE` (0x42) keeps its constant-table resolution (#41) — the two are genuinely different.

### THE FALSIFIABLE PREDICTION, AND THE RESULT
Predicted BOTH open symptoms would collapse. Measured:
- **unbound `u<N>`: 42/120 -> 1/120 modules.** Confirmed. The wrong target proto declared a different
  number of upvalues than the site captured, leaving `u1`, `u2`, `u3` unbound — i.e. nil GLOBAL READS.
- **GETIMPORT drift: 36/150 -> 52/150 matching.** Only PARTIAL. 98 still differ, so there is a
  SECOND, independent cause — consistent with `DragScroll`, which had ZERO raw `u<N>` yet still
  drifted. Predicting both and getting one is the useful outcome: it separates the causes.

Ground truth unaffected: **150/150 in BOTH directions** (the 4 new upvalue cases included).

### WHY EVERYTHING STAYED GREEN THROUGH A WRONG-FUNCTION BUG
This is the sharpest instance of the session's recurring lesson. `recompile` writes what `decompile`
read, so a CONSISTENT MISREADING ROUND-TRIPS PERFECTLY: 5,386/5,386 corpus round-trips and 150/150
behavioural traces were all structurally incapable of detecting it. Ground truth could not either —
our generated modules are small enough that child order COINCIDES with flat order, which is exactly
why the four new upvalue cases (func_up3/up5/up_nested2/up_shared) emit zero raw `u<N>` even BEFORE
the fix. **Self-consistency is not correctness, and a test suite you generate yourself inherits your
own assumptions.**
The tell that broke it open was an INDEPENDENT invariant: Luau emits exactly ONE CAPTURE per upvalue,
so capture-count vs declared-nups is a cross-check that does not depend on our reading being right.

## 2026-07-26 - long-path fix was GATED WRONG; deployed artifact re-verified

### The long-path fix never fired — my own bug
`long_path()` returned early on `p.size() < 240`, but that tests the path AS GIVEN. The four failing
scripts are reached by a **179-char RELATIVE** path that resolves to **241 absolute**, so the prefix
was never applied and they kept failing with the misleading "not a 09 03 container". Now resolves to
absolute FIRST and gates on that length. All four decompile. **A guard that measures the wrong value
is indistinguishable from no guard** — and the earlier "fixed" claim was wrong because I never
re-tested those specific files after the change.

### Deployed artifact re-verified after the #56 fix
`HarnessEffects` rebuilt with the child-list resolution is **byte-identical** to what is deployed
(697 b, `cmp` clean). So the in-game result stands and no redeploy is needed — it has a single closure,
which is exactly why #56 could not affect it.

### GETIMPORT drift: confirmed SEPARATE from #56 and still open
`DragScroll` proto[4] is unchanged by the child-list fix (still 0 -> 8 GETIMPORT, 0 -> 2 import
consts). Original reaches values via `GETUPVAL` (`nups=1`); ours emits bare global reads.
Attempted to identify the repeated name by tokenising the closure body — **that measurement was
invalid**: the tokeniser splits `obj.field` into two identifiers, so apparent "bare globals" may be
field accesses. Not drawing a conclusion from it.
Next attempt should compare the ORIGINAL's `GETUPVAL`+`GETTABLEKS` chain against our emitted
expression for the SAME source position, rather than counting tokens.

## 2026-07-26 - ★ DEFECT #57 FIXED: keys-only table templates were read as GLOBALS. Drift 98 -> 3.

Hypothesis: the residual GETIMPORT drift was an upvalue/caching artefact.

Finding: **False — it was TABLE TEMPLATES, and it was a real correctness bug.**

Method that worked (after a bad one): comparing per-proto OPCODE HISTOGRAMS of original vs recompiled,
instead of tokenising source text. `DragScroll` proto[4]:
| opcode | original | recompiled |
|---|---|---|
| 0x15 SETFIELD | 27 | 27 |
| 0x4f DUPTABLE | **10** | 6 |
| 0x2c NEWTABLE | 0 | **5** |
| 0x3f SETLIST  | 0 | **4** |
| 0x46 GETIMPORT| 0 | **8** |
SETFIELD matching exactly while the TABLE ops diverged pointed straight at template handling — nothing
to do with upvalues.

**The bug:** a keys-only template (tag 5, and tag-8 entries whose payload is 0xFFFFFFFF = no value)
rendered as `body += kname(ki)` — the bare key as an ARRAY ELEMENT. So a template pre-allocating keys
`x` and `y` decompiled to `{ x, y }`, which **READS GLOBALS x and y into array slots 1 and 2**. Wrong
values AND wrong table shape. It compiles, so every gate stayed green; the 8 phantom GETIMPORTs were
those global reads. Now emits `x = nil, y = nil` — declaring the keys, exactly what DUPTABLE
pre-allocates, with the values assigned by the following SETFIELDs as in the original.

**Result: import-signature match 52/150 -> 147/150.** Ground truth unaffected: 150/150 both directions.

### The measurement lesson, twice in one investigation
The first attempt tokenised the closure body to find "repeated bare globals" — INVALID, because the
tokeniser splits `obj.field` into two identifiers, so field accesses masqueraded as globals. Counting
OPCODES instead is immune to that: it compares what the two bytecodes actually DO. When a text-level
measurement and a structural one disagree, prefer the structural one.

## 2026-07-26 - The residual 3: one LOST PROTO, and my "signature match" metric is COARSER than claimed

### The 3 remaining files lose ops, they do not gain them
`Codex` 2177 -> 2176 GETIMPORT, `BoonSelection` 518 -> 498, `RetroMessenger` 2102 -> 2076. The
DIRECTION flipped versus #57 — these are LOSSES, a different bug class.

### `Lotus_Interface_Codex`: we emit 273 protos where the original has 274
That single missing proto shifts every later index, which is why protos 25/26/29 "differed" — the
comparison was lining up DIFFERENT FUNCTIONS. Always check proto COUNT before comparing per-proto.
Arithmetic that explains it: 274 protos = 1 root + 273 children, but the module contains only **272
closure ops** (146 NEWCLOSURE + 126 DUPCLOSURE). So at least one proto is created by NO closure
instruction at all — an ORPHAN that can never be instantiated. `decompile-mod` emits only what is
reachable from the chunk, so an orphan is dropped. **If that is the whole story it is semantically
harmless** (dead code, and both DUPCLOSURE constants and NEWCLOSURE child indices are regenerated
consistently) — but it is NOT yet proven that the dropped proto is the orphan. Needs a real
reachability walk over the kids lists, which we now parse.

### A METRIC WEAKNESS I FOUND WHILE LOOKING - report it, do not hide it
Comparing proto signatures showed EVERY recompiled proto has `nups=1`, while originals vary
(0, 2, 3, 4, 11, ...). That is expected — our source nests closures lexically at their creation site,
so Luau recomputes upvalues from what each closure actually references, and the counts need not match
the original's source structure. **But it means the "SIGNATURE MATCH" test used for the 147/150 figure
(proto count + SETGLOBAL/GETGLOBAL/GETIMPORT counts) is COARSE**: it says nothing about upvalue
structure and would not detect a closure capturing the wrong variable. 147/150 is real progress on
import fidelity, but it must not be quoted as "147 files are correct".

Next Step: (1) implement a reachability walk from the root proto over `kids` + DUPCLOSURE constants,
and report orphans explicitly — that settles Codex; (2) build a STRONGER equivalence check than opcode
counts before claiming any file is faithful.

## 2026-07-26 - ★★ ALIGNMENT ORACLE BUILT — and its FIRST RUN found a deployment-unsafe defect

Implemented the technique the decompiler literature calls instruction-level equivalence alignment
(`derecomp skeleton` + `cert/align.py`). It compares the ORIGINAL DE bytecode against our RECOMPILED
bytecode — the first oracle in this project that is not self-referential.

Skeleton = per proto, the sequence of SEMANTIC operations with RESOLVED NAMES (calls and the name
called, field/global/import access by name, table ops, branch shape, returns, and WHICH proto each
closure binds). Register numbers and materialisation MOVE/LOADNIL are excluded by construction.
Compared as a MULTISET per proto: strict sequence equality is too harsh to be useful (materialisation
legitimately reorders loads and turns DUPTABLE into NEWTABLE+SETLIST), but WHICH named entities are
touched and HOW OFTEN must not change.

### DEFECT #58 (OPEN, DEPLOYMENT-UNSAFE): our transcoder writes a FLAT proto index for NEWCLOSURE,
### and emits NO CHILD LIST
```
ORIGINAL : NEWCLOSURE  proto#2      (resolves through the proto's kids list)
OURS     : NEWCLOSURE  child?2      ("child?" = kids list is EMPTY in our output)
```
`transcode.h:500` does `d.Bx = p.kids[kidx]` — converting Luau's CHILD index to a FLAT module index —
and the postconst region we emit carries no `[nsub][kids]` entries. But DE reads `NEWCLOSURE` as a
CHILD index (proven in #56: resolving through kids fixed 42/120 unbound upvalues, and upstream
documents "child proto indices"). **So our recompiled bytecode's NEWCLOSURE operands are wrong.**

**This is the #52 "fix" being wrong.** #52 changed the transcoder child->flat and the metric improved —
but ONLY because the decompiler ALSO read flat at that time. Transcoder writes flat + decompiler reads
flat = self-consistent = every gate green. Fixing the decompiler in #56 (correctly) left the two sides
INCONSISTENT, and nothing detected it until an oracle compared against the ORIGINAL.
**Third instance of the same trap, and the most expensive: self-consistency validated a bug into place
and then hid its own inversion.**

### EXPOSURE
- **50 of 60 recompiled files contain NEWCLOSURE** -> ~83% of the corpus is affected.
- **The DEPLOYED `HarnessEffects` is SAFE**: 0 NEWCLOSURE in both the original and our build (it uses
  DUPCLOSURE only, which resolves through a CONSTANT and is unaffected). Verified, not assumed — but
  that is luck, not design. The in-game result stands and needs no action.

### Alignment baseline (60 files, before fixing #58)
ALIGNED 13 · NAME-DIFF 46 · PROTO-COUNT 1. Other real signals already visible in the same run:
- `EXTRA GETIMPORT _G` + `EXTRA GETFIELD type` where the original has `GETIMPORT type` — we route a
  stdlib global through `_G` somewhere despite RENOVICE_NATIVE_GLOBALS=1;
- `MISSING BRANCH 0` / `MISSING BRANCH "table"` — const-compare branches whose constant we drop.

Next Step: fix #58 (emit the child list AND write child-relative operands), then re-run alignment and
drive ALIGNED toward 60/60 before any further deployment.
**Do not deploy any recompiled script containing NEWCLOSURE until #58 is fixed.**

## 2026-07-26 - DEFECT #58 FIXED: NEWCLOSURE operand is child-relative in DE too

`transcode.h` converted Luau's CHILD index to a FLAT module index (the #52 "fix"). DE reads it as a
CHILD index, exactly like Luau. The conversion is simply removed — the operand passes through
unchanged, and the kids list (flat indices) is what DE resolves it THROUGH. Verified:
```
ORIG : NEWCLOSURE proto#2  proto#6  proto#19
OURS : NEWCLOSURE proto#2  proto#6  proto#19      (was child?2 / child?6 / child?19)
```
Ground truth unaffected: 150/150 both directions. Alignment 13/60 -> 15/60, and NEWCLOSURE mismatches
are GONE from the diff list.

**#52 is hereby retracted.** It "improved" its metric only because the DECOMPILER also read flat at
the time; transcoder and decompiler agreeing on the same mistake is self-consistency, not correctness.
This is the third and most expensive instance of that trap in the project.

### The alignment oracle is now the primary correctness gate
It is the only check that compares against the ORIGINAL rather than our own round-trip, and it found
#58 on its first run after every other gate had been green for days.

### Remaining alignment signals, in order of frequency
1. **`MISSING BRANCH <const>`** (dominant: `0`, `5`, `""`, `"true"`, `-1000`) — the ORIGINAL has a
   const-compare branch (JUMPXEQKN/KS/KB) and OURS has a branch carrying no constant. If we are
   turning `x == 0` into a truthiness test that is a REAL semantic bug, because **0 is truthy in Lua**.
   Highest priority.
2. **`MISSING GETIMPORT type` + `EXTRA GETIMPORT _G` + `EXTRA GETFIELD type`** — a stdlib global routed
   through `_G` despite RENOVICE_NATIVE_GLOBALS=1.
3. **PROTO-COUNT 1** (`Codex` 274 vs 273) — still the suspected orphan proto, unproven.

Next Step: (1) diagnose the const-compare branch loss; (2) the `_G.type` routing; (3) prove the Codex
orphan; (4) then TECHNIQUE 2 from the literature — EXECUTION PROFILES (equivalence of conditional
execution counts and boolean-outcome distributions), which is still NOT implemented.

## 2026-07-26 - The branch signal was a LOWERING, not a defect. And a coverage gap that invalidated a "fix".

### The `MISSING BRANCH <const>` signal: CONFIGURATION, not a bug
`OPCODE_MAP.md:99` documents it: **`JUMPXEQKN/KS/KB` are LOWERED by default** to
`LOAD<const> scratch` + reg-reg compare (`0x27`/`0x37`), and only emitted natively behind
`RENOVICE_NATIVE=JUMPXEQKN,...`. So the original's const-compare legitimately becomes our
scratch-load + reg-reg compare — semantically identical, structurally different.
**This is the RENOVICE_NATIVE_GLOBALS lesson a second time: the transcoder has LOWERINGS chosen for
injection safety that are NOT faithful reproductions.** `cert/align.py` now runs in a FIDELITY MODE
that enables the native forms; without it the oracle reports configuration as defect.

### ★ A "fix" I made and REVERTED, because the suite could not see it
I flipped the `0x20/0x41/0x34` polarity on upstream's authority ("NOT flag in high bit"). Ground truth
stayed 150/150 and alignment did not move — which prompted the check that mattered:
**ZERO of 150 ground-truth files exercise `0x20`, `0x41` or `0x34`.**
The reason is structural: ground truth is generated through `luau-compile` -> our transcoder, and the
transcoder LOWERS those ops by default, so no generated case can ever contain one.
**The suite's coverage is bounded by the transcoder's own output** — a systematic blind spot, not a
random gap, and exactly why real corpus scripts contain opcodes our cases never touch.
"150/150 still passes" was therefore meaningless for that change, and shipping it would have been
another #52 (an unverified inversion validated by a number that cannot see it). Reverted, with the
reasoning left in `emit.h`. There is also substantive doubt: `transcode.h` annotates DE's `0x20` as
NOTEQ, so upstream's JUMPXEQK bit31 rule may not transfer.

### VERIFICATION PIPELINE — current state against the literature's four techniques
| technique | status |
|---|---|
| Recompilation-based (byte-equivalence proxy) | DONE — 5,386/5,386 decompile+recompile, 0 failures |
| Side-effect consistency | DONE — `cert/realtrip.py`, 150/150 traces |
| **Instruction-level alignment (Codealign)** | **BUILT** — `derecomp skeleton` + `cert/align.py`; found #58 on its first run |
| **Execution profiles** (conditional execution counts / boolean-outcome distribution) | **NOT BUILT** |

Alignment baseline in fidelity mode: **ALIGNED 14/60**, and the remaining signals are now specific:
`EXTRA BRANCH 0`+`EXTRA BRANCH 1` PAIRS (suspect: `0x34` compares a boolean IMMEDIATE — `aux & 1` IS
the value, there is no const index — so our skeleton may be recording an index where the original has
an immediate), `_G.type` routing, and the Codex orphan proto.

Next Step: (1) fix the skeleton's handling of `0x34` immediates so the oracle stops reporting a
rendering artefact; (2) rebuild ground truth for const-compare branches FROM REAL CORPUS BYTECODE
(generated cases structurally cannot reach them); (3) build EXECUTION PROFILES.

## 2026-07-26 - ★★ ALIGNMENT 13/60 -> 58/60. Two real defects, three ORACLE artefacts.

Driving the alignment oracle to convergence separated genuine defects from noise the ORACLE itself was
generating. Both categories matter: an oracle that cries wolf is as useless as one that stays silent.

### REAL DEFECTS FIXED
- **#59 `type` treated as a RESERVED WORD.** `type`/`export`/`continue` are CONTEXTUAL keywords in
  Luau, not reserved. `type` in particular is the STDLIB FUNCTION and appears constantly as a plain
  identifier — treating it as reserved sent every `type(x)` down the `_G[...]` fallback, emitting
  `_G.type` where the original had a direct global read. Accounted for ALL 6 remaining NAME-DIFFs.
- **#58 (earlier) NEWCLOSURE child-index** — see above.

### ORACLE ARTEFACTS (my measurement, not the decompiler)
- **`JUMPXEQK*` lowering.** Documented in OPCODE_MAP.md:99: lowered to LOAD-const + reg-reg compare
  unless `RENOVICE_NATIVE=` enables the native form. `align.py` now runs in FIDELITY MODE.
- **Proper-region state variable.** My own linearisation emits `if pN == 0/1 then`, which compiles to
  const-compare branches the original never had. Branch encoding is now compared SEPARATELY from
  entity access — "what the program DOES" vs "how it DECIDES".
- **DUPCLOSURE vs NEWCLOSURE.** Luau chooses between them by whether the closure captures anything;
  our lexical nesting creates captures where DE had none, so the OPCODE differs while the BOUND PROTO
  is identical. Unified into one `CLOSURE` class keyed on the target. **CAVEAT recorded: this means
  closure-IDENTITY/caching differences are no longer detected.**

### RESULT
| | before | after |
|---|---|---|
| ALIGNED (60 files) | 13 | **58** |
| ground truth | 150/150 | **150/150** (unchanged throughout) |

### THE REMAINING 2
- `Lotus_Interface_1999_RetroMessenger`: 368 vs 367 protos — the orphan-proto question again.
- `Lotus_Interface_ArchimedeaStickerReveal` proto[5]: `MISSING GETIMPORT FlashInterpolate`,
  `MISSING GETFIELD Ternary`, `EXTRA GETIMPORT mMovie`, `EXTRA NAMECALL Name__d971...` — this one is
  NOT explained by any known artefact and is the best remaining lead.

## 2026-07-26 - Alignment converged: 262 ALIGNED + 12 orphan-correct of 300; PROTO-LOST 0

Driving the oracle to convergence required separating three OWN-MEASUREMENT artefacts from real
defects. Recording them because each one initially looked like a decompiler bug:
1. **JUMPXEQK lowering** — a transcoder LOWERING (documented, injection-oriented), not a defect;
   `align.py` runs in FIDELITY MODE (`RENOVICE_NATIVE=...`) so the native forms are emitted.
2. **Proper-region state variable** — my own linearisation emits `if pN == 0/1`, adding const-compare
   branches the original never had. Branch encoding is now compared SEPARATELY from entity access.
3. **DUPCLOSURE vs NEWCLOSURE** — Luau picks by whether the closure captures; our lexical nesting
   creates captures where DE had none. Unified into one `CLOSURE` class keyed on the TARGET PROTO.
   CAVEAT: closure-IDENTITY/caching differences are consequently NOT detected.

### PROTO-COUNT resolved into two honest categories
Added `derecomp orphans` — a real reachability walk from the chunk over `kids` + DUPCLOSURE constants,
counting only sites in LIVE blocks (the emitter drops unreachable blocks, so a closure created solely
in dead code is statically reachable yet never emitted; ignoring that made a benign drop look like a
lost proto).
- `Codex`: 274 protos, 273 live-reachable, **1 orphan** -> we emit exactly 273. **Correct.**
- `RetroMessenger`: 368 protos, 366 live-reachable, 2 orphans -> we emit 367, i.e. **one MORE**.
  A proto bound by TWO closure sites is inlined TWICE. Semantically equivalent per call site, but it
  duplicates code and yields two distinct closure objects. Now reported as **PROTO-DUP**, not hidden.
**`PROTO-LOST` is 0/300** — we never drop a live proto.

### Score, 300 real files
| category | n | meaning |
|---|---|---|
| ALIGNED | 262 | entity access identical to the original |
| ALIGNED-minus-orphans | 12 | identical once provably-dead protos are excluded |
| PROTO-DUP | 8 | a shared closure target inlined twice |
| NAME-DIFF | 18 | **real, unexplained — the remaining work** |

### Defects fixed on the way
- **#59 `type` treated as reserved** — it is a CONTEXTUAL keyword and the stdlib function name;
  every `type(x)` went through the `_G[...]` fallback. Fixed; ground truth stayed 150/150.
- Nesting guard raised 8 -> 64 (not the cause of any loss, but 8 is too low for real scripts).

## 2026-07-26 - #60 LOOP STRUCTURE IS WRONG IN 174/300 FILES (found only by alignment)

### Initial Hypothesis
After the module-level alignment fixes, the residual NAME-DIFFs were the last real defects and the
rest was measurement artefact.

### Evidence Checked
`cert/align.py` against ORIGINAL bytecode; `derecomp de-disasm`; emitted sources for
ImGuiSeasonOverride, SetVortexWindPerZone, DragScroll, ImGuiEntityViewer; `cert/realtrip.py` 150.

### Finding
**False — and the residue hid something far worse.**

Four of my own measurements were invalid and had to be fixed before any signal was real:
1. **Per-proto INDEX comparison.** Our emission ORDER legitimately differs, so `proto[30]` on the two
   sides is usually a DIFFERENT FUNCTION. Comparing by index reported 18 diffs that meant nothing;
   module-level comparison cut it to 6.
2. **Recursive closure content-signature.** Tried to make closure identity order-independent. It
   AMPLIFIES: one benign leaf difference rewrites every ancestor's signature. 5 findings -> 207. Rejected.
3. **Ordered body keys.** Register allocation decides WHEN a load is materialised, so
   `tonumber(o:Get())` may load `tonumber` before or after the inner call. 145 files "differed" while
   the multisets were identical.
4. **A binary built with the wrong compiler.** I rebuilt with plain `g++` instead of `build.bat`
   (ucrt64 + `-static`); the exe then died with 0xC0000139 under Python. Every diff came back EMPTY
   and I briefly read that as "aligned". **An oracle that cannot run reports perfect agreement.**
   align.py now treats a non-zero skeleton exit as a failure rather than as an empty skeleton.

### What the corrected oracle then found
Counting loop opcodes (FORNPREP/FORNLOOP/FORGPREP/FORGLOOP) original-vs-ours:

| | |
|---|---|
| LOOP-DIFF | **174 / 300 files** |
| ALIGNED | 82 |
| ORDER-DIFF | 21 |
| ALIGNED-minus-orphans | 12 |
| PROTO-DUP | 8 |
| NAME-DIFF | 3 |

Both directions occur: `ImGuiEntityViewer` LOSES 3 loops (6 -> 3), `DragScroll` INVENTS one (3 -> 4).

**This is why it stayed invisible.** A lost loop still decompiles, still recompiles, still round-trips,
and still passes a behavioural trace — the body simply runs ONCE instead of N times. Every oracle that
compares our output to ITSELF is blind to it by construction. Only comparison against the ORIGINAL
BYTECODE can see it.

### #60a FIXED — for-header emitted BEFORE its own setup
`emit_region`'s fallback ("a loop may carry the for-op on its latch") accepted ANY for-op on ANY
interior block. That is right for FORGLOOP (0x1e), which really does terminate the loop, but every
PREP (FORNPREP 0x47, FORGPREP 0x0b/0x30/0x1b) sits in the PREHEADER, BEFORE the loop. Finding a prep
on a non-head block means the region is `setup...; for ... end`, and opening a region-level `for`
there emitted the header BEFORE its own setup.

Measured on ImGuiSeasonOverride: ONE original loop became TWO `for`s whose bounds were assigned
INSIDE the body they controlled:
```lua
for c1v7 = c1v7, c1v5, c1v6 do     -- c1v5/c1v6/c1v7 are still nil here
  ...
  c1v7 = 1 ; c1v5 = 4 ; c1v6 = 1   -- the actual FORNPREP setup, now unreachable as setup
```
First attempt — reject preps in the fallback — traded an invented loop for a LOST one. The correct fix
is to SPLIT: emit every part up to and including the one containing the prep as setup, then the
header, then only the parts after it as the body. Now correct: `for i = 1, 4 do ... end`. 179 -> 174.
`RENOVICE_NOPREPSPLIT=1` restores the old path so the change can be attributed.

### #61 OPEN — `realtrip.py` is 120/150, NOT the recorded 150/150
Re-running the behavioural oracle gives **120 SAME / 30 DIFFERENT**. Re-running with
`RENOVICE_NOPREPSPLIT=1` gives **exactly the same 120/30**, so it is NOT caused by the loop fix.
Smallest case is 81 bytes with no loop and no inf constant, so no change made today can reach it:
```
S'  : local v0 ; v0 = function() ... end ; Run = v0
S'' : local v0 ; v0 = nil ; v0 = function() ... end ; Run = v0     <- extra LOADNIL materialisation
t1  : FINAL Run = <fn>
t2  : SET _G.Run = <fn> ; FINAL Run = <fn>                          <- extra observed global SET
```
The recorded "150/150" does not hold in the current configuration. Not yet attributed.

### Next Step
Fix the remaining 174 LOOP-DIFF files, then attribute #61.

## 2026-07-26 - #62 Proper linearisation has NO dispatch loop: backward state transitions are dead

### Initial Hypothesis
The remaining lost loops are lost because a FORNPREP inside a Proper (irreducible) region is rendered
as a boolean CONDITION instead of a loop.

### Evidence Checked
`EE_Interface_AnchorMgr` proto[3] (localised by matching proto bodies, since proto ORDER differs);
emitted sources for 300 corpus files; textual analysis of state-variable guards vs assignments.

### Finding
**Mixed / conflicting evidence.** The condition-render hypothesis is FALSE for AnchorMgr (zero
FORNPREP-shaped conditions emitted), but the investigation surfaced a different real defect.

The Proper-region linearisation emits a state variable and a STRAIGHT-LINE CHAIN of `if pN == k then`
blocks with **NO enclosing `while true do` dispatch loop** (measured: 0 dispatch loops, 3 state
variables, 110 transitions in AnchorMgr alone). A state machine without a dispatch loop can only
express FORWARD transitions. A BACKWARD transition - which is exactly what a loop back edge becomes -
assigns a state whose guard block has already been passed, so control never returns and the body runs
ONCE.

Measured over 300 files by matching each `pN = K` assignment against the line of its `if pN == K then`
guard:
| | |
|---|---|
| files with >=1 BACKWARD (unreachable) transition | **43 / 300** |
| total backward transitions | **1,362** |
| total forward transitions | 34,038 |

**CAVEAT, not yet excluded:** if a state machine sits inside a genuine `for`/`while` that we DID
recover, a backward transition can still be reached on the next iteration. So 1,362 is an UPPER BOUND
on lost back edges, not a confirmed count. Must be re-measured with enclosing-loop awareness before
being quoted as a defect count.

**AnchorMgr remains unexplained**: proto[3] has 0 backward transitions and 113 forward ones, yet its
numeric loop is gone (original 8 loops, our source 7 `for`). Its body matches ours exactly on entity
ops, so only the loop structure differs. Separate cause, still open.

### What Changed
A second concrete loop-loss mechanism identified and bounded. The dispatch-loop omission is a
structural limitation of the linearisation, not a pattern-matching miss like #60a.

### Next Step
(1) Re-measure the 1,362 with enclosing-loop awareness to get the true count. (2) Wrap Proper-region
linearisation in a `while true do` dispatch with a terminal state, which makes backward transitions
expressible at all. (3) Find AnchorMgr proto[3]'s separate cause.

## 2026-07-26 - Research dossier: loop attribution over the FULL corpus, and #63 (a v9 trap)

16-agent investigation, 1.37M tokens, 906 tool uses. Adversarial verification refuted 3 of 4
load-bearing claims, including one of MINE. Recorded verbatim because the refutations matter more
than the confirmations.

### Loop defect attribution - FULL 5386-file corpus
Per file: A = FORNPREP+FORGPREP in the ORIGINAL, B = for-statements in OUR SOURCE, C = same count in
OUR RECOMPILE.

| bucket | n | share | meaning |
|---|---|---|---|
| FINE | 2516 | 46.7% | A = B = C |
| **DECOMPILER-SIDE** (B!=A, C=B) | **2136** | **39.7%** | we wrote the wrong number of loops; the compiler was faithful |
| COMPILER-SIDE (B=A, C!=B) | 58 | 1.1% | source right, recompile changed the count |
| BOTH / unclear | 676 | 12.6% | not merged into either bucket |

**~52% of the corpus has a loop defect.** The 174/300 from align.py is consistent with this.

### The 58 "COMPILER-SIDE" files are NOT a compiler defect
Inspected: ClanUtilities (A=8 B=8 C=5), ContextAction (12/12/10), Dojo (3/3/1), WispSpawning (1/1/0).
In every case OUR SOURCE places `for` loops after `do return end`, after a `while true` with no break,
or at the tail of a state-machine if-chain. luau-compile's dead-code elimination CORRECTLY drops
them. So this is a decompiler OUTPUT-QUALITY defect - we emit unreachable loops - and DCE is not
version-gated, so **a v9 switch would fix ZERO of the 58.**

### CRASH-SAFETY: the dangerous opcode set is EMPTY
histops over 5386 files / 82,059 protos / 100.00% clean_walk yields **77 distinct attested DE opcode
bytes**. Static analysis of every path in transcode.h yields **77 emittable bytes**. The sets are
IDENTICAL. Unattested slots (03, 05, 1f, 36, 43, 48, 52, 56-FF) are never emitted; per
de-opcode-dispatch some are interpreter TRAP slots.
Only escape hatch: the `RENOVICE_OP_<name>` per-op env override (strtol -> any byte). Calibration
backdoor, dead unless such an env var is set.
Residual risk is NOT the opcode byte but WRONG OPERANDS on an attested opcode - transcode.h ~line 109
carries open TODOs on NEWCLOSURE variable-width encoding and SETLIST/SETTABLEN semantics. Unanalysed.

### V9: verified, and MY RECOMMENDATION WAS REFUTED
Verified from Bytecode.h (fetched AND confirmed against the project's local copy at
RENOVICE_Toolkit/compiler/luau_src/.../Bytecode.h:502-504):
  LBC_VERSION_MIN=3  LBC_VERSION_MAX=12  LBC_VERSION_TARGET=9
  LBC_TYPE_VERSION_MIN=1  LBC_TYPE_VERSION_MAX=3  LBC_TYPE_VERSION_TARGET=3
BytecodeBuilder.cpp getVersion(), verbatim:
  if (FFlag::LuauBytecodeCostModel)        return 12;
  if (FFlag::LuauEmitCallFeedback)         return 11;
  if (FFlag::DebugLuauUserDefinedClasses)  return 10;
  return LBC_VERSION_TARGET;   // 9
Opcode delta: v10 adds LOP_NEWCLASSMEMBER + a class-shape constant tag; v11 adds LOP_CALLFB and
LOP_CMPPROTO; v12 adds NO opcodes - it adds a per-proto cost function and a per-proto SIZE PREFIX
varint. **For plain Lua source the v9->v12 opcode delta is ZERO** - those ops are Roblox-internal and
never emitted for our input.

### #63 (NEW, LATENT) - feeding v9 bytecode to our parser would SILENTLY CORRUPT it
`luau_bc.h::read()` unconditionally reads a per-proto `dsize` varint for EVERY proto, regardless of
the version byte. That varint is the **v12 cost-model prefix**; v9 bytecode does not have it. Parsing
v9 input therefore misreads the first byte of the proto BODY as `dsize`, seeks to a wrong offset, and
yields a corrupt proto (wrong maxstack/nparams/nups/ncode) **with no exception raised**.

So the "one-line, reversible, low-risk" change I proposed (add `--fflags=false` at main.cpp:74) would
have SILENTLY DESYNCED the pipeline. It is only safe if `read()` is made version-aware FIRST. The
user's decision to leave the compiler alone was correct, and for a reason neither of us had yet.
Also: "Luau v9" != "DE v9 container" - DE remaps opcodes (CALL=0x54 vs stock 0x15), so the transcoder
is mandatory at ANY Luau version. The version match was never the thing standing between us and DE.

### Literature: nothing new
All adversarial verdicts on "the literature identifies a concrete implementable rule" returned
REFUTED. structan.h already implements the graph-theoretic primitives (Cifuentes, Muchnick, Schwartz,
Phoenix/DREAM). The remaining gap is trace-and-fix on specific failing shapes in emit.h, not a
missing algorithm. Two named root causes stand: (A) Proper regions with backward edges need a
`while true do` dispatch (= #62), (B) prep on a non-head block - and FORGPREP must be handled
DIFFERENTLY from FORNPREP: FORGPREP is unconditional and its body is the FORGLOOP latch's back-edge
target, NOT the prep's fall-through.

### Open (from the dossier)
- The luau-lang/luau revision bin/luau-compile.exe was built from is **UNRECOVERABLE**: CMakeCache
  records Luau_SOURCE_DIR = ...\LuauDE\luau, and that directory no longer exists. No pin, submodule
  or tag. Reproducibility gap.
- AnchorMgr proto[3] still unattributed. #61 (realtrip 120/150) still unattributed.
- Whether the 676 BOTH files are dead-code loops or genuine two-sided bugs: not analysed.

### #63 CORRECTION - measured, not taken on trust
I verified the mechanism and the consequence myself rather than accepting the agent's wording.

CODE PATH: CONFIRMED. `luau_bc.h:183` reads `dsize` unconditionally and its own comment names it the
LuauBytecodeCostModel prefix; `m.version` is read at `:176` but never gates it.

OBSERVED BEHAVIOUR: a LOUD failure, not the silent corruption the agent asserted:
```
v12 input -> version=12 typeversion=3 strings=1 protos=1 mainid=0     (parses fine)
v9  input -> [derecomp] parse error: rd_u8: past end                  (rejected outright)
```
On this sample the desync overran the buffer and WAS caught. Silent corruption stays POSSIBLE for
inputs where the misread length lands inside the buffer, but it is NOT demonstrated - do not quote it
as fact. The operative conclusion is unchanged: **our parser cannot consume v9 bytecode today**, so
`--fflags=false` is blocked until `read()` is made version-aware.

## 2026-07-26 - #61 RESOLVED: the behavioural oracle was measuring its caller's shell

### Initial Hypothesis
`realtrip.py` scoring 120/150 (not the recorded 150/150) was a decompiler regression.

### Evidence Checked
`cert/realtrip.py` env handling; the 81-byte EE_Scripts_PostConfig case; a full 150-file re-run with
`RENOVICE_NATIVE_GLOBALS=1`.

### Finding
**False - it was a defect in the ORACLE, not in the decompiler.**

`realtrip.py` set NO environment and simply inherited the caller's shell. With
`RENOVICE_NATIVE_GLOBALS` unset, the transcoder LOWERS global access to `_G.X`. So:
  S'  (decompile of original)                       emits  `Run = v0`
  S'' (decompile of recompile of S')                emits  `_G.Run = v0`
S' and S'' were therefore never the same program, and the traces diverged on a `SET _G.Run` event that
only one side produced:
```
t1: FINAL Run = <fn>
t2: SET _G.Run = <fn> ; FINAL Run = <fn>
```
Pinning the env took the score from **120/150 to 149/150** with no code change to the decompiler.
`ENV` is now hard-coded in realtrip.py (as align.py already did). An oracle whose verdict depends on
the caller's shell is not an oracle - this is the third time a MEASUREMENT, not the subject, was the
thing at fault (cf. the non-loading binary that reported "no differences", and per-proto index
comparison comparing different functions).

**Secondary, genuine finding:** the `_G` lowering is NOT round-trip idempotent. That is fine for
injection (its purpose) but it means the injection-safe configuration cannot be round-trip verified.
Worth stating explicitly rather than leaving implicit in the env var.

### Residual: 1/150 still DIFFERENT
`Lotus_Fx_Enemies_Tau_Drone_TauDroneEffects` - S' is 138 lines, S'' is 230, and S'' calls `Sleep(0)`
before `self.GetAttachRoot` where S' calls GetAttachRoot first. NO loops are involved (0 loop opcodes
on both sides), so this is BLOCK ORDER instability in a branchy region, i.e. the same emitter
structural defect class as the loop work. Open.

### What Changed
Technique 2 of the 4-technique verification pipeline moves from a misleading 120/150 to a real
149/150, and its configuration is now pinned so it cannot silently drift again.

## 2026-07-26 - #60b/#60c: two principled loop fixes, small measured effect; duplication is the real driver

### #60b FORGPREP body target (FIXED, no aggregate movement)
`body_start` was computed as the prep block's `succ_false` for BOTH preps. That is right for FORNPREP
(CONDITIONAL - it falls through into the body) and WRONG for FORGPREP (UNCONDITIONAL - it jumps
forward to the FORGLOOP latch, so it has no meaningful false edge). Reading it as one yields a garbage
natural loop and collapses the break scope. The generic-for body begins at the instruction right AFTER
the prep, i.e. the block FORGLOOP back-edges to. Same asymmetry as the M6d phantom edge.
Fixed and correct in principle. **Measured effect on the aggregate: NONE (174 -> 174).**

### #60c Double header for one generic-for (FIXED, marginal)
`for_header` accepts BOTH the FORGPREP prep and the FORGLOOP latch, so an outer region could open a
`for` from the latch while an inner region opened another from the prep - one loop, two headers. The
latch fallback is now suppressed when the region also contains a prep. **174 -> 172.**

### The dominant mechanism is DUPLICATION, and it is NOT mine
A/B/C on the worst cases:
| file | original | our source `for` | our recompile |
|---|---|---|---|
| EE_Types_ScriptCommands_JSON | 8 | **16** | 16 |
| EE_Interface_Components_ImageSlideShow | 3 | 4 | 4 |
B == C everywhere, so the compiler is faithful and the defect is entirely ours. JSON is EXACTLY 2x.

Ruled out by measurement, not by argument:
- **My prep-split (#60a) is NOT the cause**: `RENOVICE_NOPREPSPLIT=1` gives the SAME 16.
- **Double headers are NOT the cause for JSON**: still 16 after #60c.
- `bodydiff` on JSON shows 3 body kinds present in the ORIGINAL and missing from ours, with others
  duplicated - i.e. WHOLE-PROTO duplication that leaves the proto COUNT unchanged (n dropped + n
  duplicated nets to zero), which is why the proto-count check passes and it reaches the LOOP check.

So the remaining loop defect is largely a symptom: protos are being inlined more than once (already
seen as PROTO-DUP 8/300 where the count DID change). Loops are duplicated because their containing
FUNCTION is. Fixing closure/proto binding should collapse a large share of the 172 at once.

### Regression gate (run, not assumed)
`realtrip` 149/150 before and after both emitter changes. Corpus alignment ALIGNED 82 -> 84.

### Next Step
Attack proto duplication directly (why is one proto emitted at two closure sites?), NOT more loop
pattern-matching. That is the upstream cause.

## 2026-07-26 - #60d GREEDY PREP SCAN: a parent region stole a nested region's loop

### Initial Hypothesis
The 2x loop counts come from whole-PROTO duplication (one proto inlined at two closure sites).

### Evidence Checked
Closure-site vs function-literal counts; live vs full loop counts; direct read of emitted `for`
headers; a new RENOVICE_LOOPTRACE=1 provenance annotation.

### Finding
**False, then RESOLVED by instrumentation.**

Proto duplication was RULED OUT by measurement, not argument - emitted function literals match live
closure sites EXACTLY:
| file | protos | closure sites (live) | our function literals |
|---|---|---|---|
| JSON | 23 | 22 | 22 |
| ImageSlideShow | 52 | 51 | 51 |
| AnchorMgr | 13 | 12 | 12 |
Liveness was ruled out too (A_live == A_all on every file checked).

Three successive guesses at the double-header all failed to move JSON (16 every time). So I stopped
guessing and added `RENOVICE_LOOPTRACE=1`, which annotates each emitted `for` with the region, head
block, body-start, latch and prep-part that produced it. The answer was immediate:
```
1384:  for c18v14, c18v15 in ...  --[[rgn=70 hb=34 bs=35 latch=-1 prep=1]]
1460:  for c18v14, c18v15 in ...  --[[rgn=71 hb=34 bs=35 latch=-1 prep=2]]
```
**Same head block, same body start, TWO different regions.** The prep scan used `collect_blocks`,
which recurses over the whole SUBTREE, so a PARENT region found a prep belonging to a NESTED region
and opened a header for it - then recursion reached the child and opened the same loop again. They
emit SEQUENTIALLY, not nested, so the `for_open` guard could never catch them: the first loop had
already closed and been erased. The scan itself was the bug.

FIX: scan only each part's HEAD block, never its subtree. A deeper prep is not lost - recursion
reaches the region where that prep IS the head.

### Result - MIXED, and the regression is real
| metric | before | after |
|---|---|---|
| JSON loops (orig 8) | 16 | **14** |
| LOOP-DIFF /300 | 172 | **170** |
| ALIGNED /300 | 84 | **85** |
| ORDER-DIFF | 21 | **19** |
| **NAME-DIFF** | **3** | **6 (WORSE)** |
| realtrip /150 | 149 | 149 (unchanged) |
| ImGuiSeasonOverride (orig 1) | 1 | 1 (no regression) |

NAME-DIFF 3 -> 6 means three more files now differ in WHICH NAMED ENTITIES they touch - the
non-greedy scan drops some code that the greedy scan reached. That is a genuine regression traded for
a loop improvement, and it is NOT obviously a good trade: a lost entity access is a semantic change,
whereas a duplicated loop header is (usually) redundant structure.

Two prior fixes this session are INERT and should be reconsidered as dead complexity: the #60c
has_prep guard and the `for_open` set both never fire on any measured case.

### Next Step
Decide whether to keep #60d (trade 2 loop-diffs + 2 order-diffs for 3 name-diffs) or revert it and
attack the greedy-scan problem without dropping code. Identify the 3 newly-broken NAME-DIFF files
first - that tells us what the head-only scan is skipping.

## 2026-07-26 - #64 ARCHITECTURAL: loop identification is in the WRONG PHASE (web-researched)

### Initial Hypothesis
The loop defects are individual emitter bugs, fixable by successive pattern patches in emit.h.

### Evidence Checked
Web research against PRIMARY sources: dcc BACKEND.C (Cifuentes), Ghidra block.hh + CollapseStructure,
Hex-Rays hxe_structural phase, DREAM/angr structuring, Phoenix (Schwartz), unluac
ControlFlowHandler.java + ForBlock.java, LLVM Loop Terminology, OOPSLA 2024 Java-decompiler bug study.

### Finding
**False. I rebuilt the exact anti-pattern this project already eliminated once.**

M6d replaced a "recursive-descent pattern pile" in the STRUCTURING phase with real structural analysis
(92.32% -> 100%). I have spent this session rebuilding that same pattern pile inside the EMITTER.

**Every decompiler examined puts loop identification in STRUCTURING, never in emission:**
- dcc: BACKEND.C reads `loopType` / `latchNode` / `loopHead` / `loopFollow` - fields SET by structuring.
- Ghidra: `BlockWhileDo` / `BlockDoWhile` / `BlockInfLoop` are distinct CLASSES chosen by
  `ruleBlockWhileDo` etc. in CollapseStructure; `PrintC` dispatches virtually and reads pre-populated
  `initializeOp` / `iterateOp` / `loopDef`.
- Hex-Rays: a dedicated `hxe_structural` phase runs BEFORE ctree generation.
- DREAM/angr: `LoopNode.sort` is set by the structurer; `_handle_Loop` only reads it.
- unluac (the mature Lua decompiler): `ControlFlowHandler.find_fixed_blocks()` scans for FORPREP and
  INSTANTIATES a typed `ForBlock51` **during structuring**; emission just calls `print()` on an
  already-typed node.
**No emitter in any established decompiler scans bytecode to decide whether a region is a loop.**
Doing so creates a SECOND, independent, inconsistent loop-detection pass - which is precisely why a
parent region and its child both emit the same loop (measured: rgn=70 and rgn=71, same hb=34/bs=35).

### Two specific corrections to our model
1. **The preheader is NOT part of the loop.** LLVM's canonical definition: "the preheader dominates
   the loop without itself being part of the loop." Correct region shape is
   `Seq[ preheader, LoopNode ]` - a SIBLING that precedes the loop, never a member of it. Our
   prep-split was trying to reconstruct this at print time.
2. **For a GENERIC for, the loop header is the FORGLOOP block, NOT the FORGPREP block.** FORGPREP is
   unconditional and jumps to the latch; it is the PREHEADER. Cited as the root of exactly the
   FORGPREP bugs we have been chasing: "Getting this wrong in structuring and then trying to fix it in
   emission is the root of the FORGPREP-related bugs you described."

### A validation invariant we do NOT yet have
**Each back edge must produce EXACTLY ONE loop header in the output, and vice versa** - a bijection
between CFG back edges and emitted loop constructs. This measures the defect directly instead of
inferring it from opcode counts, and it would have flagged the duplication immediately. The OOPSLA
2024 study names "region restoration" as a top decompiler bug category, manifesting as exactly our
symptoms (code duplication and missing iterations).

### What Changed
#60d REVERTED (NAME-DIFF back to 3, nothing dropped; LOOP-DIFF 172, ALIGNED 84). Stopping emitter
patching entirely. Three of my fixes this session (#60c has_prep guard, the `for_open` set, and the
latch/bstart unification) are INERT - they never fire - and are dead complexity to strip.

### Next Step
Move loop identification into structan.h. Each loop region must carry: `loop_kind`
(NumericFor / GenericFor / While / RepeatUntil / Endless), `header_block`, `latch_block`, `body_set`,
`preheader_block` (as an external sibling reference so the emitter knows the parent Seq already emits
it), and for counted loops the induction register plus init/limit/step. Then STRIP every opcode
inspection from emit.h so it dispatches on node kind alone. Add the back-edge bijection check as a
gate.

## 2026-07-26 - #65 BACK-EDGE BIJECTION oracle built; the real loop baseline

### Initial Hypothesis
Loop-opcode counting (align.py's LOOP-DIFF) is an adequate measure of loop recovery.

### Evidence Checked
New `derecomp backedges` command (an edge u->v is a back edge iff v DOMINATES u; `compute_dom`
already existed in structur.h) plus `cert/backedge.py` over 300 corpus files.

### Finding
**Partially true - it correlates, but it is the wrong instrument.**

Opcode counting conflates a LOST loop with a RE-ENCODED one, and it cannot see a loop emitted TWICE
around a single body. Back edges are a property of the CONTROL FLOW GRAPH, so they measure loop
recovery directly: each back edge must yield exactly one loop construct, therefore the original's
back-edge count and our recompile's must be EQUAL. Counting only reachable blocks, since dead code
cannot loop at runtime.

### BASELINE (300 files) - the number the refactor must move
| | |
|---|---|
| MATCH | **133 / 300 (44.3%)** |
| EXTRA-LOOPS | 99 files, **+479** back edges |
| LOST-LOOPS | 68 files, **-386** back edges |

Worst: ChatRedux -45, Background -31, ThemedSquadPanel +28, DiegeticUpgradeCards -26,
AvatarDiorama +26.

Both directions are large, which is the signature of loop identification happening in the WRONG PHASE
(#64) rather than of any single pattern bug: we invent loops where the CFG has no back edge, AND drop
loops where it has one.

### Note on the oracle itself
`backedge.py` treats a non-zero exit from the tool as `tool-fail`, never as "no difference" - the
mistake that once made a non-loading binary report perfect agreement. It also pins the fidelity env
rather than inheriting the caller's shell (the #61 mistake).

### Next Step
The M6e refactor (#64): move loop identification out of emit.h into structan.h, so each loop region
carries loop_kind / header / latch / body_set / preheader / induction data, and emit.h dispatches on
node kind alone. Re-run this oracle after; MATCH must rise well above 133/300.

### #65b Grading on LOOP HEADERS, not back edges - and DUPLICATION dominates
Two back edges into the SAME header are ONE loop with two latches (a `continue`), not two loops. So
loop COUNT is the number of distinct back-edge TARGETS. `backedges` now reports both; the oracle
grades on headers and reports the latch delta separately.

| metric | back-edge grading | **header grading** |
|---|---|---|
| MATCH | 133 | **112 / 300 (37.3%)** |
| EXTRA | 99 files (+479 edges) | **126 files (+588 headers)** |
| LOST | 68 files (-386 edges) | 55 files (-175 headers) |
| LATCH-DIFF | n/a | 7 |

**We INVENT 3.4x more loops than we lose (+588 vs -175).** Duplication, not loss, is the dominant
defect - consistent with JSON emitting 16 `for` for 8 original loops, and with #64's diagnosis that a
second, independent loop-detection pass in the emitter fires on regions the structurer already owns.
Worst: AvatarDiorama +33, EndOfMatch +25, ChatRedux -25, ThemedSquadPanel +24, Codex +23.

Header grading is the number the #64 refactor must move: **112/300**.

## 2026-07-26 - #66 Luau loop CFG shapes VERIFIED; A+2 confirmed against DE bytecode

### Initial Hypothesis
Luau's Bytecode.h comment "numeric for loops assume a register layout [limit, step, index, variable]"
means the user-visible loop variable lives at A+3, so our A+2 model is wrong.

### Evidence Checked
Web research against Luau Bytecode.h, the Fiu Luau-in-Luau interpreter, Lua 5.1/5.2 lvm.c, and
unluac (ForBlock/TForBlock/ControlFlowHandler); then a DIRECT read of real DE bytecode
(EE_Scripts_ImGuiSeasonOverride, `for i = 1, 4`).

### Finding
**False - A+2 is CORRECT for DE. Do not "fix" this.**
```
[19] FORNPREP A=5          -> limit=R5(A+0)  step=R6(A+1)  index=R7(A+2)
[20] op=0x27 A=7 ...       -> body TESTS R7
[21] op=0x14 A=3  B=7      -> body READS R7
[25] op=0x14 A=11 B=7      -> body READS R7
```
The body reads **R7 = A+2**, never R8 = A+3. Fiu's FORNLOOP handler likewise updates only `stack[A+2]`
and never writes A+3 (unlike Lua 5.1/5.2 lvm.c, which does `setnvalue(ra+3, idx)`). Luau's compiler
binds the user variable directly to the index slot; the Bytecode.h comment describes a 4-slot layout
the VM does not actually materialise.

**This was a near miss.** Changing to A+3 on the strength of a header comment would have corrupted
EVERY numeric for loop, and NO oracle we own would have caught it: the semantic skeleton drops
register numbers by design, and a consistent misreading round-trips perfectly. Cross-checking a
documentation claim against real bytecode is what saved it.

### VERIFIED CFG SHAPES (the basis for the #64 refactor)
**Numeric for** - FORNPREP is CONDITIONAL (it can prove zero iterations from limit/step/index alone):
- preheader = the FORNPREP block (NOT part of the loop)
- header    = the block at FORNPREP+1 (first body instruction)
- latch     = the FORNLOOP block
- back edge = FORNLOOP -> header
- exits     = from BOTH FORNPREP (zero-iteration shortcut) and FORNLOOP

**Generic for** - FORGPREP is UNCONDITIONAL (the iterator has not been called yet, so zero-iteration
cannot be known without calling it; that call IS FORGLOOP):
- layout    = `FORGPREP` ... body ... `FORGLOOP`, with FORGPREP jumping FORWARD to FORGLOOP
- preheader = the FORGPREP block
- **header  = the FORGLOOP block** - every entry to the body passes through FORGLOOP, so FORGLOOP
  DOMINATES the whole body. FORGPREP reaches the body only via FORGLOOP.
- latch     = the LAST BODY block, which falls through into FORGLOOP
- back edge = last-body-block -> FORGLOOP  (NOT FORGLOOP -> body: the body does not dominate FORGLOOP)
- exit      = FORGLOOP only

That is the correction that explains the whole FORGPREP saga: emit.h treated the FORGPREP block as the
loop head and the block after it as the body start. The real header is FORGLOOP, and FORGPREP is only
a preheader - a SIBLING that precedes the loop, never a member of it.

**Generic-for registers CONFIRMED**: A+0=generator, A+1=state, A+2=control index (not user-visible),
user variables at **A+3 .. A+2+nvars**, with `nvars = aux & 0xFF` and bit31 = ipairs-style fast path.

**while vs repeat** (no dedicated opcodes; purely structural): conditional test at the HEADER = while;
conditional test at the LATCH = repeat/until.

### Next Step
Implement #64 using these shapes: identify loops in structan.h from dominators/back edges, tag each
with kind + header + latch + body + preheader, and strip opcode scanning from emit.h.

## 2026-07-26 - #67 Loop map wired per #64: fixes duplication, exposes an incomplete map. GATED OFF.

### Initial Hypothesis
Making the emitter consult the structurer's authoritative loop map, instead of scanning opcodes, will
fix the loop defects (#64's architectural prescription).

### Evidence Checked
Web research (two agents, primary sources: Ghidra blockaction.cc, angr Phoenix/DREAM, LLVM LoopInfo,
Havlak 1997, Wei/Mao/Zou/Chen SAS 2007, Cifuentes, unluac); then implementation + the back-edge oracle.

### Finding
**Partially true.** The diagnosis is right and the mechanism works, but the map is not yet complete
enough to be authoritative, so applying it half-way is net negative.

**A significant discovery while implementing: `st::find_loops` ALREADY EXISTS** in structur.h and
already handles the FORNPREP/FORGPREP asymmetry correctly (its own comments document that FORGPREP
jumps TO the FORGLOOP while FORNPREP jumps to the loop EXIT). The emitter simply never consulted it.
So the anti-pattern was not a missing capability - it was a SECOND detector built alongside an
existing, correct one.

### Measured (300 files, graded on loop HEADERS)
| | baseline | with loop map |
|---|---|---|
| MATCH | **112** | 107 |
| EXTRA (invented) | +588 | **+205** |
| LOST | -175 | **-678** |
| JSON loops (orig 8) | 16 | 7 |
| Utilities (orig 18) | 25 | 11 |
| ImGuiSeasonOverride (orig 1) | 1 | 2 (regressed) |

**Duplication is largely solved by the correct architecture (+588 -> +205, JSON 16 -> 7).** But the
gate also rejects real loops the map does not carry, so losses nearly quadrupled. Widening the gate to
accept a derived HEADER as well as a prep changed NOTHING (identical numbers), which says the missing
loops are absent from the map entirely as the emitter sees it - not merely keyed differently. That is
the next thing to investigate: why `find_loops` output, as seen from the emitter, omits loops that
demonstrably exist.

### Decision
**GATED OFF behind `RENOVICE_LOOPMAP=1`; default restores the 112 baseline (verified).** A
half-applied refactor that loses more loops than it fixes is worse than none. The plumbing is kept -
`Loop::prep` (the preheader, recorded as an external sibling per LLVM's definition), `prep2latch`,
`latch_of_loop`, `header_of_loop` - so the work is preserved and measurable rather than deleted.

### Next Step
Find why the map omits loops from the emitter's viewpoint (prime suspect: the emitter's Graph and the
graph passed to find_loops differ in reachability or preds). Once the map covers every loop the CFG
actually has - validate it against the back-edge oracle DIRECTLY, i.e. assert
`#loops-in-map == #distinct back-edge headers` per proto BEFORE using it - then enable the gate.
That assertion is the missing safety check: it would have caught the incompleteness immediately.

## 2026-07-26 - #68 FIXED: generic-for header convention in find_loops (map now matches the CFG)

### Initial Hypothesis
The loop map is INCOMPLETE - it omits loops the emitter needs, which is why gating on it lost loops.

### Evidence Checked
Added a completeness check to `derecomp backedges`: distinct back-edge headers in the CFG vs the number
of loops `st::find_loops` reports, per proto.

### Finding
**False - the map was OVER-complete, not incomplete.**
```
                     back-edge headers   loops mapped
EE_Types_..._JSON            11               18
EE_Interface_Utilities       24               38
Lotus_Interface_Hub         117              161
```
`find_loops` has two branches - a PATTERN branch for FOR* preps and a DOMINANCE branch - and it already
dedups by header. But the pattern branch assigned `L.header = body` (the block after the prep) for BOTH
loop kinds. For a GENERIC for that is wrong: FORGPREP is unconditional and jumps to FORGLOOP, every
entry to the body passes through FORGLOOP, so **FORGLOOP dominates the body and IS the header**
(FINDINGS #66). The pattern entry therefore claimed a different header from the dominance entry for the
same loop, dedup-by-header could not merge them, and every generic-for was counted twice.

FIX: `L.header = prep_gen ? loopblk : body;`

### Result - the map now matches the CFG
```
                     back-edge headers   loops mapped
EE_Types_..._JSON            11               11   exact
EE_Interface_Utilities       24               24   exact
Lotus_Interface_Hub         117              118   off by one
```
Default behaviour (map still gated off) is UNCHANGED at MATCH 112/300 - a structural correction with
no regression. This also makes "loops mapped == distinct back-edge headers" a usable INVARIANT that
can be asserted per proto, which is the safety check #67 lacked.

### Still open: the gate itself
With `RENOVICE_LOOPMAP=1` the numbers are IDENTICAL to before this fix (MATCH 107, LOST 678,
EXTRA 205). So the gate's rejections are NOT caused by the generic-for header convention, and the
correct map alone does not fix them. The remaining rejection cause is unidentified - do NOT guess it,
instrument it: count gate rejections per proto and print, for each, the region id, head block, the prep
opcode, and which lookup missed (`prep2latch`, `latch_of_loop`, or `header_of_loop`). That is the same
move that cracked the double-header question, and guessing has failed three times in a row on this one.

### Next Step
Instrument the gate rejections. Keep the gate OFF until MATCH exceeds 112.

## 2026-07-26 - #69 Gate rejections SOLVED by instrumentation; but a SECOND emission path remains

### Initial Hypothesis
The loop-map gate rejects real loops for an unknown reason; instrumenting the rejection will show it.

### Evidence Checked
Added a rejection trace to the gate (region id, head block, prep opcode, and WHICH lookup missed),
then ran it on JSON and AvatarDiorama.

### Finding
**True, and it was answered on the first run.** Every rejection had the identical shape:
```
REJECT rgn=56 hb=11 op=0x1e latch_blk=-1 inPrep2Latch=0 hdrN=-1 hdrG=-1 mapsz=3
```
`op=0x1e` is FORGLOOP. The region's OWN HEAD BLOCK was the generic-for's FORGLOOP - which after #68 IS
that loop's header - but the gate only ever asked about a PREP block or the fallback latch, never about
`hb` itself. Adding that lookup took rejections to **ZERO** and MATCH from 107 to **113, above the 112
baseline** (EXTRA 588 -> 553, LOST 175 -> 198).

### Three further refinements, all correct in principle, ALL with ZERO measured effect
1. `for_open` no longer erased on close (a loop belongs in the output ONCE; erasing caught only NESTED
   duplicates, and the measured ones are SEQUENTIAL siblings).
2. Canonical loop identity `block2loop`: prep / header / latch of one loop all map to its HEADER, so
   arriving via different blocks cannot yield two identities.
3. Gate keyed on `block2loop` rather than `prep2latch` - the latter left every proto whose loops were
   found only by DOMINANCE completely UNGATED.
Each is a genuine defect fixed. Each moved the number by exactly 0 (113 / 110 / 70 / 198 / 553 four
times running).

### What that tells us - the real conclusion
AvatarDiorama: 74 loop headers in the CFG, 132 `for` in our source, and ZERO gate rejections. If every
`for` passed through this gate, the map would cap us at 74. It does not. **Therefore a SECOND emission
path is producing `for` headers without consulting the gate at all.** Four consecutive no-op fixes is
the evidence: I have been hardening a path most `for` statements never take.

DO NOT tune this gate further. Find the other path first: instrument EVERY site that appends a `for`
header (there is at least one besides the `isfor` branch - candidates are the while/NaturalLoop arm and
`for_header` being consulted elsewhere), tag each emission with its source line, and count them per
file. Same move that solved the rejection question in one run.

### State (default path, gate OFF - verified after all changes)
back-edge MATCH **112/300**, align ALIGNED **84**, LOOP-DIFF 172, NAME-DIFF **3**, ORDER-DIFF 21,
PROTO-DUP 8. Unchanged from baseline, so nothing regressed. With `RENOVICE_LOOPMAP=1`: MATCH 113.
The #68 header-convention fix is ON by default and is a real correction (map now matches the CFG).

## 2026-07-26 - #70 The "second emission path" hypothesis is FALSE; my accounting was invalid

### Initial Hypothesis
A SECOND emission path produces `for` headers without consulting the loop-map gate - inferred from
AvatarDiorama having 74 loop headers but 132 `for` statements with zero gate rejections.

### Evidence Checked
grep of every `hdr` use in emit.h; tagged each emitted `for` with its resolved loop id, gate state and
map size (RENOVICE_LOOPTRACE), on AvatarDiorama.

### Finding
**False on both counts.**

1. **There is exactly ONE site that appends a for-header** (emit.h ~line 513). No second path exists.
2. Of 132 emitted `for`, **128 went THROUGH the gate with a valid loop id**; only 4 were ungated
   (protos where the map is empty). The gate is not being bypassed.

**My accounting was the thing that was wrong - twice:**
- I counted 132 emissions against 40 "distinct" loop ids and read that as massive duplication. But
  block indices are **PER-PROTO**, so `lid=35` in two different protos is two different loops. The
  cross-proto comparison is meaningless.
- "74 headers vs 132 for" is not like-for-like either: 74 counts loop headers in the ORIGINAL, 132
  counts `for` statements in our SOURCE. The oracle's actual overshoot for this file is **+33 headers**,
  not +58.

So #69's conclusion ("a second path must exist, four no-op fixes prove it") was itself built on a bad
measurement. The four fixes are still individually correct; their zero effect is still unexplained.

### The measurement I should have made
PER-PROTO accounting: for each proto, emissions vs that proto's map size. Only a proto where
`emitted > map size` demonstrates the dedupe failing. Everything so far has aggregated across protos
and is therefore uninterpretable. Add the proto index to the trace annotation and compare within
protos - that is a ~10 minute check and it decides whether `for_open` works at all.

### State (unchanged, verified)
Default (gate OFF): back-edge MATCH **112/300**, ALIGNED 84, LOOP-DIFF 172, NAME-DIFF 3.
With RENOVICE_LOOPMAP=1: MATCH 113. No regression from any change in this session.

## 2026-07-26 - #71 PER-PROTO ACCOUNTING: the dedupe is not firing. 22 of 27 protos emit a loop twice.

### Initial Hypothesis
Per-proto accounting will show whether `for_open` actually suppresses duplicate loop emission.

### Evidence Checked
Tagged every emitted `for` with proto, resolved loop id and map size. NOTE: `decompile-mod` uses
`decompile_proto_anon`, which carries NO proto index - the first two attempts reported `p=-1` for all
132 emissions and were useless. Fixed with a per-Emitter construction counter (one Emitter = one
proto), since block ids are per-proto and collide across them.

### Finding
**Definitive. The loop IDENTITY is right; the SUPPRESSION is broken.**

AvatarDiorama, 27 protos, 132 emissions:
| | |
|---|---|
| protos emitting the SAME loop id more than once | **22 / 27** |
| protos where distinct loop ids exceed the map size | **1** |

So canonicalisation works - distinct ids per proto almost never exceed that proto's loop count. What
fails is that the same id is emitted repeatedly. Two separate causes, both visible in the data:

1. **Ungated protos.** `proto 5: emitted=4 distinct=1 map=0`. A map size of 0 means `block2loop` is
   EMPTY for that proto, so the `!block2loop.empty()` guard skips the gate entirely and the loop is
   emitted 4 times. The guard was meant to avoid over-rejecting; it instead creates an unguarded hole.
2. **`for_open` not firing even when gated.** `proto 6: emitted=2 distinct=1 map=3`. Gate active, one
   loop identity, emitted TWICE. The `for_open` check and insert bracket the header emission, so on
   the second visit the check should hit and take the flat path. It does not. That is the bug to find
   - candidates: an emission path that reaches the header append without passing the check, or
   `loopkey` being recomputed differently on the second visit.

### Why this took four attempts
Every earlier measurement aggregated ACROSS protos, where block indices collide, so "40 distinct lids
for 132 emissions" was meaningless. Three separate metrics in this session have now been wrong in the
same way (non-loading binary, per-proto index comparison, cross-proto lid counting). The rule that
keeps proving itself: **validate the metric before trusting a number derived from it.**

### Next Step
Two concrete fixes, in order: (a) make map=0 protos REJECT rather than run ungated - if the structurer
found no loops in a proto, an emitted `for` there is by definition unjustified; (b) trace the
`for_open` check on proto 6 of AvatarDiorama specifically (2 emissions, 1 id, gate active) to find why
the second visit does not see the first insert.

### State (default, gate OFF - unchanged)
back-edge MATCH 112/300, ALIGNED 84, LOOP-DIFF 172, NAME-DIFF 3. With RENOVICE_LOOPMAP=1: MATCH 113.

## 2026-07-26 - #72 ROOT CAUSE of loop duplication FOUND: mark-after-recurse. EXTRA drops to ZERO.

### Initial Hypothesis
`for_open` fails to suppress duplicate loop emission for an unknown reason.

### Evidence Checked
Traced the suppression check itself (proto, loopkey, whether already present, set size) on
AvatarDiorama with the map gate active.

### Finding
**True, and the cause is a classic ordering bug.** The trace was unambiguous:
```
EMIT p=63 loopkey=43 already=0 open=0
EMIT p=63 loopkey=43 already=0 open=0
EMIT p=63 loopkey=43 already=0 open=0
```
The same loop, three times, `for_open` EMPTY every time - **0 suppressions across 128 emissions**.

Cause: `for_open.insert(loopkey)` sat AFTER the setup emission, and that setup emission RECURSES
(`emit_region` on the head / prep parts). The recursion reaches the same loop again while the set is
still empty, so the guard sees nothing and the loop is emitted again. Mark-AFTER-recurse. Moving the
insert BEFORE the recursion makes the guard effective on re-entry.

Ruled out on the way: `capture()` does NOT create a sub-Emitter (it swaps the output buffer), and the
Emitter count matches the proto count (93), so per-proto state was never being reset.

### Result (RENOVICE_LOOPMAP=1, 300 files)
| | baseline | before #72 | **after #72** |
|---|---|---|---|
| MATCH | 112 | 113 | **125** |
| EXTRA headers | +588 | +550 | **0** |
| LOST headers | -175 | -198 | **-1156** |

**Duplication is COMPLETELY eliminated - EXTRA is exactly zero** - and MATCH is the best yet at 125.
But losses exploded, and the reason follows directly from the fix: marking before recursing lets the
OUTERMOST region claim the loop, so the INNER region that should actually emit the `for` is suppressed
and emits its body flat instead. The loop ends up owned by the wrong region and never wrapped.

### The remaining problem, stated precisely
A loop must be claimed by the region that will actually WRAP it, not by the first region that happens
to encounter it. Options: (a) have the outer region skip a loop whose header is not its own head block
(this is what #60d attempted via a head-only scan - it dropped code and was reverted, but the INTENT
was right); (b) resolve ownership up front - assign each loop to exactly one region in the tree before
emission, which is the "annotate the region tree with the loop map" step the research prescribed and
which has still not actually been done.
(b) is the principled fix and matches every reference decompiler.

### State
Default (gate OFF) verified UNCHANGED. All of #72 is inside the gated path.

### #72 CORRECTION - the DEFAULT path changed too. My "state unchanged" line above is WRONG.
The `for_open.insert` move sits OUTSIDE the `use_map` gate, so it affects the ungated path as well.
Measured immediately after writing that claim:
| default path (gate OFF) | before | after |
|---|---|---|
| MATCH | 112 | **123** |
| files with EXTRA loops | 126 | **16** |
| files with LOST loops | 55 | **152** |
| LATCH-DIFF | 7 | 9 |

So the headline metric improved by 11 and duplication nearly vanished, but the number of files LOSING
loops nearly tripled. A lost loop runs its body once instead of N times - semantically worse than a
duplicated one - so this is NOT unambiguously an improvement, and it must not be presented as one.
`align` and `realtrip` have NOT been re-run against it yet.

Recorded rather than quietly corrected: I wrote "default verified UNCHANGED" in the same command that
measured it changing. The claim was written before the measurement returned.

## 2026-07-26 - #73 mark-before-recurse CONFINED to the gated path (it drops code on the default one)

### Initial Hypothesis
The #72 mark-before-recurse fix (duplication EXTRA 550 -> 0, MATCH 112 -> 123) is a straight win for
the default path.

### Evidence Checked
Full validation of the changed default: `align` 300 and `realtrip` 150.

### Finding
**False.** It improves loop structure but DROPS CODE.
| default path | baseline | with #72 |
|---|---|---|
| ALIGNED | 84 | 93 |
| LOOP-DIFF | 172 | 145 |
| back-edge MATCH | 112 | 123 |
| **NAME-DIFF** | **3** | **15 (WORSE)** |
| realtrip | 149/150 | 149/150 |

NAME-DIFF 3 -> 15 means twelve more files touch a DIFFERENT SET OF NAMED ENTITIES. Losing an entity
access is a semantic change; tidier loop structure never justifies it. This is the SECOND time in this
session a loop improvement was paid for with dropped code (#60d was the first, also reverted) - the
pattern is now unmistakable: **any change that makes an outer region suppress or flatten an inner one
risks losing that inner region's code.**

FIX: the early insert is now `if (use_map && ...)`, and the original late insert is `if (!use_map ...)`.
Default path is byte-for-byte the old behaviour; verified ALIGNED 84, NAME-DIFF 3, LOOP-DIFF 172,
back-edge MATCH 112.

### Where this leaves the loop work
The ROOT CAUSE of duplication is now known and fixed in principle (mark-before-recurse; EXTRA goes to
exactly 0). What is still missing is loop OWNERSHIP: a loop must be claimed by the region that will
actually WRAP it, not by the first region to encounter it. Claiming early fixes duplication but hands
the loop to the outermost region, which then flattens the inner one and loses its code.

That is precisely the step the research prescribed and that has still NOT been done: annotate the
REGION TREE with the loop map - assign each loop to exactly one region BEFORE emission - rather than
resolving ownership opportunistically during the walk. Every reference decompiler (Ghidra, angr,
unluac) does it that way. Until that exists, both orderings are wrong in opposite directions:
| ordering | duplication | code loss |
|---|---|---|
| mark AFTER recurse (default) | +588 headers | none (NAME-DIFF 3) |
| mark BEFORE recurse (gated)  | 0            | 12 files (NAME-DIFF 15) |

### State - verified default
back-edge MATCH 112/300, ALIGNED 84, LOOP-DIFF 172, ORDER-DIFF 21, PROTO-DUP 8, NAME-DIFF 3,
realtrip 149/150. With RENOVICE_LOOPMAP=1: MATCH 125, EXTRA 0, LOST 1156.

## 2026-07-26 - #74 Loop OWNERSHIP by containment: WRONG RULE. Flagged off.

### Initial Hypothesis
Assigning each loop to the innermost region CONTAINING it, before emission, gives the correct owner -
fixing duplication without the code loss that mark-before-recurse causes.

### Evidence Checked
Implemented `assign_loop_owners` (region block sets precomputed, smallest containing region wins),
gated emission on `loop_owner[loop] == this region`, measured both containment rules.

### Finding
**False. Containment does not identify the region that will actually WRAP the loop.**
| ownership rule | MATCH /300 | LOST headers |
|---|---|---|
| none (mark-before-recurse only) | **125** | 1156 |
| innermost containing header + latch | 81 | 2207 |
| innermost containing the WHOLE body | 87 | 1882 |
| (default, mark-after-recurse) | 112 | 175 |

Requiring only header+latch picks a region too DEEP - often a Basic region that is just the header
block, which cannot wrap anything, so no region emits the loop at all. Requiring the whole body helps
slightly (81 -> 87) but is still far below doing nothing. EXTRA stays at 0 in every variant, so
duplication really is solved by mark-before-recurse; the problem is purely that the loop then gets
claimed by a region that will not emit a wrapper.

The missing ingredient is that ownership is a property of the REGION TREE's shape (which region the
structurer built AS the loop), not of block containment. Several regions contain a loop's blocks;
only one of them is the loop region. The structurer knows which - `sa::RK::While` / `NaturalLoop` /
`SelfLoop` - and that is what should be consulted, not set inclusion. That is the piece to build next:
match each `st::Loop` to the region whose KIND is a loop AND whose head block is that loop's header.

### Decision
`RENOVICE_LOOPOWNER=1` gates ownership (off by default). Verified after flagging:
- gated path (`RENOVICE_LOOPMAP=1`): MATCH **125**, EXTRA **0**
- DEFAULT: MATCH **112**, ALIGNED **84**, LOOP-DIFF 172, NAME-DIFF **3** - baseline intact, no code lost

### Session end state
Default is exactly the baseline on every oracle. Two experimental paths exist, both measured and
flagged: `RENOVICE_LOOPMAP=1` (MATCH 125, zero duplication, but NAME-DIFF 15 - drops code) and
`RENOVICE_LOOPOWNER=1` (worse, 87). Nothing is enabled that regresses any metric.

## 2026-07-27 - #75 FORK RESOLVED BY MEASUREMENT: the bug is the EMITTER. Structurer is 98.1% correct.

### Initial Hypothesis
The loop bug is in the EMITTER's second detector, not the structurer - but this had NEVER been
measured. The multi-agent workflow's designated fork agent CRASHED on infrastructure (worktree
isolation needs a git repo; this project is not one), and the decision synthesizer restated the
existing #64 hypothesis as if freshly proven. So the fork was still open.

### Evidence Checked
New `derecomp loopfork` command: per proto, compare the number of loop-KIND regions the structurer
classifies (sa::RK::SelfLoop / While / NaturalLoop, each created exactly once so the count is
unambiguous) against the number of distinct back-edge HEADERS in the CFG. Ran over 400 files /
18,621 protos.

### Finding
**True - the bug is in the EMITTER, proven, not asserted.**
```
CLEAN  (loopregs == headers): 18273 / 18621  = 98.1%
MORE   (structurer over-classifies):     8   =  0.0%
FEWER  (structurer under-classifies):  340   =  1.8%
```
The structurer produces exactly one loop-kind region per real loop header 98.1% of the time. So the
+588 duplicated loop headers the emitter produces are NOT the structurer creating duplicate regions -
it creates the right number. The emitter's independent opcode scan invents them. This is the fork,
measured directly, and it does not rest on the failed agent or on restating #64.

### Consequence: the region-kind ownership fix is now GROUNDED, not guessed
Because one loop-kind region exists per header 98% of the time, an ownership rule that assigns each
loop to "the loop-KIND region whose head block is this loop's header" has a UNIQUE target 98% of the
time. The earlier ownership attempts (#74) failed because they used CONTAINMENT (smallest region
containing the body) - many regions contain a loop's blocks, so that never identified the wrapper.
Region KIND + header match is the correct key, and the 98.1% is the evidence it will work.
Implementation caveat: Region::head is a region id renumbered through reduction, so mapping it back to
a header BLOCK needs care (resolve to the head region's block). The 1.8% FEWER cases (a loop absorbed
into a Proper region) have no loop-kind region and need the containment fallback - a small minority.

### Note on the workflow
6 agents, 555k tokens. The fork agent failed (worktree/git), but the HARMLESSNESS and SHIP agents ran
and their adversaries caught real errors: the duplicate loops are CLASS-A (empty/harmless, high conf,
with a pcall caveat), and the Mallet mod is NOT blocked by the loop defect (it was built via a
different pipeline than M6). The ship agent's DEPLOY-STATUS claim was REFUTED (it checked the Steam
CustomScripts dir, not the live OneDrive one).

### Next Step
Implement region-kind ownership in emit.h assign_loop_owners: owner = the loop-kind region whose head
resolves to the loop's header block; containment fallback only for the 1.8%. Then enable the map path
by default and re-run backedge + align + realtrip. This is now a grounded change, not a guess.

## 2026-07-27 - #76 Region-kind ownership fails for a STRUCTURAL reason, now proven

### Initial Hypothesis
Region-kind ownership (owner = loop-kind region whose head IS the loop header), grounded by the 98.1%
fork, will eliminate duplication without dropping code.

### Evidence Checked
Rewrote `assign_loop_owners` to key on region KIND + head_block match (containment fallback for the
1.8%). Gated (RENOVICE_LOOPMAP=1 RENOVICE_LOOPOWNER=1), measured backedge over 300 files.

### Finding
**False - and it exposes the real structural obstacle.**
| | EXTRA | LOST | MATCH |
|---|---|---|---|
| region-kind ownership | **0** | **1904** | 86 |
Duplication is GONE (EXTRA 0), but losses are catastrophic. Cause, now proven empirically:

**A numeric for-loop emits its `for` header from the IfThen PREP region, NOT from the loop-kind
region.** FORNPREP is conditional, so the structurer wraps the loop in an `IfThen` (the zero-iteration
guard), and the actual back-edge loop is an inner `While`/`NaturalLoop`. The for-HEADER text
(limit/step/index) lives on the FORNPREP block, which heads the IfThen - the loop-kind region heads at
the BODY. So assigning ownership to the loop-kind region suppresses the IfThen prep region, which is
the exact place that writes the `for`, and the loop is lost.

### The real fix, now precisely specified
The FORNPREP-`IfThen` guard and its inner loop-kind region must COLLAPSE into ONE `for` emission:
header from the prep, body from the loop-kind region, and the zero-iteration `if` guard is IMPLICIT in
`for` semantics so it is NOT emitted separately. This is a focused restructure of the loop case in
`emit_region` - detect "IfThen whose head ends in FORNPREP wrapping a loop-kind region" and emit it as
a single for - not an ownership tweak. The 98.1% fork guarantees the loop-kind region exists to pair
with; #66 gives the exact register/header shape; #68 gives the generic-for header.

### Decision
All three experimental flags (RENOVICE_LOOPMAP / LOOPOWNER) remain OFF. Default verified UNCHANGED:
back-edge MATCH 112, ALIGNED 84, NAME-DIFF 3, LOOP-DIFF 172, realtrip 149/150. The region-kind owner
map is kept (it is correct - it just can't be applied as a naive suppression gate).

### Why I am pausing before the restructure
Six grounded attempts have each died on this same for/prep-vs-loop-kind mismatch. The mismatch is now
fully understood, so the restructure is finally specifiable - but it is a real change to how the loop
case walks the region tree, and a botched version drops code (the exact thing the user forbade). It
must be done as ONE designed change with a HARD no-code-loss gate (NAME-DIFF must stay 3), not another
incremental hack.

### Next Step
Implement the FORNPREP-IfThen + loop-kind COLLAPSE in emit_region, gated, with NAME-DIFF==3 as a
release gate. If it drops any code, it does not ship.

## 2026-07-27 - #77 DECISIVE: the DEFAULT decompiler is ACCESS-FAITHFUL. LOOPMAP drops real code.

### Initial Hypothesis
LOOPMAP's NAME-DIFF 18 (vs default 3) is a benign import-COUNT artifact from loop structure, not real
code loss - so LOOPMAP (MATCH 125, EXTRA 0) might be safe to ship, and my earlier revert was a misread.

### Evidence Checked
Per file: original named-access count (GETIMPORT+NAMECALL+GETFIELD in skeleton --live) vs the count in
our RECOMPILE under default vs LOOPMAP. Also realtrip 150 under LOOPMAP.

### Finding
**FALSE - LOOPMAP genuinely drops accesses. The default is the faithful one.**
| file | ORIGINAL | DEFAULT recompile | LOOPMAP recompile |
|---|---|---|---|
| LotusBackground (mMovie only) | 49 | **49 (faithful)** | 41 (loses 8) |
| ScriptCommands_JSON | 176 | **176 (faithful)** | 170 (loses 6) |
| BeaconInProgress | 525 | **525 (faithful)** | 521 (loses 4) |
Loop headers on LotusBackground: original 4, default 5 (one EXTRA), LOOPMAP 3 (one LOST). LOOPMAP
drops a real loop and the 8 accesses in its body.

**realtrip was a FALSE NEGATIVE.** It reported 149/150 under LOOPMAP, identical to default, which I
briefly took as "behaviour preserved." It is not - the dropped loop is an initialisation/setup loop
whose absence the mocked-engine trace does not exercise, and realtrip wraps bodies in pcall (the exact
caveat the workflow's adversary raised). **An access-count check against the original caught what the
behavioural oracle missed.** This is the same lesson as the whole session: only comparison to the
ORIGINAL finds a consistent loss; a self-referential trace can't.

### The reframe that matters for the user's "100% offline, no dropped code" goal
The DEFAULT decompiler PRESERVES 100% OF NAMED ACCESSES - every GETIMPORT/NAMECALL/GETFIELD in the
original appears in our recompile (NAME-DIFF 3 corpus-wide is near-perfect, and the access COUNTS match
exactly on every file tested). Its only flaw is +588 DUPLICATE loop wrappers, which are CLASS-A
(empty/harmless: the redundant wrapper adds a loop header but ZERO accesses, which is exactly why
NAME-DIFF stays 3). So:
- Default: access-faithful, +588 cosmetic empty loop wrappers.
- Every duplication fix so far (LOOPMAP, ownership): removes wrappers but DROPS real accesses.

The correct fix must suppress ONLY the empty duplicate wrapper while keeping every access - i.e. drop
the redundant `for...do end` syntax without flattening away the real body. No attempt has achieved this;
they all flatten the wrong region and lose the body.

### Decision
All experimental flags stay OFF; they do not ship - proven to drop code. Default is the correct
shipping state and is access-faithful. Verified: back-edge MATCH 112, ALIGNED 84, NAME-DIFF 3,
realtrip 149/150.

### Next Step
Either crack the surgical "suppress empty wrapper only" fix (hard, gated on access-count == original),
or accept the harmless duplication and verify the FLAGSHIP script specifically for the actual goal.
The default being access-faithful means the decompiler is FUNCTIONALLY correct today; loop duplication
is cosmetic.

## 2026-07-27 - #78 The 3 default NAME-DIFF bugs are BROKEN VALUE CHAINS across mis-placed block boundaries

### Finding
The default path is access-faithful on ~99% of files; the 3 NAME-DIFF files are NOT loop issues
(InfestationCyst: loops 2=2, fork CLEAN 7/7). They are subtle STRUCTURING bugs where a value chain is
severed by a block boundary placed at the wrong instruction.

InfestationCyst loses 1 each of {IsNull, GetLoadOut, GetWeaponInfo, mInfestationDate} in ONE nested
proto. Our emitted source at that site:
```
      c5v3 = c5v3:GetLoadOut()
      c5v4 = c5v3:GetWeaponInfo(c5v6, c5v7)   -- result -> c5v4
    c5v3 = c5v2.mInfestationDate              -- reads c5v2 (wrong reg), DEDENTED (block boundary)
```
vs a correct chain elsewhere in the same file:
```
      c3v4 = c3v3:GetLoadOut()
      c3v4 = c3v4:GetWeaponInfo(...)
      c3v4 = c3v4.mInfestationDate            -- clean chain on one register
```
The GetWeaponInfo result is discarded and mInfestationDate reads a different register, because a
region boundary split the chain. This is a control-flow-structuring edge case (a chain that spans what
the structurer treated as two blocks), NOT a loop or opcode bug. Deep decompiler territory.

### Consolidated state of the decompiler (the honest picture)
- ACCESS FIDELITY: ~99% - every named access preserved on all but 3/300 files. The default is the
  faithful, shipping-quality path.
- LOOP STRUCTURE: +588 duplicate wrappers (CLASS-A harmless; NAME-DIFF unaffected). Every dedup attempt
  regresses accesses (#77). Cosmetic.
- 3 NAME-DIFF: broken value chains across block boundaries (#78). Real but deep.
- 1 realtrip: TauDroneEffects block-order.
Getting to literal 100% corpus-wide means solving each deep structuring edge case - a substantial
undertaking. The decompiler is FUNCTIONALLY CORRECT and access-faithful today.

## 2026-07-27 - #79 SCOPE CORRECTION: the target is 1:1 translation, so the honest metric is ALIGNED 84/300

### The correction
I proposed scoping validation to the flagship (BardMusic/Mallet). That is WRONG for what this tool is.
This is a general-purpose LANGUAGE TRANSLATOR: any of the 5386 corpus scripts may be decompiled,
edited and recompiled, and ONE wrong instruction anywhere makes that script unusable in-game.
Validating one file proves nothing about the tool. Partial fidelity has no value here.

**So the honest completion metric is ALIGNED 84/300 = 28%, not the ~99% access-fidelity figure I had
been quoting.** Access fidelity flattered the result by measuring only whether named accesses survive,
not whether the translation is structurally faithful.

### A claim of mine I am retracting
I labelled the +588 duplicate loop wrappers "CLASS-A harmless" because NAME-DIFF stayed at 3 (the
duplicates add no named accesses). That reasoning does not establish harmlessness. An EMPTY
`for k,v in pairs(t) do end` still runs the ITERATION PROTOCOL — it calls the iterator, advances the
control variable, and burns frames; an empty `for i=1,n do end` still runs n iterations. Access-count
parity cannot see any of that. Whether the duplicates are real 1:1 breaks depends on something I never
tested: **does luau-compile's dead-code elimination remove the empty duplicate loop from the FINAL
bytecode?** If it survives compilation, every one of the 588 is a genuine behavioural difference.
That question is now under test rather than assumed.

### The campaign
12 agents: 6 defect classes attacked in ISOLATED COPIES of the project (worktree isolation is
unavailable — not a git repo), each with a dedicated adversary. Classes: loop duplication (172 files),
lost loops (55), ORDER-DIFF (21), NAME-DIFF (3), PROTO-DUP (8), and the iteration-semantics study.

RELEASE GATE applied to every proposed fix — all four required, no exceptions:
  1. ZERO ACCESS LOSS: GETIMPORT+NAMECALL+GETFIELD count in the recompile == the original, per file.
     (This is the check that caught what realtrip missed via its pcall wrapper.)
  2. NAME-DIFF must not exceed 3 on align.py 300.
  3. realtrip 150 must not fall below 149.
  4. ALIGNED must improve.
A fix that dedups loops while silently dropping accesses is the specific disaster to prevent, and an
honestly-measured negative result is worth more than a green metric bought with lost code.

## 2026-07-27 - #80 FIXED: NaturalLoop dropped every `break`. realtrip 150/150, NAME-DIFF 0.

### Initial Hypothesis
The 1:1 campaign's "shippable" result (derecomp_new.exe, claimed to pass all four gates) can be merged.

### Evidence Checked
Main-tree integrity check; independent baseline re-measure; search for the claimed binary; direct
inspection of the described change site in emit.h; then implement + full four-gate run.

### Finding
**The campaign's headline result was NOT verifiable - but the underlying defect it described was REAL,
and fixing it myself produced the best result of the entire project.**

Two campaign claims collapsed under checking:
- **Attack 1 was FABRICATED**: the claimed binary `derecomp_final2.exe` exists nowhere, and the symbol
  `owned_by_nested_loop_kind` is in no source file. The adversarial layer caught it.
- **The "shippable" binary `derecomp_new.exe` DOES NOT EXIST on disk** (searched all of Temp), and the
  synthesis measured baseline realtrip as 148/150 when it is verifiably **149/150**. Its claimed win
  was "+1 realtrip 148->149" - i.e. the entire improvement was an artefact of a wrong baseline.
- Main tree was NOT modified by any agent (timestamps + no g_hoist_protos) - isolation held.

### THE REAL FIX (implemented and verified here, not merged from an agent)
`emit.h`, BOTH NaturalLoop arms emitted `while true do` WITHOUT tracking `loop_depth`. Since
`emit_block` only emits a `break` when `loop_depth > 0`, every loop-exiting branch inside a NaturalLoop
was **SILENTLY DROPPED**. The While and SelfLoop arms already incremented it; NaturalLoop was the only
wrapper that did not. A dropped `break` is an infinite loop - and it also destroys the statements the
exit guarded, which is why it showed up as MISSING ACCESSES.

```cpp
out += ind(depth) + "while true do\n";
++loop_depth;                                    // <-- added, both arms
for (int p : r.parts) emit_region(p, depth + 1);
--loop_depth;
out += ind(depth) + "end\n";
```

### RESULTS - all four gates PASS, best state the project has reached
| metric | before | after |
|---|---|---|
| **realtrip 150** | 149 SAME | **150 SAME (PERFECT)** |
| **NAME-DIFF** | 3 | **0** |
| ALIGNED | 84 | 85 |
| ORDER-DIFF | 21 | 23 (+2) |
| LOOP-DIFF | 172 | 172 |
| PROTO-DUP | 8 | 8 |

Gate 1 (access count == original) verified per file on every previously-failing case:
InfestationCyst 127=127 (was 123), LotusBackground 190=190, JSON 176=176, BeaconInProgress 525=525,
TauDroneEffects 48=48. **ALL PASS.**

**The two oracles that measure SEMANTICS are now clean: zero dropped accesses corpus-wide, and 150/150
behavioural equivalence.** The single realtrip failure that survived this entire project
(TauDroneEffects) is fixed, and it was the same root cause as the dropped accesses.

### Remaining gap to 300/300 ALIGNED
ALIGNED 85/300. Residual: LOOP-DIFF 172 (duplicate/lost loop wrappers), ORDER-DIFF 23, PROTO-DUP 8,
ALIGNED-minus-orphans 12. These are STRUCTURAL differences; the SEMANTIC oracles are now clean.

### #80b ORDER-DIFF 21 -> 23 is NOT a regression - the accounting is exact
Checked whether the loop_depth fix regressed ORDER-DIFF. It did not; the categories rebalanced:
  NAME-DIFF   3 -> 0   (-3)
  ORDER-DIFF 21 -> 23  (+2)
  ALIGNED    84 -> 85  (+1)
The three files that left NAME-DIFF are exactly accounted for: TWO moved to ORDER-DIFF and ONE became
fully ALIGNED. InfestationCyst is now ORDER-DIFF, having previously been NAME-DIFF. So those files
went from DROPPING ACCESSES (fatal for 1:1) to merely having effect ORDER differ (still a 1:1 break,
but strictly less severe and semantically much closer). No file regressed.

This is worth stating precisely because "a number went up" reads as a regression at a glance, and on
this project that misreading has repeatedly caused a good change to be reverted.

## 2026-07-27 - #81 FIXED: IfThenElse arm-swap reversed block order. ALIGNED 85 -> 91.

### Initial Hypothesis (from the diagnosis-only campaign, adversary refuted=False)
The IfThenElse emitter reorders its two arms so the `then` branch is whichever a POSITIVE test selects.
That is behaviour-preserving but emits the arms in the opposite order to the original bytecode, making
it the dominant cause of ORDER-DIFF.

### Evidence Checked
Read the swap site (emit.h ~687) and `cond_of` to establish `negate` semantics EXACTLY rather than
assume them: `cond_of(blk,false)` is true when the branch is TAKEN (-> succ_true); `negate=true`
selects succ_false. The SINGLE-ARM path already used precisely that rule
(`negate = (tb == succ_false && tb != succ_true)`), so the two-arm path was the inconsistent one.

### Finding
**True.** The old code swapped arms whenever `head_block(arms[1]) == want`, purely so the emitted test
could be positive. Only one arm ever executes, so this was semantically safe but STRUCTURALLY
unfaithful — and 1:1 fidelity is the requirement, so readability must not reorder emitted blocks.

FIX: emit the arms in ORIGINAL BLOCK ORDER (lower head block first) and let `negate` carry the
polarity, using the same rule the single-arm case already used.

### RESULTS - all four gates PASS
| metric | before | after |
|---|---|---|
| **ALIGNED** | 85 | **91** |
| **ORDER-DIFF** | 23 | **17** |
| NAME-DIFF | 0 | **0** |
| realtrip 150 | 150 SAME | **150 SAME** |
| LOOP-DIFF | 172 | 172 |
| PROTO-DUP | 8 | 8 |
Gate 1 (access count == original) verified per file: InfestationCyst 127=127, Grid 672=672,
AllianceView 987=987, Boardgame 194=194, JSON 176=176, BeaconInProgress 525=525. ALL PASS.

### Cumulative this session
ALIGNED 84 -> 91, NAME-DIFF 3 -> 0, realtrip 149 -> 150/150, back-edge MATCH 112 -> 113.
Two fixes, both diagnosed by agents and IMPLEMENTED + GATED here.

### On method - what is now proven to work
The diagnosis-only mandate produced 4 diagnoses, ALL of which survived adversarial review
(refuted=False), versus the previous fix-reporting campaign where one agent FABRICATED a binary and
metrics, another lost its source, and a third reported a win that was an artefact of a wrong baseline.
**Agents diagnose; the orchestrator implements and gates.** Adversaries still caught real errors in
the surviving diagnoses (wrong worked examples for the Proper-region claim, wrong proto numbers for
EXTRA-LOOPS, a stale content hash for PROTO-DUP) - so the mechanism can be right while the cited
evidence is partly wrong, and each patch must still be verified at its own site before applying.

### Next Step
Three diagnosed defects remain unimplemented, all adversary-confirmed:
(1) LOST-LOOPS: RK::Proper emitter calls collect_blocks() which flattens loop SUB-REGIONS to bare
    basic blocks, so their for/while wrappers are never emitted (~102/168 lost headers). Fix: promote
    non-Basic direct parts to emit_region instead of flattening. NOTE the adversary flagged that the
    two worked examples cited are a DIFFERENT mechanism - verify at the site.
(2) EXTRA-LOOPS: two greedy FORGPREP detections in emit_region.
(3) PROTO-DUP: duplicate function literal per extra closure site referencing the same proto.

## 2026-07-27 - #82 LOST-LOOPS diagnosis is WRONG ABOUT MAGNITUDE. Fix NOT implemented.

### Initial Hypothesis (agent diagnosis, adversary refuted=False, confidence high)
The RK::Proper emitter flattens loop SUB-REGIONS to bare blocks via collect_blocks, so their for/while
wrappers are never emitted — claimed to account for ~102/168 lost loop headers (60.7%).

### Evidence Checked
Rather than implement the proposed patch (a state-machine rewrite with compound-part promotion,
interior-block skipping and successor remapping), first MEASURED whether the shape it targets exists.
Extended `derecomp loopfork` to count, across 300 files / 13,353 protos, Proper regions and how many
DIRECTLY contain a compound part and specifically a LOOP-KIND part.

### Finding
**The mechanism is real but NEGLIGIBLE in scale — the magnitude claim is false.**
```
Proper regions total                    : 1204
  with a COMPOUND direct part           :  954
  with a LOOP-KIND direct part          :   11   <-- the only ones that can lose a loop wrapper
```
Only **11 of 1204** Proper regions can suffer the described flattening. That cannot plausibly account
for 102 lost headers; at most it explains a handful. The adversary had already flagged that the two
worked examples (BootUpGlitch, SetVortexWindPerZone) exhibit a DIFFERENT mechanism — this shows the
magnitude estimate was wrong as well, even though the causal mechanism itself is genuine.

### Decision: DO NOT IMPLEMENT
The proposed patch rewrites the Proper linearisation for ALL 1204 Proper regions (954 of which have
compound parts) in order to fix at most 11. That is a large blast radius on the region kind that is
already the most fragile part of the emitter, for a tiny return, and every previous change of this
shape DROPPED CODE. Refused on cost/benefit, not on difficulty.

**The measurement cost ~2 minutes and avoided a risky rewrite of the emitter's most delicate path.**
Verifying the SCALE of a diagnosis before implementing it is now part of the loop, alongside verifying
the mechanism at its own site.

### What this implies for LOST-LOOPS (53 files, 168 headers) - still OPEN
The dominant cause is NOT Proper-region flattening. Remaining candidates, unmeasured:
- the ~1.8% of protos where the structurer under-classifies (loopfork FEWER) — a STRUCTURER fix;
- loops whose prep block never becomes a region head, so for_header never sees them;
- loop-kind regions nested inside non-Proper compound regions that the emitter mis-walks.
Next actor should MEASURE the split across these before writing any code.

## 2026-07-27 - #83 LOST-LOOPS split MEASURED; loop-first reorder TRIED and REVERTED

### The split (this corrects the agent diagnosis)
Per file, lost loop headers vs `loopfork FEWER`, over 300 files:
| cause | files | headers |
|---|---|---|
| **STRUCTURER under-classifies (FEWER>0)** | 29 | **119 (71%)** |
| EMITTER-only (FEWER=0) | 24 | 49 (29%) |
The agent diagnosis attributed the majority to the EMITTER (Proper-region flattening). The measurement
says the opposite: **71% of lost headers correlate with the STRUCTURER failing to classify the loop at
all**, which no emitter change can fix. Worst emitter-only: Dojo_InWorldTransmissionController (-8),
ThemedCustomizationButton (-6), ImGuiEntityViewer (-3).

### Hypothesis tried: rule ORDER in sa::Analyzer::step()
`RK::Proper` was tried BEFORE the NaturalLoop rule, despite Proper being the last-resort "matches no
template" fallback. Every reference decompiler (Ghidra, angr/Phoenix, Cifuentes) structures CYCLIC
regions before falling back to irreducible handling, so running Proper first can collapse part of a
loop body and leave a shape from which no loop-kind region can form. Moved NaturalLoop ahead of Proper.

### Finding: FALSE — measurably worse. REVERTED.
| metric | before | after reorder |
|---|---|---|
| back-edge MATCH | 113 | **111** |
| LOST-LOOPS files | 53 | **54** |
| EXTRA-LOOPS files | 127 | **129** |
| LOOP-DIFF | 172 | **173** |
| ALIGNED | 91 | 91 (unchanged) |
| ORDER-DIFF | 17 | 16 |
Fails the gate (ALIGNED must IMPROVE; it did not, and three loop metrics regressed). Reverted from
backup and the full baseline was re-verified: ALIGNED 91, ORDER-DIFF 17, MATCH 113, LOST 53.

**Why it likely failed:** the NaturalLoop rule's own comment states it "can only be collapsed once its
INTERIOR has been reduced". Running it earlier collapses loops whose bodies are still unreduced, so the
body becomes an unstructured part-set rather than a nested region tree. The literature's "loops before
conditionals" ordering assumes a loop-forest computed up front (Ghidra's orderLoopBodies), NOT simply
reordering rules inside a bottom-up reducer. Applying the principle without its precondition is what
broke it.

### Do not retry
Plain rule reordering in step(). If loop-first is pursued, it must be done the way the literature
actually does it: compute the loop forest FIRST (find_loops already exists and is 98.1% accurate) and
use it to DRIVE reduction, rather than hoping a reordered greedy rule discovers the same thing.

### State: unchanged at session best
ALIGNED 91 | ORDER-DIFF 17 | NAME-DIFF 0 | LOOP-DIFF 172 | PROTO-DUP 8 | MATCH 113 | realtrip 150/150

## 2026-07-27 - #84 EXTRA-LOOPS Part A+B: REJECTED. Seventh dedup attempt, seventh code loss.

### Initial Hypothesis (agent diagnosis, adversary refuted=False)
Duplicate loops persist because (A) the `for_open` insert happens AFTER the setup recursion, and (B)
when the guard DOES fire, the flat-emit path also emits the loop BODY blocks, so body code lands both
before the owner's header and inside it. Doing A unconditionally plus skipping body parts in B was
predicted to remove duplication WITHOUT the code loss that A alone caused.

### Finding
**FALSE. Worse than A alone, and it introduced a new severe failure mode.**
| metric | baseline | Part A+B |
|---|---|---|
| LOOP-DIFF | 172 | 144 |
| ALIGNED | 91 | 93 |
| **NAME-DIFF** | **0** | **20** |
| **PROTO-LOST** | **0** | **5 (NEW)** |
| ALIGNED-minus-orphans | 12 | 10 |
PROTO-LOST is entire FUNCTIONS disappearing from the output — strictly worse than the access-level
loss Part A alone produced. Reverted; baseline re-verified at ALIGNED 91 / ORDER-DIFF 17 / NAME-DIFF 0.

### The pattern is now unambiguous - SEVEN attempts, SEVEN losses
Every attempt to suppress a duplicate loop has cost real code:
| # | approach | result |
|---|---|---|
| #60d | head-only prep scan | NAME-DIFF 3 -> 6 |
| #67 | LOOPMAP gate | LOST headers 175 -> 678 |
| #72 | mark-before-recurse | NAME-DIFF 3 -> 15 |
| #74 | ownership by containment | MATCH 112 -> 87 |
| #76 | ownership by region kind | LOST 175 -> 1904 |
| #83 | loop-first rule reorder | MATCH 113 -> 111 |
| #84 | Part A+B (guard + body skip) | NAME-DIFF 0 -> 20, PROTO-LOST 5 |

The invariant behind all seven: **whenever an outer region is prevented from emitting a loop, the code
it would have emitted is lost — because suppression removes the only emission site, not just the
duplicate wrapper.** Duplication and coverage are coupled in the current design; you cannot remove one
without a mechanism that guarantees the other is emitted exactly once elsewhere.

### What would actually be required
Not another guard. The emitter needs a single up-front decision — for each block, WHICH region emits it
— computed before any output, so suppression can never orphan code. That is the "annotate the region
tree" step from the literature, and it is a redesign of emit_region's contract, not a patch.

### DO NOT retry any further variant of "detect the duplicate and suppress it"
Seven measured failures. The next person should either redesign emission ownership properly, or accept
the duplicate wrappers (which are behaviourally benign per realtrip 150/150 and NAME-DIFF 0) and spend
effort on ORDER-DIFF / PROTO-DUP instead.

### State: unchanged at session best
ALIGNED 91 | ORDER-DIFF 17 | NAME-DIFF 0 | LOOP-DIFF 172 | PROTO-DUP 8 | MATCH 113 | realtrip 150/150

## 2026-07-27 - #85 RETRACTION: the duplicate loops are NOT benign. They NEST -> body runs N^2 times.

### What I claimed, and why it was wrong
I repeatedly described the +588 duplicate loop headers as "CLASS-A harmless" / "behaviourally benign
/ cosmetic", on the grounds that NAME-DIFF stayed 0 and realtrip stayed 150/150. Both are inadequate
evidence: NAME-DIFF counts named ACCESSES (a duplicate wrapper adds none) and realtrip runs a MOCKED
engine whose iterators return nil almost immediately, so a loop that should run N times runs 0 or 1
times and N^2 == N. The oracles could not see this defect BY CONSTRUCTION.

### The measurement that settles it (EE_Types_ScriptCommands_JSON, emitted source)
```
1105: depth=2  for c17v10, c17v11 in c17v7, c17v8, c17v9 do
1111: depth=3  for c17v10        in c17v7, c17v8, c17v9 do
```
The SAME iterator triple (c17v7, c17v8, c17v9), one loop NESTED INSIDE THE OTHER. The body therefore
executes **N^2 times instead of N**. That is a severe behavioural defect, not a structural blemish.
Note the variable counts differ (2 vs 1): the outer header came from the FORGPREP prep path (which
assumes nvars=2) and the inner from the FORGLOOP latch path (which reads the real nvars from aux) —
the double-header mechanism, here producing NESTING rather than sequence.
Also present in the same file: three identical headers at the SAME depth (1351/1384/1460), i.e.
SEQUENTIAL duplicates. Both shapes occur.

### Consequence for the project's status
The decompiler is **NOT** a 1:1 translator and must not be described as one. ALIGNED is 91/300 = 30%,
and the loop duplication is a genuine correctness bug that would make a decompiled-and-recompiled
script behave differently in game (quadratic iteration in a per-frame ability script is catastrophic).
Every prior statement in this file calling the duplication cosmetic or harmless is RETRACTED.

### Consequence for method
Two oracles agreed the output was fine while a quadratic-iteration bug sat in it. Oracle agreement is
not proof of correctness when both oracles are blind to the defect class:
- NAME-DIFF cannot see a wrapper that contains no named access.
- realtrip cannot see iteration COUNT under a mock that yields nothing.
A defect class needs an oracle chosen to be SENSITIVE to it. For loop structure that oracle is the
back-edge bijection (cert/backedge.py), which correctly reported +588 all along — and which I talked
myself out of believing because the other two looked clean.

### Therefore
Loop duplication is now the TOP-PRIORITY correctness defect, not deferred polish. Seven patch attempts
have failed (#84), so the emission-ownership redesign is REQUIRED, not optional.

## 2026-07-27 - #86 OWNERSHIP EMISSION (RENOVICE_OWNEMIT): duplication solved, coverage collapses. 8th data point.

### Design
Precompute, per loop, the ONE region allowed to emit its wrapper; every other region falls through to
its NORMAL path (no forced flat emission, which is where #74/#76 went wrong). An owner is only valid
if it can ACTUALLY EMIT THE HEADER — its head block must be the loop's PREP block (numeric for, whose
header text lives on FORNPREP) or the loop's HEADER block (generic for) — AND it must span the whole
body so the body lands inside the wrapper. Gated behind RENOVICE_OWNEMIT=1.

### Result (300 files)
| metric | default | OWNEMIT=1 |
|---|---|---|
| **EXTRA-LOOPS files** | 127 | **11** |
| **LOST-LOOPS files** | 53 | **203** |
| ALIGNED | 91 | 74 |
| NAME-DIFF | 0 | 10 |
| back-edge MATCH | 113 | 85 |
Default path verified UNCHANGED at ALIGNED 91 — the flag isolates cleanly.

### What this proves (the useful part)
**Ownership genuinely solves duplication: EXTRA 127 -> 11.** That is the strongest evidence yet that
the diagnosis is right. But coverage collapses because the designated owner OFTEN NEVER EMITS: the
non-owner is correctly suppressed, and then the region we predicted would wrap the loop is either
never reached on the walk, or reaches a path that does not emit a header.

### The real lesson - why 8 attempts have failed
Every attempt so far has tried to PREDICT STATICALLY, from the region tree, which region will emit a
given loop. That prediction is unreliable because **which region emits a loop is decided by the WALK,
not by tree containment or region kind**. Static owner selection and actual emission disagree, so
suppressing the "non-owner" silently deletes the only site that would have emitted.

### Therefore the correct design is DYNAMIC, not predictive
Stop choosing an owner in advance. Make the emission itself structurally incapable of duplicating:
stream the blocks in their emission order and OPEN a loop wrapper when the first block of a loop body
is about to be emitted, CLOSE it after the last block of that body, keyed on the loop HEADER so each
loop can open exactly once. Then a loop cannot be emitted twice (the key is already open) and cannot be
lost (opening is driven by a block that is definitely being emitted). Duplication and coverage stop
being coupled, which is the property all eight attempts lacked.
This is a rewrite of how emit_region produces output, not another guard.

### State
Code retained behind RENOVICE_OWNEMIT=1 (off). Default verified: ALIGNED 91 | ORDER-DIFF 17 |
NAME-DIFF 0 | LOOP-DIFF 172 | PROTO-DUP 8 | MATCH 113 | realtrip 150/150.

## 2026-07-27 - #87 PASS 1 (mark-before-recurse on the NEW baseline): ALIGNED 91 -> 99, but 12 files lose code

### Why re-test something already rejected
#72 measured mark-before-recurse on the OLD baseline (NAME-DIFF 3 -> 15). Since then two fixes landed
(NaturalLoop loop_depth #80, IfThenElse arm order #81) which changed break emission and block order
substantially, so the old verdict no longer necessarily applied. Re-testing was cheap and correct.

### Result (300 files)
| metric | default | PASS 1 |
|---|---|---|
| **ALIGNED** | 91 | **99 (+8, best seen)** |
| LOOP-DIFF | 172 | **145** |
| **NAME-DIFF** | **0** | **12** |
| ORDER-DIFF | 17 | 24 |
Fails Gate 2. NOT shipped; reverted and default re-verified at ALIGNED 91 / NAME-DIFF 0.

### The loss is ONE reproducible shape - localised for the first time
All 12 NAME-DIFF files are the `Backgrounds_*` template family, each losing the identical set
(`MISSING GETIMPORT mMovie x8; MISSING GETFIELD Texture x2`). Diffing default vs PASS 1 output on
LotusBackground shows what actually disappears:
```
< for c1v9, c1v10 in c1v6, c1v7, c1v8 do
<   c1v6 = mMovie ; c1v6 = c1v6:GetViewportWidth()
<   c1v7 = mMovie ; c1v7 = c1v7:GetViewportHeight()
<   ... CalculateForegroundScale ... SetNumberVariable ...
```
**An entire generic-for AND its whole body vanish.** The guard fires (the loop is already marked open
by an enclosing region), the enclosing region does not emit that body, and the inner region's
flat-emit path does not produce it either — so no one emits it. This is the duplication/coverage
coupling again, but for the first time reduced to a SINGLE reproducible shape rather than a diffuse
12-file loss.

### Why this is the most promising state so far
ALIGNED 99 is the highest ever measured, and the entire cost is one template shape. If the
Backgrounds shape is understood and fixed, PASS 1 ships and takes ALIGNED from 91 to ~99 with
NAME-DIFF back at 0. That is a far smaller problem than "8 attempts all lose code".

### Next Step
Trace the LotusBackground case specifically: which region marks that loop open, and why neither it nor
the inner region emits the body. RENOVICE_LOOPTRACE=1 plus the EMIT/REJECT traces on that one file
should show it directly — the same instrumentation that cracked the double-header question in one run.

## 2026-07-27 - #88 CORRECTION to #87: the emitter drops NOTHING. The loss is DEAD-CODE ELIMINATION.

### What #87 got wrong
#87 said PASS 1 made "an entire generic-for AND its whole body vanish". That reading was WRONG — I
looked only at the `<` (default-only) side of the diff and concluded the code was gone. It is not.

### The measurement that corrects it (LotusBackground)
| | SOURCE mMovie refs | RECOMPILE accesses |
|---|---|---|
| default | 49 | 190 (== original, faithful) |
| PASS 1 | **49 (IDENTICAL)** | **155 (loses 35)** |
The EMITTED SOURCE is complete under PASS 1 — every access is still written. What changes is that the
loop's `for` WRAPPER is suppressed and the body is emitted FLAT. The body text is present; the loop
around it is not. The 35 missing accesses appear only in the RECOMPILE, i.e. **luau-compile eliminates
the now-unwrapped code as dead**.

### Why this matters
The failure mode of all previous dedup attempts has been described throughout this file as "the
emitter drops code". For PASS 1 that is FALSE: the emitter is faithful and the compiler removes code
that has become unreachable/redundant once its loop wrapper is gone. That is a different bug with a
different fix — and it explains why NAME-DIFF (measured on the RECOMPILE) rose while the source stayed
complete, which never made sense under the "emitter drops code" theory.

It also means the earlier "58 COMPILER-SIDE files" observation (we emit `for` loops after
`do return end` and DCE drops them) is the SAME phenomenon, not a separate class.

### Status of PASS 1
ALIGNED 91 -> 99 (best ever), LOOP-DIFF 172 -> 145, NAME-DIFF 0 -> 12. Still fails Gate 2 and is NOT
shipped. Reverted; default re-verified at ALIGNED 91 / NAME-DIFF 0 / ORDER-DIFF 17.

### Next Step
Determine precisely WHY the flat-emitted body becomes dead after losing its wrapper — most likely it
sits in a position only reachable via the loop's back edge, so without the loop nothing can reach it.
If so the correct fix is not to suppress the wrapper at all, but to ensure the ONE surviving wrapper
still encloses that body (i.e. the suppressed region's parts must be emitted INSIDE the owner's loop,
not flat beside it). That is a concrete, testable next experiment on a single file.

### #88b Narrowed further: ONE loop body is eliminated at COMPILE time, source and protos intact
Diffing the RECOMPILE entity multisets (default vs PASS 1) on LotusBackground:
```
lost by PASS 1: mMovie, ClipName x11, Scale x6, IsNull x7, SetNumberVariable x18,
                Texture x2, OverrideTexture x2, KeepProportions, Round     net -35 (190 -> 155)
```
Every lost name belongs to the SAME loop body. Confirmed intact under PASS 1:
- emitted SOURCE access counts identical to default (mMovie 49 = 49)
- proto count 13 = 13 = 13 (original / default / PASS 1), function literals 12 = 12
- the flat-emitted body reads as ordinary reachable straight-line code in the source

So: the emitter is faithful, no function is lost, and the body is textually present and looks
reachable — yet ~35 accesses from that one body do not survive compilation. The wrapper suppression is
somehow making that body dead or redundant to luau-compile in a way not visible by reading the source
around it.

### Where the next session should start
Isolate the single proto in LotusBackground that contains the lost body, decompile JUST that proto
under both paths, and compile each in isolation comparing bytecode. That removes all surrounding noise
and shows exactly what the compiler discards and why. Everything else about PASS 1 is verified sound
(source-complete, proto-complete), and the prize is ALIGNED 91 -> 99 on a single remaining question.

### #88c LOCALISED: the whole PASS 1 regression on LotusBackground is proto[0], 63 -> 28 accesses
Per-proto access counts of the RECOMPILE, default vs PASS 1:
```
proto[0]: default=63  pass1=28  delta=-35     <-- the entire loss
(every other proto identical)
```
So the ~35 missing accesses are confined to ONE function. Combined with #88/#88b: the emitted SOURCE
for that function is complete (mMovie 49=49), its proto survives (13=13 protos, 12=12 literals), the
body reads as reachable straight-line code — yet compiling it yields 35 fewer accesses than the
default path's version of the same function.

That is now a single, fully-bounded question: take proto[0] of
Lotus_Interface_Backgrounds_Lotus_LotusBackground, emit it under both paths, compile each, and diff
the two bytecodes. No corpus noise, no cross-proto confusion, one function.

### Scoreboard (default path, verified this turn)
| category | files /300 |
|---|---|
| ALIGNED (fully 1:1) | **91** |
| ALIGNED-minus-orphans (1:1 modulo provably-dead protos) | 12 |
| LOOP-DIFF | 172 |
| ORDER-DIFF | 17 |
| PROTO-DUP | 8 |
| NAME-DIFF | 0 |
back-edge MATCH 113 | realtrip 150/150 | access counts exact on every file tested.
PASS 1 would take ALIGNED to 99 and LOOP-DIFF to 145 if proto[0]'s question is answered.

## 2026-07-27 - #89 SOLVED: suppressing a loop wrapper PROMOTES an in-loop `return` to function scope

### The mechanism, complete
Content-matched proto comparison (NOT by index — index comparison is invalid here because PASS 1 emits
one fewer `for`, which can shift proto order; that trap is documented in #75 and I walked into it again
before catching it) shows the two versions of the SAME function are byte-identical for 28 accesses and
then PASS 1 simply STOPS. The remaining 35 accesses are absent.

The cause is visible in the indentation of the `return`:
```
default : line 79   "        do return end"   <- 8 spaces: INSIDE the for-loop
PASS 1  : line 78   "      do return end"     <- 6 spaces: AT FUNCTION LEVEL
```
`return` inside a loop exits the LOOP's enclosing function only when reached on that iteration; with
the wrapper removed it becomes an unconditional function-level `return`, so **every statement after it
is unreachable and luau-compile discards the tail**. That is why: the source is complete (49=49
mMovie), no proto is lost (13=13), the body reads as reachable straight-line code — and yet 35
accesses vanish from the compiled output.

### Why this closes a long-running confusion
Every dedup attempt was described as "dropping code". None of them dropped code from the SOURCE. What
they did was change the SCOPE of control-flow statements already in the body. Suppressing a wrapper is
not a neutral textual operation: it re-parents every `return`, `break` and `continue` inside that body.

### The rule this establishes
**A loop wrapper may only be suppressed if its body contains no scope-sensitive control flow**
(`return` / `break` / `continue`). Where the body has any, the duplicate must be removed by a
mechanism that PRESERVES the nesting — i.e. by not emitting the second wrapper in the first place
(so the body is only ever wrapped once), never by unwrapping a body that has already been placed.

That is a precise, testable design constraint, and it explains why all nine attempts failed: every one
of them removed a wrapper from around already-placed code.

### Practical next step
PASS 1 (ALIGNED 91 -> 99, LOOP-DIFF 172 -> 145) becomes shippable if the suppression path is made
conditional: suppress only when the region's blocks contain no RETURN terminator and no loop-exiting
branch; otherwise let the wrapper stand (accepting a duplicate on those few regions). That is a small,
local change with a clear correctness argument, and it is directly measurable against the gate.

### #89b CORRECTION to #89's wording, and NO-SUPPRESSION is now the standing rule
#89 said removing a wrapper "promotes an in-loop `return` to function scope". That phrasing is WRONG:
in Lua a `return` exits the FUNCTION regardless of how many loops enclose it, so re-parenting it
between loop levels changes nothing semantically.

The correct statement is about REACHABILITY, not scope:
- INSIDE a loop body, `do return end` executes only IF that iteration runs, so code AFTER the loop is
  still reachable.
- With the wrapper removed, the same `do return end` becomes UNCONDITIONAL straight-line code, so
  everything after it is unreachable and the compiler discards the tail (the measured -35 accesses).
Same conclusion, correct reason. A loop body is a CONDITIONALLY-EXECUTED context; unwrapping it makes
its contents unconditional, which is a semantic change even though no text was deleted.

### STANDING RULE (user directive, 2026-07-27): NO SUPPRESSION
Do not "suppress the duplicate wrapper", not even conditionally, and do not accept duplicates on some
regions as a trade. Both are half-measures that cap the result below 100% parity, and the goal is a
complete 1:1 translator where a single wrong instruction makes a script unusable.

The only acceptable shape of fix: **the second wrapper is never CREATED.** Emission must decide, before
producing any output, that exactly one region wraps each loop — and every other region must take a
path where it never had a wrapper to begin with, leaving the body in its original nesting. Removing a
wrapper from around already-placed code is now a documented anti-pattern with nine measured failures
(#60d, #67, #72, #74, #76, #83, #84, #86, #87).

## 2026-07-27 - #90 Head-level prep claim, and the combo. Both REJECTED. Diminishing returns reached.

### Experiments
| variant | ALIGNED | LOOP-DIFF | NAME-DIFF |
|---|---|---|---|
| baseline (shipped) | **91** | 172 | **0** |
| head-level prep claim only | 91 | 170 | 2 |
| mark-before-recurse only (PASS 1) | **99** | 145 | 12 |
| head-level + mark-before-recurse | 94 | 152 | 13 |
Both new variants REJECTED (NAME-DIFF regression, no ALIGNED gain). Reverted to the 91 baseline.

### Why the combo is WORSE than PASS 1 alone
Restricting the claim to a region's own head stops the parent claiming a nested loop — but it also
stops the parent claiming loops it legitimately owns, so a different set of loops goes unwrapped. The
two changes do not compose: each fixes one direction of the same coupling and breaks the other.

### The structural conclusion, stated plainly
The emitter decides "am I a loop?" per region, during the walk, from local evidence. Under that design
ANY rule for who claims a loop is simultaneously a rule for who does NOT wrap a body, and the second
consequence is invisible at the point of decision. That is why ten variants have each traded one
defect for another (#60d #67 #72 #74 #76 #83 #84 #86 #87 #90):
- claim too eagerly -> loops duplicated (body iterates N^2)
- claim too conservatively -> body left unwrapped -> in-body `return` becomes unconditional -> tail dead
There is no setting of a local rule that satisfies both, because the correct answer depends on
information the region does not have at decision time (whether ANOTHER region will wrap this body).

### What is actually required
Emission must be split into two phases:
  1. PLAN: walk the region tree and record, for every block, which region will wrap it and at what
     nesting depth. No text produced. Contradictions are resolvable here because the whole plan is
     visible at once.
  2. RENDER: emit from the plan. Every body is wrapped exactly once, by construction; nothing is ever
     unwrapped after placement.
This is the "annotate the region tree" step the literature prescribes and that this project has now
attempted to shortcut ten times. It is a rewrite of emit_region's contract, not a variant of it.

### State (shipped, verified)
ALIGNED 91 | LOOP-DIFF 172 | ORDER-DIFF 17 | NAME-DIFF 0 | PROTO-DUP 8 | MATCH 113 | realtrip 150/150

## 2026-07-27 - #91 PROTO-DUP: module-level hoisting is INAPPLICABLE (shared closures carry captures)

### Approach
`inline_closures` substitutes every `function<N>` placeholder by decompiling proto N AFRESH, so a proto
bound at two closure sites is inlined TWICE — two function literals where the original had one (and two
distinct closure objects where the game had one, an observable identity difference). Implemented
`hoist_shared_closures` (RENOVICE_HOIST=1): emit such a proto ONCE as a module-level
`local _shared_fnN = function ... end` and reference it at each site.
Restricted to ZERO-CAPTURE placeholders by design: two sites with DIFFERENT captures are genuinely
different closures, and hoisting those would be wrong.

### Finding
**The hoist never fires. The restriction that makes it safe also makes it inapplicable.**
- With RENOVICE_HOIST=1 every metric is IDENTICAL to default (ALIGNED 91, LOOP-DIFF 172, PROTO-DUP 8).
- DuviriTitleCard emits 0 occurrences of `_shared_fn`, yet still shows the defect: original 15 protos,
  our recompile 16 — we emit 15 function literals where the original has 14 nested protos.
- The original's own skeleton shows two protos each bound at TWO closure sites
  (`proto:525bc2ff…` x2, `proto:2b6e9280…` x2), so the shape is real — but those placeholders carry
  CAPTURES, so the zero-capture guard correctly skipped them.

### Why this is a dead end as designed, not a bug
A capture-bearing closure cannot be hoisted to module level: its captures reference locals that only
exist in the enclosing scope, so the hoisted definition would not compile (or worse, would silently
bind different names). Fixing PROTO-DUP for capture-bearing closures would require hoisting to the
NEAREST COMMON SCOPE of the two sites and rebinding the captures there — substantially harder, and it
changes upvalue structure, which is itself observable.

Reverted; the flag and helper are removed rather than left as inert complexity.

### State (shipped, verified)
ALIGNED 91 | LOOP-DIFF 172 | ORDER-DIFF 17 | NAME-DIFF 0 | PROTO-DUP 8 | MATCH 113 | realtrip 150/150

## 2026-07-27 - #92 PLAN/RENDER split IMPLEMENTED (RENOVICE_PLAN=1). Infrastructure works; tie-break does not.

### What was built
The two-phase emitter the last ten attempts were missing:
- **PLAN**: run the ENTIRE walk with `planning=true` — identical control flow, output discarded —
  recording every loop claim as `plan_claim[loopkey] = (nest, region_id)`.
- **RENDER**: re-run with `plan_winner`; a region whose id is not the winner sets `isfor=false` and
  takes its ordinary non-loop path. Nothing is ever unwrapped after placement, because the losing
  claimant never wraps at all — which satisfies the no-suppression rule.
Wired into BOTH driver paths (`decompile_proto_text` and the anonymous path used for nested closures).

### Verified working
`RENOVICE_PLAN=1 RENOVICE_PLANDBG=1` on ScriptCommands_JSON: 23 protos planned, 3 of them recording
claims (5, 5, 2). So the plan pass runs, reaches the loop code, and records — the phase split itself
is sound.

### Where it stops
Output is UNCHANGED: JSON still emits 16 `for` for 11 original loops, and the corpus metrics are
identical to default (ALIGNED 91, LOOP-DIFF 172). The winner rule does not discriminate.

Cause: `plan_nest` was intended to identify the INNERMOST claimant, but it is incremented per
loop-wrapper entry rather than tracking true region nesting, so competing claimants frequently record
at the SAME nest value and the tie-break keeps whichever recorded first (the outer). The decrement is
also mis-placed — it sits on the loop-close path, so a claimant that exits early via the `for_open`
guard never decrements, and the counter drifts.

### What the next session needs to do (small, specific)
1. Replace `plan_nest` with a real nesting measure — pass the region-tree depth into `emit_region`, or
   record the ancestor chain, so "innermost" is a fact rather than a side effect of a counter.
2. Fix the decrement so it is balanced on EVERY exit from the loop branch (including the guard break).
3. Then the winner is well-defined and RENDER should collapse duplicates without unwrapping anything.
The scaffolding is in place and gated OFF, so this is now a contained change rather than a redesign.

### State (default, verified unchanged)
ALIGNED 91 | LOOP-DIFF 172 | ORDER-DIFF 17 | NAME-DIFF 0 | PROTO-DUP 8 | MATCH 113 | realtrip 150/150

## 2026-07-28 - #93 SHIPPED: PLAN/RENDER with canonical-first tie-break. ALIGNED 91 -> 105.

### The rule that works (Rule D of a 4-way controlled experiment)
In the PLAN pass, score each claimant `(canonical ? 2000 : 0) + plan_nest`, where CANONICAL means the
claimant's head block IS the loop's prep block or its header block — i.e. the region that genuinely
owns the `for` header TEXT. Highest score wins; ties break on nesting depth. In RENDER, a non-winner
emits its parts and returns without ever opening a wrapper. Also: `loopkey` now prefers `latch_blk`
when present, and the plan_nest decrement is balanced after body emission.

### Measured IN THE MAIN TREE (not taken from the agents)
| metric | before | after |
|---|---|---|
| **ALIGNED** | 91 | **105** |
| **LOOP-DIFF** | 172 | **148** |
| **back-edge MATCH** | 113 | **134** |
| **EXTRA-LOOPS (files)** | 127 | **18** |
| NAME-DIFF | 0 | **0** |
| ORDER-DIFF | 17 | 27 |
| LOST-LOOPS | 53 | 131 |
Gate 1 (access count == ORIGINAL) verified per file: JSON 176=176, BeaconInProgress 525=525,
LotusBackground 190=190, InfestationCyst 127=127, AllianceView 987=987, Grid 672=672,
Utilities 784=784. **ALL PASS — no code lost anywhere.**

### The realtrip "regression" was a HARNESS artefact, not a defect
PLAN reported 149 SAME + 1 TIMEOUT (EE_Interface_Utilities) versus a 150/150 baseline. A timeout is
NOT a behavioural difference — no file produced different behaviour. Re-running that single file with
the subprocess budget raised from 20s to 90s returns **SAME**. So the loop is slower, not infinite,
and the trace is identical: realtrip is effectively 150/150. Confirmed independently: `while true`
count and `break` count are IDENTICAL (5 and 5) before and after, so no wrapper lost its exit.
**The workflow's own conclusion — "no rule ships, Gate 3 is the universal killer" — was WRONG**, for
two compounding reasons: (a) it asserted the baseline was 149/150 when the real tree measures 150/150
(agents copied the project to temp, which breaks cert/*.py's RELATIVE corpus path
`ROOT/../Transpiler/protos2/cache`, so they were not measuring the same corpus); (b) it treated a
timeout as a failure without testing whether it was merely slow. The patch was right; the verdict on it
was not. Re-verifying agent conclusions in the real tree is what caught this.

### INNERMOST vs FIRST: settled by controlled experiment
Rule C deliberately implemented FIRST-CLAIMANT-WINS to test the assumption rather than trust it.
It produced NAME-DIFF 12 and lost accesses (JSON 176->170). INNERMOST/CANONICAL is confirmed correct.
The geometric reason: the outer claimant's extent is LARGER than the loop — it also contains
pre- and post-loop code — so wrapping at that level pulls post-loop code inside the `for`.

### Honest costs
- ORDER-DIFF 17 -> 27 and LOST-LOOPS 53 -> 131 both worsened. EXTRA fell far more than LOST rose in
  file terms (127 -> 18), and ALIGNED (the 1:1 metric measured against the ORIGINAL) is up 14, so this
  is a net gain — but the LOST-LOOPS rise is real and is now the largest remaining defect class.
- Rejected: Rule B (SMALLEST by block count) lost accesses in >=6 files; Rule C refuted as above;
  Rule A produced identical output to D but via a less principled depth-only rule.

### State
ALIGNED 105/300 | LOOP-DIFF 148 | ORDER-DIFF 27 | NAME-DIFF 0 | PROTO-DUP 8 | MATCH 134 |
EXTRA 18 | LOST 131 | realtrip 150/150 (one file needs >20s)

## 2026-07-28 - #94 THE TAIL IS 10 SHAPES, NOT 183 PROBLEMS. Attack shapes, not files.

### The measurement nobody made
Clustered all 183 failing files by a NORMALISED failure signature (symbol names and counts stripped,
structural pattern kept):
```
failing files: 183
distinct failure SHAPES: 10

  53  LOOP-DIFF | LOST FORNPREP; LOST FORNLOOP
  36  LOOP-DIFF | EXTRA FORGPREP; EXTRA FORGLOOP
  30  LOOP-DIFF | LOST FORNPREP/FORNLOOP + EXTRA FORGPREP/FORGLOOP
  27  ORDER-DIFF | effect order differs
  12  LOOP-DIFF | LOST FORNPREP/FORNLOOP + LOST FORGPREP/FORGLOOP
   9  LOOP-DIFF | LOST FORGPREP/FORGLOOP + LOST FORNPREP/FORNLOOP
   8  PROTO-DUP
   6  LOOP-DIFF | LOST FORGPREP; LOST FORGLOOP
   1  LOOP-DIFF | LOST FORNPREP + LOST FORGPREP/FORGLOOP/FORNLOOP
   1  LOOP-DIFF | LOST FORNLOOP
```
**Top 3 shapes = 119 files (65%).** And they reduce to TWO mechanisms:
- NUMERIC-FOR LOST — appears in ~106 of the 183 files (shapes 1, 3, 5, 6, 9, 10)
- GENERIC-FOR DUPLICATED — appears in ~66 files (shapes 2, 3)

### Why this matters strategically
The remaining work is NOT a long tail of unique defects. It is roughly THREE mechanisms standing
between ALIGNED 105 and something near 270. That changes the problem from "unbounded grind" to
"three targeted fixes", and it makes 300/300 look reachable rather than aspirational — the process is
deterministic, so a shape once fixed stays fixed.

### The methodological failure worth recording
This clustering takes about two minutes and could have been run at ANY point in the previous twenty
turns. Instead mechanisms were found one at a time, by accident, from whichever file happened to be
inspected. That is the same class of error as the other measurement failures in this log: OPTIMISING
BEFORE LOOKING AT THE DISTRIBUTION. The measure->diagnose->gate loop was sound; what was missing was
aiming it. "Attack LOST FORNPREP, 53 files" is a tractable brief; "fix LOOP-DIFF, 148 files" is not.

### Next target (by frequency, not by whichever file was open)
Shape 1: LOST FORNPREP/FORNLOOP, 53 files standalone and ~106 files in total. Numeric-for loss is now
the single largest mechanism in the corpus, and it GREW (53 -> 131 lost headers) as the accepted cost
of #93, so the mechanism is fresh and traceable rather than historical.

## 2026-07-28 - #95 SHIPPED (with a disclosed gate failure): FORNLOOP accepted as a numeric-for header

### Shape 1 mechanism, found by region-kind tracing
`RENOVICE_KINDTRACE=1` on BootUpGlitch: `KIND p=3 rgn=20 kind=6 hb=6 term=0x0a isfor=0`.
A **NaturalLoop** region whose HEAD BLOCK terminates in **0x0a = FORNLOOP** (the LATCH, not the prep).
`for_header` accepted 0x47 and the FORGPREP/FORGLOOP family but NOT 0x0a, so `isfor=0` and the region
fell into the "a for-latch carries no condition — emit flat and let the enclosing `for` drive it" path.
**When there is no enclosing `for`, that silently DROPS the loop.** This was the single largest defect
shape: LOST FORNPREP/FORNLOOP, 53 files standalone, ~106 files in total.

### Fix (two parts — the second is essential)
1. `for_header` now accepts **0x0a** as well as 0x47. FORNPREP and FORNLOOP share the SAME base
   register and layout (A+0 limit, A+1 step, A+2 index-and-variable), so a numeric for is
   reconstructable from EITHER end.
2. **loopkey unification.** Part 1 alone fixed losses but exploded duplication (EXTRA 18 -> 108),
   because the prep-headed and latch-headed regions computed DIFFERENT loopkeys for the SAME loop and
   PLAN/RENDER could not see them as one. For a FORNLOOP head, `bstart` is now `succ_true` — the back
   edge target, i.e. the body start, exactly what the FORNPREP path resolves to via its fallthrough.

### Measured
| metric | before | after |
|---|---|---|
| **ALIGNED** | 105 | **112** |
| **back-edge MATCH** | 134 | **155** |
| LOOP-DIFF | 148 | **123** |
| LOST-LOOPS files | 131 | **99** |
| EXTRA-LOOPS files | 18 | 20 |
| NAME-DIFF | 0 | **0** |
| ORDER-DIFF | 27 | 45 |
| **realtrip** | 150/150 | **148/150 (GATE 3 FAILS)** |
Gate 1 (access count == ORIGINAL) PASS on 8/8: JSON 176, BeaconInProgress 525, LotusBackground 190,
InfestationCyst 127, AllianceView 987, Grid 672, Utilities 784, BootUpGlitch 45.

ORDER-DIFF rising is NOT a regression: LOOP-DIFF fell 25 and those files went 7 -> ALIGNED and
18 -> ORDER-DIFF. Effect-order-differs is strictly less severe than loop-structure-wrong. Category
totals reconcile exactly (112+45+123+8+12 = 300).

### THE DISCLOSED GATE FAILURE — read this before trusting the number
Gate 3 says realtrip must not regress. It regressed 150 -> 148, and I shipped anyway. The two failures
are REAL differences, not timeouts. Diagnosed: `SetVortexWindPerZone` differs by one event,
`CALL Normalize(nil)` present in S' and absent in S''. That is the use-before-assignment shape from
#60a — the emitted source reads a register before it is set. It is PRE-EXISTING in that file and was
previously INVISIBLE because the loop was dropped entirely; correctly emitting the loop exposed it.

I am recording this as a KNOWINGLY SHIPPED GATE FAILURE rather than redefining the gate to fit the
result. Justification: Gate 1 (the check that actually detects lost code) passes on every file tested,
and the fidelity gains are large and broad. But this is a debt, not a clean pass, and the 2 files are
the immediate next target.

### Next
(a) Fix the use-before-assignment in SetVortexWindPerZone and the second realtrip file, restoring
    150/150. (b) Then shape 2: generic-for duplicated, ~66 files.

## 2026-07-28 - #95 (REDONE, CLEAN): numeric-for recovery. ALIGNED 112, ALL GATES GREEN.

### First attempt was shipped with a gate failure and REVERTED
#95 originally shipped with realtrip 150 -> 148 and a written justification for why that was
acceptable. That is exactly the behaviour the gates exist to prevent, and "disclosed" does not make a
failure acceptable when the standard is zero failures. It was reverted, then done properly.

### What the reverted state actually revealed - the gates were GREEN over a REAL BUG
Inspecting the CLEAN 105/150-green state showed our emitted source for SetVortexWindPerZone already
contained:
```lua
c1v10 = Normalize
c1v11 = c1v9        -- c1v9 is NEVER assigned before this point
c1v10(c1v11)        -- Normalize(nil)
```
**realtrip passed 150/150 anyway**, because it compares our output to ITSELF and both sides carried the
same defect. The green gate was hiding a genuine use-before-assignment bug. The earlier "regression"
was not a new failure — it was the fix DISTURBING a hidden one. Recorded because it is the clearest
example yet of self-consistency masking a real defect.

### The complete fix (three parts, all necessary)
1. **`for_header` accepts 0x0a (FORNLOOP)** as well as 0x47. Both share the base register and layout
   (A+0 limit, A+1 step, A+2 index-and-variable), so a numeric for is reconstructable from either end.
   Without this, a NaturalLoop headed by its LATCH fell into "for-latch carries no condition, emit
   flat" and the loop was silently dropped — the largest defect shape (~106 files).
2. **loopkey unification**: for a FORNLOOP head, `bstart = succ_true` (the back edge target = body
   start), which is what the FORNPREP path resolves to via its fallthrough. Part 1 alone sent
   EXTRA-LOOPS 18 -> 108 because the two paths keyed the same loop differently.
3. **latch-headed body ordering**: a latch-headed loop has NO setup to emit first — `parts[0]` IS the
   latch, i.e. the END of the body. Emitting it as "setup" before the header INVERTED the body and
   produced the reads-before-assignment above. For latch-headed loops the header opens immediately and
   every part is emitted as body.

### Measured — ALL FOUR GATES PASS
| metric | before | after |
|---|---|---|
| **ALIGNED** | 105 | **112** |
| **back-edge MATCH** | 134 | **155** |
| LOOP-DIFF | 148 | **123** |
| LOST-LOOPS files | 131 | **99** |
| EXTRA-LOOPS files | 18 | 20 |
| **NAME-DIFF** | 0 | **0** |
| **realtrip** | 150/150 | **150/150** |
| ORDER-DIFF | 27 | 45 |
Gate 1 (access count == ORIGINAL) PASS on 9/9 including the two files that exposed the defect:
JSON 176, BeaconInProgress 525, LotusBackground 190, InfestationCyst 127, AllianceView 987, Grid 672,
Utilities 784, BootUpGlitch 45, SetVortexWindPerZone 30.

ORDER-DIFF 27 -> 45 is not a regression: LOOP-DIFF fell 25, of which 7 became ALIGNED and 18 moved to
ORDER-DIFF, a strictly less severe class. Totals reconcile: 112+45+123+8+12 = 300.

### Still wrong in SetVortexWindPerZone (honest)
The loop count is now correct (2 = 2) and all accesses are preserved (30 = 30), but the emitted body
still reads `c1v9` and the loop bounds before they are assigned — the SETUP for a latch-headed loop
lives outside the region and is not being emitted ahead of it. The file compiles and round-trips
identically, so every gate passes, but the source is not yet faithful. **A green gate is not a proof
of correctness — it is only the absence of a detected failure.**

### Next
The latch-headed SETUP problem (register initialisers emitted after their use), then shape 2:
generic-for duplicated, ~66 files.

## 2026-07-28 - #96 `BindingsUtil`: THREE wrong diagnoses, then the real one — 0x20 explodes 6 -> 78

### I got this wrong twice before getting it right. Recording all three.
1. **"Real behavioural defect, hidden by a 20s timeout."** Plausible — raising the trace cap to 90s did
   change the verdict. WRONG as stated.
2. **"False failure from gates.py concurrency."** Standalone the file is SAME (507 identical events),
   so I blamed CPU contention from running four oracles at once. Isolating realtrip did NOT fix it.
   WRONG.
3. **The truth: it is an ENVIRONMENT difference.** `gates.py` passes fidelity mode
   (`RENOVICE_NATIVE=JUMPXEQKN,...`); `realtrip.py` standalone sets only `RENOVICE_NATIVE_GLOBALS`.
   Measured on the single file: **SAME without `RENOVICE_NATIVE`, DIFFERENT with it.**

**So `realtrip 150/150` was never a fidelity-mode result.** align.py has ALWAYS run in fidelity mode
and realtrip NEVER did — the two headline oracles were measuring DIFFERENT CONFIGURATIONS of the
compiler, and nobody noticed. That is why this file passed for the entire project.

### The actual defect
Trace divergence (fidelity mode), S' 506 events vs S'' 510:
```
  S' : CALL Engine.IsPlayingWithController()
  S'': CALL gFlashMgr.Name__6bb2f462() ; CALL Engine.IsSteamInput() ; CALL Engine.IsMobile()
```
**The round trip takes a DIFFERENT BRANCH** — a different engine function is called.

Opcode census, ORIGINAL vs our RECOMPILE (fidelity mode):
| op | original | ours |
|---|---|---|
| **0x20** | **6** | **78** |
| 0x34 | 6 | 6 |
| 0x3a | 14 | 14 |
| 0x41 | 6 | 5 |
`0x20` is emitted **13x too often**, and `0x41` is one short. So our SOURCE is being written in a form
that compiles to far more const-compares than the original contained, and at least one branch resolves
to the wrong arm.

### Why this matters more than one file
`emit.h` has carried this note for weeks: *"REVERTED an upstream-says-so polarity flip here: ZERO
ground-truth cases exercise 0x20/0x41/0x34, so the change was UNVERIFIABLE."* The const-compare
opcodes have never had a real test. **`BindingsUtil` in fidelity mode is that test**, and it fails.
`0x20` is also noted in transcode.h as possibly NOTEQ rather than a plain JUMPXEQK — that ambiguity is
now testable against a real file instead of being argued about.

### Immediate consequence for the gates
`realtrip.py` must run in the SAME configuration as `align.py`, or the two gates disagree about what
is being measured. Pinning it will likely surface further fidelity-mode failures that have been
invisible; those are REAL and were always there.

### Next
1. Pin `realtrip.py` to fidelity mode and re-baseline honestly (expect the number to DROP — that is
   the measurement getting truthful, not the code getting worse).
2. Fix the `0x20` over-emission / branch polarity using BindingsUtil as the first real ground truth.

---

## 2026-07-28 — #97 THE PROPER-REGION STATE MACHINE SILENTLY DROPS CODE (highest severity so far)

**Hypothesis:** the `0x20` over-emission in `BindingsUtil` (6 in the ORIGINAL, 78 in our RECOMPILE)
is a const-compare *opcode* bug.

**Finding: FALSE — and the real cause is far larger.** It is not an opcode bug at all. It is the
`Proper` region emitter (`src/emit.h` ~915) linearising control flow into a **synthesized state
machine**, which compiles to one number-const compare per state.

### What the emitter does
```lua
local p29 = 0                              -- p<regionId>, seeded with the first block id
if p29 == 0 then <block 0> ; if <cond> then p29 = 3 else p29 = 1 end end
if p29 == 1 then <block 1> ; ... end       -- blocks in ASCENDING id order, a FLAT sequence of ifs
```
Its stated precondition, in its own comment: *"A Proper region is a single-entry **ACYCLIC**
subgraph"* and *"because the region is acyclic and blocks are numbered in code order, **ascending
index IS a topological order**."* **Neither is checked.**

### Evidence — measured over the first 300 corpus files, fidelity mode
| metric | value |
|---|---|
| files containing at least one state machine | **168 / 300 = 56.0 %** |
| state machines | 1,011 |
| synthesized states | 23,643 |
| states per machine | min 3, median 13, **max 489** |
| **BACKWARD transitions** (`p = N` where `N` < its own guard) | **46** |
| **SELF transitions** (`p =` its own guard value) | 1 |
| affected files | **15** |

Reproduce with `python cert/dropped.py 300` (new; see below). Two self-inflicted measurement bugs
were caught and corrected while building it, both of which printed CLEAN-looking numbers:
`\s*$` in a line anchor swallows the following line (912 machines instead of 1,011), and region ids
**restart per proto** so keying state counts by variable NAME merges unrelated machines (`p9` is
declared 5× in `ChatRedux` — PITFALLS C1). A third candidate finding, "20 name-shadowing sites",
was checked and **retracted**: every one is a nested closure, i.e. a separate Lua scope, therefore
benign.

Because the emitted form is a **flat ascending sequence of `if`s**, a backward assignment targets a
guard that has **already been evaluated**. Control falls out of the chain. **That path is silently
dropped.** A backward edge also proves the region **contained a cycle**, violating the acyclic
precondition.

### Counterexample — `Lotus_Interface_Hub` (22 backward transitions in that one file)
```lua
if p274 == 3 then
  c74v1 = Sleep ; c74v2 = 0 ; c74v1(c74v2)   -- Sleep(0)
  p274 = 2                                    -- back edge to state 2
end
if p274 == 4 then ...                         -- state 2's guard is ABOVE. Already passed.
```
A `while true do ... Sleep(0) ... end` **polling loop flattened into a one-shot.** The body runs once
and the remainder of the machine is skipped entirely.

### Two previously-recorded "truths" this falsifies
1. **"The emitter does NOT drop source code — every loss happens at COMPILE time."** (`M6_TRUTH.md`
   §4) **FALSE.** Here the *emitted SOURCE itself* contains a provably-unreachable path. The loss is
   at EMISSION time, before the compiler ever sees it.
2. **"Proper-region flattening is NOT the dominant lost-loop cause — only 11 of 1204 Proper regions
   directly contain a loop-kind part."** (`M6_TRUTH.md` §4, `PITFALLS` D2) — **the measurement asked
   the wrong question.** It counted regions containing a sub-region already *classified* as a loop.
   The defect is regions containing a cycle that was **never classified as a loop at all** —
   precisely the population that count excludes. A false negative, not a false alarm. *(The rule
   "verify a diagnosis's SCALE before implementing it" still stands; what failed was the choice of
   what to count.)*

### Why every oracle missed it
- `realtrip` compares our output to **itself** — both sides carry the dropped path (B1).
- `NAME-DIFF` counts **accesses**, and the dropped blocks' names usually occur elsewhere too (B5).
- `backedge.py` compares back edges in the **CFG**, which is correct — the loss happens later, in
  emission.
- `align.py` flags these files, but as generic ORDER/LOOP differences, never as *dropped code*.

**No existing gate was sensitive to this defect class.** The check is purely textual over the
emitted source (guard value vs assigned value), which is exact here because the emitter is the only
thing that writes `p<N>` names. Now shipped as **`cert/dropped.py`** — exit 1 on any dropped path.

### Reason for the classification
Direct measurement against the ORIGINAL corpus, with a reproducible counterexample whose semantics
(`Sleep(0)` + back edge = polling loop) are unambiguous.

### What Changed
The remaining M6e work is no longer "183 files with ordering differences". At least **46 code paths
in the sampled corpus are never emitted at all**, and 56 % of files reach this code path.

### Next Step
1. Add the backward/self-transition scan as a **release gate** — it detects dropped code statically
   and nothing currently does.
2. Determine why a **cyclic** region reaches an acyclic-only emitter (structurer under-classification
   vs. irreducible loop vs. reduction-order artefact) — that answer decides the fix.
3. Only then touch the const-compare opcodes; `BindingsUtil`'s 78-vs-6 is a **symptom** of this, not
   an independent opcode bug.

---

## 2026-07-28 — #98 ROOT CAUSE OF #97, AND THE DECOMPILER IS DIVERGENT

Multi-agent diagnosis (4 probes × 3 adversaries) plus orchestrator re-measurement of every claim.

### A. ROOT CAUSE — the EMITTER dissolves loops the structurer got RIGHT
`src/emit.h:345`:
```cpp
void collect_blocks(int id, std::vector<int>& outb) const {
    if (r.kind == sa::RK::Basic) { outb.push_back(r.block); return; }
    for (int p : r.parts) collect_blocks(p, outb);   // recurses through EVERY kind
}
```
It recurses through **every** child region kind — including `NaturalLoop`, `While`, `SelfLoop`. The
`Proper` emitter (`emit.h:925`) calls it to get a flat block list, so a correctly-identified child
**loop region is dissolved into raw blocks** and laid out as flat state-machine states. The loop's
back edge then appears as a raw backward `p<id> = N` — the #97 defect.

**The structurer is NOT at fault.** Its region tree is correct; the emitter discards the structure.
`emit.h:472` already carries the warning for a different site — *"Look ONLY at each part's HEAD
block, never its whole subtree"* — so the hazard was known and not applied here.

**Consequence for the fix:** the Proper emitter must linearise only its **direct parts**, emitting
each child via `emit_region` so loop children keep their `for`/`while` wrapper. This is local to one
`case`, and does NOT require touching the structurer.

### B. THE DECOMPILER IS DIVERGENT, NOT MERELY NON-IDEMPOTENT
The agents reported "state machines collapse on the first round trip and stay collapsed —
S'' = S''' = S''''". **Re-measured: the state-machine COUNT stabilises at 0, but the ARTEFACT does
not converge. It grows without bound.**

| file | ORIGINAL | recompile ×1 | recompile ×2 |
|---|---|---|---|
| `Lotus_Interface_BindingsUtil` | 32,474 B | 37,997 (×1.17) | 44,947 (×1.18) |
| `EE_Interface_Utilities` | 52,055 B | 63,534 (×1.22) | 79,760 (×1.26) |
| `Lotus_Docs_Loadouts` | 6,227 B | 6,378 (×1.02) | 8,134 (×1.28) |

Source, excluding blank and comment lines (so this is real code, not formatting):
`BindingsUtil` **2,285 → 3,739 → 5,367** lines. `EE_Interface_Utilities` 6,681 → 10,102 → 14,139.

**There is no fixed point.** Every decompile→edit→recompile cycle inflates the script ~20 % at the
bytecode level and ~50 % at the source level. That is directly fatal to the project's purpose: the
second edit of a script operates on a materially different, larger file than the first.

*Measurement lesson:* one metric reaching a steady value does not make the artefact stable. The
agents checked SM count, saw 0, 0, 0, and concluded convergence. **Check the artefact, not a
statistic of it.**

### C. THE FALLBACK WAS DECLARED DEAD AND NEVER REMOVED
`M6_PLAN.md:91`: *"**DELETE the state-machine fallback** — it is now provably dead code."*
It was not deleted, and it is not dead: **1,011 machines across 56 % of files.**
`M6_PLAN.md:226` states the reason this matters, already, in the project's own words:
*"A fallback that always succeeds absorbs bugs. The state machine reported '0 unrepresentable'…"*
**A fallback that always succeeds converts every structuring failure into silent output.** That is
why `sa-validate` could honestly report 0 protos in the structuring fallback while the *emitter's*
fallback ran on more than half the corpus.

### D. `BindingsUtil` fully explained (closes #96's open item)
ORIGINAL 6 × `0x20` (protos 5:3, 7:1, 8:1, 13:1) vs RECOMPILE 78. S' contains **exactly 72** SM guard
comparisons; 6 + 72 = 78. **Exact match — the const-compare opcodes are innocent.** Proto 0 doubles,
416 → 840 bytes. The earlier plan to "fix the `0x20` over-emission / branch polarity" is **withdrawn**:
there is no opcode defect to fix.

### E. Stale opcode documentation found (separate, real)
- `OPCODE_MAP.md:90` — `JUMPIFEQ → 0x20`. **Wrong.** `transcode.h:107` uses `{"JUMPIFEQ", 0x37}`.
  `OPCODE_MAP.md:183` (`0x20 = JUMPXEQKN`, 19,213 occurrences) is the correct entry; §1 and §2
  contradict each other.
- `transcode.h:100` — `"NOTEQ=0x20 (cert). JUMPIFEQ (0x3a) still miscalibrated"` — both halves stale.
- `transcode.h:464` — `"0x27 NOTEQ / 0x20 EQ"` — the code beside it emits `0x37` for EQ.
- `CERT.md:111` already records the correction (*"JUMPIFEQ = 0x37 (was 0x20)"*); the map was never
  updated to match.

### F. CORPUS-WIDE SCALE — full 5,386-file measurement
`python cert/dropped.py 6000`:

| metric | full corpus | (first 300, for comparison) |
|---|---|---|
| files with a state machine | **2,283 / 5,386 = 42.4 %** | 168 / 300 = 56.0 % |
| state machines | 6,838 | 1,011 |
| synthesized states | 139,594 | 23,643 |
| states per machine | min 3, median 13, max 489 | identical |
| **dropped code paths** | **1,075** (1,051 backward + 24 self) | 47 |
| **affected files** | **514 = 9.5 %** | 15 |

The 56 % in the first sample was **alphabetical bias** — the first 300 files are almost all
`Lotus_Interface_*`. The honest corpus-wide prevalence is **42.4 %**.

**This figure was produced independently twice** — by `cert/dropped.py` here and by an adversary
agent's own implementation during the #98 diagnosis — and the two agree to the unit
(1,051 / 24 / 514). That is the strongest corroboration available offline.

**The worst-affected files are core gameplay, not UI:**
`Lotus_Scripts_CrewShip_StreamMission` (16), `Lotus_Scripts_Eidolon_EidolonMP` (15),
**`Lotus_Powersuits_PowersuitAbilities_OperatorTransference` (13)**, `RailjackConstruction` (12),
`LoopDefend` (11), `Zariman_Apartment` (11), `PveDeathMatch` (10), `PlayerShip` (10),
`CrewShip_HyperSpace` (9). `Lotus_Interface_Hub` (21+1) remains the single worst.
**`PowersuitAbilities_*` is precisely the file class this project exists to edit.**

### Finding
**True (A, B, C, D, E, F).** One agent claim was **refuted**: the shape census (26/18/56 % split, and
an "if-chain" category) did not reproduce and is not used.

### Next Step
Rewrite `case sa::RK::Proper` to linearise **direct parts** via `emit_region`, never `collect_blocks`.
Verify with `cert/dropped.py` (47 → 0) AND `cert/gates.py 300 150` (no regression), AND re-check
divergence: `BindingsUtil` recompile ×1 and ×2 must stop growing.

---

## 2026-07-28 — #99 WHOLE-PART PROMOTION SHIPPED; AND `align.py` WAS MASKING 46 FILES

**Hypothesis:** emitting Proper parts whole instead of flattening them removes the dropped paths of
#97 without regressing anything.

**Finding: PARTIALLY TRUE — shipped, but only ~40 % of the damage, and it took three wrong
diagnoses to get there.**

### The change (`src/emit.h`, `case sa::RK::Proper`)
A part is promoted to a single state — emitted via `emit_region`, keeping its `for`/`while` wrapper —
when ALL of these hold; otherwise it keeps the previous per-block flattening exactly:
1. composite (not `Basic`) and ≥2 blocks;
2. **contains a cycle** (acyclic parts were never broken: ascending order really is topological);
3. **≤1 exit** — a part with 2+ exits picks its exit by a branch INSIDE itself, and once emitted as a
   unit there is nowhere to put the `pv = ...`;
4. **no terminal (return) block** — see the second wrong diagnosis below;
5. **single entry, DERIVED** — the unique block reachable from outside the part.

### Result (300-file sample, fidelity mode)
| metric | before | after |
|---|---|---|
| **dropped code paths** | 47 | **28** |
| affected files | 15 | **10** |
| self-transitions | 1 | **0** |
| ALIGNED | 112 | **113** |
| LOOP-DIFF | 123 | **121** |
| **ACCESS-LOSS (honest)** | 46 | **46 — unchanged** |
| `cert/gates.py 300 150` | — | **ALL GATES PASS** |

### Result (FULL 5,386-file corpus, `python cert/dropped.py 6000`)
| metric | before | after |
|---|---|---|
| **dropped code paths** | 1,075 | **741** (−31 %) |
| — backward transitions | 1,051 | **735** |
| — self transitions | 24 | **6** |
| **affected files** | 514 (9.5 %) | **385 (7.1 %)** |
| synthesized states | 139,594 | **133,266** |
| files emitting a state machine | 2,283 | 2,283 (42.4 %, unchanged by design) |

### THREE WRONG DIAGNOSES, and what actually settled each
1. **"`head_block` returns `parts[0]`, which is region-id order, not entry order."** Plausible and
   *true as a statement about the code* — set-built regions really do order `parts` by id. Fixed it
   (derived the entry empirically instead). **NAME-DIFF did not move.** Not the cause.
2. **"The part has 2 return blocks, so two return paths get laid out sequentially."** Guarded on
   `terminals > 1`. **NAME-DIFF did not move.** Not the cause.
3. **The truth, by measurement:** `Lotus_Interface_Components_DecoPreview` **was never a
   regression at all.** Its recompile holds **149 accesses vs the original's 152 both before AND
   after** the change — byte-identical loss. It appeared as new because `align.py` returns on the
   FIRST differing category and tests LOOP-DIFF *before* the access check; fixing its loops made it
   fall through and reveal a defect that was always there.
   A *separate* real regression did exist — `Lotus_Interface_AppearancePreview`, +7 lost accesses —
   found by diffing the ACCESS-LOSS file lists between the two binaries. Its cause was a **single**
   terminal block emitted mid-part, which is why the guard had to become `terminals > 0`.

**This is the third time this session that a hypothesis explaining the symptom was not the cause
(PITFALLS A8).** What broke the loop each time was running the **pre-change binary** from
`.snapshot_pre97/` against the same oracle, rather than reasoning about the diff.

### THE BIGGER FINDING — `NAME-DIFF` IS UNSOUND AS A SAFETY GATE
Because of that first-match ordering, `NAME-DIFF` does not mean "files that lost an access". It
means **"files that lost an access AND had no loop difference"** — a set that *grows as loops get
fixed*. It read **0** while the honest number was **46 files**, one of them
(`Lotus_Interface_Codex`) losing **293 accesses**.

New oracle **`cert/allcats.py`** scores every category independently. New **GATE 6: ACCESS-LOSS**,
baselined at 46, is now the real safety net. `NAME-DIFF` is retained as advisory only.

### Baselines changed — each proven stale by running the PRE-change binary
- `realtrip_same` **150 → 149**: `BindingsUtil` returns DIFFERENT with **both** binaries. It has
  failed since realtrip was pinned to fidelity mode (#96); the baseline was never updated then.
- `NAME-DIFF` **0 → 1**: the unmasking above, proven by identical 149-vs-152 access counts.
- Added `KNOWN_DIFF` to GATE 3 so a **new** behavioural difference still hard-fails while a
  documented pre-existing one does not block. Entry requires a recorded pre/post measurement.

### What did NOT change
**Divergence is byte-for-byte identical** (`BindingsUtil` 32,474 → 37,997 → 44,947 both before and
after; `EE_Interface_Utilities` 52,055 → 63,534 → 79,760). Predicted in the task note before
measuring, and confirmed: **#98-B is a SEPARATE mechanism**, not a symptom of #97.

### Reason
Every number above was measured pre and post with the same oracle, using the snapshot binary as the
control. No baseline was moved without a control measurement.

### Next Step
1. The remaining **28** dropped paths are the excluded classes: **2+ exit** parts (~10 % of parts)
   and parts containing a **return**. Both need `emit_region` to stop laying mutually-exclusive
   paths out sequentially — that is the real underlying defect, and fixing it would also unlock a
   much less conservative promotion rule.
2. Drive **ACCESS-LOSS 46 → 0**. `Lotus_Interface_Codex` (293) is the largest single case and was
   invisible until today.
3. Divergence (#98-B) is untouched and needs its own diagnosis.

---

## 2026-07-28 — #100 THE DEAD TAIL IS REAL CODE LOSS; AND A PROPOSED FIX REJECTED

Second multi-agent diagnosis (4 probes × 3 adversaries). **2 of 4 probes were refuted by their own
adversaries** — the structure did its job. Every surviving claim below was re-measured by the
orchestrator before being recorded.

### THE ANSWER TO THE OPEN QUESTION (was flagged before measuring)
**The dead code IS reachable in the ORIGINAL bytecode. This is real loss, not a faithful
reproduction of DE's own dead code.**
`DecoPreview` proto[3]: `JUMPIF` at insn[82] `@0x01d4` targets `insn[207]` — computed
`0x01d4 + 4 + 161*4 = 0x045c` — which is exactly the block sitting after our emitted
`do return end`. The original branches there; we make it unreachable, and Luau discards it.

**Consequence: GATE 6's 46 ACCESS-LOSS files are a defect count, not an artefact.** The recompiled
scripts really are missing paths that execute in game.

### Established (orchestrator-verified)
- **181 dead-tail sites across 77 files** (first 300, fidelity mode).
- **100 % PRE-EXISTING.** The affected-file set is *identical* between the current binary and
  `.snapshot_pre97/`: delta 0 files, 0 sites. The Proper-part promotion of #99 neither caused nor
  cured any of it.
- Locus confirmed by reading the code: `case sa::RK::Seq` is
  `for (int p : r.parts) emit_region(p, depth);` — parts are emitted unconditionally, in order,
  with no check for a preceding terminal.

### CORRECTION TO #99
#99 recorded that promoting a part in `Lotus_AppearancePreview` "lost 7 accesses". Re-measured:
that loss existed only in the **intermediate build** (the `terminals > 1` guard). With the shipped
`terminals > 0` guard the file has **1 dead-tail site and 0 access loss in BOTH binaries**. The
guard is still correct and still required — but the 7-access figure describes a build that was
never shipped, and should not be quoted as a property of the shipped one.

### REFUTED — an agent claim that would have entered the record as a large false win
An adversary reported *"the pre-change binary had **261** ACCESS-LOSS files, so the #99 fix already
recovered 215."* **False.** Measured twice by the orchestrator with the snapshot binary placed in
`bin/`: **46 before and 46 after.** The 261 almost certainly comes from running the snapshot binary
from a directory **without `luau-compile.exe` beside it**, so every recompile failed and every file
read as a loss — PITFALLS A1, a tool that cannot run reporting a plausible number.
**#99's claim stands: ACCESS-LOSS was unchanged at 46.**

### RECOMMENDED FIX — REJECTED
The synthesis proposed: *in `case sa::RK::Seq`, after emitting a part whose last block is a terminal,
**break** — the remaining siblings are unreachable.*

**Rejected. E4, in the same report, proves those siblings ARE reachable.** Breaking would stop
emitting them at all: the source would no longer even contain the code, the recompile would lose
exactly what it loses today, and **the dead-tail count would fall to 0 while ACCESS-LOSS did not
move.** That is a change that improves the metric by deleting the evidence. Precisely what the
gates exist to prevent (PITFALLS E4).

### The structural objection that needs settling first
`structan.h` forms a Seq only when `one_succ(n, m) && npred(m) == 1`. **If region `n` always
returned it would have no successor and the Seq could not have formed at all.** So one of these
must be true, and they imply different fixes:
- **(a)** the return we emit should be **CONDITIONAL** — the emitter dropped a guard, and the fix is
  in whatever renders that block's terminator; or
- **(b)** the attribution to `Seq` is wrong. The agents' own wording was a *"heuristic"*
  (`dead_tail_attrib.py`), and 179/181 landing in one bucket is what a coarse heuristic looks like.

### Finding
**True** (dead tails are real loss, 181 sites / 77 files, pre-existing, Seq is where parts are
emitted unconditionally). **The proposed remedy is refuted**, and the mechanism that produces an
unconditional return ahead of a reachable sibling is **NOT yet established**.

### Next Step
Settle (a) vs (b) on ONE case, from the bytecode: take a dead-tail site, identify the region kind
actually being emitted (instrument `emit_region`, do not infer from text), and check whether the
original block's terminator is a conditional branch. **Do not implement anything until that returns**
— three hypotheses have already been wrong on this defect family.

---

## 2026-07-28 — #101 THE SINGLE HIGHEST-LEVERAGE LINE IN THE DECOMPILER

Prompted by the strategy question *"is structuring inherently hard, or are we using the wrong tool?"*
Answered by measurement, and it **refuted the approach I proposed first**.

### Literature check
Structuring is a genuinely open problem — Phoenix (USENIX Sec '13), DREAM (NDSS '15), rev.ng (2020),
SAILR (USENIX Sec '24). SAILR's result: the difficulty is caused by **compiler optimisations**
mangling the CFG, *"the cause of most gotos is just 9 compiler optimisations, most found in O2"* —
and the remedy is to be **compiler-aware**. That framing favours us: Luau is a simple, largely
syntax-directed compiler, we HAVE the exact compiler binary, and this project already established
there are **ZERO irreducible protos** in the corpus. So a Proper region is a *missing template*, not
genuine irreducibility.

### HYPOTHESIS (mine): mine templates against `luau-compile.exe`. **REFUTED by measurement.**
`cert/shapes.py` (new) clusters Proper regions by canonical CFG shape. Over 1,500 files:
**3,301 machines → 2,514 DISTINCT shapes.** Top 10 cover **10.9 %**, top 100 cover **24 %**, and
**92.2 % of shapes occur exactly once** (70 % of all machines). A flat long tail — template mining
would need thousands of templates and is a dead end.

**Why:** the shapes are **compositional, not a vocabulary.** Every `and`/`or` adds a shared-join node,
so a function with three short-circuits produces a shape never seen again. Enumerating whole regions
explodes; enumerating PRIMITIVES does not.

### The primitive, quantified
A simulated reducer over 2,335 real Proper regions (700 files):
| rule set | regions fully reduced |
|---|---|
| Seq / IfThen / IfThenElse | 195 = **8.4 %** |
| **+ short-circuit condition merging** | 1,034 = **44.3 %** |
| **newly solved by that one rule** | **839 = 35.9 %** |
*(Caveat: the existing rules were simulated, not called. The baseline should have been 0 % — these
regions are by definition what the real structurer failed to reduce — so 8.4 % is the error bar.)*

### THE FINDING — the merge already exists, and ONE LINE gates it
`src/m6d_cmd.h:70` already collapses short-circuit chains, and `emit.h`'s `cond_of` already renders
`a and b or c` from `Node::chain` / `chain_and`. **The machinery is built.** It is gated by:
```cpp
if (F.first != F.last) continue;   // F must be a PURE TEST
```
Instrumented (`RENOVICE_SCDBG`), over 700 files:
| outcome | count |
|---|---|
| MERGED (rule fires) | 2,391 |
| **BLOCKED by the pure-test rule** | **39,215** |
| blocked by `F.preds != 1` | 13,587 |
| blocked by shape | 1,741 |

**94.3 % of otherwise-valid short-circuit sites are refused by that one line.** It fires on 5.7 % of
the sites it could apply to.

### Can the rule simply be widened? NO — measured, not assumed.
The comment says hoisting F's statements above B's test is unsound (`t and t.x` indexes nil).
`RENOVICE_SCOPS` dumps what those blocks actually hold (250 files, 47,738 instructions):
| opcode | share | hoistable? |
|---|---|---|
| `0x54` CALL | 18.5 % | **no** — side effects |
| `0x3d` GETFIELD | 16.8 % | **no** — faults on nil |
| `0x46` SETTABLE | 15.3 % | **no** — side effects |
| `0x2d` NAMECALL | 8.0 % | **no** |
| MOVE + LOADK + LOADB + LOADN | **6.8 %** | yes |

A block is hoistable only if **every** instruction in it is safe, so the fully-safe population is far
below 6.8 %. **The pure-test rule is CORRECT and must stay.** A "safe-list" widening is not worth
building.

### What the real fix has to be
F's statements must stay **under the guard**. Two options:
- **(A) Guarded-temp emission** — `local t = a; if t then <F stmts>; t = b end; if t then ...`.
  Sound and structured, but adds instructions the ORIGINAL does not have, so it may *cost* alignment
  even while improving readability.
- **(B) Expression folding (preferred).** If F's statements form a single expression tree whose value
  is used ONLY by F's test, fold them into the condition and emit the flat `a and obj:Method()` —
  which is **what the source actually said**, so alignment should IMPROVE. `src/expr.h` (M6c) already
  does per-block expression reconstruction; the missing piece is a single-use/no-escape check.

### Finding
**True.** One line gates 94.3 % of short-circuit merging; widening it by hoisting is unsound (measured);
the correct fix is expression folding, and most of the machinery already exists.

### Option (B) FEASIBILITY — measured (`RENOVICE_SCFOLD`, 700 files, 39,215 blocked blocks)
| statements in F | share | cumulative |
|---|---|---|
| 1 | 22.4 % | 22.4 % |
| 2 | 17.6 % | 40.0 % |
| 3 | 15.2 % | 55.2 % |
| 4 | 20.8 % | **76.1 %** |
| 11+ | 2.7 % | 100 % |

- **78.9 %** have the tail instruction writing the very register the test reads — the chain
  terminates in the test, which is the shape an expression fold needs.
- **41.9 %** satisfy BOTH (≤3 statements AND tail-feeds-test); **59.7 %** at ≤4 statements.

The spike at exactly 4 (20.8 %) is the `NAMECALL` shape — load self, load arg, call, test — i.e.
literally `a and obj:Method()`. **So option (B) covers roughly 42–60 % of the 39,215 blocked sites,
~19,000 merges that do not happen today.**

### THE IMPLEMENTATION BLOCKER (found by reading `emit_block`, and it is NOT small)
```cpp
ex::reconstruct_block(*ip, n.first, n.last, po, bo);   // emit.h:357
```
`emit_block` reconstructs the **whole range** `n.first .. n.last`. The merge sets `B.last = F.last`,
so after a widened merge B's range spans BOTH blocks and `reconstruct_block` would emit F's
statements **as statements, before the condition** — which is exactly the unsound hoist the
pure-test rule exists to prevent.

**Therefore widening the structurer rule ALONE is not just insufficient, it is actively wrong.**
Option (B) requires `cond_of` to CONSUME F's statement range as an expression and `emit_block` to
skip it. The structurer change and the emitter change must land together or not at all.

### Next Step
Implement (B) as a pair: record each chain element's statement range on the node, have `cond_of`
fold that range via `expr.h`, and have `emit_block` exclude it. Gate on an **escape check** — a
register written in F and read outside it cannot be folded away, and cross-block liveness does not
exist at this point in the pipeline, so it has to be added. Start at `≤3 statements` (41.9 %) rather
than `≤4`; the smaller rule is easier to prove and `cert/dropped.py` + GATE 6 will show whether it
holds before widening.

---

## 2026-07-28 — #102 THE DEAD TAIL IS A SYMPTOM: `IfThen` IS EMITTING WITHOUT ITS `if` WRAPPER

Instrumented `emit_region` directly (`RENOVICE_SEQDBG` / `RENOVICE_SEQTEXT`) rather than inferring
region kinds from emitted text, because a prior diagnosis attributed 179/181 sites to `Seq` using a
self-described *heuristic*.

### Attribution, now from the emitter itself (300 files)
- **165 dead-tail sites in 65 files** — independently close to the 181/77 from the textual scan.
- The containing region is **`Seq`, 100 %**, always with exactly **2 parts**.
- The part that returns (A) is **`IfThen` in 97.6 %** of cases (`IfThenElse` 2.4 %).
- The part left dead (B) is `Basic` 73.9 %, `Seq` 24.2 %.
- A's head has a **renderable condition in 97 %** of cases, with an ordinary conditional terminator:
  `JUMPIF` 49.7 %, `JUMPIFNOT` 18.2 %, `JUMPXEQKNIL` 10.3 %.

### THE ACTUAL DEFECT — a LOST CONDITION, not a dead tail
An `IfThen` emits `if <cond> then ... end`, which cannot leave a bare `do return end` at the OUTER
depth. Printing the emitted text at the moment of failure shows why — `DecoPreview`, lines 378–406:
```lua
      c4v22 = c4v0.DecoPreview        -- 6-space indent
      ...
      c4v22:AttachEntity(c4v24, c4v25, c4v26, c4v27)
      do return end                   -- SAME indent. no `if`, no `end`.
      c4v10 = gRegion                 -- dead
```
**There is no `if` wrapper anywhere in that stretch** (everything at 6 spaces, the enclosing `end` at
4). The `IfThen` region emitted its arm FLAT. So:
1. the guard is **gone** — the body runs unconditionally;
2. its `return` therefore becomes unconditional;
3. everything after it is dead and the compiler discards it.

**The dead tail is the visible symptom of a dropped condition**, which is a far more serious class:
the emitted code takes a branch the original takes only conditionally. This is the same family as the
already-recorded *"compilability is VALIDITY not CORRECTNESS: it hid inverted ifs"*.

### A FOURTH WRONG HYPOTHESIS (recorded deliberately)
`emit.h:835` builds `arms` as `parts[1..]`, so an `IfThen` holding only its head would have EMPTY
arms and emit the head with no wrapper — a clean explanation. **Measured: `aparts == 2` in 97.6 % of
sites, `3` in the rest. Arms are never empty. The hypothesis is FALSE.**
That is the fourth hypothesis refuted in this defect family (after the timeout, the concurrency, and
the `terminals > 1` guard). Every one was plausible and had partial supporting evidence. **The only
thing that has ever settled it is instrumenting the code at the point of failure and printing what
actually happened** — see PITFALLS A8.

### Finding
**True and narrowed, mechanism NOT yet identified.** Established: `Seq[IfThen(2 parts, renderable
condition), B]` emits A's arm without the `if` wrapper, at 165 sites in 65 files. Not established:
*which* path in `emit_region` skips the wrapper.

### ⚠ THE "ROOT CAUSE" BELOW WAS **WRONG** — FIFTH REFUTED HYPOTHESIS (2026-07-29)
The correlation was real: 165/165 dead-tail regions did pass through the `plan_winner` flat path.
**Correlation was not causation.** Both suppression paths (`plan_winner` AND `for_open`) were guarded
to flatten only loop-kind regions, so that a losing `IfThen` would keep its condition. Result:

| | |
|---|---|
| dead-tail regions still reaching ANY flat path | **0** |
| dead-tail sites | **165 — UNCHANGED** |
| dropped paths / ACCESS-LOSS / EXTRA-LOOPS | 28 / 46 / 22 — all unchanged |

The flattening was **INCIDENTAL**. Those regions were flattened *and* had dead tails; removing the
flattening removed neither the tail nor a single lost access. **The `do return end` is emitted from
INSIDE A's own sub-regions, not by A being flattened** — the whole line of attack was aimed one level
too high. Both guards were **REVERTED** (unproven changes must not sit in the loop-dedup machinery,
where ten previous attempts lost code). Tree re-verified: ALL GATES PASS, ALIGNED 113.

**Method note:** the flat-path marking WAS the right technique — it is what proved the hypothesis
false in one measurement instead of shipping it. What failed was reading a 100 % correlation as a
cause. The next probe must instrument **inside** A: mark the emitter site that writes the
`do return end` itself, not the region that contains it.

### ~~ROOT CAUSE FOUND~~ (superseded, kept for the record) — the PLAN/RENDER loop-dedup fix (#93)
Rather than guess a fifth time, every flat-emission path in `emit_region` was marked with a distinct
site id and correlated against the dead-tail sites by region id.

| flat path taken by region A | share |
|---|---|
| **site 1 — `plan_winner` loser suppression** | **100 %** (all 165) |
| (also site 3, post-loop `after`) | 62.4 % |
| (also site 2, `for_open`) | 5.4 % |

`emit.h:733`:
```cpp
} else if (loopkey >= 0 && !plan_winner.empty()) {
    auto wit = plan_winner.find(loopkey);
    if (wit != plan_winner.end() && wit->second != id) {
        for (int p : r.parts) emit_region(p, depth);   // <-- flattens the WHOLE region
        break;
    }
}
```
PLAN/RENDER exists to stop a loop being wrapped twice: several regions may claim the same loop, and
only the winner emits the `for`. **But a losing claimant is not necessarily a loop region.** When the
loser is an `IfThen`, this drops the ENTIRE region — including its own `if <cond> then … end`, which
has nothing to do with the loop. The condition is lost, the body becomes unconditional, its `return`
becomes unconditional, and the tail dies.

**This is the NO-SUPPRESSION rule being violated by the very mechanism written to honour it.**
`M6_TRUTH` §5 rule 1 says *"never remove a loop wrapper from around already-placed code"*; here we
remove **more than** the loop wrapper. The rule needs restating: **suppress only the LOOP WRAPPER,
never the region's own conditional structure.**

### THE FIX
In the loser branch, flatten only when `r.kind` is a loop kind (`SelfLoop` / `While` / `NaturalLoop`).
For `IfThen` / `IfThenElse`, fall through to the normal conditional emission (`emit.h:~896`) so the
`if` is still emitted — just without opening the `for`.

Risk to watch: the loser may be a region that legitimately holds only the loop, in which case
emitting its condition could re-introduce a duplicate wrapper. `cert/backedge.py` (EXTRA-LOOPS) is
the oracle sensitive to that, and `cert/dropped.py` + GATE 6 cover the loss side.

### Finding
**True, and fully attributed.** 165 sites, 65 files, 100 % through one code path, whose purpose is
loop de-duplication and whose side effect is dropping unrelated conditions.

### Next Step
Implement the kind-guard above. Verify: `cert/dropped.py` 741 → lower, `cert/allcats.py` ACCESS-LOSS
46 → lower, `cert/backedge.py` EXTRA-LOOPS must NOT rise, `cert/gates.py 300 150` green.

---

## 2026-07-28 — #103 DIVERGENCE SOLVED: THE FLAT LOCAL DECLARATION IS A RATCHET, AND IT IS TERMINAL

Multi-agent diagnosis (4 probes × 3 adversaries, **4/4 survived, 0 refuted**), with every
load-bearing claim re-measured by the orchestrator before being recorded here.

### THE MECHANISM
1. `emit_function` declares **every** register the body mentions as one flat upfront
   `local v1, v2, … vN` header (`emit.h:1232`).
2. Luau places every call frame at **TOP-OF-STACK** — the first register above all declared locals.
   Declaring N locals therefore pins every call above them.
3. A self-reassigning call `vX = vX(vY)`, which our emitter produces constantly, can no longer be
   done in place. Luau must **spill**: `MOVE r31←r21`, `MOVE r32←r22`, `CALL A=31`, `MOVE r21←r31` —
   **1 instruction becomes 4**.
4. Those spill registers appear in the next decompile as new `vN`, get swept into the flat
   declaration, and **raise the ceiling again**. Growth is linear per cycle, forever.

### ORCHESTRATOR-VERIFIED (not taken on trust)
| claim | verification |
|---|---|
| `maxstack` ratchets +20/cycle on `Lotus_Docs_Loadouts` | **63 → 83 → 103** — reproduced exactly |
| NEWTABLE orphans accumulate | empty `= {}` **9 → 10 → 11**, valued `= {v…}` stable at **1** |
| `MOVE` = `0x14`, `LOADNIL` = `0x0d` | confirmed in `OPCODE_MAP.md` (MOVE is the corpus's most frequent op, 364,632) |
| `LOCAL_BUDGET = 150` and a `vT[n]` rewriter exist | `emit.h:1239` and `:1249` |

*(Correction to my own earlier note: I had guessed `0x17` was MOVE in an ad-hoc table. It is `0x14`.
The guess was never used for anything, but it was wrong — verify opcodes against `OPCODE_MAP.md`.)*

### SECOND, INDEPENDENT MECHANISM — the NEWTABLE orphan
A filled constructor is emitted TWICE: once as `vA = {}` for the NEWTABLE instruction and again as
`vA = {v1, v2, …}` for the SETLIST. Re-decoding keeps both, so the empty precursor accumulates
(+109/cycle on BindingsUtil, +1/cycle on Loadouts) while `SETLIST` itself stays stable at 140.
A fix must guard on **SETTABLE as well as SETLIST** — the keyed-table case does the same thing.

### IT IS TERMINAL, NOT MERELY UNTIDY
`emit.h:1240` — once `decl.size() > 150`, the emitter **blindly textually substitutes** every `vN`
token with `vT[n]`, including tokens in **binding positions**. Lua requires *names* there, so it
emits:
```lua
for vT[149], vT[150] in vT[146], vT[147], vT[148] do   -- SYNTAX ERROR
```
`EE_Types_ScriptCommands_JSON` reaches `maxstack=158` at cycle 10 and **can never be recompiled
again**. Because maxstack ratchets on 87–100 % of protos in every file measured, **every script
eventually crosses the budget.** The toolchain does not merely bloat — it destroys its own input.

### Also established
- **0 / 90 files are idempotent at cycle 2.** Byte series, `EE_Interface_Utilities`:
  52,055 → 63,534 → 79,760 → 98,449 → 119,599 → 143,219.
- **All logic opcodes are stable.** `CALL` 706/706/706/706, and RETURN/BRANCH/JUMP/GETIMPORT/NAMECALL
  likewise. Only `MOVE`, `LOADNIL` and `NEWTABLE` grow — so **behaviour is preserved; only size
  diverges.** That makes this a lesser problem than a semantic drift, but a fatal one all the same.
- 99.5–99.8 % of added source lines are attributable to MOVE chains and nil-inits.
- **State machines are NOT the cause** (confirming #99's prediction): they vanish after cycle 1, yet
  the per-cycle growth rate is unchanged from cycle 2 onward. `SporePrimer` even *shrinks* 24 % on
  the first trip, then grows at ~1.25× like everything else.
- 14 protos in `EE_Interface_Utilities` are stable — all have **CALL count 0**. A genuine
  counterexample that confirms the mechanism rather than contradicting it: no calls, no spills.

### Finding
**True.** Two independent mechanisms, both verified, one of them terminal.

### THE RECOMMENDED FIX IS INSUFFICIENT — measured before implementing, and REFUTED
The synthesis (which survived all three adversaries) recommended: *declare only registers that cross
a block boundary; let the rest stay block-local so `maxstack` stops ratcheting.* Probed with
`RENOVICE_DECLDBG` before writing any of it.

**Static population (400 files, 37,218 protos):** 254,488 registers declared function-scope; 101,110
(39.7 %) confined to a single basic block. But that headline is inflated by single-block protos,
where there is no narrower scope to move to — **restricted to protos with >1 block it is 17.5 %**.
Worse, the protos closest to the fatal budget (`ndecl ≥ 100`) are **100 % single-block with
`nblocks = 1`**: giant straight-line functions where narrowing is impossible. **The fix cannot help
the files that actually die.**

**And the static population is the wrong question — the ratchet is about the registers ADDED each
cycle.** Measured per cycle, testing both "fits in one basic block" and the fairer "fits in any
proper SUB-REGION" (a loop body or if arm, which is a real Lua scope and can hold its own `local`):

| file | cycle | ndecl | narrowable | Δ declared | Δ narrowable |
|---|---|---|---|---|---|
| Loadouts | 0 | 112 | 82 (73.2 %) | | |
| | 1 | 154 | 48 (31.2 %) | +42 | **−34** |
| | 2 | 194 | 36 (18.6 %) | +40 | **−12** |
| BindingsUtil | 0 | 368 | 190 (51.6 %) | | |
| | 1 | 590 | 208 (35.3 %) | +222 | +18 (**8 %** of growth) |
| | 2 | 806 | 282 (35.0 %) | +216 | +74 (**34 %** of growth) |

**On `Loadouts` the narrowable count FALLS in absolute terms while declarations grow.** The added
registers span the whole function; scope-narrowing reaches at most ~1/3 of the growth on
BindingsUtil and essentially **none** of it on Loadouts. **The ratchet survives the recommended fix.**

### A SECOND FINDING, visible in that table
`narrowable` falls **73 % → 31 % → 19 %** on Loadouts and **52 % → 35 %** on BindingsUtil. The
emitted code gets **FLATTER every cycle** — fewer nested regions, so fewer registers fit inside one.
**Round trips progressively destroy STRUCTURE**, not just add bulk. That links this defect to #97
(state-machine flattening) and #102 (lost `if` wrappers): each cycle the output is less structured
than the last, which is why re-decompiling never recovers.

### What the fix actually has to be
The root cause is that we emit **one named local per distinct register**, which forbids the register
reuse Luau would otherwise do — so `maxstack` becomes "distinct registers ever used" instead of
"peak simultaneous liveness". The real fix is **decompiler-side register allocation**: compute live
ranges and give registers with DISJOINT ranges the SAME name. Fewer locals → calls fit below the
frame → no spills → no ratchet.

That is a bigger change than narrowing, and it needs the cross-block liveness that #27 also wants —
so the two share a prerequisite and should be sequenced together.

### HOW URGENT IS THIS REALLY? — scanned the whole corpus before prioritising
| | |
|---|---|
| corpus files where the `vT` spill rewriter fires **today** (cycle 0) | **37 / 5,386** |
| files with `vT[...]` in a **binding position** today (the syntax error) | **0** |

**The terminal failure is not live.** It needs ~10 round trips to appear; the 37 files that already
use the `vT` path emit valid Lua. So the practical severity of #103 is much lower than "terminal"
suggests: at the cycle counts a real edit workflow reaches (1, occasionally 2), this is **size bloat
of ~17–22 % with behaviour fully preserved** — every logic opcode is stable.

**This demotes #25 below #97 and #102**, which produce WRONG CODE on the very first decompile:
| defect | wrong at cycle | scale |
|---|---|---|
| #102 lost `if` wrapper (condition dropped) | **0** | 165 sites / 65 files |
| #97 dropped code paths | **0** | 741 paths / 385 files |
| #103 divergence | ~10 (terminal); size only before that | all files |

*(Correcting my own earlier recommendation, which called #25 highest priority because it "permanently
destroys files". It does — but only after roughly ten cycles, which no realistic workflow reaches.)*

### Next Step
1. **#102 first** — a dropped condition makes the emitted code take a branch the original takes only
   conditionally, on the first decompile. That is the worst thing in the tree.
2. Build the **live-range analysis** (#28) once; shared prerequisite for #25 and #27.
3. Make the `vT` rewriter **binding-aware** (`emit.h:1240`) as defensive work — 0 files affected
   today, so it is not urgent, but it converts a permanent failure into a recoverable one.
4. Add an **idempotence gate**: bytes(recompile ×2) == bytes(recompile ×1).

*(Note: `bin/derecomp_dbg.exe` is a scratch build for this instrumentation, produced with the same
compiler and flags as `build.bat`. `bin/derecomp.exe` is unaffected — the Seq-case edit is an indexed
loop with an env-gated `fprintf`, emission order unchanged.)*

---

## 2026-08-20 — #104 SHIPPED: `0x20`/`0x41` NOT-BIT POLARITY; `BindingsUtil` 149/150 -> 150/150

### Hypothesis

The only behavioral difference was caused by `src/emit.h` interpreting bit 31 backwards for native
number/string constant comparisons (`0x20` JUMPXEQKN and `0x41` JUMPXEQKS).

### Discriminating pre-change result

The existing native-opcode ground truth was run directly, rather than inferring from `BindingsUtil`:

- number `0x20` equality/inequality: **0/2 SAME**;
- string `0x41` equality/inequality: **0/2 SAME**;
- boolean `0x34` equality/inequality controls: **2/2 SAME**;
- nil `0x3a` equality/inequality controls: **2/2 SAME**.

Exactly the suspected families failed; a blanket flip would have broken the four controls.

### Raw `BindingsUtil` proof

Proto 17's original comparison is `op=0x41 aux=0x00000003`. The old read path emitted
`if binding == "" then`; fidelity-mode recompilation changed the aux to `0x80000003`; the second
read emitted `if binding ~= "" then`. Traces were 506 vs 510 events, with the second form making
additional `gFlashMgr.Name__6bb2f462` and `Engine.IsSteamInput` calls.

`one_cond` and `invert_cond` now use the Luau/DE NOT-bit convention consistently: clear means branch
on equality, set means branch on inequality. IR diagnostic rendering was corrected for all four
JUMPXEQK operand families. `cert/cmpk_polarity.py` permanently gates both polarities for number,
string, boolean, and nil and is integrated as consolidated Gate 0.

### Post-change result

- native comparison ground truth: **8/8 SAME**;
- `BindingsUtil`: **510 vs 510 events, SAME**;
- emitted condition: `binding ~= ""`;
- recompiled raw comparison: `0x41 aux=0x00000003` (stable);
- behavioral corpus sample: **150 SAME, 0 DIFFERENT, 0 timeout**;
- ACCESS-LOSS: **46 -> 45**;
- ALIGNED/loop/order/prototype/back-edge/dropped metrics: unchanged.

The known `BindingsUtil` exception was deleted and baselines were ratcheted to 8/8, 150/150, and
ACCESS-LOSS <=45. The complete suite passed twice: first to measure the improvement against the old
baseline, then against the stricter baseline with no behavioral exception.

### Correction to #98-D

#98 correctly proved that the 72 extra `0x20` instructions were synthesized state-machine guards,
so the **opcode-count explosion** was not a const-opcode defect. Its broader phrase *"the
const-compare opcodes are innocent"* was too strong: it did not test the isolated `0x41` NOT-bit
round trip above. The state-machine/drop defects remain real and separate.

### Finding

**True and shipped.** Full evidence and hashes are in
`../RESEARCH/DE LUAU TRANSLATOR/CMPK_POLARITY_FIX_2026-08-20.md`.

### Next Step

Add the explicit two-cycle/ten-cycle idempotence gate before the next emitter change.

---

## 2026-08-20 — #105 IDEMPOTENCE GATE ADDED; DIVERGENCE REDUCED 92.89%, NOT YET COMPLETE

### Hypothesis

The #103 ratchet contains several independently removable compiler-artifact feedback loops before
the larger value-live-range allocator is attempted: duplicate empty table constructors, explicit
copies of the function-local LOADNIL prologue, CALL/setup/result MOVEs, and contiguous for-frame
MOVEs.

### Pre-change discriminator

`cert/idempotence.py` now records exact source/bytecode hashes, size, proto count, every proto's
maxstack, and full opcode histograms for two and ten cycles. On the deterministic historical sample:

- strict cycle-two fixed points: **0/90**;
- byte growth: **+343,753**;
- maxstack-sum growth: **+10,853**;
- MOVE growth: **+55,081**;
- LOADNIL growth: **+28,328**;
- NEWTABLE growth: **+1,031**;
- execution errors: **0**.

### Fixes proven separately

1. The first SETLIST now consumes a preceding unobserved empty NEWTABLE assignment instead of
   rebinding the register. Loadouts stays `9 -> 9` NEWTABLEs through ten cycles; positive sampled
   NEWTABLE drift is zero.
2. Entry LOADNIL instructions for non-parameters are omitted when the function-scope `local` header
   already supplies exactly the same nil initialization. Later semantic nil writes are untouched.
3. Pure compiler setup MOVEs are coalesced into CALL, CONCAT, SETLIST and RETURN operands; immediate
   single-result and sequential multi-result CALL MOVEs retarget the original assignment.
4. A proven contiguous `MOVE A/B/C` triplet consumed by a for header is rendered directly in the
   header and suppressed only after that region wins loop ownership/deduplication.

### Post-change result

- strict cycle-two fixed points: **8/90**;
- byte growth: **+24,432** (**92.89% lower**);
- maxstack-sum growth: **+2,002** (**81.55% lower**);
- MOVE growth: **+3,391** (**93.84% lower**);
- LOADNIL growth: **+2,306** (**91.86% lower**);
- proto-count delta: **0**;
- execution errors: **0**.

The final default binary passes the unchanged full semantic release suite: polarity 8/8, all nine
focused access counts exact, ALIGNED 113, ACCESS-LOSS 45, DROPPED 28, and realtrip 150/150 with zero
timeouts/differences. No baseline was relaxed.

### Negative result: physical-register coloring is not the final allocator

An opt-in cross-block live-in/live-out analysis with interference coloring reduced stack totals but
regressed exact fixed points **8/90 -> 1/90**. Compiler allocation changes physical register numbers
between cycles, so one name per physical register is not canonical. The required next unit is a
definition/value live range with merge/phi handling. `RENOVICE_LIVERANGE` remains experimental and
off by default.

### Finding

**True for the four concrete feedback loops and shipped; false that register-level coloring is
sufficient.** The strict goal remains open: 82/90 sample files and all five ten-cycle stress files
still drift, with several showing loop/control/prototype opcode changes rather than allocation-only
growth.

Full measurements, hashes, rejected-hypothesis evidence, and exact next work are in
`../RESEARCH/DE LUAU TRANSLATOR/IDEMPOTENCE_GATE_AND_DIVERGENCE_FIXES_2026-08-20.md`.

---

## 2026-08-20 — #106 LOST CONDITIONALS 165 -> 3; FINAL THREE REQUIRE LOOP-ESCAPE STATE

### Hypotheses and results

1. **True:** a losing `IfThen`/`IfThenElse` plan claimant still needs normal conditional emission.
   Promoting that behavior reduced render-pass lost-condition sites **165 -> 13**.
2. **True:** greedy interior scans mutated the working head block before the conditional handler.
   Saving/restoring the region's original condition block reduced **13 -> 3**.
3. **False:** prefer the outermost claimant globally. It fixed two focused files but regressed the
   corpus **3 -> 62 sites in 49 files**.
4. **False as a global fix:** always use `Region::head`; none of the final class was repaired.
5. **False:** forced ownership emission repaired none of the last three.

### Original-code proof

In `Lotus_Interface_Components_DecoPreview.lua_B`, original proto 3 instruction 82 branches to
instruction 207, immediately after the return at instruction 206. The old source emitted that return
as unconditional and left `gRegion:DestroyObject(...)` after it, so recompilation deleted an original
cleanup path. Return/region/CFG tracing proved that the conditional region existed but its wrapper was
suppressed. The repaired source preserves the guard and cleanup.

### Current result

- lost conditions: **165 -> 3**;
- `ALIGNED`: **113 -> 117**;
- `ACCESS-LOSS`: **45 -> 16**;
- clean structural files: **158 -> 161**;
- lost-loop file class: **92 -> 88**;
- behavior: **150/150**, zero differences/timeouts;
- dropped paths: unchanged at **28**;
- exact idempotence: unchanged at **8/90**, ten-cycle **0/5**.

Idempotence byte drift worsened **+24,432 -> +39,062** because real guarded code was restored. This
negative is accepted as a semantic prerequisite, not hidden or called an idempotence improvement.

The remaining files are `ControllerLayout`, `Dojo_InWorldTransmissionController`, and `HudRedux`.
Their paths escape nested/multi-exit loops and cannot be represented by choosing a different single
region owner. Next implement explicit normal-completion/break/continue/function-exit state, prove
**3 -> 0** on those specimens, and rerun every release gate.

Full evidence:
`../RESEARCH/DE LUAU TRANSLATOR/LOST_CONDITION_FIX_2026-08-20.md`.
