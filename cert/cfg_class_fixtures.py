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

  compound_exit_loop          RENOVICE_NO_LOOP_BODY_DAG       (`while IsNull(g) or not g:GameStarted()` before
                              another loop: the IsNull branch was dropped, GameStarted ran on nil;
                              the harness predefines IsNull/Sleep/gGameRules as globals)
  compound_exit_namecall      RENOVICE_NO_LOOP_BODY_DAG       (the same shape with upvalue mocks)

Loop-carried nil (emit.h implicit-nil canonicalizer, #41), fixture loop_carried_nil:
  LOOP_CARRIED_NIL_RUNS / _DEFAULT_BEHAVIOR_SAME / _DEFAULT_CFG_IDENTITY
  LOOP_CARRIED_NIL_LEGACY_BEHAVIOR_DIFFERS  RENOVICE_NO_LOOP_NIL_HOIST resets the variable per iteration
  LOOP_CARRIED_NIL_LEGACY_CFG_BLIND         ... and cfg-identity still PASSes it (LOADNIL is epsilon):
                              a recorded gate blind spot, not a requirement to keep

Gate normalization S3 (cfg_identity_cmd.h), fixture truthy_noop:
  TRUTHY_DEFAULT_BEHAVIOR_SAME / TRUTHY_DEFAULT_CFG_IDENTITY
  TRUTHY_LEGACY_GATE_FAILS    RENOVICE_CFGID_LEGACY_TRUTHY_NOOP=1 reports the identical round trip as
                              different (stock keeps the dead test of an empty `if a and b then end`)
  TRUTHY_MUTATION_*_FAILS     a body in the empty if, or a real early return, must still FAIL

Gate normalization S4 (cfg_identity_cmd.h), fixture loop_prep_slots:
  LOOP_SLOT_DEFAULT_BEHAVIOR_SAME / LOOP_SLOT_DEFAULT_CFG_IDENTITY
  LOOP_SLOT_LEGACY_GATE_FAILS RENOVICE_CFGID_LEGACY_LOOP_SLOT=1 reports the identical round trip as
                              different (FORNPREP A+2 matched its jump offset B by coincidence)
  LOOP_SLOT_MUTATION_BOUND_FAILS  a changed loop bound must still FAIL

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
DEC = os.path.join(ROOT, "bin", os.environ.get("RENOVICE_FIXTURE_EXE", "derecomp.exe"))
LUAU = os.path.join(ROOT, "bin", "luau.exe")
FIX = os.path.join(HERE, "fixtures", "cfg_class_2026_09_30")
OPT_OUTS = ("RENOVICE_NO_TERMINAL_SELF_LOOP", "RENOVICE_NO_ENTRY_HEADED_LOOP",
            "RENOVICE_NO_IMPORT_CHAIN_GUARD", "RENOVICE_NO_ENTRY_CALLER_EDGE",
            "RENOVICE_CFGID_LEGACY_TAIL", "RENOVICE_NO_LOOP_BODY_DAG", "RENOVICE_NO_LOOP_NIL_HOIST",
            "RENOVICE_CFGID_LEGACY_TRUTHY_NOOP", "RENOVICE_CFGID_LEGACY_LOOP_SLOT")
DECOMPILER_FIXTURES = {
    "terminal_self_loop": "RENOVICE_NO_TERMINAL_SELF_LOOP",
    "entry_headed_loop": "RENOVICE_NO_ENTRY_HEADED_LOOP",
    "entry_outer_loop": "RENOVICE_NO_ENTRY_CALLER_EDGE",
    "import_chain": "RENOVICE_NO_IMPORT_CHAIN_GUARD",
    "compound_exit_loop": "RENOVICE_NO_LOOP_BODY_DAG",
    "compound_exit_namecall": "RENOVICE_NO_LOOP_BODY_DAG",
}
IMPORT_PRELUDE = '_T = { RenoviceImportFixture = "stale", RenoviceOther = "other" }\n'
# Globals for compound_exit_loop: gGameRules appears after the second Sleep, starts on its second
# GameStarted() call and returns a crew-ship manager from the fifth Sleep on.
GAME_RULES_PRELUDE = """polls = 0
function IsNull(value) return value == nil end
function Sleep(seconds)
    polls = polls + 1
    print("sleep", seconds, polls)
    if polls == 2 then
        gGameRules = { started = 0 }
        function gGameRules:GameStarted() self.started = self.started + 1; return self.started >= 2 end
        function gGameRules:GetCrewShipManager() if polls < 5 then return nil end return {} end
    end
    if polls >= 8 then error("stop", 0) end
end
"""
PRELUDES = {"import_chain": IMPORT_PRELUDE, "compound_exit_loop": GAME_RULES_PRELUDE}
TRUTHY_ANCHOR = "    if Ready() and IsNull(target) then\n    end\n"
TRUTHY_MUTATIONS = {
    "BODY": "    if Ready() and IsNull(target) then\n        print(\"body\")\n    end\n",
    "EARLY_RETURN": "    if Ready() and IsNull(target) then\n        return 0\n    end\n",
}
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
                prelude = PRELUDES.get(name, "")
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

            fixture = os.path.join(FIX, "loop_carried_nil.luau")
            expected = trace(fixture, temp)
            checks["LOOP_CARRIED_NIL_RUNS"] = expected.count("\n") >= 2
            original = os.path.join(temp, "loop_carried_nil.original.lua_B")
            run([DEC, "recompile", fixture, original])
            source, rebuilt = round_trip(original, temp, "loop_carried_nil.default")
            checks["LOOP_CARRIED_NIL_DEFAULT_BEHAVIOR_SAME"] = trace(source, temp) == expected
            checks["LOOP_CARRIED_NIL_DEFAULT_CFG_IDENTITY"] = cfg_verdict(original, rebuilt) == "PASS"
            legacy_env = base_env()
            legacy_env["RENOVICE_NO_LOOP_NIL_HOIST"] = "1"
            legacy_source, legacy_rebuilt = round_trip(original, temp, "loop_carried_nil.legacy",
                                                       legacy_env)
            checks["LOOP_CARRIED_NIL_LEGACY_BEHAVIOR_DIFFERS"] = trace(legacy_source, temp) != expected
            checks["LOOP_CARRIED_NIL_LEGACY_CFG_BLIND"] = cfg_verdict(original, legacy_rebuilt) == "PASS"

            fixture = os.path.join(FIX, "truthy_noop.luau")
            text = open(fixture, encoding="utf-8").read()
            expected = trace(fixture, temp)
            original = os.path.join(temp, "truthy.original.lua_B")
            run([DEC, "recompile", fixture, original])
            source, rebuilt = round_trip(original, temp, "truthy.default")
            checks["TRUTHY_DEFAULT_BEHAVIOR_SAME"] = trace(source, temp) == expected
            checks["TRUTHY_DEFAULT_CFG_IDENTITY"] = cfg_verdict(original, rebuilt) == "PASS"
            legacy_gate = base_env()
            legacy_gate["RENOVICE_CFGID_LEGACY_TRUTHY_NOOP"] = "1"
            checks["TRUTHY_LEGACY_GATE_FAILS"] = cfg_verdict(original, rebuilt, legacy_gate) == "FAIL"
            if text.count(TRUTHY_ANCHOR) != 1:
                raise RuntimeError("truthy mutation anchor not unique")
            for label, new in TRUTHY_MUTATIONS.items():
                mutant = compile_text(text.replace(TRUTHY_ANCHOR, new), temp,
                                      "truthy.mutant_" + label.lower())
                checks["TRUTHY_MUTATION_%s_FAILS" % label] = cfg_verdict(original, mutant) == "FAIL"

            fixture = os.path.join(FIX, "loop_prep_slots.luau")
            text = open(fixture, encoding="utf-8").read()
            expected = trace(fixture, temp)
            original = os.path.join(temp, "loop_slot.original.lua_B")
            run([DEC, "recompile", fixture, original])
            source, rebuilt = round_trip(original, temp, "loop_slot.default")
            checks["LOOP_SLOT_DEFAULT_BEHAVIOR_SAME"] = trace(source, temp) == expected
            checks["LOOP_SLOT_DEFAULT_CFG_IDENTITY"] = cfg_verdict(original, rebuilt) == "PASS"
            legacy_gate = base_env()
            legacy_gate["RENOVICE_CFGID_LEGACY_LOOP_SLOT"] = "1"
            checks["LOOP_SLOT_LEGACY_GATE_FAILS"] = cfg_verdict(original, rebuilt, legacy_gate) == "FAIL"
            if text.count("for i = 400, 415 do") != 1:
                raise RuntimeError("loop-slot mutation anchor not unique")
            mutant = compile_text(text.replace("for i = 400, 415 do", "for i = 400, 416 do"), temp,
                                  "loop_slot.mutant_bound")
            checks["LOOP_SLOT_MUTATION_BOUND_FAILS"] = cfg_verdict(original, mutant) == "FAIL"

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
