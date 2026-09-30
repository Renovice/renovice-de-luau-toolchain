"""Scratch sampler: rebuild selected stock modules with a pipeline exe and gate them (cfg-identity)."""
import concurrent.futures as cf, json, os, re, subprocess, sys
from pathlib import Path
T = Path(__file__).resolve().parents[3]
STOCK = T / "work" / "u44-rawhash-2026-09-29" / "stock"
EXE, OUT, CLASSES = sys.argv[1], Path(sys.argv[2]), sys.argv[3].split("|")
LIMIT = int(sys.argv[4]) if len(sys.argv) > 4 else 100000
d = json.load(open(Path(os.environ.get("SAMPLE_RESULTS", str(T / "work/forloops-2026-09-30/before/results-u44.json")))))
mods = []
for r in d["results"]:
    c = r.get("cfgIdentity", {})
    if CLASSES == ["PASS"]:
        if c.get("verdict") == "PASS": mods.append((r["module"], c["cfgEqual"], c["protosStock"]))
        continue
    if c.get("verdict") != "FAIL" or not c.get("firstDiffs"): continue
    m = re.search(r'class="([^"]*)"', c["firstDiffs"][0])
    if m and (m.group(1) in CLASSES or CLASSES == ["*"]):
        mods.append((r["module"], c["cfgEqual"], c["protosStock"]))
mods.sort(key=lambda x: (STOCK / x[0]).stat().st_size)
mods = mods[:LIMIT]
OUT.mkdir(parents=True, exist_ok=True)
def one(item):
    m, before_eq, total = item
    import hashlib, shutil
    dd = OUT / (m[:60] if len(m) <= 60 else hashlib.sha1(m.encode()).hexdigest()[:16]); dd.mkdir(exist_ok=True)
    (dd / "module.txt").write_text(m)
    st = dd / "stock.lua_B"
    shutil.copyfile(STOCK / m, st)
    s1, b1 = dd / "s1.luau", dd / "b1.lua_B"
    subprocess.run([EXE, "decompile-mod-u44", str(st), str(s1)], capture_output=True)
    subprocess.run([EXE, "recompile-u44", str(s1), str(b1)], capture_output=True)
    r = subprocess.run([EXE, "cfg-identity", str(st), str(b1), "--u44"], capture_output=True, text=True)
    line = [l for l in r.stdout.splitlines() if l.startswith("CFG_IDENTITY")]
    mm = re.search(r"cfg_equal=(\d+)", line[0]) if line else None
    eq = mm.group(1) if mm else "-1"
    if not mm: print("NOPARSE", m, line[:1], r.stdout[-300:])
    verdict = line[0].rsplit("=", 1)[-1] if line else "ERROR"
    diffs = [l for l in r.stdout.splitlines() if l.startswith("proto ")]
    return {"module": m, "before": before_eq, "after": int(eq), "total": total, "verdict": verdict, "diffs": diffs[:4]}
with cf.ThreadPoolExecutor(8) as p:
    res = list(p.map(one, mods))
json.dump(res, open(str(OUT) + ".json", "w"), indent=1)
print("modules", len(res), "PASS", sum(r["verdict"] == "PASS" for r in res),
      "gained", sum(r["after"] > r["before"] for r in res), "lost", sum(r["after"] < r["before"] for r in res))
for r in res:
    if r["after"] < r["before"]: print("LOST", r["module"], r["before"], r["after"])
