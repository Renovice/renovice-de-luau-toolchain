#!/usr/bin/env python3
"""Split the failing modules of a roundtrip run into diagnosis families by the FIRST operation of their CFG-ID
first-mismatch labels (2026-10-09 campaign). A module with several failing prototypes can sit in several families; a
family is a work queue for one diagnosis agent, not a partition (PITFALLS B9).

Usage: python families.py RESULTS_JSON STOCK_DIR OUT_DIR
Writes OUT_DIR/<family>.txt (one module file name per line, smallest stock first) and OUT_DIR/families.json.
"""
import json, sys
from pathlib import Path

results, stock, out = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
res = json.loads(results.read_text(encoding='utf-8'))['results']
size = {p.name: p.stat().st_size for p in stock.iterdir() if p.suffix == '.lua_B'}
ACCESS = ('GETIMPORT', 'GETUPVAL', 'GETFIELD', 'NAMECALL', 'GETTABLE', 'GETTABLEN', 'GETTABLEKS', 'GETGLOBAL', 'CALL')


def family(label):
    op = label.replace('LABEL ', '').split(' -> ')[0].split()[0]
    if op == 'LOAD':
        return 'A_load_order'
    if op in ACCESS:
        return 'B_access_order'
    if op == 'IF':
        return 'C_conditions'
    if op.startswith(('SET', 'NEWTABLE', 'DUPTABLE', 'FOR', 'RETURN', 'CLOSURE', 'CAPTURE')):
        return 'D_tables_loops_returns'
    return 'D_tables_loops_returns'


fams = {}
for r in res:
    name = Path(r['module']).name
    c = r.get('cfgIdentity', {})
    if not r.get('decompile') or not r.get('recompile'):
        fams.setdefault('E_stage_failures', set()).add(name)
        continue
    if c.get('verdict') == 'FAIL' and c.get('protosStock') != c.get('protosCandidate'):
        fams.setdefault('E_proto_count', set()).add(name)
        continue
    if c.get('verdict') == 'PASS' and r.get('constIdentity', {}).get('verdict') != 'PASS':
        fams.setdefault('E_const_only', set()).add(name)
    for label in c.get('classes', {}):
        fams.setdefault(family(label), set()).add(name)
out.mkdir(parents=True, exist_ok=True)
summary = {}
for f, mods in sorted(fams.items()):
    ordered = sorted(mods, key=lambda m: size.get(m, 0))
    (out / f'{f}.txt').write_text('\n'.join(ordered) + '\n', encoding='utf-8')
    summary[f] = len(ordered)
(out / 'families.json').write_text(json.dumps(summary, indent=1), encoding='utf-8')
print(summary)
