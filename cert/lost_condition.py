#!/usr/bin/env python3
"""Detect conditional returns emitted at an unconditional outer depth (FINDINGS #102).

The emitter's RENOVICE_SEQDBG instrumentation writes one DEADTAIL record when a region part ends
with a bare `do return end` at the same lexical depth as a following sibling. The record includes
the prototype index so a failure can be isolated with `de-disasm`. Only `planning=0`
records are graded: PLAN/RENDER deliberately performs a planning walk whose output is discarded,
and counting its temporary text produced 59 false residual sites after the production fix. For the
proven #102 render shape, the original CFG has a conditional path around that return, so the sibling
remains reachable; emitted source that loses the wrapper makes Luau correctly delete that sibling.

Usage:
    python cert/lost_condition.py          # first 300 sorted corpus files
    python cert/lost_condition.py 600
    python cert/lost_condition.py 300 -v   # list every affected file/site

Exit codes: 0 = zero lost-condition sites; 1 = sites or decompile failures; 2 = bad corpus.
"""

import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

from workspace_paths import corpus_cache


HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC = os.path.join(ROOT, "bin", "derecomp.exe")
CORPUS = corpus_cache(ROOT)

ENV = dict(
    os.environ,
    RENOVICE_NATIVE_GLOBALS="1",
    RENOVICE_NATIVE="JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,JUMPBACK,AND,OR,ANDK,ORK,SUBK,FORGPREP",
    RENOVICE_SEQDBG="1",
)


def one(filename):
    path = os.path.join(CORPUS, filename)
    try:
        proc = subprocess.run(
            [DEC, "decompile-mod", path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=300,
            env=ENV,
            cwd=ROOT,
        )
    except subprocess.TimeoutExpired:
        return filename, None, "timeout"
    if proc.returncode != 0:
        return filename, None, "exit %d" % proc.returncode
    sites = [line for line in proc.stderr.splitlines()
             if line.startswith("DEADTAIL ") and " planning=0 " in line]
    return filename, sites, None


def main():
    if not os.path.isdir(CORPUS):
        sys.stderr.write("FATAL: corpus directory not found: %s\n" % CORPUS)
        return 2
    all_files = sorted(name for name in os.listdir(CORPUS) if name.endswith(".lua_B"))
    if not all_files:
        sys.stderr.write("FATAL: corpus contains no .lua_B files: %s\n" % CORPUS)
        return 2

    count = int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else 300
    verbose = "-v" in sys.argv
    files = all_files[:count]
    print("== LOST-CONDITION GATE == files=%d corpus=%s" % (len(files), CORPUS))

    with ThreadPoolExecutor(max_workers=min(8, os.cpu_count() or 4)) as executor:
        results = list(executor.map(one, files))

    failures = [(name, error) for name, sites, error in results if error is not None]
    affected = [(name, sites) for name, sites, error in results if error is None and sites]
    total_sites = sum(len(sites) for _, sites in affected)

    print("  files scanned       %d" % (len(files) - len(failures)))
    print("  decompile failures  %d" % len(failures))
    print("  affected files      %d" % len(affected))
    print("  DEADTAIL sites      %d" % total_sites)

    if verbose:
        for name, sites in affected:
            for site in sites:
                print("    %s  %s" % (name, site))
    if failures:
        print("  failures:")
        for name, error in failures[:20]:
            print("    %s: %s" % (name, error))

    print("\n== VERDICT ==")
    if failures:
        print("   FAIL  measurement incomplete: %d decompile failure(s)" % len(failures))
        return 1
    if total_sites:
        print("   FAIL  %d lost-condition site(s) in %d file(s)" % (total_sites, len(affected)))
        return 1
    print("   PASS  no conditional return was flattened into an unconditional dead tail")
    return 0


if __name__ == "__main__":
    sys.exit(main())
