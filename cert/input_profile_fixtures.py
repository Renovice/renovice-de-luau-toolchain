#!/usr/bin/env python3
"""Regression gate for input-profile routing (44.1.1 campaign wave 3, agent profiles, 2026-10-10).

The 44.1.1 cache ships 13 stale U43-profile modules. A U44 entry point now handles a module that is
structurally valid ONLY under the U43 opcode numbering through its own profile: decompile with U43
opcodes and the U43 name-hash seed (raw-hash source contract, `-- RENOVICE_NAME_HASH_SEED: 7e5af8e9`),
rebuild in the U43 format, and gate both sides under U43. RENOVICE_NO_INPUT_PROFILE_ROUTING restores
the batch-1 rejection (#54).

Fixture: cert/fixtures/input_profile_2026_10_10/u43_module.luau (own code, run under luau.exe), built
with the U43 `recompile` (hashed field reads via RENOVICE_HASH_FIELD, like the stale ImGui/Cmd modules).
  ORIGINAL_RUNS                 the fixture executes and prints a trace
  ROUTED_DECOMPILE              decompile-mod-u44 reports the U43 profile and declares seed 7e5af8e9
  ROUTED_REBUILD_U43            recompile-u44 builds that source in the U43 profile
  ROUTED_<GATE>_U44_FLAG        cfg/const/dataflow-identity --u44 route to U43 (INPUT_PROFILE line) and PASS
  ROUTED_<GATE>_U43_GATE        the same gates without --u44 (plain U43) PASS: the rebuild is U43 bytecode
  ROUTED_BEHAVIOR_SAME          the decompiled source prints the identical trace
  ROUTED_CLOSES                 decompile-mod-u44 -> recompile-u44 source repeats within 3 rounds
  MISMATCH_<GATE>_ERROR         stock U43 vs a U44-format rebuild of the same source: --u44 gate ERRORs
                                with "input profile mismatch" (a rebuild in the other format is never
                                "the same program")
  U44_CONTROL_NOT_ROUTED        a U44-profile build of the same source is not routed (seed 768e5ed0)
  LEGACY_REJECTS                RENOVICE_NO_INPUT_PROFILE_ROUTING: decompile-mod-u44 fails with
                                "input is U43-profile bytecode"
"""
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC = os.path.join(ROOT, "bin", os.environ.get("RENOVICE_FIXTURE_EXE", "derecomp.exe"))
LUAU = os.path.join(ROOT, "bin", "luau.exe")
FIX = os.path.join(HERE, "fixtures", "input_profile_2026_10_10", "u43_module.luau")
OPT_OUTS = ("RENOVICE_NO_INPUT_PROFILE_ROUTING", "RENOVICE_NO_INPUT_PROFILE_CHECK")
GATES = ("cfg-identity", "const-identity", "dataflow-identity")


def base_env():
    env = dict(os.environ)
    for name in OPT_OUTS:
        env.pop(name, None)
    return env


def run(args, env=None, check=True):
    proc = subprocess.run(args, cwd=ROOT, env=env or base_env(), capture_output=True, text=True,
                          encoding="utf-8", errors="replace", timeout=300)
    if check and proc.returncode != 0:
        raise RuntimeError("%s failed (%d): %s" % (os.path.basename(args[0]), proc.returncode,
                                                  (proc.stderr or proc.stdout).strip()[-600:]))
    return proc


def trace(path):
    proc = run([LUAU, path], check=False)
    text = proc.stdout.replace("\r\n", "\n")
    if proc.returncode != 0:
        text += "<runtime error %d>\n" % proc.returncode
    return text


def gate(mode, stock, candidate, u44):
    out = run([DEC, mode, stock, candidate] + (["--u44"] if u44 else []), check=False).stdout
    match = re.search(r"verdict=(\w+)", out)
    return (match.group(1) if match else "NONE"), out


def main():
    checks = {}
    try:
        with tempfile.TemporaryDirectory(prefix="renovice-input-profile-") as temp:
            path = lambda name: os.path.join(temp, name)
            expected = trace(FIX)
            checks["ORIGINAL_RUNS"] = expected.count("\n") >= 3
            run([DEC, "recompile", FIX, path("o43.lua_B")])
            run([DEC, "recompile-u44", FIX, path("o44.lua_B")])
            proc = run([DEC, "decompile-mod-u44", path("o43.lua_B"), path("s1.luau")])
            source = open(path("s1.luau"), encoding="utf-8").read()
            checks["ROUTED_DECOMPILE"] = ("handled through the U43 profile" in proc.stderr
                                          and "-- RENOVICE_NAME_HASH_SEED: 7e5af8e9" in source)
            proc = run([DEC, "recompile-u44", path("s1.luau"), path("b1.lua_B")])
            checks["ROUTED_REBUILD_U43"] = "built in the U43 profile" in proc.stdout
            for mode in GATES:
                key = mode.split("-")[0].upper()
                verdict, out = gate(mode, path("o43.lua_B"), path("b1.lua_B"), True)
                checks["ROUTED_%s_U44_FLAG" % key] = verdict == "PASS" and "INPUT_PROFILE stock=u43" in out
                checks["ROUTED_%s_U43_GATE" % key] = gate(mode, path("o43.lua_B"), path("b1.lua_B"), False)[0] == "PASS"
                verdict, out = gate(mode, path("o43.lua_B"), path("o44.lua_B"), True)
                checks["MISMATCH_%s_ERROR" % key] = verdict == "ERROR" and "input profile mismatch" in out
            checks["ROUTED_BEHAVIOR_SAME"] = trace(path("s1.luau")) == expected
            previous, current, closes = None, path("o43.lua_B"), False
            for index in range(1, 4):
                run([DEC, "decompile-mod-u44", current, path("c%d.luau" % index)])
                run([DEC, "recompile-u44", path("c%d.luau" % index), path("c%d.lua_B" % index)])
                text = open(path("c%d.luau" % index), "rb").read()
                if text == previous:
                    closes = True
                    break
                previous, current = text, path("c%d.lua_B" % index)
            checks["ROUTED_CLOSES"] = closes
            proc = run([DEC, "decompile-mod-u44", path("o44.lua_B"), path("u44.luau")])
            control = open(path("u44.luau"), encoding="utf-8").read()
            checks["U44_CONTROL_NOT_ROUTED"] = ("handled through" not in proc.stderr
                                                and "-- RENOVICE_NAME_HASH_SEED: 768e5ed0" in control)
            legacy = base_env(); legacy["RENOVICE_NO_INPUT_PROFILE_ROUTING"] = "1"
            proc = run([DEC, "decompile-mod-u44", path("o43.lua_B"), path("legacy.luau")], env=legacy, check=False)
            checks["LEGACY_REJECTS"] = proc.returncode != 0 and "input is U43-profile bytecode" in proc.stderr
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        print("FATAL %s" % error)
        return 2
    for name, passed in checks.items():
        print("%-40s %s" % (name, "PASS" if passed else "FAIL"))
    ok = all(checks.values())
    print("INPUT_PROFILE_FIXTURES checks=%d passed=%d verdict=%s"
          % (len(checks), sum(checks.values()), "PASS" if ok else "FAIL"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
