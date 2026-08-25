#!/usr/bin/env python3
"""
align.py - INSTRUCTION-LEVEL EQUIVALENCE ALIGNMENT between the ORIGINAL DE bytecode and our recompile.

Every previous oracle compared our output to ITSELF (decompile -> recompile -> decompile). That is
self-consistency, and it is structurally blind to a consistent misreading — #56 bound the WRONG
FUNCTION at every NEWCLOSURE site and still passed 5,386/5,386 round-trips and 150/150 behavioural
traces, because `recompile` faithfully writes back whatever `decompile` misread.

This compares against the ORIGINAL, which is the only thing that can catch that class. We cannot run
DE bytecode offline and DE's sources do not exist, but we have both BYTECODES, so we align them.

The comparison is on the SEMANTIC SKELETON (`derecomp skeleton`): calls and the name called, field /
global / import access BY NAME, table ops, branch shape, returns, and which proto each closure binds.
Register numbers and materialisation MOVE/LOADNIL are excluded by construction — those are allocation
details we deliberately change.

Reported per proto, so a single divergence is localised rather than smeared across a whole file.

Usage:  python cert/align.py [N]        (N = how many corpus files, default 200)
"""
import os, sys, re, subprocess, sys, tempfile, collections
from concurrent.futures import ThreadPoolExecutor

from workspace_paths import corpus_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC  = os.path.join(ROOT, "bin", "derecomp.exe")
# CORPUS LOCATION. Overridable via RENOVICE_CORPUS so the project can be COPIED to an isolated
# workspace and still measure the real corpus. The default is RELATIVE to the project root, and that
# relative path is what silently broke sub-agents working in temp copies: they measured an empty or
# different file set and reported a wrong baseline that nearly caused a correct fix to be discarded.
CACHE = corpus_cache(ROOT)
if not os.path.isdir(CACHE) or not any(x.endswith(".lua_B") for x in os.listdir(CACHE)):
    # FAIL LOUDLY. An oracle that cannot see the corpus must never report "0 differences".
    sys.stderr.write("FATAL: corpus not found or empty at %s\n"
                     "       set RENOVICE_CORPUS to the dir holding *.lua_B\n" % CACHE)
    sys.exit(2)
WORKERS = min(16, (os.cpu_count() or 4) * 2)
# FIDELITY MODE. Two transcoder behaviours are LOWERINGS chosen for injection safety, not faithfulness:
#  - globals routed through _G (DE runs injected chunks in a transient sandbox env)
#  - JUMPXEQK* lowered to LOAD-const-to-scratch + reg-reg compare
# Both are semantically fine but structurally different from the original, so alignment must enable
# the native forms or it reports differences that are configuration, not defects.
ENV = dict(os.environ, RENOVICE_NATIVE_GLOBALS="1",
           RENOVICE_NATIVE="JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,JUMPBACK,AND,OR,ANDK,ORK,SUBK,FORGPREP")


def run(args, timeout=180):
    return subprocess.run(args, capture_output=True, text=True, encoding="utf-8",
                          errors="replace", timeout=timeout, env=ENV)


def skeleton(path, reachable=False):
    """-> list of (header, [lines])  one entry per proto, in order."""
    # `--live` on BOTH sides: the emitter drops blocks the CFG cannot reach (M6b established these are
    # benign compiler dead code), so the original legitimately holds named accesses that can never run.
    # Counting them charges us for code with no behaviour. Symmetric, and it only ever removes what is
    # positively PROVEN unreachable — when no CFG can be built, every instruction stays live.
    args = [DEC, "skeleton", path, "--live"]
    if reachable:
        args.append("--reachable")
    p = run(args)
    if p.returncode != 0:
        return None
    protos, cur = [], None
    for line in p.stdout.splitlines():
        if line.startswith("== proto["):
            cur = (line, []); protos.append(cur)
        elif cur is not None and line:
            cur[1].append(line)
    return protos


