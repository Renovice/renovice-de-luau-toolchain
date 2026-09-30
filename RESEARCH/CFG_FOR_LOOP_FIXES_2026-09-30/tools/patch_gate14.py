"""Scratch: extend cert/cfg_class_fixtures.py (Gate 14) with the 2026-09-30 numeric-for fixtures."""
import sys

p = sys.argv[1]
s = open(p, encoding="utf-8").read()


def rep(a, b):
    global s
    assert s.count(a) == 1, a
    s = s.replace(a, b)


rep('''  compound_exit_namecall      RENOVICE_NO_LOOP_BODY_DAG       (the same shape with upvalue mocks)
''', '''  compound_exit_namecall      RENOVICE_NO_LOOP_BODY_DAG       (the same shape with upvalue mocks)

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

Compiler-closure fix (#49), fixture selector_residue:
  SELECTOR_RESIDUE_RUNS / _DEFAULT_BEHAVIOR_SAME / _DEFAULT_CFG_IDENTITY
  SELECTOR_RESIDUE_DEFAULT_CLOSES     the decompile->recompile source repeats within 3 rounds
  SELECTOR_RESIDUE_LEGACY_NOT_CLOSED  RENOVICE_KEEP_SELECTOR_GUARD_RESIDUE: no repeat within 5 rounds
  SELECTOR_RESIDUE_LEGACY_CFG_FAILS   ... and the first pass fails cfg-identity (the residue compare)
''')
rep('''            "RENOVICE_CFGID_LEGACY_TRUTHY_NOOP", "RENOVICE_CFGID_LEGACY_LOOP_SLOT")''',
    '''            "RENOVICE_CFGID_LEGACY_TRUTHY_NOOP", "RENOVICE_CFGID_LEGACY_LOOP_SLOT",
            "RENOVICE_NO_FOR_BODY_PART_ORDER", "RENOVICE_NO_PREP_HEADED_WHILE",
            "RENOVICE_NO_FOR_BREAK_ARM", "RENOVICE_NO_LOOP_ENTRY_NIL", "RENOVICE_NO_PROPER_PREP_FOR",
            "RENOVICE_NO_PROPER_NESTED_LOOP_PARTS", "RENOVICE_KEEP_SELECTOR_GUARD_RESIDUE")''')
rep('''    "compound_exit_namecall": "RENOVICE_NO_LOOP_BODY_DAG",
}''', '''    "compound_exit_namecall": "RENOVICE_NO_LOOP_BODY_DAG",
    "for_body_order": "RENOVICE_NO_FOR_BODY_PART_ORDER",
    "nested_for_break": "RENOVICE_NO_PREP_HEADED_WHILE",
    "proper_prep_for": "RENOVICE_NO_PROPER_PREP_FOR",
}
# Additional opt-outs checked on an existing fixture: (fixture, check label, switch, cfg expectation).
# cfg expectation "FAIL" = the gate must catch it; "PASS" = a recorded gate blind spot.
EXTRA_LEGACY = (
    ("nested_for_break", "BREAK_ARM", "RENOVICE_NO_FOR_BREAK_ARM", "FAIL"),
    ("nested_for_break", "ENTRY_NIL", "RENOVICE_NO_LOOP_ENTRY_NIL", "PASS"),
    ("proper_prep_for", "NESTED", "RENOVICE_NO_PROPER_NESTED_LOOP_PARTS", "FAIL"),
)
O2_FIXTURES = {"proper_prep_for"}          # compiled with inlining, like the shipped modules
LUAU_COMPILE = os.path.join(ROOT, "bin", "luau-compile.exe")''')
rep('''def compile_text(text, temp, tag):''', '''def compile_fixture(fixture, name, out):
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


def compile_text(text, temp, tag):''')
rep('''                original = os.path.join(temp, name + ".original.lua_B")
                run([DEC, "recompile", fixture, original])
                source, rebuilt = round_trip(original, temp, name + ".default")''',
    '''                original = os.path.join(temp, name + ".original.lua_B")
                compile_fixture(fixture, name, original)
                source, rebuilt = round_trip(original, temp, name + ".default")''')
rep('''                checks[name.upper() + "_LEGACY_BEHAVIOR_DIFFERS"] = trace(legacy_source, temp, prelude) != expected
''', '''                checks[name.upper() + "_LEGACY_BEHAVIOR_DIFFERS"] = trace(legacy_source, temp, prelude) != expected
                for extra_name, label, switch, cfg_expect in EXTRA_LEGACY:
                    if extra_name != name:
                        continue
                    extra_env = base_env()
                    extra_env[switch] = "1"
                    extra_source, extra_rebuilt = round_trip(original, temp,
                                                             "%s.legacy_%s" % (name, label.lower()),
                                                             extra_env)
                    key = "%s_LEGACY_%s" % (name.upper(), label)
                    if cfg_expect == "FAIL":
                        checks[key + "_CFG_FAILS"] = cfg_verdict(original, extra_rebuilt) == "FAIL"
                    else:
                        checks[key + "_CFG_BLIND"] = cfg_verdict(original, extra_rebuilt) == "PASS"
                    checks[key + "_BEHAVIOR_DIFFERS"] = trace(extra_source, temp, prelude) != expected

            fixture = os.path.join(FIX, "selector_residue.luau")
            expected = trace(fixture, temp)
            checks["SELECTOR_RESIDUE_RUNS"] = expected.count("\\n") >= 2
            original = os.path.join(temp, "selector_residue.original.lua_B")
            run([DEC, "recompile", fixture, original])
            source, rebuilt = round_trip(original, temp, "selector_residue.default")
            checks["SELECTOR_RESIDUE_DEFAULT_BEHAVIOR_SAME"] = trace(source, temp) == expected
            checks["SELECTOR_RESIDUE_DEFAULT_CFG_IDENTITY"] = cfg_verdict(original, rebuilt) == "PASS"
            checks["SELECTOR_RESIDUE_DEFAULT_CLOSES"] = closes_within(original, temp,
                                                                      "selector_residue.close", 3)
            legacy_env = base_env()
            legacy_env["RENOVICE_KEEP_SELECTOR_GUARD_RESIDUE"] = "1"
            checks["SELECTOR_RESIDUE_LEGACY_NOT_CLOSED"] = not closes_within(
                original, temp, "selector_residue.legacy_close", 5, legacy_env)
            legacy_source, legacy_rebuilt = round_trip(original, temp, "selector_residue.legacy",
                                                       legacy_env)
            checks["SELECTOR_RESIDUE_LEGACY_CFG_FAILS"] = cfg_verdict(original, legacy_rebuilt) == "FAIL"
''')
open(p, "w", encoding="utf-8", newline="").write(s)
print("patched")
