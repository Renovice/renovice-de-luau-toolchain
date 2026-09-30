import concurrent.futures as cf, os, subprocess, sys, json
from pathlib import Path
T = Path(r"C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE\repos\toolchains\de-luau-toolchain")
EXE = sys.argv[1] if len(sys.argv) > 1 else str(T / "bin" / "derecomp.b4221c48.exe")
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else Path(__file__).parent / "mods"
N = int(sys.argv[3]) if len(sys.argv) > 3 else 400
STOCK = T / "work" / "u44-rawhash-2026-09-29" / "stock"
tsv = T / "RESEARCH" / "CFG_IDENTITY_GATE_2026-09-29" / "evidence" / "u44-full-after-results.tsv"
fails = []
for line in open(tsv, encoding="utf-8").read().splitlines()[1:]:
    f = line.split("\t")
    if f[14] == "FAIL": fails.append(f[0])
fails.sort(key=lambda m: (STOCK / m).stat().st_size)
fails = fails[:N]
OUT.mkdir(parents=True, exist_ok=True)

def one(m):
    d = OUT / m.replace(".lua_B", "")
    d.mkdir(exist_ok=True)
    s1, b1 = d / "s1.luau", d / "b1.lua_B"
    subprocess.run([EXE, "decompile-mod-u44", str(STOCK / m), str(s1)], capture_output=True)
    subprocess.run([EXE, "recompile-u44", str(s1), str(b1)], capture_output=True)
    r = subprocess.run([EXE, "cfg-identity", str(STOCK / m), str(b1), "--u44"], capture_output=True, text=True)
    return m, [l for l in r.stdout.splitlines() if l.startswith(("proto ", "CFG_IDENTITY"))]

with cf.ThreadPoolExecutor(8) as p:
    res = dict(p.map(one, fails))
json.dump(res, open(OUT.parent / (OUT.name + ".json"), "w"), indent=1)
print(len(res))