def one(f):
    a = skeleton(f)
    if a is None:
        return (f, "decompile-fail", None)
    src = run([DEC, "decompile-mod", f])
    if src.returncode != 0:
        return (f, "decompile-fail", None)
    fd, sp = tempfile.mkstemp(suffix=".luau"); os.close(fd)
    with open(sp, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(src.stdout)
    out = sp + ".lua_B"
    r = run([DEC, "recompile", sp, out])
    try: os.remove(sp)
    except OSError: pass
    if r.returncode != 0 or not os.path.exists(out):
        return (f, "recompile-fail", None)
    b = skeleton(out)
    try: os.remove(out)
    except OSError: pass
    if b is None:
        return (f, "reskeleton-fail", None)

    if len(a) != len(b):
        # A proto no closure instruction can create is DEAD CODE; `decompile-mod` emits only reachable
        # code, so dropping exactly the orphans is CORRECT, not a loss. Losing a REACHABLE proto is a
        # real defect. Distinguish them instead of lumping both into one suspicious bucket.
        orph = 0
        po = run([DEC, "orphans", f])
        m = re.search(r"orphans=(\d+)", po.stdout or "")
        if m: orph = int(m.group(1))
        live = len(a) - orph
        if len(b) == live:
            return (f, "ALIGNED-minus-orphans", None)   # exactly the dead protos were dropped
        if len(b) < live:
            return (f, "PROTO-LOST",
                    "orig %d (orphans %d, live %d) vs recompiled %d -> %d LIVE proto(s) LOST"
                    % (len(a), orph, live, len(b), live - len(b)))
        # More protos than live ones: a proto bound by TWO closure sites is inlined TWICE, so the
        # single original becomes two copies. Semantically equivalent per call site, but it DUPLICATES
        # code and the two copies are distinct closure objects — flagged, not silently accepted.
        return (f, "PROTO-DUP",
                "orig %d (orphans %d, live %d) vs recompiled %d -> %d duplicated"
                % (len(a), orph, live, len(b), len(b) - live))
    # Compare MULTISETS, not raw sequences. Strict sequence equality is too harsh to be useful:
    # materialisation legitimately reorders loads and changes how a table literal is built (DUPTABLE vs
    # NEWTABLE+SETLIST), so it flags benign differences. What must NOT change is WHICH named entities
    # are touched and HOW OFTEN.
    #
    # Two order-independent invariants, neither of which amplifies a single difference into many.
    #
    #  ENTITY  = the module-wide multiset of NAMED accesses: calls, field/global/import reads by name.
    #            Catches a phantom global read (#57) or a lost access. Compared module-wide because our
    #            proto ORDER legitimately differs (inlining decides it), so `proto[N]` on the two sides
    #            is often a different function and per-index comparison says nothing.
    #  BODY    = the multiset of per-proto entity skeletons — WHICH FUNCTIONS EXIST, by content. This is
    #            what catches #56: binding the wrong proto at a closure site inlines the wrong body, so
    #            one body goes missing and another appears twice, even though the module-wide access
    #            totals can stay identical.
    # Excluded by construction: BRANCH lines (control-flow encoding is ours to choose — Proper-region
    # state tests, JUMPXEQK lowering) and the closure TARGET (a module-local index; a recursive content
    # hash was tried and rejected — one benign leaf difference rewrites every ancestor's signature and
    # turned 5 real findings into 207).
    def norm(lines):
        out = []
        for ln in lines:
            if "	" not in ln or ln.startswith("BRANCH	"):
                continue
            out.append("CLOSURE" if ln.startswith("CLOSURE	") else ln)
        return out

    # The body key must not be ORDER-SENSITIVE for pure reads. Register allocation decides when a
    # global/field load is materialised, so `tonumber(o:Get())` may load `tonumber` before or after the
    # inner call with identical meaning — measured on ScrollBar, where the two bodies were the SAME
    # MULTISET in a different order. Keeping order in the key reported 192 files as differing while
    # nothing actually differed. So: SIDE EFFECTS keep their relative ORDER (reordering two calls IS a
    # semantic change), pure reads are compared as a multiset.
    EFFECT = ("NAMECALL	", "SETFIELD	", "SETINDEX	", "SETGLOBAL	", "SETUPVAL	", "SETLIST	")
    EA, EB = collections.Counter(), collections.Counter()
    BA, BB = collections.Counter(), collections.Counter()
    NL = chr(10)

    def body_key(lines):
        eff = [ln for ln in lines if ln.startswith(EFFECT)]
        rd  = sorted(ln for ln in lines if not ln.startswith(EFFECT))
        return NL.join(eff) + "||" + NL.join(rd)

    # ...but the STATIC order of effects is not comparable for every proto either. Where a proto needs
    # the Proper-region flag-guarded linearisation, blocks are emitted in an order chosen by the
    # reduction, and correctness comes from the state-variable dispatch rather than from textual order —
    # measured on SetVortexWindPerZone, whose effect sequence comes out essentially REVERSED while the
    # multiset is identical. So grade against the ORDER-FREE key first (a difference there is real), and
    # report a pure ordering difference SEPARATELY as advisory instead of pretending it is a defect.
    OA, OB = collections.Counter(), collections.Counter()

    for pa in a:
        na = norm(pa[1]); EA.update(na); BA[body_key(na)] += 1; OA[NL.join(sorted(na))] += 1
    for pb in b:
        nb = norm(pb[1]); EB.update(nb); BB[body_key(nb)] += 1; OB[NL.join(sorted(nb))] += 1

    # LOOP STRUCTURE. Counted separately and FIRST because it is the most consequential thing that can
    # go wrong and the least visible: a lost loop still round-trips, still recompiles, and still passes
    # a self-consistent behavioural trace — the body simply runs once instead of N times. Found via
    # SetVortexWindPerZone, whose two numeric `for` loops came out as bare FORNPREP setups with their
    # bodies hoisted above them and no `for` statement anywhere in the output.
    LOOPOPS = ("FORNPREP", "FORNLOOP", "FORGLOOP", "FORGPREP")
    LA = collections.Counter(ln for p in a for ln in p[1] if ln in LOOPOPS)
    LB = collections.Counter(ln for p in b for ln in p[1] if ln in LOOPOPS)
    if LA != LB:
        miss, extra = LA - LB, LB - LA
        bits  = ["LOST %s x%d" % (k, v) for k, v in miss.items()]
        bits += ["EXTRA %s x%d" % (k, v) for k, v in extra.items()]
        return (f, "LOOP-DIFF", "; ".join(bits)[:140])
    if EA != EB:
        miss, extra = EA - EB, EB - EA
        bits  = ["MISSING %s x%d" % (k.replace("	", " "), v) for k, v in list(miss.items())[:2]]
        bits += ["EXTRA %s x%d"   % (k.replace("	", " "), v) for k, v in list(extra.items())[:2]]
        return (f, "NAME-DIFF", "; ".join(bits)[:140])
    # NOTE ON THIS FUNCTION'S FIRST-MATCH-WINS ORDERING (2026-07-28).
    # The checks above return on the FIRST differing category, and LOOP-DIFF is tested BEFORE the
    # access check. So a file that has BOTH a loop difference AND an access loss is reported only as
    # LOOP-DIFF, and its access loss is INVISIBLE. NAME-DIFF is therefore not "files that lost an
    # access" -- it is "files that lost an access AND had no loop difference", which is a much
    # smaller set and shrinks as loops improve.
    #
    # Consequence, measured: fixing DecoPreview's loop structure moved it LOOP-DIFF -> NAME-DIFF and
    # made NAME-DIFF go 0 -> 1. That reads as a regression and is NOT one -- its recompile loses the
    # SAME 3 accesses (152 -> 149) before and after the change. The defect was always there, masked.
    #
    # The ordering is kept deliberately (loop loss really is the most consequential single class, and
    # reporting one category per file keeps the tally summing to the file count), but any rise in
    # NAME-DIFF must be checked against `align_allcats` below before being called a regression.
    # See PITFALLS B6, and FINDINGS #99.
    if OA != OB:
        miss, extra = OA - OB, OB - OA
        return (f, "BODY-DIFF", "%d body kind(s) missing, %d extra (module-wide access totals MATCH)"
                % (sum(miss.values()), sum(extra.values())))
    if BA != BB:
        return (f, "ORDER-DIFF", "same functions, same accesses; effect ORDER differs (linearisation)")
    return (f, "ALIGNED", None)


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 200
    files = sorted(os.path.join(CACHE, x) for x in os.listdir(CACHE) if x.endswith(".lua_B"))[:n]
    with ThreadPoolExecutor(max_workers=WORKERS) as ex:
        res = list(ex.map(one, files))
    tally = collections.Counter(k for _, k, _ in res)
    print("== INSTRUCTION-LEVEL ALIGNMENT vs ORIGINAL BYTECODE ==")
    print("files=%d" % len(files))
    for k, c in tally.most_common():
        print("  %-16s %d" % (k, c))
    shown = 0
    for f, k, why in res:
        if k not in ("ALIGNED",) and why and shown < 60:
            shown += 1
            print("  !! %-52s %s" % (os.path.basename(f)[:52], why))
    return 0 if tally.get("ALIGNED", 0) == len(files) else 1


if __name__ == "__main__":
    sys.exit(main())
