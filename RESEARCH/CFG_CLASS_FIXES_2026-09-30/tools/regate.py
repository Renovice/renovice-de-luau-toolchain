"""Re-run only cfg-identity over sampled modules (b1 already built). usage: regate.py GATE_EXE MODS_DIR OUT_JSON [env=val ...]"""
import concurrent.futures as cf, os, subprocess, sys, json, collections
from pathlib import Path
T = Path(r"C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE\repos\toolchains\de-luau-toolchain")
STOCK = T / "work" / "u44-rawhash-2026-09-29" / "stock"
EXE, MODS, OUT = sys.argv[1], Path(sys.argv[2]), sys.argv[3]
env = dict(os.environ)
for kv in sys.argv[4:]:
    k, v = kv.split("=", 1); env[k] = v

def one(d):
    r = subprocess.run([EXE, "cfg-identity", str(STOCK / (d.name + ".lua_B")), str(d / "b1.lua_B"), "--u44"], capture_output=True, text=True, env=env)
    return d.name, [l for l in r.stdout.splitlines() if l.startswith(("proto ", "CFG_IDENTITY"))]

dirs = sorted(p for p in MODS.iterdir() if (p / "b1.lua_B").exists())
with cf.ThreadPoolExecutor(10) as p:
    res = dict(p.map(one, dirs))
json.dump(res, open(OUT, "w"), indent=1)
c = collections.Counter(); ok = 0
for m, ls in res.items():
    if ls and ls[-1].endswith("verdict=PASS"): ok += 1
    for l in ls:
        if "class=" in l: c[l.split("class=")[1]] += 1
print("PASS", ok, "of", len(res))
for k, v in c.most_common(15): print(v, k)
