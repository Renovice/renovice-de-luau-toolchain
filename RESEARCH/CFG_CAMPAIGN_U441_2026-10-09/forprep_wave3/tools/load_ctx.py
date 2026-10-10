import json, re, sys, collections
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent)); import irscan
exe = sys.argv[1]; res = sys.argv[2]; pref = sys.argv[3] if len(sys.argv) > 3 else 'LOAD ->'
stock = Path(__file__).resolve().parents[3] / "stock-2026.10.08.13.05"
d = json.load(open(res)); cache = {}; cnt = collections.Counter(); rows = []
for x in d['results']:
    for l in (x.get('cfgIdentity') or {}).get('firstDiffs', []):
        m = re.match(r'proto (\d+) CFG_DIFF kind=\w+ depth=\d+ stock\[(\d+)\]="([^"]*)" candidate\[(\d+)\]="([^"]*)" class="LABEL (.*)"', l)
        if not m or not m.group(6).startswith(pref): continue
        if x['module'] not in cache: cache[x['module']] = irscan.parse_text(irscan.dump(exe, stock / x['module']))
        p = [q for q in cache[x['module']] if q['idx'] == int(m.group(1))][0]
        k = int(m.group(2)); ins = p['insns']; pc2i = {pc: i for i, (pc, *_r) in enumerate(ins)}
        i = pc2i.get(k, 0); nxt = [o for (_, o, _, _) in ins[i:i + 6]]
        ctx = 'FORNPREP<=5' if 'FORNPREP' in nxt else ('FORGPREP<=5' if any(o.startswith('FORGPREP') for o in nxt) else 'other')
        cnt[(m.group(6), ctx)] += 1
        rows.append((x['module'][:-6], m.group(1), m.group(6), m.group(3), m.group(5), ctx))
for r in sorted(rows, key=lambda r: (r[2], r[5])): print(*r, sep=' | ')
for k, v in cnt.most_common(): print(v, k)
