#!/usr/bin/env python3
"""Regression gate for native DE JUMPXEQK comparison polarity.

The known sources in cert/rt/src are compared behaviorally with the corresponding native-opcode
DE modules in cert/rt/de_native. Both equality and inequality are required for number, string,
boolean, and nil operands. The boolean/nil cases are controls: a patch that merely flips every
constant comparison must fail them.
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import behave

NATIVE_DE = os.path.join(HERE, "rt", "de_native")
CASES = (
    ("cmp_eq_branch_kn", "0x20"),
    ("cmp_ne_branch_kn", "0x20"),
    ("cmp_eq_kstr", "0x41"),
    ("cmp_ne_kstr", "0x41"),
    ("cmp_eq_kbool", "0x34"),
    ("cmp_ne_kbool", "0x34"),
    ("cmp_eq_knil", "0x3a"),
    ("cmp_ne_knil", "0x3a"),
)


def contains_opcode(path, opcode):
    result = subprocess.run(
        [behave.DEC, "histops", path], capture_output=True, text=True,
        encoding="utf-8", errors="replace", timeout=120)
    return result.returncode == 0 and re.search(
        r"^\s+%s\s+\d+\s+8B\s*$" % re.escape(opcode), result.stdout, re.M)


def main():
    for path in (behave.DEC, behave.LUAU, NATIVE_DE):
        if not os.path.exists(path):
            print("FATAL: required comparison artifact missing: %s" % path)
            return 2

    original_de = behave.DE
    behave.DE = NATIVE_DE
    passed = 0
    failed = []
    try:
        for name, opcode in CASES:
            bytecode = os.path.join(NATIVE_DE, name + ".lua_B")
            if not contains_opcode(bytecode, opcode):
                print("FAIL %-22s missing required native %s" % (name, opcode))
                failed.append(name + ":opcode")
                continue
            _, setup, source_status, source_out, emitted_status, emitted_out, _ = behave.eval_case(name)
            same = (setup == "ok" and source_status == emitted_status and source_out == emitted_out)
            print("%-4s %-22s %s" % ("PASS" if same else "FAIL", name, opcode))
            if same:
                passed += 1
            else:
                failed.append(name + ":behaviour")
    finally:
        behave.DE = original_de

    print("SUMMARY same=%d different=%d" % (passed, len(failed)))
    if failed:
        print("FAILED " + ", ".join(failed))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
