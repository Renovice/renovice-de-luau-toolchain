#!/usr/bin/env python3
"""For each FORGPREP-labelled failing prototype: region-tree context of the generic for (forprep agent scratch).

Usage: forg_tree.py EXE RESULTS_JSON [--label-substr FORGPREP] [--env K=V ...]
Prints module, proto, label, the FORGLOOP block, the kind chain from the region holding prep+latch up to 3 levels,
the shape of the loop region (NaturalLoop parts) and the CFG renderer verdict.
"""
import json, os, re, subprocess, sys, collections
from pathlib import Path

exe = str(Path(sys.argv[1]).resolve()); res = sys.argv[2]
sub = 'FORGPREP'; extra = {}
args = sys.argv[3:]
while args:
    a = args.pop(0)
    if a == '--label-substr': sub = args.pop(0)
    elif a == '--env': k, v = args.pop(0).split('=', 1); extra[k] = v
ROOT = Path(__file__).resolve().parents[3].parent
stock = ROOT / 'work' / 'stock-2026.10.08.13.05'
tmp = ROOT / 'work' / 'agents' / 'forprep-runs' / 't' / 'tree.luau'
d = json.load(open(res))
sat = re.compile(r'^SATREE( *)(\d+) (\w+) head=(-?\d+) blocks=([\d,]*)')
node = re.compile(r'^GRAPH_NODE pidx=(\d+) block=(\d+) first=(\d+) last=(\d+) true=(-?\d+) false=(-?\d+) .* term=0x([0-9a-f]+)')


def analyse(module, pidx, k):
    env = dict(os.environ); env.update(extra)
    env['RENOVICE_SATREE_PIDX'] = str(pidx); env['RENOVICE_GRAPH_DUMP_PIDX'] = str(pidx)
    env['RENOVICE_CFG_FOR_DEBUG'] = '1'
    p = subprocess.run([exe, 'decompile-mod-u44', str(stock / module), str(tmp)], capture_output=True, text=True,
                       env=env, errors='replace')
    blocks = {}
    for l in p.stderr.splitlines():
        m = node.match(l)
        if m and int(m.group(1)) == pidx:
            blocks[int(m.group(2))] = dict(first=int(m.group(3)), last=int(m.group(4)), t=int(m.group(5)),
                                           f=int(m.group(6)), term=int(m.group(7), 16))
    regions, stack = {}, []
    for l in p.stderr.splitlines():
        m = sat.match(l)
        if not m: continue
        depth = len(m.group(1)) // 2
        rid = int(m.group(2))
        regions[rid] = dict(kind=m.group(3), head=int(m.group(4)),
                            blocks=[int(b) for b in m.group(5).split(',') if b], depth=depth, parent=None, kids=[])
        stack = stack[:depth]
        if stack:
            regions[rid]['parent'] = stack[-1]; regions[stack[-1]]['kids'].append(rid)
        stack.append(rid)
    # the generic for at/after pc k
    preps = sorted((b for b, v in blocks.items() if v['term'] in (0x0b, 0x30, 0x1b) and v['last'] >= k),
                   key=lambda b: blocks[b]['last'])
    if not preps: return 'no-prep', ''
    prep = preps[0]; latch = blocks[prep]['t']
    # smallest region holding the latch, and its ancestors
    def owner(b):
        best = None
        for rid, r in regions.items():
            if b in r['blocks'] and r['kind'] != 'Basic' and (best is None or len(r['blocks']) < len(regions[best]['blocks'])):
                best = rid
        return best
    lo = owner(latch)
    chain = []
    x = lo
    while x is not None and len(chain) < 4:
        r = regions[x]
        kids = ','.join(f"{regions[c]['kind'][:4]}{'(L)' if latch in regions[c]['blocks'] else ''}{'(P)' if prep in regions[c]['blocks'] else ''}" for c in r['kids'])
        chain.append(f"{r['kind']}[{kids}]")
        x = r['parent']
    cfg = 'RENDERED' if re.search(r'CFG_FOR_RESULT pidx=%d rendered=1' % pidx, p.stderr) else \
        ';'.join(sorted(set(re.findall(r'CFG_FOR_(?:RENDER_)?REJECT pidx=%d (?:phase=\S+ )?reason=(\S+)' % pidx, p.stderr)))) or 'none'
    return ' <- '.join(chain), cfg


rows = []
for x in d['results']:
    c = x.get('cfgIdentity') or {}
    if c.get('verdict') != 'FAIL': continue
    for l in c.get('firstDiffs', []):
        m = re.match(r'proto (\d+) CFG_DIFF kind=\w+ depth=\d+ stock\[(\d+)\]="([^"]*)" candidate\[(\d+)\]="([^"]*)" class="LABEL (.*)"', l)
        if not m or sub not in m.group(6): continue
        shape, cfg = analyse(x['module'], int(m.group(1)), int(m.group(2)))
        rows.append((x['module'][:-6], int(m.group(1)), m.group(6), shape, cfg))
        print(*rows[-1], sep=' | ', flush=True)
print()
cnt = collections.Counter(r[3].split(' <- ')[0] + ' <- ' + (r[3].split(' <- ')[1] if ' <- ' in r[3] else '') for r in rows)
for k, v in cnt.most_common(): print(v, k)
