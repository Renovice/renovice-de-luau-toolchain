#!/usr/bin/env python3
"""Focused discriminator for the liveness-proven loop-free LOADN short-circuit fold.

The broad experiment passed sampled behavior while emitting `left and right` for bytecode whose
two branch-taken predicates reach the same target (`left or right`). This gate pins the real Grid
counterexample and the BoosterInfo loop-boundary rejection so aggregate gates cannot miss either.
"""
import os
import re
import subprocess
import sys

from workspace_paths import corpus_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC = os.path.join(ROOT, "bin", "derecomp.exe")
CACHE = corpus_cache(ROOT)
BASE_ENV = dict(os.environ)
BASE_ENV.pop("RENOVICE_SC_LOADN_FOLD", None)


def decompile(name, candidate):
    env = dict(BASE_ENV)
    if candidate:
        env["RENOVICE_SC_LOADN_FOLD"] = "1"
    path = os.path.join(CACHE, name)
    proc = subprocess.run([DEC, "decompile-mod", path], cwd=ROOT, env=env,
                          capture_output=True, text=True, encoding="utf-8", errors="replace",
                          timeout=180)
    if proc.returncode != 0 or not proc.stdout:
        raise RuntimeError("decompile failed for %s candidate=%s: %s" %
                           (name, candidate, (proc.stderr or "empty source").strip()))
    return proc.stdout


def main():
    if not os.path.isdir(CACHE):
        print("FATAL: corpus missing at %s" % CACHE)
        return 2

    grid_base = decompile("EE_Interface_Components_Grid.lua_B", False)
    grid_candidate = decompile("EE_Interface_Components_Grid.lua_B", True)
    booster_base = decompile("Lotus_Interface_Components_BoosterInfo.lua_B", False)
    booster_candidate = decompile("Lotus_Interface_Components_BoosterInfo.lua_B", True)

    # Real ground-truth chain: first branch exits when direction ~= UP; only its false arm evaluates
    # `1 < row`, whose true branch reaches the SAME exit. Branch-taken predicate = left OR right.
    expected = re.search(r"if\s+c26v1\s*~=\s*c26v5\s+or\s+1\s*<\s*c26v4\s+then",
                         grid_candidate) is not None
    rejected_wrong_and = re.search(
        r"if\s+c26v1\s*~=\s*c26v5\s+and\s+1\s*<\s*c26v4\s+then", grid_candidate) is None
    changed_grid = grid_candidate != grid_base
    loop_rejected = booster_candidate == booster_base

    inputs = ((False, False), (False, True), (True, False), (True, True))
    expected_truth = [False, True, True, True]
    truth = ([left or right for left, right in inputs] == expected_truth
             and [left and right for left, right in inputs] != expected_truth)
    checks = {
        "GRID_CHANGED": changed_grid,
        "GRID_SAME_TARGET_USES_OR": expected,
        "GRID_WRONG_AND_ABSENT": rejected_wrong_and,
        "BOOSTER_LOOP_PROTO_REJECTED": loop_rejected,
        "OR_TRUTH_TABLE_4_OF_4": truth,
    }
    for name, passed in checks.items():
        print("%-30s %s" % (name, "PASS" if passed else "FAIL"))
    print("VERDICT %s" % ("PASS" if all(checks.values()) else "FAIL"))
    return 0 if all(checks.values()) else 1


if __name__ == "__main__":
    sys.exit(main())
