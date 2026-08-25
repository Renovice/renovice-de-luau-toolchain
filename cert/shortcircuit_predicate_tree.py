#!/usr/bin/env python3
"""Truth-table certification for exact pure-test short-circuit predicate reconstruction.

The fixture is first compiled to DE bytecode, so production is tested through the real
Luau -> DE -> decompile path.  Its eight explicit rows avoid coupling this gate to loop recovery.
"""
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC = os.path.join(ROOT, "bin", "derecomp.exe")
LUAU = os.path.join(ROOT, "bin", "luau.exe")
FIXTURE = os.path.join(HERE, "fixtures", "shortcircuit_predicate_tree.luau")


def run(args, env=None):
    proc = subprocess.run(args, cwd=ROOT, env=env, capture_output=True, text=True,
                          encoding="utf-8", errors="replace", timeout=180)
    if proc.returncode != 0:
        raise RuntimeError("%s failed (%d): %s" %
                           (os.path.basename(args[0]), proc.returncode,
                            (proc.stderr or proc.stdout).strip()))
    return proc.stdout.replace("\r\n", "\n")


def decompile(path):
    env = dict(os.environ)
    env.pop("RENOVICE_SC_PREDICATE_TREE", None)
    return run([DEC, "decompile-mod", path], env=env)


def execute_source(source_path):
    return [line for line in run([LUAU, source_path]).splitlines() if line]


def main():
    try:
        expected = execute_source(FIXTURE)
        with tempfile.TemporaryDirectory(prefix="renovice-sc-predicate-") as temp:
            bytecode = os.path.join(temp, "fixture.lua_B")
            run([DEC, "recompile", FIXTURE, bytecode])
            current_source = decompile(bytecode)
            current_path = os.path.join(temp, "current.luau")
            with open(current_path, "w", encoding="utf-8", newline="\n") as stream:
                stream.write(current_source)
            current = execute_source(current_path)
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        print("FATAL %s" % error)
        return 2

    checks = {
        "EXPECTED_EIGHT_ROWS": len(expected) == 8,
        "DEFAULT_EIGHT_OF_EIGHT": current == expected,
    }
    for name, passed in checks.items():
        print("%-42s %s" % (name, "PASS" if passed else "FAIL"))
    print("VERDICT %s" % ("PASS" if all(checks.values()) else "FAIL"))
    return 0 if all(checks.values()) else 1


if __name__ == "__main__":
    sys.exit(main())
