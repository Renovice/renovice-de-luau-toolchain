"""Scratch: re-gate kept rebuilds (<dir>/<module>/b1.lua_B) against stock with a gate exe."""
import concurrent.futures as cf, json, re, subprocess, sys, os
from pathlib import Path
T = Path(__file__).resolve().parents[2]
STOCK = T / "work" / "u44-rawhash-2026-09-29" / "stock"
GATE, SRC = sys.argv[1], Path(sys.argv[2])
env = dict(os.environ)
def one(d):
    b1 = d / "b1.lua_B"
    if not b1.exists(): return d.name, None, None
    st = d / "stock.lua_B"
    name = (d / "module.txt").read_text()[:-6] if (d / "module.txt").exists() else d.name
    if not st.exists(): st = STOCK / (d.name + ".lua_B")
    r = subprocess.run([GATE, "cfg-identity", str(st), str(b1), "--u44"], capture_output=True, text=True, env=env)
    line = [l for l in r.stdout.splitlines() if l.startswith("CFG_IDENTITY")]
    if not line: return name, "ERROR", -1
    return name, line[0].rsplit("=", 1)[-1], int(re.search(r"cfg_equal=(\d+)", line[0]).group(1))
dirs = sorted(p for p in SRC.iterdir() if p.is_dir())
with cf.ThreadPoolExecutor(8) as p:
    res = list(p.map(one, dirs))
out = {m: [v, e] for m, v, e in res}
json.dump(out, open(sys.argv[3], "w"), indent=0)
print("modules", len(res), "PASS", sum(1 for _, v, _ in res if v == "PASS"), "protos_equal", sum(e for _, _, e in res if e and e > 0))
