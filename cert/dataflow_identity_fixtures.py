#!/usr/bin/env python3
"""Sensitivity and negative controls for `derecomp dataflow-identity` (2026-10-09).

dataflow-identity compares, per prototype, which value origin reaches every register operand of every
operation matched by CFG-ID, the live dynamic values at every matched operation, and what each
CAPTURE captures (src/dataflow_identity_cmd.h). CFG-ID is register-free and cannot see these facts.
Every check goes through the real Luau -> DE -> decompile-mod -> recompile path; behavior is the
luau.exe trace of the source.

Documented wrong outputs CFG-ID passes (the decompiler opt-out reproduces each):
  loop_carried_nil   RENOVICE_NO_LOOP_NIL_HOIST    (#41: `owner = nil` reset every iteration)
  nested_for_break   RENOVICE_NO_LOOP_ENTRY_NIL    (#47: loop-entry LOADNIL dropped, idx carried)
  capture_snapshot   RENOVICE_NO_CAPTURE_SNAPSHOT  (#52: by-value capture bound to a flat local)
  <F>_DEFAULT_BEHAVIOR_SAME / <F>_DEFAULT_DF_PASS    the fixed output
  <F>_LEGACY_BEHAVIOR_DIFFERS / <F>_LEGACY_CFG_BLIND the defect is real and CFG-ID passes it
  <F>_LEGACY_DF_FAILS                                dataflow-identity reports it

Identity: every fixture under cert/fixtures/cfg_class_2026_09_30 and dataflow_2026_10_09 compared
with itself must PASS (<F>_SELF_DF_PASS), and the default round trip of every fixture whose rebuild
passes CFG-ID must pass dataflow-identity too (<F>_ROUNDTRIP_DF_PASS).

Source mutants (compiled and compared with the original):
  dataflow must catch, CFG-ID blind, behavior differs:
    NESTED_FOR_BREAK_MUT_DROPPED_LOADNIL   `local idx = nil` hoisted out of the `while`
    LOOP_CARRIED_NIL_MUT_MOVED_RESET       `local owner = nil` moved into the `while`
    CAPTURE_SNAPSHOT_MUT_BY_REFERENCE      the per-element local shared across iterations (CAPTURE REF)
    READ_BEFORE_WRITE_MUT                  an unassigned local read instead of the call result
    REF_CAPTURE_MUT_LATE_WRITE             the captured variable assigned after the closure ran
  equivalent, both gates must PASS:
    REF_CAPTURE_EQUIVALENT                 REF capture with no write while open == VAL capture
    TAIL_EQUIVALENT_REORDER                an unread load moved later in its block
  CFG-ID must still catch (unchanged verdicts): TAIL_MUTATION_CONSTANT, TAIL_MUTATION_EFFECT_ORDER

Open-defect witnesses (cert/fixtures/dataflow_2026_10_09/open_defects, real defects found by the
2026-10-09 specificity run over the CFG-ID PASS population): each must still show
  <F>_OPEN_CFG_BLIND  CFG-ID passes the rebuild
  <F>_OPEN_DF_FAILS   dataflow-identity fails it
  <F>_OPEN_BEHAVIOR_DIFFERS  luau.exe output differs (decompiled source; for the recompiler defect the
                             source re-decompiled from the rebuilt bytecode)
When a fix lands these flip: move the fixture to the passing set and record it in DEFECTS.md.

Fixed open defects (fixture moved up to cert/fixtures/dataflow_2026_10_09; the opt-out reproduces the
old output, applied to decompile-mod for decompiler fixes and to recompile for the recompiler fix):
  copy_fold_live_dest     RENOVICE_NO_COALESCE_LIVE_DEST_GUARD    (#63, decompiler)
  table_move_live_source  RENOVICE_NO_TABLEMOVE_LIVE_SOURCE_GUARD (#64, decompiler)
  or_lowering_c_equals_a  RENOVICE_LEGACY_ORAND_LOWERING          (#65, recompiler)
  orand_alias_cases       RENOVICE_LEGACY_ORAND_LOWERING          (#65, all A/B/C aliasing cases)
  call_move_live_multi    RENOVICE_NO_CALLMOVE_LIVE_SOURCE_GUARD  (#64, multi-result call retarget)
  <F>_FIXED_BEHAVIOR_SAME / <F>_FIXED_CFG_PASS / <F>_FIXED_DF_PASS     the fixed output
  <F>_LEGACY_BEHAVIOR_DIFFERS / <F>_LEGACY_CFG_BLIND / <F>_LEGACY_DF_FAILS  the defect stays reproducible

Fixed shape defects (CFG-ID sees the old form):
  setlist_batch_merge     RENOVICE_NO_SETLIST_BATCH_MERGE         (#66, >16-item constructors)
  <F>_FIXED_BEHAVIOR_SAME / <F>_FIXED_CFG_PASS / <F>_FIXED_DF_PASS / <F>_LEGACY_BEHAVIOR_DIFFERS / <F>_LEGACY_CFG_FAILS
  (the old index-store form also truncated a multret tail in a later batch to one value: the fixture's
  `select(2, 0, 36, 37)` tail lost 37)

Fixed by the two-exit loop escape (2026-10-09, #76), decompiler opt-outs:
  for_index_after_exit_o2  RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN       (moved up to cert/fixtures/dataflow_2026_10_09)
  escape_pretest           RENOVICE_NO_CFG_LOOP_ESCAPE_PRETEST    (cert/fixtures/twoexit_2026_10_09, -O2;
                           the construct starts at the inlined helper's guard)
"""
import os
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import cfg_class_fixtures as cc  # noqa: E402  (shared run/trace/round-trip helpers, opt-out scrubbing)

