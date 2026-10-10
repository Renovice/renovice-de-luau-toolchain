#!/usr/bin/env python3
"""Compare two u44_rawhash_roundtrip result sets on the AFTER run's module set (forprep agent scratch).

Usage: cmp.py BEFORE_RESULTS_JSON AFTER_RESULTS_JSON [--list FILE]
Counts per gate (CFG-ID, CONST-ID, dataflow, CFG+dataflow, compiler-closed, equal prototypes on prototype-aligned
modules), and every transition by module name; every module losing equal prototypes, closure or any PASS.
"""
import json, sys
from pathlib import Path

b = {r['module']: r for r in json.load(open(sys.argv[1]))['results']}
a = {r['module']: r for r in json.load(open(sys.argv[2]))['results']}
mods = sorted(a)
if '--list' in sys.argv:
    want = {l.strip() for l in open(sys.argv[sys.argv.index('--list') + 1]) if l.strip()}
    mods = [m for m in mods if m in want]
missing = [m for m in mods if m not in b]
mods = [m for m in mods if m in b]


def v(r, k):
    return (r.get(k) or {}).get('verdict') == 'PASS'


def eq(r):
    c = r.get('cfgIdentity') or {}
    if c.get('protosStock') is None or c.get('protosStock') != c.get('protosCandidate'): return None
    return c.get('cfgEqual', 0), c['protosStock']


gates = {'CFG-ID': lambda r: v(r, 'cfgIdentity'), 'CONST-ID': lambda r: v(r, 'constIdentity'),
         'DATAFLOW': lambda r: v(r, 'dataflowIdentity'),
         'CFG+DF': lambda r: v(r, 'cfgIdentity') and v(r, 'dataflowIdentity'),
         'CLOSED': lambda r: r.get('closedAtPass') is not None,
         'CLOSED-CFG': lambda r: r.get('closedAtPass') is not None and ((r.get('closedCfgIdentity') or r.get('cfgIdentity') or {}).get('verdict') == 'PASS'),
         'CLOSED-CONST': lambda r: r.get('closedAtPass') is not None and ((r.get('closedConstIdentity') or r.get('constIdentity') or {}).get('verdict') == 'PASS')}
print(f'modules {len(mods)} (missing in before: {len(missing)})')
for name, f in gates.items():
    nb = sum(1 for m in mods if f(b[m])); na = sum(1 for m in mods if f(a[m]))
    up = [m for m in mods if not f(b[m]) and f(a[m])]
    down = [m for m in mods if f(b[m]) and not f(a[m])]
    print(f'{name:12s} {nb:5d} -> {na:5d}   FAIL->PASS {len(up):4d}   PASS->FAIL {len(down):4d}')
    if down: print('    PASS->FAIL:', ', '.join(m[:-6] for m in down))
    if up and name in ('CFG-ID', 'CLOSED', 'DATAFLOW'): print('    FAIL->PASS:', ', '.join(m[:-6] for m in up))
pb = pa = tot = 0; losses = []; gains = 0
for m in mods:
    eb, ea = eq(b[m]), eq(a[m])
    if eb is None or ea is None:
        if (eb is None) != (ea is None): losses.append(f'{m[:-6]} proto-count alignment {eb} -> {ea}')
        continue
    pb += eb[0]; pa += ea[0]; tot += eb[1]
    if ea[0] < eb[0]: losses.append(f'{m[:-6]} equal protos {eb[0]} -> {ea[0]} of {eb[1]}')
    if ea[0] > eb[0]: gains += 1
print(f'equal prototypes (aligned in both) {pb} -> {pa} of {tot}; modules gaining {gains}, losing {len(losses)}')
for l in losses: print('    LOSS', l)
for m in mods:
    for k in ('decompile', 'recompile', 'deterministic'):
        if b[m].get(k) and not a[m].get(k): print('    STAGE LOSS', m, k)
