#!/usr/bin/env python3
"""Re-gate the kept U44 first-pass failures with a given derecomp and classify them, then compare
with the U43 baseline results for the same module names.

Usage: python classify_failures.py EXE U44_RESULTS_DIR U44_STOCK_DIR U43_RESULTS_JSON OUT_JSON
Categories (U44): pass-after-regate (the final gate's access normalization / boolean separation
accepts it), class-swap (hash/string class loss -- the defect this work removes), proto-count
(the recompiled module has a different prototype count), structural (same prototype count, other
constant or key-use differences).
"""
import collections, json, os, re, subprocess, sys
from pathlib import Path

exe, u44_dir, stock_dir, u43_json, out_json = sys.argv[1:6]
exe = os.path.abspath(exe)
u44 = json.load(open(Path(u44_dir) / "results-u44.json"))
u43 = {r["module"]: r for r in json.load(open(u43_json))["results"]}
rows, cats = [], collections.Counter()
for r in u44["results"]:
    if r.get("constIdentity", {}).get("verdict") == "PASS":
        continue
    m = r["module"]
    row = {"module": m}
    if not r.get("decompile") or not r.get("recompile"):
        row["class"] = "no-candidate"; row["error"] = (r.get("error") or "")[:200]
    else:
        cand = Path(u44_dir) / "failures" / m / "b1.lua_B"
        out = subprocess.run([exe, "const-identity", os.path.abspath(Path(stock_dir) / m), os.path.abspath(cand), "--u44"],
                             capture_output=True, text=True).stdout
        v = re.search(r"verdict=(\w+)", out).group(1)
        swaps = int(re.search(r"hash_string_class_swaps=(\d+)", out).group(1))
        counts = re.search(r"protos_stock=(\d+) protos_candidate=(\d+)", out).groups()
        row.update(verdict=v, swaps=swaps, protos=counts,
                   diffs=[l for l in out.splitlines() if l.startswith("proto ")][:3])
        row["class"] = ("pass-after-regate" if v == "PASS" else "class-swap" if swaps else
                        "proto-count" if counts[0] != counts[1] else "structural")
    b = u43.get(m)
    if b is None:
        row["u43"] = "absent"
    else:
        c = b.get("constIdentity", {})
        row["u43"] = ("decompile-fail" if not b.get("decompile") else
                      "proto-count" if c.get("protosStock") != c.get("protosCandidate") else
                      "structural" if c.get("otherKeyUseDiffs", 0) > 0 or c.get("verdict") != "PASS" and not c.get("classSwaps") else
                      "class-swap-only" if c.get("verdict") != "PASS" else "pass")
    cats[(row["class"], row["u43"])] += 1
    rows.append(row)
summary = {f"{k[0]} | u43={k[1]}": v for k, v in sorted(cats.items())}
json.dump({"summary": summary, "rows": rows}, open(out_json, "w"), indent=1)
print(json.dumps(summary, indent=1))
