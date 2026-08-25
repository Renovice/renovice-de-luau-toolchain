#!/usr/bin/env python3
"""Compare one environment-gated experiment against production per file.

Unlike aggregate gates, this prints only files whose back-edge classification or independent category
set changes, which makes a regression attributable instead of sending an investigation through 300
unrelated scripts.

Usage: python cert/ab_compare.py RENOVICE_EXPERIMENT_FLAG [N]
"""
import collections
from concurrent.futures import ThreadPoolExecutor
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import align
import allcats
import backedge


def files(count):
    return sorted(os.path.join(align.CACHE, name) for name in os.listdir(align.CACHE)
                  if name.endswith(".lua_B"))[:count]


def parallel(function, inputs, workers):
    with ThreadPoolExecutor(max_workers=workers) as executor:
        return list(executor.map(function, inputs))


def main():
    if len(sys.argv) not in (2, 3):
        sys.stderr.write("usage: python cert/ab_compare.py RENOVICE_FLAG [N]\n")
        return 2
    flag = sys.argv[1]
    if not flag.startswith("RENOVICE_"):
        sys.stderr.write("FATAL: expected a RENOVICE_* environment flag\n")
        return 2
    count = int(sys.argv[2]) if len(sys.argv) == 3 else 300
    inputs = files(count)

    # Each oracle snapshots a separate environment mapping at import time. Run complete production
    # and candidate passes rather than mutating a mapping while worker threads are active.
    backedge.ENV.pop(flag, None)
    production_edges = parallel(backedge.one, inputs, backedge.WORKERS)
    backedge.ENV[flag] = "1"
    candidate_edges = parallel(backedge.one, inputs, backedge.WORKERS)

    align.ENV.pop(flag, None)
    production_categories = parallel(allcats.one, inputs, align.WORKERS)
    align.ENV[flag] = "1"
    candidate_categories = parallel(allcats.one, inputs, align.WORKERS)

    print("== A/B PER-FILE COMPARISON == files=%d flag=%s" % (len(inputs), flag))
    print("-- BACK EDGES --")
    edge_changes = 0
    for before, after in zip(production_edges, candidate_edges):
        if before[1:] == after[1:]:
            continue
        edge_changes += 1
        print("  %-58s %s %+d %s -> %s %+d %s" % (
            os.path.basename(before[0])[:58], before[1], before[2], before[3:],
            after[1], after[2], after[3:]))
    if not edge_changes:
        print("  (none)")

    print("-- INDEPENDENT CATEGORIES --")
    category_changes = 0
    for before, after in zip(production_categories, candidate_categories):
        if before[1:] == after[1:]:
            continue
        category_changes += 1
        print("  %-58s %s %-22s -> %s %s" % (
            os.path.basename(before[0])[:58], ",".join(sorted(before[1])), before[2],
            ",".join(sorted(after[1])), after[2]))
    if not category_changes:
        print("  (none)")
    print("changed files: backedge=%d categories=%d" % (edge_changes, category_changes))
    return 0


if __name__ == "__main__":
    sys.exit(main())