HERE = os.path.dirname(os.path.abspath(__file__))
FIX_CFG = os.path.join(HERE, "fixtures", "cfg_class_2026_09_30")
FIX_DF = os.path.join(HERE, "fixtures", "dataflow_2026_10_09")
FIX_OPEN = os.path.join(FIX_DF, "open_defects")
# fixture -> how its behavior is observed: "source" (decompiled source) or "rebuilt" (the source
# re-decompiled from the rebuilt bytecode: the defect is in recompile, the decompiled text is right)
OPEN_DEFECTS = {}
# Fixed open defects: fixture (in FIX_DF) -> (legacy opt-out, observation, stage the opt-out applies to)
FIXED_DEFECTS = {
    "copy_fold_live_dest": ("RENOVICE_NO_COALESCE_LIVE_DEST_GUARD", "source", "decompile"),
    "table_move_live_source": ("RENOVICE_NO_TABLEMOVE_LIVE_SOURCE_GUARD", "source", "decompile"),
    "or_lowering_c_equals_a": ("RENOVICE_LEGACY_ORAND_LOWERING", "rebuilt", "recompile"),
    "orand_alias_cases": ("RENOVICE_LEGACY_ORAND_LOWERING", "rebuilt", "recompile"),
    "call_move_live_multi": ("RENOVICE_NO_CALLMOVE_LIVE_SOURCE_GUARD", "source", "decompile"),
    # fixed by #64 (2026-10-09 batch 3)
    "loop_exit_test_register": ("RENOVICE_NO_WHILE_TAIL_TEST", "source", "decompile"),
    # fixed by #76 (2026-10-09, two-exit loop escape joins)
    "for_index_after_exit_o2": ("RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN", "source", "decompile"),
    "escape_pretest": ("RENOVICE_NO_CFG_LOOP_ESCAPE_PRETEST", "source", "decompile"),
}
# fixtures outside FIX_DF
FIXED_FOLDERS = {"escape_pretest": os.path.join(HERE, "fixtures", "twoexit_2026_10_09")}
SHAPE_FIXED = {"setlist_batch_merge": "RENOVICE_NO_SETLIST_BATCH_MERGE"}
# never inherit these from the caller's shell (PITFALLS A7)
cc.OPT_OUTS = tuple(cc.OPT_OUTS) + tuple(sorted({switch for switch, _, _ in FIXED_DEFECTS.values()}
                                                 | set(SHAPE_FIXED.values())))
