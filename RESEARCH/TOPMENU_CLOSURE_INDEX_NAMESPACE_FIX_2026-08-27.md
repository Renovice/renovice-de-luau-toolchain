# TopMenu closure-index namespace fix — 2026-08-27

## Shipped result

The `derecomp ir` command no longer prints an ambiguous flat-looking
`NEWCLOSURE ... proto=N` label when `N` is actually a child-list index.

Before:

```text
NEWCLOSURE R157 <- closure(proto 132)
```

This presentation allowed child slot 132 to be mistaken for global prototype
132. In the current TopMenu those are unrelated functions.

After:

```text
NEWCLOSURE R157 <- closure(child[132] -> proto[349])
DUPCLOSURE R157 <- closure(const[178] -> proto[353])
```

The operand namespace and resolved global target are now both explicit.

## Hypotheses and verdicts

| Hypothesis | Evidence | Verdict |
|---|---|---|
| `NEWCLOSURE.Bx` is a flat/global prototype index | DE `Proto::kids`, upstream Luau contract, TopMenu parent/child resolution | **FALSE** |
| `NEWCLOSURE.Bx` indexes the current prototype's child list | `kids[Bx]` resolves all 5,386 corpus files with zero invalid operands | **TRUE** |
| `DUPCLOSURE.Bx` uses the same namespace | tag-6 closure constant resolves its global prototype | **FALSE** |
| Ambiguous IR output contributed to the U17 TopMenu hook error | old output showed child slot 132 as “proto 132”; resolved output identifies proto 349 | **TRUE** |
| Fixing the label changes bytecode/decompilation semantics | change is limited to IR annotation and validation; all consolidated gates remain green | **FALSE** |

## Code changes

- `src/main.cpp`
  - `NEWCLOSURE` validates `Bx < kids.size()`;
  - valid output is `child[index] -> proto[global]`;
  - out-of-range operands fail closed and report both the operand and child
    count;
  - `DUPCLOSURE` requires a tag-6 closure constant and prints
    `const[index] -> proto[global]`;
  - new `closure-index-selftest` command covers seven positive and negative
    assertions.
- `src/expr.h`
  - corrected the misleading “direct sub-proto” wording.
- `build.bat`
  - runs `closure-index-selftest` on every certified build.

## Exact TopMenu proof

The upgraded IR resolves the five key module-root closure sites as:

```text
R144 <- closure(child[105] -> proto[295])  BuildMenuOptions
R29  <- closure(child[114] -> proto[313])  PopulateVisibleRows
R150 <- closure(child[117] -> proto[328])  CreateList
R157 <- closure(child[131] -> proto[347])  FinishInitialize
R157 <- closure(child[132] -> proto[349])  Initialize
```

That output makes it impossible to honestly report child 132 as global proto
132 without ignoring an explicit resolved target.

## Verification

Build:

```text
warnings=0
errors=0
closure-index-selftest=7/7 PASS
transcode-global-selftest=PASS
```

Targeted/current TopMenu:

```text
384/384 constant pools re-encode exact
FULL BODY identical: True
five key closure targets resolved exactly
```

Full 5,386-file corpus:

```text
prototypes=82,059
instructions=5,529,447
fully annotated=5,529,447 (100%)
unresolved operands=0
constants resolved=1,622,494/1,622,494
```

Consolidated release gates:

```text
ALL GATES PASS
ALIGNED=127
NAME-DIFF=0
behavioral round-trip=150/150
Semantic IR behavior=150/150
Warframe API trace=11/11
dropped paths=0
access loss=0
native NAMECALL exact=yes
```

Reproducible shipped binary:

```text
bin/derecomp.exe
bytes=5,819,715
SHA256=F29F18C7180C35B5671BDD566C4B53314C2395EEF71298EAEFDD8B24E7F09052
second build SHA256 identical=True
```

## Runtime consequence

The corrected static map identified `Initialize.U14` as the menu builder and
`Initialize.U17` as `CreateList`. The corresponding V5 bootstrapper build then
passed live attachment, row insertion, and six script-toggle actions with zero
Scripts UI failures. The screenshot and runtime excerpt are stored under:

`repos/runtime/bootstrapper-runtime/RENOVICE_DEPLOYMENTS/NATIVE_SCRIPTS_MENU_U14_V5_2026-08-27/evidence/`
