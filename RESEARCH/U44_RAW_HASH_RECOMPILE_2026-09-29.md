# U44 raw-hash recompile path — 2026-09-29

Build under test: Warframe 2026.09.24.13.29 client, content 44.0.2 (2026.09.28.13.06), native-name
hash seed `768e5ed0`. Stock modules were extracted read-only from the Steam cache
(`B.Font.toc` SHA-256 `10cced56…9dfe`, 5,473 `.lua` entries) with
`U44_RAW_HASH_RECOMPILE_2026-09-29/tools/extract_u44_stock.py`. Nothing was written to the game
install; nothing was deployed.

## Hypothesis

`recompile-u44` output for U44-decompiled source loses the stock hash class of native names because
(a) U44 bytecode was decompiled with the U43 namebase and no hash-class metadata, so native names
became opaque `Name__<u44 hash>` spellings, and (b) the recompiler treated every `__<hex>` suffix
as a U43 alias and every metadata-less field read as a string. A per-prototype comparison of hash
and string constants against stock detects it; the source fixed point cannot.

**Result: TRUE.**

## Evidence for the defect

`/Lotus/Interface/OmegaRerollSelection.lua` (content key 477479ee5209dc94, stock SHA-256
`cdecc069…1283`):

| candidate | CONST-ID protos | hash/string class swaps |
|---|---|---|
| legacy: research `decompile-mod` source → baseline `recompile-u44` + identity alias rows | **43/77 FAIL** | **73** |
| research workaround control (`build_u44.py`) | 77/77 PASS | 0 |
| new path: `decompile-mod-u44` → `recompile-u44` (first pass) | **77/77 PASS** | 0 |
| new path: same research legacy source through `recompile-u44-raw` | 77/77 PASS | 0 |

The legacy candidate turned `GETFIELD H:d339ce1f` into `GETFIELD S:"Name__d339ce1f"` and hashed
`_T` members (`_T.SetButtons` → `GETIMPORT1 H:5ff46bcc`) because the `_T` root was spelled
`Name__9828c6d9`. It still reached a source fixed point, because that gate compares our output
with itself.

## Root causes

1. **Wrong namebase for U44 input.** The namebase is keyed by U43 hashes. Every row is a verified
   preimage (`FNV(name, 7e5af8e9) == hash` for 922,276/922,276 rows), so the name is
   build-independent, but a U44 hash only resolves if rehashed with `768e5ed0`. A U44 hash that
   collides with an unrelated U43 hash would even render a wrong name that recompiles to a
   different hash.
2. **No hash-class metadata from `decompile-mod`.** The M6e module emitter writes no
   `RENOVICE_HASH_FIELD/GLOBAL` directives, so every hashed field read or hashed global recompiles
   as a tag-3 string.
3. **Namespace confusion in `recompile-u44`.** `X__<hex>` suffixes were always looked up as U43
   aliases; U44-decompiled suffixes are already U44 hashes. Identity alias rows papered over this.
4. **`_T` recognized only by spelling.** `Name__9828c6d9` (= `FNV("_T", 768e5ed0)`) was not treated
   as the shared-table root, so its members were hashed.
5. **Two transcoder rules not expressible from source** (found by the new gate on the full corpus):
   GETIMPORT members of engine-injected script properties (`EndColor.x`, `floatTime.minValue`,
   `PurgeFlashTint.red`) and of string-keyed roots (`package.seeall`) are tag-3 strings in stock;
   and a constant shared by a string-class GETTABLEKS and a hashed import member was redirected to
   the hash duplicate for *every* GETTABLEKS use (name-level instead of instruction-level remap).

## Fix (toolchain, generic; no module or ability branch)

- `decompile-mod-u44`, `semantic-ir-render-module-u44`, `ir-u44`: lower U44 opcodes to canonical
  U43 opcodes in memory (`change_build_profile(bytes, false)`, hashes untouched) through one
  input hook (`read_de_input`); resolve names through the namebase rehashed with the U44 seed
  (921,979 names; 102 ambiguous U44 hashes and 93 suffix-shaped names stay raw); emit
  `-- RENOVICE_NAME_HASH_SEED: 768e5ed0`, `RENOVICE_HASH_GLOBAL`, `RENOVICE_HASH_FIELD` and
  `RENOVICE_IMPORT_CLASS: path=HS..` for import paths whose classes differ from the default rule.
  A spelling used both hashed and string-keyed in one module renders its hashed uses as
  `name__<hash>`; non-identifier hashed names render as `Name__<hash>`. Mixed/non-identifier
  hashed metadata fails closed.