cc.O2_FIXTURES.add("for_index_after_exit_o2")
cc.O2_FIXTURES.add("escape_pretest")

LEGACY = (("loop_carried_nil", "RENOVICE_NO_LOOP_NIL_HOIST"),
          ("nested_for_break", "RENOVICE_NO_LOOP_ENTRY_NIL"),
          ("capture_snapshot", "RENOVICE_NO_CAPTURE_SNAPSHOT"))

# (check, fixture dir, fixture, anchor, replacement, cfg expectation, df expectation, behavior)
MUTANTS = (
    ("NESTED_FOR_BREAK_MUT_DROPPED_LOADNIL", FIX_CFG, "nested_for_break",
     "    while true do\n        local idx = nil\n", "    local idx = nil\n    while true do\n",
     "PASS", "FAIL", "DIFFERS"),
    ("LOOP_CARRIED_NIL_MUT_MOVED_RESET", FIX_CFG, "loop_carried_nil",
     "    local owner = nil\n    while true do\n", "    while true do\n        local owner = nil\n",
     "PASS", "FAIL", "DIFFERS"),
    ("CAPTURE_SNAPSHOT_MUT_BY_REFERENCE", FIX_CFG, "capture_snapshot",
     "    for i = 1, #elements do\n        local element = elements[i]\n",
     "    local element\n    for i = 1, #elements do\n        element = elements[i]\n",
     "PASS", "FAIL", "DIFFERS"),
    ("READ_BEFORE_WRITE_MUT", FIX_DF, "read_before_write",
     "        local wind = Compute(zone)\n", "        local wind\n        local computed = Compute(zone)\n",
     "PASS", "FAIL", "DIFFERS"),
    ("REF_CAPTURE_MUT_LATE_WRITE", FIX_DF, "ref_capture",
     "    value = scaled\n    local reader = function()\n        return value\n    end\n    print(\"made\", n, reader())\n",
     "    local reader = function()\n        return value\n    end\n    print(\"made\", n, reader())\n    value = scaled\n",
     "PASS", "FAIL", "DIFFERS"),
    ("REF_CAPTURE_EQUIVALENT", FIX_DF, "ref_capture",
     "    value = scaled\n    local reader = function()\n        return value\n    end\n",
     "    local final = scaled\n    local reader = function()\n        return final\n    end\n",
     "PASS", "PASS", "SAME"),
    ("TAIL_EQUIVALENT_REORDER", FIX_CFG, "tail_load_order",
     "    local t = 0\n    local info = obj:GetRegionMgr():GetLevelInfo()\n",
     "    local info = obj:GetRegionMgr():GetLevelInfo()\n    local t = 0\n",
     "PASS", "PASS", "SAME"),
    ("TAIL_MUTATION_CONSTANT", FIX_CFG, "tail_load_order",
     "    local t = 0\n", "    local t = 1\n", "FAIL", None, "DIFFERS"),
    ("TAIL_MUTATION_EFFECT_ORDER", FIX_CFG, "tail_load_order",
     "        t = t + 0.5\n        info:SetFade(from + t)\n", "        info:SetFade(from + t)\n        t = t + 0.5\n",
     "FAIL", None, "DIFFERS"),
)


def df_verdict(original, candidate, env=None):
    out = cc.run([cc.DEC, "dataflow-identity", original, candidate], env=env, check=False).stdout
    for line in out.splitlines():
        if line.startswith("DATAFLOW_IDENTITY "):
            return line.rsplit("verdict=", 1)[-1].strip()
    return "ERROR"


