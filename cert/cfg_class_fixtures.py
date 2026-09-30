#!/usr/bin/env python3
"""Regression gate for the 2026-09-30 CFG-identity class fixes (Gate 14).

Fixtures: cert/fixtures/cfg_class_2026_09_30/*.luau (own code, mock natives, run under luau.exe).
Every check goes through the real Luau -> DE -> decompile-mod -> recompile path.

Decompiler fixes (structan.h / emit.h). For each fixture:
  <F>_RUNS                    the fixture itself executes and prints a trace
  <F>_DEFAULT_BEHAVIOR_SAME   the decompiled source prints the identical trace
  <F>_DEFAULT_CFG_IDENTITY    cfg-identity(original, rebuilt) PASS for every prototype
  <F>_LEGACY_CFG_FAILS        negative control: with the fix's opt-out set the gate FAILs
  <F>_LEGACY_BEHAVIOR_DIFFERS ... and the behavior differs (the defect is real, not cosmetic)
  terminal_self_loop          RENOVICE_NO_TERMINAL_SELF_LOOP  (exitless loop emitted as run-once)
  entry_headed_loop           RENOVICE_NO_ENTRY_HEADED_LOOP   (latch printed before the first test)
  entry_outer_loop            RENOVICE_NO_ENTRY_CALLER_EDGE   (Seq[latch, entry] rotated an outer loop)
  import_chain                RENOVICE_NO_IMPORT_CHAIN_GUARD  (`_T[NAME]` read became a snapshot import;
                              the harness predefines _T before loading the chunk)

Gate normalization fix (cfg_identity_cmd.h S2), fixture tail_load_order:
  TAIL_DEFAULT_BEHAVIOR_SAME / TAIL_DEFAULT_CFG_IDENTITY
  TAIL_LEGACY_GATE_FAILS      RENOVICE_CFGID_LEGACY_TAIL=1 on the gate reports the identical
                              round trip as different (the measured normalization gap)
  TAIL_EQUIVALENT_REORDER_PASSES  moving the unread load later in the same block is equivalent
  TAIL_MUTATION_*_FAILS       a changed constant and swapped effects must still FAIL
"""
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC = os.path.join(ROOT, "bin", "derecomp.exe")
LUAU = os.path.join(ROOT, "bin", "luau.exe")
FIX = os.path.join(HERE, "fixtures", "cfg_class_2026_09_30")
OPT_OUTS = ("RENOVICE_NO_TERMINAL_SELF_LOOP", "RENOVICE_NO_ENTRY_HEADED_LOOP",
            "RENOVICE_NO_IMPORT_CHAIN_GUARD", "RENOVICE_NO_ENTRY_CALLER_EDGE",
            "RENOVICE_CFGID_LEGACY_TAIL")
DECOMPILER_FIXTURES = {
    "terminal_self_loop": "RENOVICE_NO_TERMINAL_SELF_LOOP",
    "entry_headed_loop": "RENOVICE_NO_ENTRY_HEADED_LOOP",
    "entry_outer_loop": "RENOVICE_NO_ENTRY_CALLER_EDGE",
    "import_chain": "RENOVICE_NO_IMPORT_CHAIN_GUARD",
}
IMPORT_PRELUDE = '_T = { RenoviceImportFixture = "stale", RenoviceOther = "other" }\n'
TAIL_MUTATIONS = {
    "CONSTANT": ("    local t = 0\n", "    local t = 1\n"),
    "EFFECT_ORDER": ("        t = t + 0.5\n        info:SetFade(from + t)\n",
                     "        info:SetFade(from + t)\n        t = t + 0.5\n"),
}
TAIL_EQUIVALENT = ("    local t = 0\n    local info = obj:GetRegionMgr():GetLevelInfo()\n",
                   "    local info = obj:GetRegionMgr():GetLevelInfo()\n    local t = 0\n")


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


def trace(path, temp, prelude=""):
    """Run a source file under luau.exe. With a prelude, the source is loaded as a chunk AFTER the
    prelude runs, so globals it reads already exist at load time (import resolution)."""
    if prelude:
        body = open(path, encoding="utf-8").read()
        level = 1
        while ("]" + "=" * level + "]") in body:
            level += 1
        driver = os.path.join(temp, "driver_%s" % os.path.basename(path))
        with open(driver, "w", encoding="utf-8", newline="\n") as stream:
            stream.write(prelude)
            stream.write("local chunk = assert(loadstring([%s[%s]%s]))\nchunk()\n"
                         % ("=" * level, body, "=" * level))
        path = driver
    proc = run([LUAU, path], check=False)
    text = proc.stdout.replace("\r\n", "\n")
    if proc.returncode != 0:              # a runtime error is a behavior, recorded, not a crash
        text += "<runtime error %d>\n" % proc.returncode
    return text


