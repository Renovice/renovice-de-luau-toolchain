import json, re, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
import irscan
ROOT = Path(__file__).resolve().parents[3].parent
exe = sys.argv[1]; res = sys.argv[2]
stock = ROOT / 'work' / 'stock-2026.10.08.13.05'
d = json.load(open(res))
rows = []
cache = {}
for x in d['results']:
    c = x.get('cfgIdentity') or {}
    if c.get('verdict') != 'FAIL': continue
    for l in c.get('firstDiffs', []):
        m = re.match(r'proto (\d+) CFG_DIFF kind=(\w+) depth=\d+ stock\[(\d+)\]="([^"]*)" candidate\[(\d+)\]="([^"]*)"', l)
        if not m: continue
        p, k, sop, cop = int(m.group(1)), int(m.group(3)), m.group(4), m.group(6)
        if not (sop.startswith('FORGPREP') or cop.startswith('FORGPREP')): continue
        if x['module'] not in cache:
            cache[x['module']] = irscan.parse_text(irscan.dump(exe, stock / x['module']))
        pr = [q for q in cache[x['module']] if q['idx'] == p][0]
        shapes = irscan.generic_for_shapes(pr)
        # loop: prep at k (stock FORGPREP) or the first prep after k
        cand = [s for s in shapes if s['prep'] >= k]
        s = cand[0] if cand else None
        if s:
            brk = [e for e in s['exits'] if e[1] == s['exitPc']]
            oth = [e for e in s['exits'] if e[1] != s['exitPc']]
            shape = f"latches={len(s['latchPreds'])} breaksToExit={len(brk)} otherExits={len(oth)} dist={s['prep']-k}"
        else:
            shape = 'no-forg'
        rows.append((x['module'][:-6], p, f'{sop[:12]} -> {cop[:12]}', shape))
for r in sorted(rows, key=lambda r: r[3]): print(*r, sep='  ')
