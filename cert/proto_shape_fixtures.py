#!/usr/bin/env python3
"""Regression gate for prototype-shape fixes of the 44.1.1 campaign (wave 2, agent protos2, 2026-10-09).

Fixtures: cert/fixtures/proto_shape_2026_10_09/*.luau (own code, run under luau.exe). Every check goes
through the real Luau -> DE -> decompile-mod -> recompile path.

Shared prototypes (src/shared_protos.h, src/m6e_cmd.h inline_closures). The originals are compiled
with `luau-compile -O2` + transcode, as DE builds its modules: a local function containing a function
literal is inlined, and every inlined copy references THE SAME prototype.
  <F>_RUNS                    the fixture executes and prints a trace
  <F>_ORIGINAL_SHARED         the -O2 original really has a prototype with >= 2 closure sites
  <F>_DEFAULT_PROTO_COUNT     the rebuilt module has the original's prototype count
  <F>_DEFAULT_CFG_IDENTITY    cfg-identity PASS
  <F>_DEFAULT_CONST_IDENTITY  const-identity PASS
  <F>_DEFAULT_DATAFLOW        dataflow-identity PASS
  <F>_DEFAULT_BEHAVIOR_SAME   the decompiled source prints the identical trace
  <F>_DEFAULT_CLOSES          decompile -> recompile source repeats within 3 rounds
  <F>_LEGACY_MARKER_CFG_FAILS RENOVICE_NO_SHARED_PROTO_MARKER (decompiler): one prototype per literal,
                              the gate FAILs (prototype count)
  <F>_LEGACY_MERGE_CFG_FAILS  RENOVICE_NO_SHARED_PROTO_MERGE (recompiler): the same
  <F>_MUTATION_EDITED_COPY_FAILS  one marked copy edited in the decompiled source: the copies no longer
                              compile identically, are NOT merged (recompile reports unequal=1) and the
                              gate FAILs
The legacy outputs behave the same in these fixtures (closure identity differs only for two DUPCLOSURE
sites of one prototype inside one function, which the merge refuses; see shared_protos.h).

Dead tails (src/m6e_cmd.h dead_tail_start / splice_dead_tail). The originals are built with
RENOVICE_NATIVE=JUMPBACK so the endless loop closes with a real JUMPBACK as in stock; the closure rounds
then see our own lowering (backward JUMP).
  <F>_RUNS / _DEFAULT_PROTO_COUNT / _DEFAULT_CFG_IDENTITY / _DEFAULT_CONST_IDENTITY / _DEFAULT_DATAFLOW /
  _DEFAULT_BEHAVIOR_SAME / _DEFAULT_CLOSES   as above
  <F>_LEGACY_CONST_FAILS      RENOVICE_NO_DEAD_TAIL: the tail's constants are lost, const-identity FAILs
  <F>_LEGACY_PROTO_COUNT_FAILS  ... and the tail's closure prototype is lost
  dead_tail_loop              statements after `while true do ... end`; the tail declares 12 registers the
                              live code never uses (declaration order must follow register order or the
                              names drift every round, CoHUpgrades) and creates a closure (BoonSelection)
  dead_tail_return            statements after `repeat return 2 until true` (a single RETURN)

Interior dead code (src/m6e_cmd.h interior_dead_ranges / splice_interior_dead_ranges; wave 3, agent
profiles, 2026-10-10). The originals are built with the U43 `recompile`.
  <F>_RUNS / _DEFAULT_PROTO_COUNT / _DEFAULT_CFG_IDENTITY / _DEFAULT_CONST_IDENTITY / _DEFAULT_DATAFLOW /
  _DEFAULT_BEHAVIOR_SAME / _DEFAULT_CLOSES   as above
  <F>_DEFAULT_SPLICED         the decompiled source carries the `if true then break end` wrapper
  <F>_LEGACY_CONST_FAILS      RENOVICE_NO_INTERIOR_DEAD_CODE: the range's constants are lost
  interior_dead_ifexpr        `return if x and false then A else B` (KuvaPath, RailJackEnemyEffects)
  interior_dead_after_return  statements after a mid-function return, live code after them, one of them
                              in a loop body whose back-edge becomes unreachable (EndlessSpawnLib,
                              InfBoomerangPods: closure needs the leading jump-to-return copy skipped)
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
LUAU_COMPILE = os.path.join(ROOT, "bin", "luau-compile.exe")
FIX = os.path.join(HERE, "fixtures", "proto_shape_2026_10_09")
OPT_OUTS = ("RENOVICE_NO_SHARED_PROTO_MARKER", "RENOVICE_NO_SHARED_PROTO_MERGE", "RENOVICE_NATIVE",
            "RENOVICE_NO_DEAD_TAIL", "RENOVICE_NO_INTERIOR_DEAD_CODE")
SHARED_FIXTURES = ("shared_newclosure", "shared_dupclosure")
DEAD_TAIL_FIXTURES = ("dead_tail_loop", "dead_tail_return")
INTERIOR_DEAD_FIXTURES = ("interior_dead_ifexpr", "interior_dead_after_return")
CLOSURE = re.compile(r"(?:DUP|NEW)CLOSURE\s.*-> proto\[(\d+)\]")


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


def verdict(mode, original, candidate, env=None):
    """(verdict, protos_stock, protos_candidate) of cfg-identity / const-identity / dataflow-identity."""
    out = run([DEC, mode, original, candidate], env=env, check=False).stdout
    match = re.search(r"protos_stock=(\d+) protos_candidate=(\d+) .*verdict=(\w+)", out)
    if not match:
        return ("ERROR", -1, -2)
    return (match.group(3), int(match.group(1)), int(match.group(2)))


def compile_o2(fixture, out):
    proc = subprocess.run([LUAU_COMPILE, "--binary", "-O2", fixture], cwd=ROOT, capture_output=True,
                          timeout=300)
    if proc.returncode != 0:
        raise RuntimeError("luau-compile -O2 failed: %s" % proc.stderr[-400:])
    luaubc = out + ".luaubc"
    with open(luaubc, "wb") as stream:
        stream.write(proc.stdout)
    run([DEC, "transcode", luaubc, out])


def max_closure_sites(bytecode):
    sites = {}
    for line in run([DEC, "ir", bytecode]).stdout.splitlines():
        match = CLOSURE.search(line)
        if match:
            sites[match.group(1)] = sites.get(match.group(1), 0) + 1
    return max(sites.values() or [0])


def decompile(bytecode, source, env=None):
    run([DEC, "decompile-mod", bytecode, source], env=env)


def recompile(source, rebuilt, env=None):
    return run([DEC, "recompile", source, rebuilt], env=env).stdout


def round_trip(bytecode, temp, tag, decompile_env=None, recompile_env=None):
    source = os.path.join(temp, tag + ".luau")
    rebuilt = os.path.join(temp, tag + ".lua_B")
    decompile(bytecode, source, decompile_env)
    recompile(source, rebuilt, recompile_env)
    return source, rebuilt


def closes_within(bytecode, temp, tag, rounds):
    previous, current = None, bytecode
    for index in range(1, rounds + 1):
        source, rebuilt = round_trip(current, temp, "%s.r%d" % (tag, index))
        text = open(source, "rb").read()
        if text == previous:
            return True
        previous, current = text, rebuilt
    return False


def shared_checks(name, temp, checks):
    fixture = os.path.join(FIX, name + ".luau")
    key = name.upper()
    expected = trace(fixture)
    checks[key + "_RUNS"] = expected.count("\n") >= 2
    original = os.path.join(temp, name + ".original.lua_B")
    compile_o2(fixture, original)
    checks[key + "_ORIGINAL_SHARED"] = max_closure_sites(original) >= 2
    source, rebuilt = round_trip(original, temp, name + ".default")
    cfg = verdict("cfg-identity", original, rebuilt)
    checks[key + "_DEFAULT_PROTO_COUNT"] = cfg[1] == cfg[2]
    checks[key + "_DEFAULT_CFG_IDENTITY"] = cfg[0] == "PASS"
    checks[key + "_DEFAULT_CONST_IDENTITY"] = verdict("const-identity", original, rebuilt)[0] == "PASS"
    checks[key + "_DEFAULT_DATAFLOW"] = verdict("dataflow-identity", original, rebuilt)[0] == "PASS"
    checks[key + "_DEFAULT_BEHAVIOR_SAME"] = trace(source) == expected
    checks[key + "_DEFAULT_CLOSES"] = closes_within(original, temp, name + ".close", 3)
    marker_env = base_env(); marker_env["RENOVICE_NO_SHARED_PROTO_MARKER"] = "1"
    _, legacy = round_trip(original, temp, name + ".legacy_marker", decompile_env=marker_env)
    checks[key + "_LEGACY_MARKER_CFG_FAILS"] = verdict("cfg-identity", original, legacy)[0] == "FAIL"
    merge_env = base_env(); merge_env["RENOVICE_NO_SHARED_PROTO_MERGE"] = "1"
    _, legacy = round_trip(original, temp, name + ".legacy_merge", recompile_env=merge_env)
    checks[key + "_LEGACY_MERGE_CFG_FAILS"] = verdict("cfg-identity", original, legacy)[0] == "FAIL"
    # Mutation: change one operation (`+` -> `-`) or string constant inside the LAST marked copy only.
    text = open(source, encoding="utf-8").read()
    lines = text.split("\n")
    marked = [i for i, line in enumerate(lines) if "-- RENOVICE_SHARED_PROTO " in line]
    edited = False
    if len(marked) >= 2:
        head = lines[marked[-1]]
        indent = len(head) - len(head.lstrip(" "))
        stop = next(i for i in range(marked[-1] + 1, len(lines))
                    if lines[i].startswith(" " * indent + "end") and not lines[i][indent].isspace())
        for old, new in ((" + ", " - "), ('"', '"mutated ')):
            for i in range(marked[-1] + 1, stop):
                if old in lines[i]:
                    lines[i] = lines[i].replace(old, new, 1)
                    edited = True
                    break
            if edited:
                break
    mutant_source = os.path.join(temp, name + ".mutant.luau")
    with open(mutant_source, "w", encoding="utf-8", newline="\n") as stream:
        stream.write("\n".join(lines))
    mutant = os.path.join(temp, name + ".mutant.lua_B")
    report = recompile(mutant_source, mutant)
    checks[key + "_MUTATION_EDITED_COPY_FAILS"] = (edited and "unequal=1" in report
                                                  and verdict("cfg-identity", original, mutant)[0] == "FAIL")


def dead_tail_checks(name, temp, checks):
    fixture = os.path.join(FIX, name + ".luau")
    key = name.upper()
    expected = trace(fixture)
    checks[key + "_RUNS"] = expected.count("\n") >= 2
    original = os.path.join(temp, name + ".original.lua_B")
    native = base_env(); native["RENOVICE_NATIVE"] = "JUMPBACK"
    recompile(fixture, original, native)
    source, rebuilt = round_trip(original, temp, name + ".default")
    cfg = verdict("cfg-identity", original, rebuilt)
    checks[key + "_DEFAULT_PROTO_COUNT"] = cfg[1] == cfg[2]
    checks[key + "_DEFAULT_CFG_IDENTITY"] = cfg[0] == "PASS"
    checks[key + "_DEFAULT_CONST_IDENTITY"] = verdict("const-identity", original, rebuilt)[0] == "PASS"
    checks[key + "_DEFAULT_DATAFLOW"] = verdict("dataflow-identity", original, rebuilt)[0] == "PASS"
    checks[key + "_DEFAULT_BEHAVIOR_SAME"] = trace(source) == expected
    checks[key + "_DEFAULT_CLOSES"] = closes_within(original, temp, name + ".close", 3)
    legacy_env = base_env(); legacy_env["RENOVICE_NO_DEAD_TAIL"] = "1"
    _, legacy = round_trip(original, temp, name + ".legacy", decompile_env=legacy_env)
    checks[key + "_LEGACY_CONST_FAILS"] = verdict("const-identity", original, legacy)[0] == "FAIL"
    legacy_cfg = verdict("cfg-identity", original, legacy)
    checks[key + "_LEGACY_PROTO_COUNT_FAILS"] = legacy_cfg[1] != legacy_cfg[2]


def interior_dead_checks(name, temp, checks):
    fixture = os.path.join(FIX, name + ".luau")
    key = name.upper()
    expected = trace(fixture)
    checks[key + "_RUNS"] = expected.count("\n") >= 1
    original = os.path.join(temp, name + ".original.lua_B")
    recompile(fixture, original)
    source, rebuilt = round_trip(original, temp, name + ".default")
    cfg = verdict("cfg-identity", original, rebuilt)
    checks[key + "_DEFAULT_PROTO_COUNT"] = cfg[1] == cfg[2]
    checks[key + "_DEFAULT_CFG_IDENTITY"] = cfg[0] == "PASS"
    checks[key + "_DEFAULT_CONST_IDENTITY"] = verdict("const-identity", original, rebuilt)[0] == "PASS"
    checks[key + "_DEFAULT_DATAFLOW"] = verdict("dataflow-identity", original, rebuilt)[0] == "PASS"
    checks[key + "_DEFAULT_BEHAVIOR_SAME"] = trace(source) == expected
    checks[key + "_DEFAULT_SPLICED"] = "if true then break end" in open(source, encoding="utf-8").read()
    checks[key + "_DEFAULT_CLOSES"] = closes_within(original, temp, name + ".close", 3)
    legacy_env = base_env(); legacy_env["RENOVICE_NO_INTERIOR_DEAD_CODE"] = "1"
    _, legacy = round_trip(original, temp, name + ".legacy", decompile_env=legacy_env)
    checks[key + "_LEGACY_CONST_FAILS"] = verdict("const-identity", original, legacy)[0] == "FAIL"


def main():
    checks = {}
    try:
        with tempfile.TemporaryDirectory(prefix="renovice-proto-shape-") as temp:
            for name in SHARED_FIXTURES:
                shared_checks(name, temp, checks)
            for name in DEAD_TAIL_FIXTURES:
                dead_tail_checks(name, temp, checks)
            for name in INTERIOR_DEAD_FIXTURES:
                interior_dead_checks(name, temp, checks)
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        print("FATAL %s" % error)
        return 2
    for name, passed in checks.items():
        print("%-48s %s" % (name, "PASS" if passed else "FAIL"))
    ok = all(checks.values())
    print("PROTO_SHAPE_FIXTURES checks=%d passed=%d verdict=%s"
          % (len(checks), sum(checks.values()), "PASS" if ok else "FAIL"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
