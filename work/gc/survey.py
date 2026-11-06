"""Per failing proto: CFG-ID diff + CFG renderer reject reasons/debug lines for that proto."""
import json, os, re, subprocess, sys, tempfile, concurrent.futures as cf
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
EXE = str(ROOT / "bin" / (sys.argv[1] if len(sys.argv) > 1 else "derecomp.exe"))
STOCK = ROOT.parent / "de-luau-toolchain/work/failure-clusters-2026-11-02/stock-2026.10.22.13.12"
base = json.load(open(ROOT / "work/me/rt_full6/results-u44.json"))["results"]
mods = [r["module"] for r in base if r.get("cfgIdentity", {}).get("verdict") != "PASS"]
env = dict(os.environ, RENOVICE_CFG_FOR_DEBUG="1")

def one(m):
    d = Path(tempfile.mkdtemp(dir=ROOT / "work/gc"))
    s1, b1 = d / "s1.luau", d / "b1.lua_B"
    p = subprocess.run([EXE, "decompile-mod-u44", str(STOCK / m), str(s1)], capture_output=True, text=True,
                       env=env, errors="replace", timeout=300)
    subprocess.run([EXE, "recompile-u44", str(s1), str(b1)], capture_output=True, timeout=300)
    c = subprocess.run([EXE, "cfg-identity", str(STOCK / m), str(b1), "--u44"], capture_output=True, text=True,
                       errors="replace", timeout=300).stdout
    fails = {}
    for line in c.splitlines():
        mm = re.match(r"proto (\d+) CFG_DIFF .*class=\"([^\"]*)\"", line)
        if mm: fails[int(mm.group(1))] = mm.group(2)
    dbg = {}
    for line in p.stderr.splitlines():
        mm = re.search(r"pidx=(\d+)", line)
        if mm and int(mm.group(1)) in fails:
            k = re.sub(r"=-?\d+", "", line) if "RENDER_REJECT" not in line else line
            dbg.setdefault(int(mm.group(1)), []).append(line.strip())
    for f in d.iterdir(): f.unlink()
    d.rmdir()
    return m, {str(k): {"diff": v, "dbg": dbg.get(k, [])} for k, v in fails.items()}

out = {}
with cf.ThreadPoolExecutor(20) as ex:
    for m, r in ex.map(one, mods):
        out[m] = r
json.dump(out, open(ROOT / "work/gc/survey.json", "w"), indent=1)
print(len(out), "modules", sum(len(v) for v in out.values()), "failing protos")
