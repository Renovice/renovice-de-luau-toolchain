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

Numeric-for fixes (2026-09-30, RESEARCH/CFG_FOR_LOOP_FIXES_2026-09-30.md):
  for_body_order              RENOVICE_NO_FOR_BODY_PART_ORDER (#45: print(i) ran before the inner loop)
  nested_for_break            RENOVICE_NO_PREP_HEADED_WHILE   (#44: the outer `while true` was deleted)
    + NESTED_FOR_BREAK_LEGACY_BREAK_ARM_{CFG_FAILS,BEHAVIOR_DIFFERS}   RENOVICE_NO_FOR_BREAK_ARM (#46)
    + NESTED_FOR_BREAK_LEGACY_ENTRY_NIL_BEHAVIOR_DIFFERS             RENOVICE_NO_LOOP_ENTRY_NIL (#47)
    + NESTED_FOR_BREAK_LEGACY_ENTRY_NIL_CFG_BLIND   cfg-identity still PASSes #47 (LOADNIL is epsilon)
  proper_prep_for             RENOVICE_NO_PROPER_PREP_FOR     (#48; compiled at -O2 so the helper loops
                              inline into two-exit loops inside a Proper region; the harness compiles it
                              with luau-compile -O2 + transcode)
    + PROPER_PREP_FOR_LEGACY_NESTED_{CFG_FAILS,BEHAVIOR_DIFFERS}  RENOVICE_NO_PROPER_NESTED_LOOP_PARTS
    (both legacy controls also set RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN: since #76 the CFG renderer owns
    these two-exit loops and the Proper dispatcher is no longer reached)

Two-exit loops (2026-10-09, cert/fixtures/twoexit_2026_10_09):
  escape_join_forgen          RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN (#76; -O2 inlined `return true` in a
                              generic for: the arm skips the exhaustion code `r = false`; legacy printed
                              the arm outside the loop, IsA(nil))
  escape_join_loop_value      RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN (#76; the arm reads the loop variable,
                              three inlined searches in sequence; legacy returned nil for every lookup)
  while_break_return_arms     RENOVICE_NO_CFG_WHILE_LOOP_ARMS  (#77; a while leaving by its header test,
                              a break and a shared bare RETURN; legacy fallback duplicated the next for)

Proper dispatcher fixes (proper campaign 2026-10-09):
  proper_exit_in_body         RENOVICE_NO_PROPER_EXIT_IN_BODY_DAG (a loop-leaving edge inside a Proper
                              region refused the loop-body DAG; the `or` test was dropped, DeathSquadFlak)
    + PROPER_EXIT_IN_BODY_LEGACY_EXIT_ARM_ONCE_{CFG_FAILS,BEHAVIOR_SAME}  RENOVICE_NO_PROPER_EXIT_ARM_ONCE
                              (the dispatcher re-tested a break condition: an extra IF, behavior-neutral)

Compiler-closure fix (#49), fixture selector_residue:
  SELECTOR_RESIDUE_RUNS / _DEFAULT_BEHAVIOR_SAME / _DEFAULT_CFG_IDENTITY
  SELECTOR_RESIDUE_DEFAULT_CLOSES     the decompile->recompile source repeats within 3 rounds
  SELECTOR_RESIDUE_LEGACY_NOT_CLOSED  RENOVICE_KEEP_SELECTOR_GUARD_RESIDUE: no repeat within 5 rounds
  SELECTOR_RESIDUE_LEGACY_CFG_FAILS   ... and the first pass fails cfg-identity (the residue compare)

Loop-carried nil (emit.h implicit-nil canonicalizer, #41), fixture loop_carried_nil:
  LOOP_CARRIED_NIL_RUNS / _DEFAULT_BEHAVIOR_SAME / _DEFAULT_CFG_IDENTITY
  LOOP_CARRIED_NIL_LEGACY_BEHAVIOR_DIFFERS  RENOVICE_NO_LOOP_NIL_HOIST resets the variable per iteration
  LOOP_CARRIED_NIL_LEGACY_CFG_BLIND         ... and cfg-identity still PASSes it (LOADNIL is epsilon):
                              a recorded gate blind spot, not a requirement to keep

Behavior fixes the gate cannot see or cannot yet match (#51, #52):
  setlist_existing   RENOVICE_NO_SETLIST_EXISTING_TABLE  (`{ k = v, (f()) }`: the SETLIST rebuilt a fresh
                     table and lost the fields). SETLIST_EXISTING_{RUNS,DEFAULT_BEHAVIOR_SAME,
                     LEGACY_BEHAVIOR_DIFFERS}; no CFG-ID check: the exact output stores `t[1] = v`
                     (SETTABLEN), stock uses SETLIST, so the prototype still differs (recorded).
  capture_snapshot   RENOVICE_NO_CAPTURE_SNAPSHOT  (a by-value capture of a loop-rewritten register saw
                     the last element). CAPTURE_SNAPSHOT_{RUNS,DEFAULT_BEHAVIOR_SAME,
                     DEFAULT_CFG_IDENTITY,DEFAULT_CLOSES,LEGACY_BEHAVIOR_DIFFERS,LEGACY_CFG_BLIND}:
                     cfg-identity does not compare MOVE/CAPTURE dataflow, so the legacy output PASSes
                     (blind spot); DEFAULT_CLOSES = the source repeats within 3 rounds.

Register-pressure / constant-key fixes (2026-10-10, agent spill, cert/fixtures/spill_2026_10_10). All
three defects are CFG-only (the legacy output behaves the same), so each records
<F>_{RUNS,DEFAULT_BEHAVIOR_SAME,DEFAULT_CFG_IDENTITY,DEFAULT_CLOSES,LEGACY_CFG_FAILS,LEGACY_BEHAVIOR_SAME}:
  register_key_index  RENOVICE_NO_INDEXN_KEY_GUARD (a register key 1..256 folded into `u[k]`: Luau
                      emits GETTABLEN/SETTABLEN instead of the stock LOADN + GETTABLE/SETTABLE)
  wide_root           RENOVICE_NO_EXACT_LOCAL_LIMIT (198 module locals: the fixed 195 budget spilled the
                      root to `vT[N]`, every child read became GETUPVAL + GETTABLEN)
  merged_root         RENOVICE_NO_STRAIGHT_LINE_REGISTER_MERGE (200 locals + a closure temporary above
                      them: 201 names; the temporary shares a dead local's name instead of the spill)

Gate normalization S5 (cfg_identity_cmd.h, #50), fixture or_block (original built with native ORK):
  OR_BLOCK_DEFAULT_BEHAVIOR_SAME / OR_BLOCK_DEFAULT_CFG_IDENTITY
  OR_BLOCK_LEGACY_GATE_FAILS  RENOVICE_CFGID_LEGACY_OR_BLOCK=1 reports the identical round trip as
                              different (a pure GETIMPORT could not sink past the lowered ORK)
  OR_BLOCK_MUTATION_*_FAILS   a changed `or` constant and `or` -> `and` must still FAIL

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
            "RENOVICE_CFGID_LEGACY_TRUTHY_NOOP", "RENOVICE_CFGID_LEGACY_LOOP_SLOT",
            "RENOVICE_NO_FOR_BODY_PART_ORDER", "RENOVICE_NO_PREP_HEADED_WHILE",
            "RENOVICE_NO_FOR_BREAK_ARM", "RENOVICE_NO_LOOP_ENTRY_NIL", "RENOVICE_NO_PROPER_PREP_FOR",
            "RENOVICE_NO_PROPER_NESTED_LOOP_PARTS", "RENOVICE_KEEP_SELECTOR_GUARD_RESIDUE",
            "RENOVICE_CFGID_LEGACY_OR_BLOCK", "RENOVICE_NATIVE",
            "RENOVICE_NO_SETLIST_EXISTING_TABLE", "RENOVICE_NO_CAPTURE_SNAPSHOT",
            "RENOVICE_INNERMOST_LOOP_FIRST", "RENOVICE_KEEP_UNUSED_SELECTOR_CONDITION",
            "RENOVICE_NO_PROPER_EXIT_IN_BODY_DAG", "RENOVICE_NO_PROPER_EXIT_ARM_ONCE",
            "RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN", "RENOVICE_NO_CFG_LOOP_ESCAPE_PRETEST",
            "RENOVICE_NO_CFG_WHILE_LOOP_ARMS",
            "RENOVICE_NO_INEXACT_HEAD_SELECTOR", "RENOVICE_NO_INLINE_BREAK_ARM",
            "RENOVICE_NO_INNERMOST_LOOP_FIRST", "RENOVICE_INEXACT_HEAD_SELECTOR",
            "RENOVICE_NO_DAG_PRECISE_NESTED_EXIT", "RENOVICE_NO_DECISION_PREP_OWNER",
            "RENOVICE_NO_FORNLOOP_LATCH_KEY", "RENOVICE_NO_DAG_BREAK_ARM_EXIT",
            "RENOVICE_NO_WHILE_PREP_GUARD", "RENOVICE_NO_INDEXN_KEY_GUARD",
            "RENOVICE_NO_EXACT_LOCAL_LIMIT", "RENOVICE_NO_STRAIGHT_LINE_REGISTER_MERGE")
DECOMPILER_FIXTURES = {
    "terminal_self_loop": "RENOVICE_NO_TERMINAL_SELF_LOOP",
    # Space-separated switches are all set for the legacy control. Innermost-first selection (#68,
    # default again since #82) also takes the clean header first, so the control switches both off.
    "entry_headed_loop": "RENOVICE_NO_ENTRY_HEADED_LOOP RENOVICE_NO_INNERMOST_LOOP_FIRST",
    "entry_outer_loop": "RENOVICE_NO_ENTRY_CALLER_EDGE",
    "import_chain": "RENOVICE_NO_IMPORT_CHAIN_GUARD",
    "compound_exit_loop": "RENOVICE_NO_LOOP_BODY_DAG",
    "compound_exit_namecall": "RENOVICE_NO_LOOP_BODY_DAG",
    "for_body_order": "RENOVICE_NO_FOR_BODY_PART_ORDER",
    "nested_for_break": "RENOVICE_NO_PREP_HEADED_WHILE",
    # Space-separated switches are all set for the legacy control. Since the two-exit loop escape
    # (2026-10-09, #80) the CFG renderer owns proper_prep_for's inlined two-exit loops, so the #48
    # legacy control must switch the escape off as well to reach the Proper dispatcher again.
    "proper_prep_for": "RENOVICE_NO_PROPER_PREP_FOR RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN",
    # the while break/return arms (#81) also structure this fixture's loop, so its legacy controls
    # switch them off too to reach the #76 Proper path
    "proper_exit_in_body": "RENOVICE_NO_PROPER_EXIT_IN_BODY_DAG RENOVICE_NO_CFG_WHILE_LOOP_ARMS",
    # Two-exit loops (2026-10-09, cert/fixtures/twoexit_2026_10_09, #80/#81)
    "escape_join_forgen": "RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN",
    "escape_join_loop_value": "RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN",
    # (#86) the FORNLOOP latch key also structures this shape (verified: with it off the control
    # reproduces the #81 defect again)
    "while_break_return_arms": "RENOVICE_NO_CFG_WHILE_LOOP_ARMS RENOVICE_NO_FORNLOOP_LATCH_KEY",
    # Loops campaign (#82-#89): Platform p2 break arm, VentKidsBand p1 innermost-first
    "loop_break_arm_join": "RENOVICE_NO_INEXACT_HEAD_SELECTOR",
    "innermost_nested_repeat": "RENOVICE_NO_INNERMOST_LOOP_FIRST",
}
FIXTURE_DIRS = {name: os.path.join(HERE, "fixtures", "twoexit_2026_10_09")
                for name in ("escape_join_forgen", "escape_join_loop_value", "while_break_return_arms")}
# Additional opt-outs checked on an existing fixture: (fixture, check label, switch, cfg expectation
# [, behavior expectation]). cfg expectation "FAIL" = the gate must catch it; "PASS" = a recorded gate
# blind spot. Behavior expectation (default "DIFFERS"); "SAME" = a CFG-only defect (an extra
# operation stock never had, behavior-neutral). Space-separated switches are all set.
EXTRA_LEGACY = (
    # the break arm printed inside its loop (#83) covers #46's arm too
    ("nested_for_break", "BREAK_ARM", "RENOVICE_NO_FOR_BREAK_ARM RENOVICE_NO_INLINE_BREAK_ARM", "FAIL"),
    ("nested_for_break", "ENTRY_NIL", "RENOVICE_NO_LOOP_ENTRY_NIL", "PASS"),
    ("proper_prep_for", "NESTED", "RENOVICE_NO_PROPER_NESTED_LOOP_PARTS RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN",
     "FAIL"),
    ("proper_exit_in_body", "EXIT_ARM_ONCE", "RENOVICE_NO_PROPER_EXIT_ARM_ONCE RENOVICE_NO_CFG_WHILE_LOOP_ARMS", "FAIL", "SAME"),
)
O2_FIXTURES = {"proper_prep_for",          # compiled with inlining, like the shipped modules
               "escape_join_forgen", "escape_join_loop_value"}
LUAU_COMPILE = os.path.join(ROOT, "bin", "luau-compile.exe")
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
# Globals for for_body_order: gGameRules appears on every second Sleep.
FOR_BODY_PRELUDE = """polls = 0
function IsNull(value) return value == nil end
function Sleep(seconds)
    polls = polls + 1
    print("sleep", seconds, polls)
    if polls % 2 == 0 then gGameRules = {} end
    if polls > 20 then error("runaway", 0) end
end
"""
# Globals for proper_exit_in_body (proper campaign 2026-10-09): engine mocks and Setup(), which
# builds the leech and its victim; the victim dies after three hits.
PROPER_EXIT_PRELUDE = open(os.path.join(FIX, "proper_exit_in_body.prelude.lua"), encoding="utf-8").read()
PRELUDES = {"import_chain": IMPORT_PRELUDE, "compound_exit_loop": GAME_RULES_PRELUDE,
            "for_body_order": FOR_BODY_PRELUDE, "proper_exit_in_body": PROPER_EXIT_PRELUDE}
OR_BLOCK_PRELUDE = "_T = {}\n"
OR_BLOCK_ANCHOR = "    _T.Timer = _T.Timer or 0\n"
OR_BLOCK_MUTATIONS = {
    "CONSTANT": "    _T.Timer = _T.Timer or 1\n",
    "AND": "    _T.Timer = _T.Timer and 0\n",
}
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


def trace(path, temp, prelude="", epilogue=""):
    """Run a source file under luau.exe. With a prelude, the source is loaded as a chunk AFTER the
    prelude runs, so globals it reads already exist at load time (import resolution). An epilogue
    runs after the chunk (it reads the globals the chunk defined)."""
    if prelude or epilogue:
        body = open(path, encoding="utf-8").read()
        level = 1
        while ("]" + "=" * level + "]") in body:
            level += 1
        driver = os.path.join(temp, "driver_%s" % os.path.basename(path))
        with open(driver, "w", encoding="utf-8", newline="\n") as stream:
            stream.write(prelude)
            stream.write("local chunk = assert(loadstring([%s[%s]%s]))\nchunk()\n"
                         % ("=" * level, body, "=" * level))
            stream.write(epilogue)
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


def compile_fixture(fixture, name, out):
    """Luau source -> DE bytecode. -O2 fixtures go through luau-compile -O2 + transcode so the
    compiler inlines local functions exactly as the shipped modules were built."""
    if name not in O2_FIXTURES:
        run([DEC, "recompile", fixture, out])
        return
    proc = subprocess.run([LUAU_COMPILE, "--binary", "-O2", fixture], cwd=ROOT, capture_output=True,
                          timeout=300)
    if proc.returncode != 0:
        raise RuntimeError("luau-compile -O2 failed: %s" % proc.stderr[-400:])
    luaubc = out + ".luaubc"
    with open(luaubc, "wb") as stream:
        stream.write(proc.stdout)
    run([DEC, "transcode", luaubc, out])


def closes_within(bytecode, temp, tag, rounds, env=None):
    """decompile -> recompile repeatedly; True when the source repeats within `rounds` rounds."""
    previous_source, current = None, bytecode
    for index in range(1, rounds + 1):
        source, rebuilt = round_trip(current, temp, "%s.r%d" % (tag, index), env)
        text = open(source, "rb").read()
        if text == previous_source:
            return True
        previous_source, current = text, rebuilt
    return False


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
                fixture = os.path.join(FIXTURE_DIRS.get(name, FIX), name + ".luau")
                prelude = PRELUDES.get(name, "")
                expected = trace(fixture, temp, prelude)
                checks[name.upper() + "_RUNS"] = expected.count("\n") >= 2
                original = os.path.join(temp, name + ".original.lua_B")
                compile_fixture(fixture, name, original)
                source, rebuilt = round_trip(original, temp, name + ".default")
                checks[name.upper() + "_DEFAULT_BEHAVIOR_SAME"] = trace(source, temp, prelude) == expected
                checks[name.upper() + "_DEFAULT_CFG_IDENTITY"] = cfg_verdict(original, rebuilt) == "PASS"
                legacy_env = base_env()
                for switch_name in opt_out.split():
                    legacy_env[switch_name] = "1"
                legacy_source, legacy_rebuilt = round_trip(original, temp, name + ".legacy", legacy_env)
                checks[name.upper() + "_LEGACY_CFG_FAILS"] = cfg_verdict(original, legacy_rebuilt) == "FAIL"
                checks[name.upper() + "_LEGACY_BEHAVIOR_DIFFERS"] = trace(legacy_source, temp, prelude) != expected
                for extra in EXTRA_LEGACY:
                    extra_name, label, switch, cfg_expect = extra[:4]
                    behavior_expect = extra[4] if len(extra) > 4 else "DIFFERS"
                    if extra_name != name:
                        continue
                    extra_env = base_env()
                    for switch_name in switch.split():
                        extra_env[switch_name] = "1"
                    extra_source, extra_rebuilt = round_trip(original, temp,
                                                             "%s.legacy_%s" % (name, label.lower()),
                                                             extra_env)
                    key = "%s_LEGACY_%s" % (name.upper(), label)
                    if cfg_expect == "FAIL":
                        checks[key + "_CFG_FAILS"] = cfg_verdict(original, extra_rebuilt) == "FAIL"
                    else:
                        checks[key + "_CFG_BLIND"] = cfg_verdict(original, extra_rebuilt) == "PASS"
                    if behavior_expect == "SAME":
                        checks[key + "_BEHAVIOR_SAME"] = trace(extra_source, temp, prelude) == expected
                    else:
                        checks[key + "_BEHAVIOR_DIFFERS"] = trace(extra_source, temp, prelude) != expected

            fixture = os.path.join(FIX, "selector_residue.luau")
            expected = trace(fixture, temp)
            checks["SELECTOR_RESIDUE_RUNS"] = expected.count("\n") >= 2
            original = os.path.join(temp, "selector_residue.original.lua_B")
            run([DEC, "recompile", fixture, original])
            source, rebuilt = round_trip(original, temp, "selector_residue.default")
            checks["SELECTOR_RESIDUE_DEFAULT_BEHAVIOR_SAME"] = trace(source, temp) == expected
            checks["SELECTOR_RESIDUE_DEFAULT_CFG_IDENTITY"] = cfg_verdict(original, rebuilt) == "PASS"
            checks["SELECTOR_RESIDUE_DEFAULT_CLOSES"] = closes_within(original, temp,
                                                                      "selector_residue.close", 3)
            legacy_env = base_env()
            legacy_env["RENOVICE_KEEP_SELECTOR_GUARD_RESIDUE"] = "1"
            # 2026-10-09 (#59): the unused-condition canonicalizer also drops the residue's integer
            # compare, so the legacy control must switch both off to reproduce the #49 output.
            legacy_env["RENOVICE_KEEP_UNUSED_SELECTOR_CONDITION"] = "1"
            # (#83) the residue came from a break-arm selector, which the break arm printed inside its
            # loop no longer creates
            legacy_env["RENOVICE_NO_INLINE_BREAK_ARM"] = "1"
            checks["SELECTOR_RESIDUE_LEGACY_NOT_CLOSED"] = not closes_within(
                original, temp, "selector_residue.legacy_close", 5, legacy_env)
            legacy_source, legacy_rebuilt = round_trip(original, temp, "selector_residue.legacy",
                                                       legacy_env)
            checks["SELECTOR_RESIDUE_LEGACY_CFG_FAILS"] = cfg_verdict(original, legacy_rebuilt) == "FAIL"

            # (#83) the break arm printed inside its loop re-decompiles to itself; the recorded-exit
            # selector (RENOVICE_NO_INLINE_BREAK_ARM) is exact but grows a relay per compile cycle.
            fixture = os.path.join(FIX, "loop_break_arm_join.luau")
            original = os.path.join(temp, "loop_break_arm_join.close.lua_B")
            run([DEC, "recompile", fixture, original])
            checks["LOOP_BREAK_ARM_JOIN_DEFAULT_CLOSES"] = closes_within(original, temp,
                                                                         "loop_break_arm_join.close", 3)
            selector_env = base_env()
            selector_env["RENOVICE_NO_INLINE_BREAK_ARM"] = "1"
            selector_env["RENOVICE_INEXACT_HEAD_SELECTOR"] = "1"     # the opt-in selector fallback
            selector_env["RENOVICE_NO_INNERMOST_LOOP_FIRST"] = "1"   # outer-first: the selector spans the outer loop
            checks["LOOP_BREAK_ARM_JOIN_SELECTOR_NOT_CLOSED"] = not closes_within(
                original, temp, "loop_break_arm_join.selector_close", 5, selector_env)

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

            for name, switch, cfg_checks in (("setlist_existing", "RENOVICE_NO_SETLIST_EXISTING_TABLE", False),
                                              ("capture_snapshot", "RENOVICE_NO_CAPTURE_SNAPSHOT", True)):
                fixture = os.path.join(FIX, name + ".luau")
                expected = trace(fixture, temp)
                key = name.upper()
                checks[key + "_RUNS"] = expected.count("\n") >= 2
                original = os.path.join(temp, name + ".original.lua_B")
                run([DEC, "recompile", fixture, original])
                source, rebuilt = round_trip(original, temp, name + ".default")
                checks[key + "_DEFAULT_BEHAVIOR_SAME"] = trace(source, temp) == expected
                legacy_env = base_env()
                legacy_env[switch] = "1"
                legacy_source, legacy_rebuilt = round_trip(original, temp, name + ".legacy", legacy_env)
                checks[key + "_LEGACY_BEHAVIOR_DIFFERS"] = trace(legacy_source, temp) != expected
                if cfg_checks:
                    checks[key + "_DEFAULT_CFG_IDENTITY"] = cfg_verdict(original, rebuilt) == "PASS"
                    checks[key + "_LEGACY_CFG_BLIND"] = cfg_verdict(original, legacy_rebuilt) == "PASS"
                    # the snapshot must re-decompile to itself (no new local per round)
                    checks[key + "_DEFAULT_CLOSES"] = closes_within(original, temp, name + ".close", 3)

            spill_dir = os.path.join(HERE, "fixtures", "spill_2026_10_10")
            make_prelude = "function Make(i) return i * 3 + 1 end\n"
            wide_epilogue = "".join("print(Sum%d())\n" % k for k in range(0, 198, 33))
            merged_epilogue = ("".join("print(Sum%d())\n" % k for k in range(1, 200, 40))
                               + "print(Name())\n")
            for name, switch, prelude, epilogue in (
                    ("register_key_index", "RENOVICE_NO_INDEXN_KEY_GUARD", "", ""),
                    ("wide_root", "RENOVICE_NO_EXACT_LOCAL_LIMIT", make_prelude, wide_epilogue),
                    ("merged_root", "RENOVICE_NO_STRAIGHT_LINE_REGISTER_MERGE", make_prelude,
                     merged_epilogue)):
                fixture = os.path.join(spill_dir, name + ".luau")
                key = name.upper()
                expected = trace(fixture, temp, prelude, epilogue)
                checks[key + "_RUNS"] = expected.count("\n") >= 2 and "<runtime error" not in expected
                original = os.path.join(temp, name + ".original.lua_B")
                run([DEC, "recompile", fixture, original])
                source, rebuilt = round_trip(original, temp, name + ".default")
                checks[key + "_DEFAULT_BEHAVIOR_SAME"] = trace(source, temp, prelude, epilogue) == expected
                checks[key + "_DEFAULT_CFG_IDENTITY"] = cfg_verdict(original, rebuilt) == "PASS"
                checks[key + "_DEFAULT_CLOSES"] = closes_within(original, temp, name + ".close", 3)
                legacy_env = base_env()
                legacy_env[switch] = "1"
                legacy_source, legacy_rebuilt = round_trip(original, temp, name + ".legacy", legacy_env)
                checks[key + "_LEGACY_CFG_FAILS"] = cfg_verdict(original, legacy_rebuilt) == "FAIL"
                checks[key + "_LEGACY_BEHAVIOR_SAME"] = (trace(legacy_source, temp, prelude, epilogue)
                                                         == expected)

            fixture = os.path.join(FIX, "or_block.luau")
            text = open(fixture, encoding="utf-8").read()
            expected = trace(fixture, temp, OR_BLOCK_PRELUDE)
            original = os.path.join(temp, "or_block.original.lua_B")
            native_env = base_env()
            native_env["RENOVICE_NATIVE"] = "ORK"
            run([DEC, "recompile", fixture, original], env=native_env)
            source, rebuilt = round_trip(original, temp, "or_block.default")
            checks["OR_BLOCK_DEFAULT_BEHAVIOR_SAME"] = trace(source, temp, OR_BLOCK_PRELUDE) == expected
            checks["OR_BLOCK_DEFAULT_CFG_IDENTITY"] = cfg_verdict(original, rebuilt) == "PASS"
            legacy_gate = base_env()
            legacy_gate["RENOVICE_CFGID_LEGACY_OR_BLOCK"] = "1"
            checks["OR_BLOCK_LEGACY_GATE_FAILS"] = cfg_verdict(original, rebuilt, legacy_gate) == "FAIL"
            if text.count(OR_BLOCK_ANCHOR) != 1:
                raise RuntimeError("or_block mutation anchor not unique")
            for label, new in OR_BLOCK_MUTATIONS.items():
                mutant = compile_text(text.replace(OR_BLOCK_ANCHOR, new), temp,
                                      "or_block.mutant_" + label.lower())
                checks["OR_BLOCK_MUTATION_%s_FAILS" % label] = cfg_verdict(original, mutant) == "FAIL"

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
