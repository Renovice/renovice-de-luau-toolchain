# Generic UI closure-map command — 2026-08-27

## Shipped result

`derecomp.exe` now provides a generic fail-closed command for mapping closure
ownership in any DE `09 03` module:

```powershell
derecomp.exe closure-map input.lua_B closure-map.tsv
```

The output separates parent/global prototype index, instruction index,
`NEWCLOSURE` child-list slot, `DUPCLOSURE` constant slot, resolved global target
prototype, target shape, and every upvalue capture. This removes the need to
infer UI ownership from visually similar functions or an ambiguous flat
prototype number.

## Hypotheses and results

| Hypothesis | Result | Evidence |
|---|---|---|
| The readable source alone is enough to map runtime upvalues | **FALSE** | Aggressive compiler register reuse and separate child/global namespaces caused the earlier U17/U14 mistake. |
| A closure operand can be displayed as one flat prototype index | **FALSE** | `NEWCLOSURE` uses a child slot; `DUPCLOSURE` uses a tag-6 constant slot. |
| Target prototype shape alone uniquely identifies ownership | **FALSE** | Large UI modules contain many closures; the parent site and capture contract are also required. |
| A generic map can be generated from DE-aware IR | **TRUE** | Current TopMenu produced 381 closure sites and 880 captures with zero failures. |
| Invalid capture contracts can be ignored for mapping | **FALSE** | The command fails on invalid target, mode, source range, or target-upvalue count. |

## Output contract

Each TSV row contains:

- parent global prototype and instruction index;
- closure operation and destination register;
- operand namespace and operand index;
- resolved global target prototype;
- target parameters, upvalues, and max stack;
- observed capture count;
- ordered captures as `VAL:Rn`, `REF:Rn`, or `UPVAL:Un`;
- fail-closed status.

The certified build also runs the command against
`cert/cert_all.spawn.lua_B` and retains `cert/closure-map-smoke.tsv` as the
smoke-test artifact.

## Current TopMenu proof

Exact input:

- bytes: `159,749`;
- SHA-256: `D3279EE9A715B90BD078D9F614ACC691FD050E957212723541E5C92DD6639D94`;
- prototypes: `384`.

Map result:

```text
CLOSURE_MAP PASS protos=384 sites=381 captures=880 failures=0
```

The authoritative Initialize row is:

```text
parent proto 383
instruction 663
NEWCLOSURE destination R157
child[132] -> global proto[349]
target upvalues 23
capture 14 = VAL:R144
capture 17 = VAL:R150
```

That independently proves `Initialize.U14` owns the closure created in root
register `R144` (`BuildMenuOptions`) while `Initialize.U17` owns `R150`
(`CreateList`). The runtime TopMenu verifier now regenerates and asserts this
map on every run.

## Verification

- Static C++ build with `-Wall -Werror`: **PASS**.
- Native global lowering self-test: **PASS**.
- Closure-index self-test: **PASS, 7/7**.
- Closure-map smoke fixture: **PASS, 4 sites, 0 failures**.
- Exact TopMenu closure map: **PASS, 381 sites, 880 captures, 0 failures**.
- TopMenu Semantic IR: **PASS, 384/384**.
- TopMenu DE container roundtrip: **PASS, 384/384 constant pools and full body byte-identical**.
- Full release gates: **ALL PASS**.
  - aligned: `127`;
  - name differences: `0`;
  - behavioral roundtrip: `150/150`;
  - Semantic IR behavior: `150/150`;
  - Warframe API trace: `11/11`;
  - dropped paths: `0`;
  - access loss: `0`;
  - native NAMECALL preservation: exact.

## Shipped binary

- Path: `bin/derecomp.exe`.
- Bytes: `5,827,586`.
- SHA-256: `9A30A7520DED0D8A38B988117D299067C0D1CADF8C4CD2029CECE2433B8814B6`.

## Boundary

`closure-map` is an ownership map, not a claim that every rendered source
module is byte-identical after decompile/source-recompile. DE-aware
`de-roundtrip` remains the container identity proof, and Semantic IR/release
gates remain mandatory for source reconstruction.

The live-accepted Generic Settings bridge also closed a focused API-registry
coverage gap: `UIMovie:PushChildMovie(resource)`, the two-argument
`UIMovie:Execute(exportedFunction, value)` form, and `UIMovie:Close()` now have
explicit stock-plus-live contracts. Their broader overloads and exact native
ownership/destruction behavior remain unresolved rather than inferred.
