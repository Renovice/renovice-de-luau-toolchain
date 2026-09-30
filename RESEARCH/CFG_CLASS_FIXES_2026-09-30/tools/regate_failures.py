#!/usr/bin/env python3
"""Re-gate the kept first-pass rebuilds of one corpus run with a different cfg-identity binary.

Attribution helper: the kept FAIL artifacts of the BEFORE run (u44_rawhash_roundtrip.py --keep)
hold the old pipeline's b1. Gating them with the NEW gate separates gate-normalization gains from
pipeline (decompiler) gains without another full corpus run. Only cfg-identity is re-run.

Usage: regate_failures.py GATE_EXE STOCK_DIR FAILURES_DIR OUT.json [--jobs N] [--env NAME=VALUE ...]
"""
import argparse, collections, concurrent.futures as cf, json, os, re, subprocess
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("gate"); ap.add_argument("stock"); ap.add_argument("failures"); ap.add_argument("out")
    ap.add_argument("--jobs", type=int, default=4)
    ap.add_argument("--env", action="append", default=[])
    args = ap.parse_args()
    args.gate = str(Path(args.gate).resolve())
    env = dict(os.environ)
    for item in args.env:
        key, _, value = item.partition("=")
        env[key] = value

    def one(module_dir):
        b1 = module_dir / "b1.lua_B"
        if not b1.exists():
            return module_dir.name, None
        p = subprocess.run([args.gate, "cfg-identity", str(Path(args.stock) / module_dir.name), str(b1), "--u44"],
                           capture_output=True, text=True, env=env, timeout=300)
        m = re.search(r"CFG_IDENTITY protos_stock=(\d+) protos_candidate=(\d+) cfg_equal=(\d+) "
                      r"model_errors=(\d+) candidate_dispatch_webs=(\d+) verdict=(\w+)", p.stdout)
        if not m:
            return module_dir.name, {"verdict": "ERROR"}
        diffs = [line for line in p.stdout.splitlines() if line.startswith("proto ")]
        return module_dir.name, {"verdict": m.group(6), "protosStock": int(m.group(1)),
                                 "protosCandidate": int(m.group(2)), "cfgEqual": int(m.group(3)),
                                 "firstDiffs": diffs[:6]}

    dirs = sorted(p for p in Path(args.failures).iterdir() if p.is_dir())
    with cf.ThreadPoolExecutor(args.jobs) as pool:
        results = dict(pool.map(one, dirs))
    verdicts = collections.Counter((r or {}).get("verdict", "NO_B1") for r in results.values())
    summary = {"gate": args.gate, "modules": len(results), "verdicts": dict(verdicts)}
    json.dump({"summary": summary, "results": results}, open(args.out, "w", encoding="utf-8"), indent=1)
    print(json.dumps(summary, indent=1))


if __name__ == "__main__":
    main()
