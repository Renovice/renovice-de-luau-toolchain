#!/usr/bin/env python3
"""Parse `derecomp ir-u44` dumps (forprep agent scratch tool, 2026-10-10).

parse(path) -> list of protos: {'idx', 'insns': [(pc, op, text, target)]}
generic_for_shapes(proto) -> per FORGLOOP: latch preds (jumps into the FORGLOOP from the body), exits.
"""
import re, subprocess, sys
from pathlib import Path

EXE = None
HEAD = re.compile(r'^== proto\[(\d+)\]')
INS = re.compile(r'^  \[ *(\d+)\] (\S+)\s*(.*)$')
TGT = re.compile(r'-> \[(\d+)\]')


def dump(exe, path):
    p = subprocess.run([str(Path(exe).resolve()), 'ir-u44', str(path)], capture_output=True, text=True, errors='replace')
    return p.stdout


def parse_text(text):
    protos, cur = [], None
    for line in text.splitlines():
        m = HEAD.match(line)
        if m:
            cur = {'idx': int(m.group(1)), 'insns': []}; protos.append(cur); continue
        m = INS.match(line)
        if m and cur is not None:
            t = TGT.search(m.group(3))
            cur['insns'].append((int(m.group(1)), m.group(2), m.group(3).strip(), int(t.group(1)) if t else None))
    return protos


UNCOND = {'JUMP', 'JUMPBACK', 'RETURN', 'JUMPX'}


def successors(ins, i):
    pc, op, text, tgt = ins[i]
    nxt = ins[i + 1][0] if i + 1 < len(ins) else None
    if op in ('RETURN',):
        return []
    if op in ('JUMP', 'JUMPBACK', 'JUMPX'):
        return [tgt]
    if op.startswith('FORGPREP'):
        return [tgt]
    if tgt is not None:
        return [tgt, nxt]
    if op == 'LOADB':
        m = re.search(r'C=(\d+)', text)
        if m and int(m.group(1)):
            # skip C instructions (pc units are instruction indexes here)
            j = i + 1 + int(m.group(1))
            return [ins[j][0] if j < len(ins) else None]
    return [nxt]


def generic_for_shapes(proto):
    ins = proto['insns']
    pc2i = {pc: i for i, (pc, *_r) in enumerate(ins)}
    out = []
    for i, (pc, op, text, tgt) in enumerate(ins):
        if not op.startswith('FORGPREP'):
            continue
        L = tgt
        if L not in pc2i:
            continue
        li = pc2i[L]
        H = ins[li][3]
        latch_preds, exits = [], []
        for j in range(pc2i.get(H, li), li):
            for s in successors(ins, j):
                if s == L:
                    latch_preds.append(ins[j][0])
                elif s is not None and not (H <= s <= L):
                    exits.append((ins[j][0], s))
        out.append({'prep': pc, 'loop': L, 'body': H, 'latchPreds': latch_preds, 'exits': exits,
                    'exitPc': ins[li + 1][0] if li + 1 < len(ins) else None})
    return out


if __name__ == '__main__':
    exe, path = sys.argv[1], sys.argv[2]
    for p in parse_text(dump(exe, path)):
        for s in generic_for_shapes(p):
            print(p['idx'], s)
