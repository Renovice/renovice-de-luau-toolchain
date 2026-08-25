#!/usr/bin/env python3
"""bodydiff.py <file.lua_B> - show WHICH function bodies differ between original and recompiled.

`align.py` reports BODY-DIFF when the module-wide access totals MATCH but the per-proto distribution
does not: some named access sits in a DIFFERENT function than it did originally. That is worth seeing
in full, because "same totals, different owner" is exactly the shape a mis-attributed nested function
would have.
"""
import os, sys, subprocess, tempfile, collections

from workspace_paths import corpus_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC = os.path.join(ROOT, "bin", "derecomp.exe")
ENV = dict(os.environ, RENOVICE_NATIVE_GLOBALS="1",
           RENOVICE_NATIVE="JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,JUMPBACK,AND,OR,ANDK,ORK,SUBK,FORGPREP")
TAB, NL = chr(9), chr(10)


def run(a):
    return subprocess.run(a, capture_output=True, text=True, encoding="utf-8",
                          errors="replace", env=ENV, timeout=180)


def bodies(path):
    p = run([DEC, "skeleton", path, "--live"])
    protos, cur = [], None
    for line in p.stdout.splitlines():
        if line.startswith("== proto["):
            cur = []; protos.append(cur)
        elif cur is not None and line:
            cur.append(line)
    # Same key align.py uses: side effects keep their order, pure reads compare as a multiset.
    EFFECT = tuple(x + TAB for x in
                   ("NAMECALL", "SETFIELD", "SETINDEX", "SETGLOBAL", "SETUPVAL", "SETLIST"))
    out, rep = collections.Counter(), {}
    for pr in protos:
        keep = [("CLOSURE" if ln.startswith("CLOSURE" + TAB) else ln)
                for ln in pr if TAB in ln and not ln.startswith("BRANCH" + TAB)]
        eff = [ln for ln in keep if ln.startswith(EFFECT)]
        rd  = sorted(ln for ln in keep if not ln.startswith(EFFECT))
        k = NL.join(eff) + "||" + NL.join(rd)
        out[k] += 1
        rep.setdefault(k, NL.join(keep))
    return out, rep


def main():
    f = sys.argv[1]
    if not os.path.isabs(f):
        f = os.path.join(corpus_cache(ROOT), f)
    A, RA = bodies(f)
    src = run([DEC, "decompile-mod", f]).stdout
    fd, sp = tempfile.mkstemp(suffix=".luau"); os.close(fd)
    open(sp, "w", encoding="utf-8", newline=NL).write(src)
    out = sp + ".lua_B"
    run([DEC, "recompile", sp, out])
    B, RB = bodies(out)
    for t in (sp, out):
        try: os.remove(t)
        except OSError: pass

    miss, extra = A - B, B - A
    print("== bodies only in ORIGINAL (%d) ==" % sum(miss.values()))
    for k, v in list(miss.items())[:3]:
        print("-- x%d --" % v); print(RA[k][:700] if k else "(empty body)")
    print()
    print("== bodies only in OURS (%d) ==" % sum(extra.values()))
    for k, v in list(extra.items())[:3]:
        print("-- x%d --" % v); print(RB[k][:700] if k else "(empty body)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