- `recompile-u44`: a source that declares the U44 seed is a raw-hash source. Suffixes pass through
  verbatim (`de::raw_source_hashes`), suffix-spelled global/field reads keep the hash class,
  `Name__9828c6d9` is `_T`, import-class overrides are honored, and dual-use constants are remapped
  per instruction class. A raw-hash source plus an alias map is rejected, and the U43 `recompile`
  rejects a source declaring the U44 seed. `recompile-u44-raw` applies the raw contract to older
  undeclared U44 sources. Without the declaration, `recompile-u44` keeps its U43-alias contract.
- `const-identity <stock> <candidate> [--u44]`: the new gate. Per prototype index it compares the
  multiset of tag-1 native-name hashes (payloads 0/1 are booleans, reported separately), the
  multiset of tag-3 strings, and the set of name-key uses by access class (GLOBAL = GETGLOBAL or
  import root, FIELD = GETFIELD or import member, SETGLOBAL, SETFIELD, NAMECALL) with key class.
  It counts hash/string class swaps and attributes differing code bytes by canonical op/field.
  `cert/u44_rawhash_roundtrip.py` runs decompile → recompile ×2 (determinism) → fixed point →
  compiler-closed fixed point → CONST-ID → byte identity over a directory.
- `u44-rawhash-selftest` (15 offline checks) runs in `build.bat`.

Files: `src/u44_raw_cmd.h` (new), `src/de_namehash.h`, `src/transcode.h`, `src/main.cpp`,
`src/m6e_cmd.h`, `src/semantic_ir/command.h`, `build.bat`, `profiles/u44/README.md`,
`cert/u44_rawhash_roundtrip.py`, tools under `U44_RAW_HASH_RECOMPILE_2026-09-29/tools/`.
Build: g++ 15.2.0 `-O2 -std=c++17 -Wall -Werror` (and `-Wextra` for the shared-string verifier):
zero warnings, zero errors. Final `derecomp.exe` SHA-256
`c1672d8d70e44bf7001a68f873f229714f5afdefb0b93c8558b6abb49e187c58` (baseline HEAD build
`09b2bf39…9d60`, reproducible and identical to the previously installed binary).

## Results — full current corpus (U44)

Denominator: 5,473 `.lua` modules in the U44 cache. 13 of them are byte-identical to the U43 corpus
(stale U43-format debug/ImGui bytecode: `EE_Scripts_ImGui*`, `Lotus_Scripts_Cmds_*`,
`SetVortexWindPerZone`, `HighwayVehicle`, `CommandExample`). They are not U44 bytecode; the U44
path fails them loudly (unsupported opcode 86/87/90 or CFG failure), never silently. U44-format
denominator: **5,460**.

Run: `derecomp.v3` (SHA-256 `5295a438…2b16`; differs from the final binary only in the gate's
access-class normalization and one `ir-u44` diagnostic line), 11 workers, 1,904 s. Failures were
then re-gated with the final binary (`tools/classify_failures.py`).

| measurement | result |
|---|---|
| decompile (`decompile-mod-u44`) | 5,459 / 5,460 (1 failure: `Jade_Abilities_Chaos`, `map::at`; also fails on U43) |
| recompile (`recompile-u44`) | 5,459 / 5,459 |
| compile determinism (two recompiles byte-identical) | 5,459 / 5,459 |
| one-pass source fixed point / bytecode fixed point | 2,120 / 2,130 of 5,459 (U43 standard path: 2,098 / 2,108 of 5,385) |
| compiler-closed fixed point within 5 passes | 5,372 / 5,459 (U43: 5,301 / 5,385) |
| **CONST-ID first pass (final gate)** | **5,330 / 5,459 PASS** |
| **hash/string class swaps** | **0 modules, 0 swaps** |
| CONST-ID residual: prototype-count differs | 71 (69 of the same modules differ on U43; 2 modules are new in U44) |
| CONST-ID residual: same prototype count, other constants | 58 (40 also show non-swap differences on U43; the other 18 were re-run individually and lose the same stock strings on U43, e.g. the dead tail `"EncounterScheduler.lua Complete!"` after an endless loop, or `""`) |
| exact original-byte identity (first pass) | 0 / 5,459 (not required; upstream Luau codegen differs) |
| metadata emitted | seed 5,459 modules; HASH_FIELD 3,004 modules / 23,794 names; HASH_GLOBAL 349 / 659; IMPORT_CLASS 619 / 1,166 paths |

