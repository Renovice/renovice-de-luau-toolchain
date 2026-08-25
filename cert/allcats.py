#!/usr/bin/env python3
"""
allcats.py - HONEST per-category counts, without align.py's first-match-wins masking.

WHY THIS EXISTS
`align.py` returns on the FIRST differing category and tests LOOP-DIFF before the access check. A
file with BOTH a loop difference AND an access loss is therefore reported only as LOOP-DIFF, and its
access loss is invisible. That makes NAME-DIFF mean "lost an access AND had no loop difference" --
a set that SHRINKS as loops get worse and GROWS as loops get fixed.

Measured consequence (FINDINGS #99): fixing DecoPreview's loop structure moved it from LOOP-DIFF to
NAME-DIFF, so NAME-DIFF went 0 -> 1. That looks exactly like a regression. It is not: DecoPreview's
recompile loses the SAME 3 accesses (152 -> 149) before AND after the change. The defect was always
there, hidden behind a more severe label.

So: before calling any NAME-DIFF rise a regression, run this. It reports every category a file
belongs to, independently. The ACCESS-LOSS number here is the one that must never rise. Whole orphan
prototypes are excluded because no live closure site can create them; counting their bodies previously
produced nine false-positive loss files.

Usage:
    python cert/allcats.py [N]
    RENOVICE_CORPUS=... python cert/allcats.py 300
"""
import os, sys, collections
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import align  # reuses its skeleton extraction, normalisation and corpus guard


def norm(lines):
    """Same normalisation align.one() uses: drop BRANCH lines, collapse CLOSURE targets."""
    out = []
    for ln in lines:
        if "\t" not in ln or ln.startswith("BRANCH\t"):
            continue
        out.append("CLOSURE" if ln.startswith("CLOSURE\t") else ln)
    return out


def one(f):
    """Return the set of categories this file exhibits, tested INDEPENDENTLY.

    Mirrors align.one()'s decompile -> recompile -> re-skeleton pipeline, but scores every
    category rather than returning on the first match.
    """
    import tempfile
    # Named accesses in orphan prototypes are dead code and are deliberately not emitted.  Compare
    # only prototypes reachable through closure sites in live blocks; otherwise a correctly dropped
    # orphan is falsely reported as ACCESS-LOSS.
    a = align.skeleton(f, reachable=True)
    if a is None:
        return (f, {"ERROR"}, "decompile-fail")
    src = align.run([align.DEC, "decompile-mod", f])
    if src.returncode != 0:
        return (f, {"ERROR"}, "decompile-fail")
    fd, sp = tempfile.mkstemp(suffix=".luau"); os.close(fd)
    with open(sp, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(src.stdout)
    out = sp + ".lua_B"
    r = align.run([align.DEC, "recompile", sp, out])
    try: os.remove(sp)
    except OSError: pass
    if r.returncode != 0 or not os.path.exists(out):
        return (f, {"ERROR"}, "recompile-fail")
    b = align.skeleton(out, reachable=True)
    try: os.remove(out)
    except OSError: pass
    if b is None:
        return (f, {"ERROR"}, "reskeleton-fail")

    LOOPOPS = ("FORNPREP", "FORNLOOP", "FORGLOOP", "FORGPREP")
    EA, EB = collections.Counter(), collections.Counter()
    NA, NB = [norm(pa[1]) for pa in a], [norm(pb[1]) for pb in b]
    for body in NA: EA.update(body)
    for body in NB: EB.update(body)
    LA = collections.Counter(ln for p in a for ln in p[1] if ln in LOOPOPS)
    LB = collections.Counter(ln for p in b for ln in p[1] if ln in LOOPOPS)

    cats = set()
    if LA != LB: cats.add("LOOP-DIFF")
    if EA != EB:
        cats.add("ACCESS-DIFF")
        if sum((EA - EB).values()): cats.add("ACCESS-LOSS")
        if sum((EB - EA).values()): cats.add("ACCESS-GAIN")
    if len(a) != len(b): cats.add("PROTO-COUNT-DIFF")
    # Independent effect-order category. Like access and loop loss, this must not disappear merely
    # because align.py returned an earlier category first. Only compare order when each side has the
    # same per-body access multiset; otherwise this is a content difference, not just ordering.
    effect = ("NAMECALL\t", "SETFIELD\t", "SETINDEX\t", "SETGLOBAL\t",
              "SETUPVAL\t", "SETLIST\t")
    def order_free(body):
        return "\n".join(sorted(body))
    def order_sensitive(body):
        effects = [line for line in body if line.startswith(effect)]
        reads = sorted(line for line in body if not line.startswith(effect))
        return "\n".join(effects) + "||" + "\n".join(reads)
    OA = collections.Counter(order_free(body) for body in NA)
    OB = collections.Counter(order_free(body) for body in NB)
    BA = collections.Counter(order_sensitive(body) for body in NA)
    BB = collections.Counter(order_sensitive(body) for body in NB)
    if OA == OB and BA != BB: cats.add("ORDER-DIFF")
    if not cats: cats.add("CLEAN")
    lost = sum((EA - EB).values())
    return (f, cats, "lost %d access(es)" % lost if lost else "")


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 300
    files = sorted(os.path.join(align.CACHE, x)
                   for x in os.listdir(align.CACHE) if x.endswith(".lua_B"))[:n]
    with ThreadPoolExecutor(max_workers=align.WORKERS) as ex:
        res = list(ex.map(one, files))

    tally = collections.Counter(c for _, cats, _ in res for c in cats)
    print("== INDEPENDENT CATEGORY COUNTS (no first-match masking) ==  files=%d" % len(files))
    for k, c in tally.most_common():
        print("   %-18s %d" % (k, c))
    loss = [(f, w) for f, cats, w in res if "ACCESS-LOSS" in cats]
    loss_total = sum(int(w.split()[1]) for _, w in loss)
    print("   ACCESS-LOSS-TOTAL  %d" % loss_total)
    print("\n   ACCESS-LOSS is the number that must never rise: %d file(s)" % len(loss))
    for f, w in sorted(loss):
        print("     %-56s %s" % (os.path.basename(f)[:56], w))
    return 0


if __name__ == "__main__":
    sys.exit(main())
