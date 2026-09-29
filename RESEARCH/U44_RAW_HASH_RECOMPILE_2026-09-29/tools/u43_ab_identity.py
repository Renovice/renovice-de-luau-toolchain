#!/usr/bin/env python3
"""U43 A/B identity: prove the legacy (U43) decompile and recompile outputs are byte-identical
between a baseline derecomp and a candidate derecomp over a corpus directory.

For every module: `decompile-mod` with both binaries (sources must be identical, including failure
status), then `recompile` of the baseline source with both binaries (bytes must be identical).
Usage: python u43_ab_identity.py BASE_EXE NEW_EXE CORPUS_DIR OUT_JSON [--jobs N] [--tmp DIR]
"""
import argparse, concurrent.futures as cf, hashlib, json, shutil, subprocess, tempfile, time
from pathlib import Path


def run(exe, args, cwd):
    try:
        p = subprocess.run([exe] + [str(a) for a in args], cwd=cwd, capture_output=True, timeout=600)
        return p.returncode
    except subprocess.TimeoutExpired:
        return 124


def one(path, a):
    work = Path(tempfile.mkdtemp(prefix="u43ab-", dir=a.tmp))
    r = {"module": path.name}
    try:
        sb, sn = work / "b.luau", work / "n.luau"
        rb, rn = run(a.base, ["decompile-mod", path, sb], work), run(a.new, ["decompile-mod", path, sn], work)
        r["decompileRc"] = [rb, rn]
        tb = sb.read_bytes() if sb.exists() else None
        tn = sn.read_bytes() if sn.exists() else None
        r["sourceIdentical"] = rb == rn and tb == tn
        if rb != 0 or tb is None:
            return r
        bb, bn = work / "b.lua_B", work / "n.lua_B"
        cb, cn = run(a.base, ["recompile", sb, bb], work), run(a.new, ["recompile", sb, bn], work)
        r["recompileRc"] = [cb, cn]
        r["bytecodeIdentical"] = cb == cn and (bb.read_bytes() if bb.exists() else None) == (bn.read_bytes() if bn.exists() else None)
        if bb.exists():
            r["sha256"] = hashlib.sha256(bb.read_bytes()).hexdigest()
        return r
    finally:
        shutil.rmtree(work, ignore_errors=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("base"); ap.add_argument("new"); ap.add_argument("corpus"); ap.add_argument("out")
    ap.add_argument("--jobs", type=int, default=12); ap.add_argument("--tmp", default=None)
    a = ap.parse_args()
    a.base, a.new = str(Path(a.base).resolve()), str(Path(a.new).resolve())
    files = sorted(p.resolve() for p in Path(a.corpus).iterdir() if p.suffix == ".lua_B")
    t0 = time.time()
    with cf.ThreadPoolExecutor(a.jobs) as pool:
        results = list(pool.map(lambda p: one(p, a), files))
    s = {
        "baseSha256": hashlib.sha256(Path(a.base).read_bytes()).hexdigest(),
        "newSha256": hashlib.sha256(Path(a.new).read_bytes()).hexdigest(),
        "modules": len(results),
        "sourceIdentical": sum(1 for r in results if r.get("sourceIdentical")),
        "decompileFailedBoth": sum(1 for r in results if r["decompileRc"][0] != 0 and r["decompileRc"][1] != 0),
        "recompiled": sum(1 for r in results if "recompileRc" in r),
        "bytecodeIdentical": sum(1 for r in results if r.get("bytecodeIdentical")),
        "recompileFailedBoth": sum(1 for r in results if "recompileRc" in r and r["recompileRc"][0] != 0 and r["recompileRc"][1] != 0),
        "seconds": round(time.time() - t0, 1),
    }
    s["mismatches"] = [r for r in results if not r.get("sourceIdentical") or ("recompileRc" in r and not r.get("bytecodeIdentical"))]
    Path(a.out).write_text(json.dumps({"summary": s, "results": results}, indent=1))
    print(json.dumps({k: v for k, v in s.items() if k != "mismatches"}, indent=1), "mismatches:", len(s["mismatches"]))


if __name__ == "__main__":
    main()