No residual CONST-ID failure is a native-name/hash-class failure. All residuals are decompiler
structure classes that the U43 path shows on the same modules (2 prototype-count modules are new in
U44 and have no U43 counterpart). Evidence: `U44_RAW_HASH_RECOMPILE_2026-09-29/evidence/`.

### OmegaRerollSelection control (final binary)

First pass: 77/77 prototypes, native names identical, strings identical, name-key uses identical,
deterministic. Compiler-closed at pass 2 (the known `~= K` comparison normalization); the closed
bytecode (SHA-256 `a7ec7f3a…c323`, 43,000 bytes) is CONST-ID identical to stock and to the research
control candidate, and its annotated `ir-u44` listing is identical to the control's. The 79
differing bytes versus the control are all the C operand of GETFIELD (`3d.C:79`): the inline-cache
slot hint the upstream compiler derives from the source spelling (`SetButtons` vs
`Name__d339ce1f`). 27 metadata lines; opaque names fall from 158 (legacy) to 17.

## U43 behavior unchanged

- Full-corpus A/B, baseline HEAD binary vs final binary, 5,386 U43 modules
  (`tools/u43_ab_identity.py`): `decompile-mod` sources identical **5,386 / 5,386** (1 fails on
  both), `recompile` bytecode identical **5,385 / 5,385**.
- Selftests: transcode-global, shared-string verifier, closure-index, semantic-IR (140/140),
  lowering (22/22), readable (13/13), closure-map smoke (identical TSV), u44-rawhash (15/15).
- `python cert/gates.py 300 150` with the final binary: **ALL GATES PASS** (ALIGNED 211,
  NAME-DIFF 0, realtrip 150/150, DROPPED 0, ACCESS-LOSS-TOTAL 0, DEADTAIL 0, semantic gates
  22/22, 150/150, 11/11, NAMECALL 11/11). The same run with the baseline binary produced an
  identical results JSON apart from binary identity fields (`evidence/gates-final.json`).
- New behavior is reachable only through a source seed declaration, `recompile-u44-raw`, an
  explicit `RENOVICE_IMPORT_CLASS` directive, or the `*-u44` decompile modes.

## Pre-existing U43 finding (not changed here)

The same gate on the **U43 standard path** (`decompile-mod` → `recompile`, baseline binary, full
5,386-module corpus) fails CONST-ID on 3,256 / 5,385 modules; **3,240 modules carry 39,749
hash/string class swaps** (GETFIELD/GETGLOBAL/SETGLOBAL hashed in stock, strings after the round
trip, plus the dual-use and import-member rules above). The certified 360/360 fixed point and
NAME-DIFF 0 cannot see this. Repairing it changes U43 output, so it was left for a separately
authorized change: emit the same metadata from `decompile-mod` and enable instruction-level
dual-use remapping for U43 sources, then re-baseline the release gates.

## Limitations

- CONST-ID compares prototype-by-index constant multisets and key-use sets. It does not compare
  instruction order, values of numeric constants, or control flow; it is a name/constant-class
  gate, not a behavioral proof. Booleans are reported but not in the verdict.
- The compiler-closed CONST-ID count (5,217 / 5,372 with the v3 gate) was not re-gated with the
  final access-class normalization.
- `semantic-ir-render-module-u44` output is a readable rendering, not a byte-fidelity round trip:
  its recompile adds renderer capture accesses (as on U43); no stock name is lost on the control.
- 102 ambiguous U44 hashes and all hashes absent from the namebase stay `Name__<hash>`
  (50,458 distinct raw spellings summed over modules).
- No live in-game load or behavior was tested. Static identity does not prove gameplay.

## Rejected designs

- Per-module identity alias rows (research workaround): works for one module, requires external
  preprocessing, and keeps the namespaces conflated.
- Rehashing `Name__<hex>` spellings as strings or treating them as U43 aliases in U44 sources.
- Using the U43 namebase for U44 input (collision risk; wrong names).
- Enabling instruction-level dual-use remapping for all sources (would change U43 output).

## Next step

Authorize the U43 metadata repair above, then extend `cert/gates.py` with a CONST-ID gate so
future release gates catch hash-class loss directly.
