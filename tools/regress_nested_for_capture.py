# Regression gate (2026-10-08): nested loop variables must not shadow a captured outer loop index.
# Compiles tests/nested_for_capture.luau, decompiles it with `decompile-mod`, recompiles the source and
# requires cfg-identity and const-identity PASS against the first compile, plus distinct generated loop
# names in the decompiled source. Exit 0 = PASS.
# Usage: python tools/regress_nested_for_capture.py
import re
import subprocess
import sys
import tempfile
from pathlib import Path

here = Path(__file__).resolve().parents[1]
exe = here / 'bin' / 'derecomp.exe'
fixture = here / 'tests' / 'nested_for_capture.luau'


def run(*args):
    r = subprocess.run([str(exe), *map(str, args)], capture_output=True, text=True)
    return r.returncode, r.stdout + r.stderr


with tempfile.TemporaryDirectory() as tmp:
    tmp = Path(tmp)
    first, decompiled, second = tmp / 'first.lua_B', tmp / 'roundtrip.luau', tmp / 'second.lua_B'
    checks = []
    code, text = run('recompile', fixture, first)
    checks.append(('compile fixture', code == 0, text.strip().splitlines()[-1:]))
    code, text = run('decompile-mod', first, decompiled)
    checks.append(('decompile-mod', code == 0 and decompiled.exists(), text.strip().splitlines()[-1:]))
    source = decompiled.read_text(encoding='utf-8') if decompiled.exists() else ''
    loop_names = re.findall(r'\bfor\s+([A-Za-z_]\w*)', source)
    generated = [n for n in loop_names if n.startswith('__renovice_for_')]
    checks.append(('generated loop names unique', len(generated) == len(set(generated)), generated))
    code, text = run('recompile', decompiled, second)
    checks.append(('recompile round trip', code == 0, text.strip().splitlines()[-1:]))
    code, text = run('cfg-identity', first, second)
    checks.append(('cfg-identity', code == 0 and 'verdict=PASS' in text, text.strip().splitlines()[-1:]))
    code, text = run('const-identity', first, second)
    checks.append(('const-identity', code == 0 and 'verdict=PASS' in text, text.strip().splitlines()[-1:]))

ok = all(passed for _, passed, _ in checks)
for name, passed, detail in checks:
    print(f'{"PASS" if passed else "FAIL"}  {name}  {detail}')
print('NESTED_FOR_CAPTURE', 'PASS' if ok else 'FAIL')
sys.exit(0 if ok else 1)
