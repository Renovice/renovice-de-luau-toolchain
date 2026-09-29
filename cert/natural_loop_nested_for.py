#!/usr/bin/env python3
"""Regression gate for the natural-loop header / nested-for structuring defect (2026-09-29).

Fixture: cert/fixtures/natural_loop_nested_for.luau, the control-flow shape of SyndicateScarves
NewLokaScarfUpdate (44.0.2 proto 13): guarded prologue, `while not IsNull(obj)` with a returning hub
branch, lazy-init guards, `a ~= nil and b[k] ~= nil` (second operand needs statements), a nested
numeric for with an if/elseif chain, a fallback else and a trailing Sleep.

Checks (all through the real Luau -> DE -> decompile -> recompile path):
  FIXTURE_RUNS              the fixture itself executes and prints its trace
  DEFAULT_BEHAVIOR_SAME     decompile-mod output prints the identical trace
  DEFAULT_CFG_IDENTITY      cfg-identity(original, rebuilt) PASS for every prototype
  LEGACY_CFG_FAILS          negative control: with the four repairs switched off
                            (RENOVICE_LEGACY_ENTRY_IN_LOOP, RENOVICE_NO_LOOP_BODY_PROPER,
                            RENOVICE_NO_PROVEN_WHILE_NATURAL, RENOVICE_NO_FOR_CYCLE_WHOLE_PART)
                            the gate must FAIL -- it is sensitive to the defect
  LEGACY_BEHAVIOR_DIFFERS   ... and the behavior must differ (the defect is real, not cosmetic)
  MUTATION_<name>_FAILS     sensitivity controls: small source mutations (branch bodies swapped,
                            loop bound, statement moved) must each fail cfg-identity
"""
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC = os.path.join(ROOT, "bin", "derecomp.exe")
LUAU = os.path.join(ROOT, "bin", "luau.exe")
FIXTURE = os.path.join(HERE, "fixtures", "natural_loop_nested_for.luau")
LEGACY = ("RENOVICE_LEGACY_ENTRY_IN_LOOP", "RENOVICE_NO_LOOP_BODY_PROPER",
          "RENOVICE_NO_PROVEN_WHILE_NATURAL", "RENOVICE_NO_FOR_CYCLE_WHOLE_PART")
MUTATIONS = {
    "BRANCH_SWAP": ("                if i == 1 then", "                elseif i == 2 then",
                    "                if i == 2 then", "                elseif i == 1 then"),
    "LOOP_BOUND": ("for i = 1, 4 do", None, "for i = 1, 3 do", None),
    "SLEEP_MOVED": ("        Sleep(0)\n    end\nend", "    while not IsNull(scarf) do\n",
                    "    end\nend", "    while not IsNull(scarf) do\n        Sleep(0)\n"),
}


def base_env():
    env = dict(os.environ)
    for name in LEGACY:
        env.pop(name, None)
    return env


def run(args, env=None, check=True):
    proc = subprocess.run(args, cwd=ROOT, env=env or base_env(), capture_output=True, text=True,
                          encoding="utf-8", errors="replace", timeout=300)
    if check and proc.returncode != 0:
        raise RuntimeError("%s failed (%d): %s" % (os.path.basename(args[0]), proc.returncode,
                                                  (proc.stderr or proc.stdout).strip()[-600:]))
    return proc


def trace(path, check=True):
    proc = run([LUAU, path], check=check)
    text = proc.stdout.replace("\r\n", "\n")
    if proc.returncode != 0:              # a runtime error is a behavior, recorded, not a crash
        text += "<runtime error %d>\n" % proc.returncode
    return text


def cfg_verdict(original, candidate):
    out = run([DEC, "cfg-identity", original, candidate], check=False).stdout
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


def main():
    checks = {}
    try:
        expected = trace(FIXTURE)
        checks["FIXTURE_RUNS"] = expected.count("\n") >= 40
        with tempfile.TemporaryDirectory(prefix="renovice-natural-loop-") as temp:
            original = os.path.join(temp, "original.lua_B")
            run([DEC, "recompile", FIXTURE, original])
            source, rebuilt = round_trip(original, temp, "default")
            checks["DEFAULT_BEHAVIOR_SAME"] = trace(source, check=False) == expected
            checks["DEFAULT_CFG_IDENTITY"] = cfg_verdict(original, rebuilt) == "PASS"
            legacy_env = base_env()
            for name in LEGACY:
                legacy_env[name] = "1"
            legacy_source, legacy_rebuilt = round_trip(original, temp, "legacy", legacy_env)
            checks["LEGACY_CFG_FAILS"] = cfg_verdict(original, legacy_rebuilt) == "FAIL"
            checks["LEGACY_BEHAVIOR_DIFFERS"] = trace(legacy_source, check=False) != expected
            text = open(FIXTURE, encoding="utf-8").read()
            for name, (old_a, old_b, new_a, new_b) in MUTATIONS.items():
                mutated = text
                if old_b is None:
                    if mutated.count(old_a) != 1:
                        raise RuntimeError("mutation %s anchor not unique" % name)
                    mutated = mutated.replace(old_a, new_a)
                else:
                    if mutated.count(old_a) != 1 or mutated.count(old_b) != 1:
                        raise RuntimeError("mutation %s anchor not unique" % name)
                    mutated = mutated.replace(old_a, "\0A").replace(old_b, "\0B")
                    mutated = mutated.replace("\0A", new_a).replace("\0B", new_b)
                path = os.path.join(temp, "mutant_%s.luau" % name.lower())
                with open(path, "w", encoding="utf-8", newline="\n") as stream:
                    stream.write(mutated)
                mutant = os.path.join(temp, "mutant_%s.lua_B" % name.lower())
                run([DEC, "recompile", path, mutant])
                checks["MUTATION_%s_FAILS" % name] = cfg_verdict(original, mutant) == "FAIL"
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        print("FATAL %s" % error)
        return 2
    for name, passed in checks.items():
        print("%-42s %s" % (name, "PASS" if passed else "FAIL"))
    verdict = all(checks.values())
    print("NATURAL_LOOP_FIXTURE checks=%d passed=%d verdict=%s"
          % (len(checks), sum(checks.values()), "PASS" if verdict else "FAIL"))
    return 0 if verdict else 1


if __name__ == "__main__":
    sys.exit(main())