def cfg_verdict(original, candidate, env=None):
    out = run([DEC, "cfg-identity", original, candidate], env=env, check=False).stdout
    for line in out.splitlines():
        if line.startswith("CFG_IDENTITY "):
            return line.rsplit("verdict=", 1)[-1].strip()
    return "ERROR"


def round_trip(bytecode, temp, tag, env=None):
    source = os.path.join(temp, tag + ".luau")
    rebuilt = os.path.join(temp, tag + ".lua_B")
    run([DEC, "decompile-mod", bytecode, source], env=env)
    run([DEC, "recompile", source, rebuilt])
    return source, rebuilt


def compile_text(text, temp, tag):
    path = os.path.join(temp, tag + ".luau")
    with open(path, "w", encoding="utf-8", newline="\n") as stream:
        stream.write(text)
    out = os.path.join(temp, tag + ".lua_B")
    run([DEC, "recompile", path, out])
    return out


def main():
    checks = {}
    try:
        with tempfile.TemporaryDirectory(prefix="renovice-cfg-class-") as temp:
            for name, opt_out in DECOMPILER_FIXTURES.items():
                fixture = os.path.join(FIX, name + ".luau")
                prelude = IMPORT_PRELUDE if name == "import_chain" else ""
                expected = trace(fixture, temp, prelude)
                checks[name.upper() + "_RUNS"] = expected.count("\n") >= 2
                original = os.path.join(temp, name + ".original.lua_B")
                run([DEC, "recompile", fixture, original])
                source, rebuilt = round_trip(original, temp, name + ".default")
                checks[name.upper() + "_DEFAULT_BEHAVIOR_SAME"] = trace(source, temp, prelude) == expected
                checks[name.upper() + "_DEFAULT_CFG_IDENTITY"] = cfg_verdict(original, rebuilt) == "PASS"
                legacy_env = base_env()
                legacy_env[opt_out] = "1"
                legacy_source, legacy_rebuilt = round_trip(original, temp, name + ".legacy", legacy_env)
                checks[name.upper() + "_LEGACY_CFG_FAILS"] = cfg_verdict(original, legacy_rebuilt) == "FAIL"
                checks[name.upper() + "_LEGACY_BEHAVIOR_DIFFERS"] = trace(legacy_source, temp, prelude) != expected

            fixture = os.path.join(FIX, "tail_load_order.luau")
            text = open(fixture, encoding="utf-8").read()
            expected = trace(fixture, temp)
            original = os.path.join(temp, "tail.original.lua_B")
            run([DEC, "recompile", fixture, original])
            source, rebuilt = round_trip(original, temp, "tail.default")
            checks["TAIL_DEFAULT_BEHAVIOR_SAME"] = trace(source, temp) == expected
            checks["TAIL_DEFAULT_CFG_IDENTITY"] = cfg_verdict(original, rebuilt) == "PASS"
            legacy_gate = base_env()
            legacy_gate["RENOVICE_CFGID_LEGACY_TAIL"] = "1"
            checks["TAIL_LEGACY_GATE_FAILS"] = cfg_verdict(original, rebuilt, legacy_gate) == "FAIL"
            old, new = TAIL_EQUIVALENT
            if text.count(old) != 1:
                raise RuntimeError("equivalent-reorder anchor not unique")
            equivalent = compile_text(text.replace(old, new), temp, "tail.equivalent")
            checks["TAIL_EQUIVALENT_REORDER_PASSES"] = cfg_verdict(original, equivalent) == "PASS"
            for label, (old, new) in TAIL_MUTATIONS.items():
                if text.count(old) != 1:
                    raise RuntimeError("mutation %s anchor not unique" % label)
                mutant = compile_text(text.replace(old, new), temp, "tail.mutant_" + label.lower())
                checks["TAIL_MUTATION_%s_FAILS" % label] = cfg_verdict(original, mutant) == "FAIL"
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        print("FATAL %s" % error)
        return 2
    for name, passed in checks.items():
        print("%-44s %s" % (name, "PASS" if passed else "FAIL"))
    verdict = all(checks.values())
    print("CFG_CLASS_FIXTURES checks=%d passed=%d verdict=%s"
          % (len(checks), sum(checks.values()), "PASS" if verdict else "FAIL"))
    return 0 if verdict else 1


if __name__ == "__main__":
    sys.exit(main())
