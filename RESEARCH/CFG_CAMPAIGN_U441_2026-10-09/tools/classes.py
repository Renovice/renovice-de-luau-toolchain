#!/usr/bin/env python3
"""Failure distribution of a cert/u44_rawhash_roundtrip.py run (2026-10-09 campaign, PITFALLS D3: attack shapes by
frequency).

Usage: python classes.py RESULTS_JSON STOCK_DIR [--top N] [--examples K] [--json OUT]

Per module the first-mismatch CFG-ID classes (by prototype) are read from the run; a module can carry several classes
(one per failing prototype), so the per-class module counts do NOT sum to the failing-module count (B9). Also listed:
modules failing CONST-ID only, PROTO_COUNT modules (prototype count differs: per-index comparison is meaningless, C2),
decompile/recompile/determinism failures, and the K smallest stock modules per class (smallest = cheapest repro).
"""
import argparse, json
from pathlib import Path

ap = argparse.ArgumentParser()
ap.add_argument('results'); ap.add_argument('stock')
ap.add_argument('--top', type=int, default=40); ap.add_argument('--examples', type=int, default=6)
ap.add_argument('--json', default=None)
a = ap.parse_args()
data = json.loads(Path(a.results).read_text(encoding='utf-8'))
res = data['results']
size = {p.name: p.stat().st_size for p in Path(a.stock).iterdir() if p.suffix == '.lua_B'}

def mod(r): return Path(r['module']).name

stages = {k: [mod(r) for r in res if not r.get(k)] for k in ('decompile', 'recompile', 'deterministic')}
cfg_fail = [r for r in res if r.get('cfgIdentity', {}).get('verdict') != 'PASS']
const_fail = [r for r in res if r.get('constIdentity', {}).get('verdict') != 'PASS']
both_pass = [r for r in res if r.get('cfgIdentity', {}).get('verdict') == 'PASS'
             and r.get('constIdentity', {}).get('verdict') == 'PASS']
proto_count = [mod(r) for r in cfg_fail if r.get('cfgIdentity', {}).get('protosStock') is not None
               and r['cfgIdentity']['protosStock'] != r['cfgIdentity'].get('protosCandidate')]
by_class = {}
for r in cfg_fail:
    for cls, n in r.get('cfgIdentity', {}).get('classes', {}).items():
        e = by_class.setdefault(cls, {'modules': [], 'protos': 0})
        e['modules'].append(mod(r)); e['protos'] += n
only_const = [mod(r) for r in const_fail if r.get('cfgIdentity', {}).get('verdict') == 'PASS']
no_class = [mod(r) for r in cfg_fail if not r.get('cfgIdentity', {}).get('classes') and mod(r) not in proto_count]

out = {'modules': len(res), 'constAndCfgPass': len(both_pass), 'cfgFail': len(cfg_fail), 'constFail': len(const_fail),
       'constFailOnly': only_const, 'protoCount': sorted(proto_count, key=lambda m: size.get(m, 0)),
       'cfgFailWithoutClass': no_class, 'stageFailures': stages, 'classes': {}}
for cls, e in sorted(by_class.items(), key=lambda kv: -len(kv[1]['modules']))[:a.top]:
    ex = sorted(e['modules'], key=lambda m: size.get(m, 0))[:a.examples]
    out['classes'][cls] = {'modules': len(e['modules']), 'protos': e['protos'],
                           'examples': [f'{m} ({size.get(m, 0)} B)' for m in ex]}
print(f"modules {out['modules']}  CONST+CFG PASS {out['constAndCfgPass']}  CFG FAIL {out['cfgFail']}  "
      f"CONST FAIL {out['constFail']} (CONST only {len(only_const)})  PROTO_COUNT {len(proto_count)}  "
      f"CFG FAIL w/o class {len(no_class)}  stage failures "
      + ', '.join(f'{k} {len(v)}' for k, v in stages.items()))
for cls, e in out['classes'].items():
    print(f"{e['modules']:5d} mod {e['protos']:6d} proto  {cls}   e.g. {', '.join(e['examples'][:3])}")
if a.json:
    Path(a.json).write_text(json.dumps(out, indent=1), encoding='utf-8')
