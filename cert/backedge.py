#!/usr/bin/env python3
"""backedge.py - the BACK-EDGE BIJECTION oracle.

An edge u->v is a back edge iff v DOMINATES u. Each back edge must produce EXACTLY ONE loop construct
in the output, so the back-edge count of the ORIGINAL and of our RECOMPILE must be EQUAL.

Why this is better than counting loop opcodes (what align.py does):
  - a loop emitted TWICE around one body shows up here as +1 back edge; the opcode count can miss it
  - a loop re-encoded in a different form (for -> while) is NOT flagged here, because the control flow
    is what matters, not the syntax we chose
  - a LOST loop shows up as -1 back edge, unambiguously

This measures loop RECOVERY directly rather than inferring it. Standard invariant across the
decompiler literature (dcc, Ghidra, Phoenix); the OOPSLA-2024 decompiler-bug study calls this failure
class "region restoration".

Usage:  python cert/backedge.py [N] [-v]
"""
import os, sys, re, subprocess, sys, tempfile, collections
from concurrent.futures import ThreadPoolExecutor

from workspace_paths import corpus_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC = os.path.join(ROOT, "bin", "derecomp.exe")
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
# Same fidelity configuration align.py uses: the default lowerings are injection-oriented, not faithful.
ENV = dict(os.environ, RENOVICE_NATIVE_GLOBALS="1",
           RENOVICE_NATIVE="JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,JUMPBACK,AND,OR,ANDK,ORK,SUBK,FORGPREP")


def run(a, timeout=180):
    return subprocess.run(a, capture_output=True, text=True, encoding="utf-8",
                          errors="replace", timeout=timeout, env=ENV)


def backedges(path):
    p = run([DEC, "backedges", path])
    if p.returncode != 0:
        return None                       # a tool that cannot run must NOT read as "no difference"
    m = re.search(r"TOTAL backedges=(\d+) headers=(\d+)", p.stdout or "")
    return (int(m.group(1)), int(m.group(2))) if m else None


def one(f):
    a = backedges(f)
    if a is None:
        return (f, "tool-fail", 0, None, None)
    src = run([DEC, "decompile-mod", f])
    if src.returncode != 0:
        return (f, "decompile-fail", 0, a, None)
    fd, sp = tempfile.mkstemp(suffix=".luau"); os.close(fd)
    with open(sp, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(src.stdout)
    out = sp + ".lua_B"
    r = run([DEC, "recompile", sp, out])
    try: os.remove(sp)
    except OSError: pass
    if r.returncode != 0 or not os.path.exists(out):
        return (f, "recompile-fail", 0, a, None)
    b = backedges(out)
    try: os.remove(out)
    except OSError: pass
    if b is None:
        return (f, "tool-fail", 0, a, None)
    # Grade on HEADERS (= loop count; two latches into one header is still one loop) and report the
    # back-edge delta alongside, since a lost/invented LATCH is a real difference the header count
    # cannot see.
    if a == b:
        return (f, "MATCH", 0, a, b)
    if a[1] == b[1]:
        return (f, "LATCH-DIFF", b[0] - a[0], a, b)
    return (f, "EXTRA-LOOPS" if b[1] > a[1] else "LOST-LOOPS", b[1] - a[1], a, b)


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else 300
    verbose = "-v" in sys.argv
    files = sorted(os.path.join(CACHE, x) for x in os.listdir(CACHE) if x.endswith(".lua_B"))[:n]
    with ThreadPoolExecutor(max_workers=WORKERS) as ex:
        res = list(ex.map(one, files))
    tally = collections.Counter(k for _, k, _, _, _ in res)
    print("== BACK-EDGE BIJECTION vs ORIGINAL ==")
    print("files=%d" % len(files))
    for k, c in tally.most_common():
        print("  %-16s %d" % (k, c))
    lost = sum(-d for _, k, d, _, _ in res if k == "LOST-LOOPS")
    extra = sum(d for _, k, d, _, _ in res if k == "EXTRA-LOOPS")
    print("  loop headers LOST=%d  EXTRA=%d" % (lost, extra))
    print("  %-16s %d" % ("LOST-HEADERS", lost))
    print("  %-16s %d" % ("EXTRA-HEADERS", extra))
    worst = sorted((abs(d), os.path.basename(f), k, d) for f, k, d, _, _ in res if d)[-5:]
    for _, nm, k, d in reversed(worst):
        print("  !! %-52s %s %+d" % (nm[:52], k, d))
    if verbose:
        print("\n  all non-matching files:")
        for f, k, d, original, recompiled in sorted(res):
            if k != "MATCH":
                detail = ""
                if original is not None and recompiled is not None:
                    detail = " orig=%d/%d recomp=%d/%d" % (
                        original[0], original[1], recompiled[0], recompiled[1])
                print("    %-60s %-16s %+d%s" % (os.path.basename(f)[:60], k, d, detail))
    return 0 if tally.get("MATCH", 0) == len(files) else 1


if __name__ == "__main__":
    sys.exit(main())
