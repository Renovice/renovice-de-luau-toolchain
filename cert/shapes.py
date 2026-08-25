#!/usr/bin/env python3
"""
shapes.py - CLUSTER PROPER REGIONS BY CFG SHAPE.

THE QUESTION THIS ANSWERS
Every Proper region is a subgraph the structurer could not match to an if/while/for template, so the
emitter falls back to a synthesized state machine (FINDINGS #97). 42.4% of corpus files hit it.

The decompiler literature (SAILR, USENIX Sec '24) finds that structuring difficulty is caused by
COMPILER OPTIMIZATIONS mangling the CFG, not by the structuring algorithm -- "the cause of most gotos
is just 9 compiler optimizations, most found in O2". That applies to GCC/Clang. It does NOT obviously
apply here:
  - Luau is a simple, largely syntax-directed compiler; it does not do those transformations.
  - We HAVE the exact compiler (bin/luau-compile.exe), so we can be maximally "compiler-aware".
  - This project already established there are ZERO irreducible protos in the corpus (the ~9,000 that
    looked irreducible were the phantom-edge bug).

If nothing is genuinely irreducible, then a Proper region is a MISSING TEMPLATE, not hard graph
theory -- and templates are a finite enumeration, because Luau emits a small fixed set of shapes,
one per source construct.

So: how CONCENTRATED are these shapes?
  - Top ~10 shapes cover most of them  -> template mining is days of bounded work. Do that.
  - Flat long tail                     -> the general algorithm is right; keep grinding it.
Answering this BEFORE choosing an approach is the same "look at the distribution first" move that
reframed twenty turns of work earlier (PITFALLS D3).

METHOD (purely textual, no rebuild needed)
The emitted state machine IS the region's CFG, written out: each `if pN == G then ... pN = T ... end`
records an edge G -> T. Extract those, renumber states by rank so two regions with the same shape but
different block ids collide, and count signatures.

A signature looks like:  4:0>1,2|1>3|2>3|3>.
                         ^ state count, then each state's ordered successor ranks.

Usage:
    python cert/shapes.py [N]          # N files, default 1500
    python cert/shapes.py 1500 -e      # also print example file+line per top shape
    RENOVICE_CORPUS=... python cert/shapes.py
"""
import os, re, sys, subprocess, collections
from concurrent.futures import ThreadPoolExecutor

from workspace_paths import corpus_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC = os.path.join(ROOT, "bin", "derecomp.exe")

# Must match align.py / realtrip.py / dropped.py exactly (PITFALLS A7).
ENV = dict(os.environ, RENOVICE_NATIVE_GLOBALS="1",
           RENOVICE_NATIVE="JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,JUMPBACK,AND,OR,ANDK,ORK,SUBK,FORGPREP")

CACHE = corpus_cache(ROOT)
if not os.path.isdir(CACHE) or not any(x.endswith(".lua_B") for x in os.listdir(CACHE)):
    sys.stderr.write("FATAL: corpus not found or empty at %s\n" % CACHE)
    sys.exit(2)

DECL = re.compile(r"^[ \t]*local (p\d+) = (\d+)[ \t]*$")
GUARD = re.compile(r"^[ \t]*if (p\d+) == (\d+) then[ \t]*$")
ASSIGN = re.compile(r"^[ \t]*(p\d+) = (\d+)[ \t]*$")


def machines_of(text):
    """-> list of (entry_state, {state: [targets in order]}, first_line).

    A `local pN = k` OPENS a machine. Region ids restart per proto, so keying by NAME alone merges
    unrelated machines (PITFALLS C1) -- each declaration therefore starts a fresh one.
    """
    out, open_idx = [], {}
    cur = None
    for i, ln in enumerate(text.splitlines()):
        m = DECL.match(ln)
        if m:
            out.append([int(m.group(2)), collections.OrderedDict(), i + 1])
            open_idx[m.group(1)] = len(out) - 1
            cur = None
            continue
        m = GUARD.match(ln)
        if m:
            name, val = m.group(1), int(m.group(2))
            cur = (name, val)
            if name in open_idx:
                out[open_idx[name]][1].setdefault(val, [])
            continue
        m = ASSIGN.match(ln)
        if m and cur and m.group(1) == cur[0]:
            k = open_idx.get(cur[0])
            if k is not None and cur[1] in out[k][1]:
                out[k][1][cur[1]].append(int(m.group(2)))
    return [(e, g, l) for e, g, l in out if len(g) >= 2]


def signature(entry, graph):
    """Canonical shape string: states renumbered by ascending block id."""
    states = sorted(graph)
    rank = {s: i for i, s in enumerate(states)}
    parts = []
    for s in states:
        tgt = [str(rank[t]) if t in rank else "x" for t in graph[s]]
        parts.append("%d>%s" % (rank[s], ",".join(tgt)))
    return "%d:%s" % (len(states), "|".join(parts))


def one(fn):
    p = subprocess.run([DEC, "decompile-mod", os.path.join(CACHE, fn)],
                       capture_output=True, text=True, encoding="utf-8",
                       errors="replace", timeout=300, env=ENV, cwd=ROOT)
    if p.returncode != 0:
        return None
    return [(signature(e, g), fn, l) for e, g, l in machines_of(p.stdout)]


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else 1500
    show_ex = "-e" in sys.argv
    files = sorted(f for f in os.listdir(CACHE) if f.endswith(".lua_B"))[:n]
    print("== PROPER-REGION SHAPE CLUSTERING ==  files=%d" % len(files))

    with ThreadPoolExecutor(max_workers=min(8, (os.cpu_count() or 4))) as ex:
        res = list(ex.map(one, files))

    failed = sum(1 for r in res if r is None)
    sigs = [s for r in res if r for s in r]
    if not sigs:
        sys.stderr.write("FATAL: no state machines found - measuring nothing\n")
        return 2

    cnt = collections.Counter(s for s, _, _ in sigs)
    example = {}
    for s, fn, ln in sigs:
        example.setdefault(s, (fn, ln))
    total = len(sigs)

    print("   decompile FAILED        %d" % failed)
    print("   state machines          %d" % total)
    print("   DISTINCT shapes         %d" % len(cnt))
    print()
    print("   rank  count   cumul%   states  shape")
    run = 0
    for i, (s, c) in enumerate(cnt.most_common(20), 1):
        run += c
        print("   %-5d %-7d %6.1f%%  %-7s %s" % (i, c, 100.0 * run / total, s.split(":")[0], s[:74]))
        if show_ex:
            fn, ln = example[s]
            print("           e.g. %s:%d" % (fn, ln))

    for k in (5, 10, 20, 50, 100):
        if k <= len(cnt):
            cum = sum(c for _, c in cnt.most_common(k))
            print("\n   top %-4d shapes cover %6.2f%% of all state machines" % (k, 100.0 * cum / total))

    singles = sum(1 for _, c in cnt.items() if c == 1)
    print("\n   shapes occurring exactly ONCE: %d (%.1f%% of distinct shapes, %.2f%% of machines)"
          % (singles, 100.0 * singles / len(cnt), 100.0 * singles / total))
    print("\n   READ THIS AS: concentrated -> mine templates against luau-compile.exe (bounded work).")
    print("                 flat tail    -> the general structuring algorithm is the right tool.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
