#!/usr/bin/env python3
"""
bindmap.py - does each exported global bind the SAME function across a round-trip?

#52: `Lotus_Interface_BindingsUtil` binds `ResetCustomBindings` to a 0-parameter closure in S' and a
1-parameter closure in S''. Different ARITY proves a different sub-proto is bound, so one pass resolves
a closure constant to the wrong proto.

This extracts, from `decompile-mod` output, the map  exported-global -> arity of the closure it binds,
for S' and S'', and reports every name whose arity changes. Arity is a coarse fingerprint - it cannot
see two protos with the SAME arity being swapped - so a clean result bounds the defect rather than
disproving it, and that is stated in the output rather than left implied.

Usage:  python cert/bindmap.py [N]
"""
import os, re, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor

from workspace_paths import corpus_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC  = os.path.join(ROOT, "bin", "derecomp.exe")
CACHE = corpus_cache(ROOT)
WORKERS = min(16, (os.cpu_count() or 4) * 2)

# module-level only: exactly two spaces of indent (nested code is deeper)
# `vT[N]` is the register-TABLE spill used when a proto names more than Luau's 200 locals.
ASSIGN_FN = re.compile(r"^  (v\d+|vT\[\d+\]) = function\(([^)]*)\)", re.M)
EXPORT    = re.compile(r"^  ([A-Za-z_]\w*) = (v\d+|vT\[\d+\])\s*$", re.M)


def bindmap(src):
    """name -> arity, by walking module-level lines in order and tracking the last closure per reg."""
    reg_arity = {}
    out = {}
    for line in src.splitlines():
        m = ASSIGN_FN.match(line + "\n") or ASSIGN_FN.match(line)
        if m:
            args = [a for a in m.group(2).split(",") if a.strip()]
            reg_arity[m.group(1)] = len(args)
            continue
        m2 = EXPORT.match(line + "\n") or EXPORT.match(line)
        if m2 and m2.group(2) in reg_arity:
            out[m2.group(1)] = reg_arity[m2.group(2)]
    return out


def dec_mod(f):
    p = subprocess.run([DEC, "decompile-mod", f], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
    return p.stdout if p.returncode == 0 else None


def one(f):
    s1 = dec_mod(f)
    if s1 is None:
        return (f, "decompile-fail", {})
    fd, sp = tempfile.mkstemp(suffix=".luau"); os.close(fd)
    with open(sp, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(s1)
    de2 = sp + ".lua_B"
    r = subprocess.run([DEC, "recompile", sp, de2], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
    try: os.remove(sp)
    except OSError: pass
    if r.returncode != 0 or not os.path.exists(de2):
        return (f, "recompile-fail", {})
    s2 = dec_mod(de2)
    try: os.remove(de2)
    except OSError: pass
    if s2 is None:
        return (f, "decompile2-fail", {})
    m1, m2 = bindmap(s1), bindmap(s2)
    bad = {k: (m1[k], m2[k]) for k in m1 if k in m2 and m1[k] != m2[k]}
    if bad:
        return (f, "ARITY-MISMATCH", bad)
    if not m1:
        return (f, "no-exports", {})
    return (f, "ok", {})


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 300
    files = sorted(os.path.join(CACHE, x) for x in os.listdir(CACHE) if x.endswith(".lua_B"))[:n]
    with ThreadPoolExecutor(max_workers=WORKERS) as ex:
        res = list(ex.map(one, files))
    tally = {}
    for _, k, _ in res:
        tally[k] = tally.get(k, 0) + 1
    print("== EXPORT BINDING MAP across round-trip ==")
    print("files=%d" % len(files))
    for k in sorted(tally, key=lambda z: -tally[z]):
        print("  %-16s %d" % (k, tally[k]))
    shown = 0
    for f, k, bad in res:
        if k == "ARITY-MISMATCH" and shown < 8:
            shown += 1
            print("  !! %s" % os.path.basename(f))
            for name, (a, b) in sorted(bad.items())[:4]:
                print("       %-34s S'=%d  S''=%d" % (name, a, b))
    print("\nNOTE: arity is a COARSE fingerprint - two protos with the SAME arity being swapped would")
    print("      not show here. A clean result BOUNDS this defect, it does not disprove it.")
    return 0 if tally.get("ARITY-MISMATCH", 0) == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
