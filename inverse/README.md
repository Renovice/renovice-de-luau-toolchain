# inverse/ — compiler-inverse structurer (side project, started 2026-11-08)

The production decompiler structures control flow GENERICALLY: it builds a block graph, matches
graph shapes (Seq / IfThen / While / NaturalLoop / Proper) and patches every Luau-specific shape it
gets wrong with a targeted rule. 353 switches and several competing emitters later, fixes collide.

This folder takes the other route, the one the table-constructor parser (`expr.h` CtorParser) already
proves: **read the bytecode with a grammar that mirrors the Luau compiler's own code generators**
(`compileStatIf`, `compileStatWhile`, `compileStatRepeat`, `compileStatFor`, `compileStatForIn`,
`compileConditionValue`, `break`/`continue`/`return`). A parse that consumes every instruction and
explains every jump describes source that compiles back to the same control flow by construction.

It compiles into `derecomp` (own commands, own files, nothing in `src/` changes behaviour) so it can
reuse the certified loader/IR (`ir.h`), names, expression rebuilding and the identity gates.

## Milestones

1. `inverse-scan` — coverage only: per prototype, does the statement grammar explain every jump?
   Reports parsed / total and the first unexplained instruction per failing prototype.
2. Statement tree + emission (reusing expr.h block expressions), gated by CONST/CFG/dataflow-ID.
3. Per-module selection: use the inverse output when it passes the gates and the production
   output does not (never lose a passing module).

## Grammar (mirrors Luau Compiler.cpp; DE opcode names)

- straight-line instruction: any non-control instruction
- `return`: RETURN
- numeric for: `FORNPREP A -> X` .. body .. `FORNLOOP A -> body` at X-1 (break = JUMP X,
  continue = JUMP latch)
- generic for: `FORGPREP* -> L` .. body .. `L: FORGLOOP -> body` (exit L+1); degenerate
  `for .. do break end` (FORGLOOP -> L+1) accepted
- while / `while true`: header H .. `JUMPBACK H` at J (exit J+1); the header test is an ordinary
  `if not c then break end` (identical bytecode)
- repeat: body .. conditional backward jump to the start
- if: condition chain (tests whose targets are the false label T, the then-start S or a later test's
  start; `and`/`or` trees) .. then [S, T) .. optional `JUMP E` at T-1 + else [T, E)
- comparison value: `cmp -> k+2; LOADB r,0,1; LOADB r,1,0`

## Measurements

2026-11-08, client 44.1.3, milestone 1 (`inverse-scan`, 80,375 prototypes in 5,068 readable modules):
- first grammar: 74,823 parsed (93.1%)
- + jump threading (a jump that would land on an unconditional JUMP goes straight to its destination;
  `lands()`), numeric-for latch found by its back edge: **78,001 parsed (97.0%)**
- on the production decompiler's 196 CFG-ID failing modules: 181 of their 239 first-failing prototypes
  parse; **142 modules have every failing prototype explained by the grammar**.
Remaining parse failures: IF_CHAIN (conditions crossing JUMPs / NOT-folded tests / an if whose skip
lands past a loop), STRAY_JUMP, FORN_SHAPE.