def native_original(fixture, out):
    """Stock DE carries native OR/AND (0x2b/0x2f); our recompile lowers them, so a recompiler-defect
    original is built with the native-emission knob exactly as the stock module was."""
    native_env = cc.base_env()
    native_env["RENOVICE_NATIVE"] = "OR,AND"
    cc.run([cc.DEC, "recompile", fixture, out], env=native_env)


def round_trip_staged(bytecode, temp, tag, decompile_env=None, recompile_env=None):
    source = os.path.join(temp, tag + ".luau")
    rebuilt = os.path.join(temp, tag + ".lua_B")
    cc.run([cc.DEC, "decompile-mod", bytecode, source], env=decompile_env)
    cc.run([cc.DEC, "recompile", source, rebuilt], env=recompile_env)
    return source, rebuilt


def fixtures():
    out = []
    for folder in (FIX_CFG, FIX_DF):
        for name in sorted(os.listdir(folder)):
            if name.endswith(".luau"):
                out.append((folder, name[:-5]))
    return out


def main():
    checks = {}
    try:
        with tempfile.TemporaryDirectory(prefix="renovice-dataflow-") as temp:
            originals = {}
            for folder, name in fixtures():
                original = os.path.join(temp, name + ".original.lua_B")
                cc.compile_fixture(os.path.join(folder, name + ".luau"), name, original)
                originals[name] = original
                key = name.upper()
                checks[key + "_SELF_DF_PASS"] = df_verdict(original, original) == "PASS"
                _, rebuilt = cc.round_trip(original, temp, name + ".default")
                if cc.cfg_verdict(original, rebuilt) == "PASS":
                    checks[key + "_ROUNDTRIP_DF_PASS"] = df_verdict(original, rebuilt) == "PASS"

            for name, switch in LEGACY:
                fixture = os.path.join(FIX_CFG, name + ".luau")
                expected = cc.trace(fixture, temp)
                original = originals[name]
                key = name.upper()
                source, rebuilt = cc.round_trip(original, temp, name + ".default2")
                checks[key + "_DEFAULT_BEHAVIOR_SAME"] = cc.trace(source, temp) == expected
                checks[key + "_DEFAULT_DF_PASS"] = df_verdict(original, rebuilt) == "PASS"
                legacy_env = cc.base_env()
                legacy_env[switch] = "1"
                legacy_source, legacy_rebuilt = cc.round_trip(original, temp, name + ".legacy", legacy_env)
                checks[key + "_LEGACY_BEHAVIOR_DIFFERS"] = cc.trace(legacy_source, temp) != expected
                checks[key + "_LEGACY_CFG_BLIND"] = cc.cfg_verdict(original, legacy_rebuilt) == "PASS"
                checks[key + "_LEGACY_DF_FAILS"] = df_verdict(original, legacy_rebuilt) == "FAIL"

            for check, folder, name, anchor, replacement, cfg_expect, df_expect, behavior in MUTANTS:
                path = os.path.join(folder, name + ".luau")
                text = open(path, encoding="utf-8").read()
                if text.count(anchor) != 1:
                    raise RuntimeError("%s: mutation anchor not unique" % check)
                mutant_text = text.replace(anchor, replacement)
                mutant = cc.compile_text(mutant_text, temp, check.lower())
                mutant_source = os.path.join(temp, check.lower() + ".luau")
                original = originals[name]
                checks[check + "_CFG_" + cfg_expect] = cc.cfg_verdict(original, mutant) == cfg_expect
                if df_expect:
                    checks[check + "_DF_" + df_expect] = df_verdict(original, mutant) == df_expect
                same = cc.trace(mutant_source, temp) == cc.trace(path, temp)
                checks[check + "_BEHAVIOR_" + behavior] = same == (behavior == "SAME")
            for name, observe in OPEN_DEFECTS.items():
                fixture = os.path.join(FIX_OPEN, name + ".luau")
                key = name.upper() + "_OPEN"
                original = os.path.join(temp, name + ".open_original.lua_B")
                if observe == "rebuilt":
                    native_original(fixture, original)
                else:
                    cc.compile_fixture(fixture, name, original)
                source, rebuilt = cc.round_trip(original, temp, name + ".open")
                if observe == "rebuilt":
                    source, _ = cc.round_trip(rebuilt, temp, name + ".open2")
                checks[key + "_CFG_BLIND"] = cc.cfg_verdict(original, rebuilt) == "PASS"
                checks[key + "_DF_FAILS"] = df_verdict(original, rebuilt) == "FAIL"
                checks[key + "_BEHAVIOR_DIFFERS"] = cc.trace(source, temp) != cc.trace(fixture, temp)
            for name, (switch, observe, stage) in FIXED_DEFECTS.items():
                fixture = os.path.join(FIXED_FOLDERS.get(name, FIX_DF), name + ".luau")
                expected = cc.trace(fixture, temp)
                original = os.path.join(temp, name + ".fixed_original.lua_B")
                if observe == "rebuilt":
                    native_original(fixture, original)
                else:
                    cc.compile_fixture(fixture, name, original)
                legacy_env = cc.base_env()
                legacy_env[switch] = "1"
                for variant, env in (("FIXED", None), ("LEGACY", legacy_env)):
                    source, rebuilt = round_trip_staged(
                        original, temp, "%s.%s" % (name, variant.lower()),
                        decompile_env=env if stage == "decompile" else None,
                        recompile_env=env if stage == "recompile" else None)
                    if observe == "rebuilt":
                        source, _ = cc.round_trip(rebuilt, temp, "%s.%s2" % (name, variant.lower()))
                    same = cc.trace(source, temp) == expected
                    cfg = cc.cfg_verdict(original, rebuilt)
                    df = df_verdict(original, rebuilt)
                    key = "%s_%s" % (name.upper(), variant)
                    if variant == "FIXED":
                        checks[key + "_BEHAVIOR_SAME"] = same
                        checks[key + "_CFG_PASS"] = cfg == "PASS"
                        checks[key + "_DF_PASS"] = df == "PASS"
                    else:
                        checks[key + "_BEHAVIOR_DIFFERS"] = not same
                        checks[key + "_CFG_BLIND"] = cfg == "PASS"
                        checks[key + "_DF_FAILS"] = df == "FAIL"
            for name, switch in SHAPE_FIXED.items():
                fixture = os.path.join(FIX_DF, name + ".luau")
                expected = cc.trace(fixture, temp)
                original = os.path.join(temp, name + ".shape_original.lua_B")
                cc.compile_fixture(fixture, name, original)
                legacy_env = cc.base_env()
                legacy_env[switch] = "1"
                key = name.upper()
                source, rebuilt = round_trip_staged(original, temp, name + ".shape_fixed")
                checks[key + "_FIXED_BEHAVIOR_SAME"] = cc.trace(source, temp) == expected
                checks[key + "_FIXED_CFG_PASS"] = cc.cfg_verdict(original, rebuilt) == "PASS"
                checks[key + "_FIXED_DF_PASS"] = df_verdict(original, rebuilt) == "PASS"
                source, rebuilt = round_trip_staged(original, temp, name + ".shape_legacy", decompile_env=legacy_env)
                checks[key + "_LEGACY_BEHAVIOR_DIFFERS"] = cc.trace(source, temp) != expected
                checks[key + "_LEGACY_CFG_FAILS"] = cc.cfg_verdict(original, rebuilt) == "FAIL"
    except (OSError, RuntimeError) as error:
        print("FATAL %s" % error)
        return 2
    for name, passed in checks.items():
        print("%-52s %s" % (name, "PASS" if passed else "FAIL"))
    verdict = all(checks.values())
    print("DATAFLOW_FIXTURES checks=%d passed=%d verdict=%s"
          % (len(checks), sum(checks.values()), "PASS" if verdict else "FAIL"))
    return 0 if verdict else 1


if __name__ == "__main__":
    sys.exit(main())
