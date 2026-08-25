#!/usr/bin/env python3
"""List multi-exit cyclic parts selected for explicit escape propagation."""

import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

from workspace_paths import corpus_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC = os.path.join(ROOT, "bin", "derecomp.exe")
CORPUS = corpus_cache(ROOT)
ENV = dict(os.environ,
           RENOVICE_NATIVE_GLOBALS="1",
           RENOVICE_NATIVE="JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,JUMPBACK,AND,OR,ANDK,ORK,SUBK,FORGPREP",
           RENOVICE_ESCDBG="1")


def one(name):
    proc = subprocess.run([DEC, "decompile-mod", os.path.join(CORPUS, name)],
                          stdout=subprocess.DEVNULL, stderr=subprocess.PIPE,
                          text=True, encoding="utf-8", errors="replace", timeout=300,
                          env=ENV, cwd=ROOT)
    sites = [line for line in proc.stderr.splitlines() if line.startswith("ESC_PROMOTE ")]
    # PLAN and RENDER are intentionally identical; retain one copy of each site.
    return name, sorted(set(sites)), proc.returncode


def main():
    count = int(sys.argv[1]) if len(sys.argv) > 1 else 300
    names = sorted(x for x in os.listdir(CORPUS) if x.endswith(".lua_B"))[:count]
    with ThreadPoolExecutor(max_workers=min(8, os.cpu_count() or 4)) as pool:
        results = list(pool.map(one, names))
    total = 0
    for name, sites, code in results:
        if code:
            print("FAIL %s exit=%d" % (name, code))
        for site in sites:
            total += 1
            print("%s %s" % (name, site))
    print("TOTAL sites=%d files=%d" % (total, sum(bool(s) for _, s, _ in results)))
    return 1 if any(code for _, _, code in results) else 0


if __name__ == "__main__":
    raise SystemExit(main())
