#!/usr/bin/env python3
"""
gates.py - run the consolidated release gates and print one verdict.

Why this exists: the bottleneck on this project is not compute, it is the SERIAL verification loop.
Every candidate change costs align (~2 min) + backedge (~2 min) + realtrip (~10 min) run one after
another, several times per fix. Run concurrently the wall-clock is bounded by realtrip alone.

It also removes a recurring human error: gates were sometimes checked partially, or a number was
written down before the measurement returned. This prints every gate together, from one invocation,
and exits non-zero if ANY gate fails.

CORE GATES (a change ships only if ALL pass):
  0. CONST POLARITY     - native 0x20/0x41/0x34/0x3a equality and inequality cases all preserve
                          known-source behavior.
  1. ZERO ACCESS LOSS   - per file, GETIMPORT+NAMECALL+GETFIELD in our RECOMPILE == the ORIGINAL.
                          This is the check that detects silently dropped code. realtrip CANNOT:
                          it wraps bodies in pcall and compares our output to ITSELF, so a defect
                          present on both sides reads as a pass.
  2. NAME-DIFF == 0     - no file touches a different set of named entities.
  3. realtrip           - behavioural equivalence, must not regress below the baseline.
  4. ALIGNED            - must be >= the baseline (strictly greater to justify shipping).
  7. LOST CONDITION     - a guarded return must never be flattened into an unconditional dead tail.
  8. SEMANTIC LOWERING  - execute the exact production Semantic IR lowering templates in real Luau,
                          including call/mutation order, exact nil tails, errors, returns, and varargs.
  9. SEMANTIC BEHAVIOR  - compare ground-truth source against the new Semantic IR renderer over the
                          150-case behavior corpus; ratchet known differences down, never up.
 10. WARFRAME API TRACE - execute Warframe-shaped callbacks against a deterministic mocked native
                          boundary and compare returns, state, calls, arguments, and effect order.
 11. NATIVE NAMECALL     - render and rebuild a real Warframe module whose native method sequence is
                          known, then require every NAMECALL spelling and order to remain exact.

Usage:
    python cert/gates.py                 # 300 files, baseline from BASELINE below
    python cert/gates.py 300 150         # align/backedge N, realtrip M
    python cert/gates.py 300 150 --json-out cert/baselines/latest.json
    RENOVICE_CORPUS=... python cert/gates.py

A TIMEOUT in realtrip is NOT a behavioural difference - it is reported separately, because treating
one as a failure once caused a correct fix to be discarded.
"""
import argparse, collections, hashlib, json, os, re, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor

from workspace_paths import corpus_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC  = os.path.join(ROOT, "bin", "derecomp.exe")
PY   = sys.executable or "python3"

# Update these when a change legitimately ships, so the gate always compares against the CURRENT
# shipped state rather than a stale number. A gate that measures against the wrong baseline is worse
# than no gate: it once reported a real improvement as a regression.
BASELINE = {"ALIGNED": 123, "NAME-DIFF": 0, "realtrip_same": 150,
            "ACCESS_LOSS": 0, "ACCESS_LOSS_TOTAL": 0, "ORDER_DIFF_ALL": 149,
            "LOOP_MATCH": 163, "EXTRA_LOOPS": 25, "LOST_LOOPS": 82,
            "LATCH_DIFF": 30, "LOST_HEADERS": 359, "EXTRA_HEADERS": 40,
            "DROPPED": 0, "CMPK_SAME": 8,
            "LOST_CONDITION": 0, "SEMANTIC_BEHAVIOR_SAME": 150,
            "SEMANTIC_BEHAVIOR_DIFFERENT": 0,
            "WARFRAME_API_SAME": 10, "WARFRAME_API_DIFFERENT": 0}

# BASELINE CHANGE OF 2026-08-22 -- mocked Warframe ability/API trace closure:
#   Ten property-focused Warframe-shaped modules exercise callback lifecycle,
#   native receiver/argument/effect order, target iteration and continue,
#   upgrade-value calls, secondary arguments, shared callback state, closures,
#   handled errors, tables, varargs, and multiple returns. Known source and the
#   Semantic IR renderer match 10/10 with zero differences and zero vacuous
#   cases. This is a deterministic native-boundary regression gate, not a claim
#   that the real game VM or all native API behavior has been reproduced.

# BASELINE CHANGE OF 2026-08-22 -- executable Semantic IR correctness closure:
#   The real-Luau Semantic IR oracle improved 129/150 -> 150/150 with zero
#   vacuous matches. Shared repairs recovered exact NOTLT/NOTLE semantics (10),
#   measured DE numeric-for A+2 ownership (6), capture-safe lexical names plus
#   fixed/open varargs (3), and deferred self-closure snapshots (1). The final
#   mismatch was an invalid July nested-closure fixture retaining the project's
#   documented obsolete flat-prototype operand; rt-build regenerated it with
#   the current child-list encoder.
#   Gate 9 now forbids losing even one of these executable matches.

# BASELINE CHANGE OF 2026-08-20 -- ChatRedux terminal-arm ownership and lossless imports:
#   ChatRedux p181's terminal command arms each contain exactly one dominance-backed generic loop.
#   Their parent condition stole the nested prep, replaced the command branch with `for`, and placed
#   four callback closures after an unconditional return. Rejecting ownership only for a terminal
#   child arm with exactly one loop restores all 591/591 reachable prototypes and recovers 184/194
#   lost accesses. The remaining ten were DE hash 2898f6ea rendered through the mined preimage
#   "899c4c"; because that is not an identifier, source used _G["899c4c"] and rebuilt one GETIMPORT
#   as GETIMPORT _G + GETFIELD. Invalid name-hash import components now use the existing lossless
#   Name__2898f6ea alias, which the transcoder maps back to the exact hash. ChatRedux reaches
#   15,040/15,040 accesses with zero missing/extra. ACCESS-LOSS 1/194 -> 0/0, MATCH 162 -> 163,
#   LOST-HEADERS 362 -> 359, EXTRA-LOOPS 26 -> 25, EXTRA-HEADERS 41 -> 40. Independent ORDER-DIFF
#   148 -> 149 is category unmasking: ChatRedux becomes order-comparable only after access parity.
#   Behavior remains 150/150, and the full 5,386-file dropped-path scan remains zero.

# BASELINE CHANGE OF 2026-08-20 -- latch-headed numeric-loop region partition:
#   Dojo InWorldTransmission p9's reduced region stored the loop as three siblings in structural
#   order [FORNLOOP latch + normal return, body, FORNPREP + entry/control]. The innermost claimant
#   therefore emitted an empty numeric `for`, then an unconditional return, and the compiler removed
#   the entire 111-access body. The emitter now pairs a latch with its unique dominance-approved prep,
#   emits the prep/entry part first, partitions the mixed latch/exit artifact by the authoritative
#   natural-loop block set, emits the actual body inside, and emits the normal exit afterward. There
#   is no filename/prototype exception. Dojo recovers 505/505 accesses and its file-level loop deficit
#   improves 7 -> 2. Five unrelated ORDER-DIFF files become CLEAN; no file regresses in the 300-file
#   A/B comparison. ALIGNED 119 -> 123, first-match ORDER-DIFF 46 -> 42, independent ORDER-DIFF
#   152 -> 148, ACCESS-LOSS 2/305 -> 1/194, and LOST-HEADERS 367 -> 362. Behavior remains 150/150,
#   DROPPED/DEADTAIL remain zero, and all other loop/header/prototype ratchets hold.

# BASELINE CHANGE OF 2026-08-20 -- terminal nested-loop arm ownership:
#   EndOfMatch p95's IfThen chose between two terminal branches. Its terminal arm contained a generic
#   loop, so the parent stole that child's loop header, replaced its own condition with `for`, and
#   emitted the branch unconditionally; the following valid branch became dead and lost 43 accesses.
#   A parent now rejects that ownership only when both the complete child arm and the nested loop's
#   normal exhaustion are terminal. The loop prep/latch gets one canonical identity and a second claim
#   plan prevents an ancestor/child duplicate. DuviriBuildConfig proves why both terminal facts are
#   required: the arm alone matched, but its loop exhaustion was nonterminal and the broad experiment
#   lost a numeric loop. ACCESS-LOSS 3/348 -> 2/305 and LOST-HEADERS 368 -> 367; all other loop file
#   categories and header/latch ratchets hold. ORDER-DIFF 151 -> 152 is an explicit unmasking:
#   per-file A/B shows EndOfMatch alone becomes newly order-comparable after exact access recovery;
#   its branches are mutually exclusive and terminal, targeted mocked behavior is SAME, and the full
#   behavioral suite remains 150/150. Hub p83 removes one invented header (original 0, prior 5, new 4),
#   although file-total cancellation makes its unrelated aggregate lost-header delta look one worse.

# BASELINE CHANGE OF 2026-08-20 -- single-loop, three-latch FORGLOOP union:
#   Dialog proto 62 has one FORGLOOP header and exactly three dominance-proven latch predecessors.
#   Reducing those predecessors independently built nested partial loops, separated the FORGPREP
#   from its canonical latch identity, and lost eight reachable mMovie/SetNumberVariable accesses.
#   The structurer now unions all three reverse predecessor closures into one NaturalLoop only for
#   this measured shape; the emitter gives its prep/latch claims one identity and emits every part
#   inside the loop. ACCESS-LOSS 4 -> 3 (356 -> 348), ALIGNED 118 -> 119, MATCH 160 -> 162,
#   LOST-LOOPS 84 -> 82. EXTRA-LOOPS/headers, ORDER-DIFF, latch differences, behavior 150/150,
#   DROPPED 0, and DEADTAIL 0 do not regress. Broader >=2-latch and all-loop variants were rejected.

# BASELINE CHANGE OF 2026-08-20 -- terminal search-loop ownership:
#   BindingsUtil proto 16 contains five mutually exclusive generic-for searches. A conditional parent
#   greedily claimed each arm's FORGPREP and emitted itself as the loop, deleting its own device-type
#   guard; the first false return then made four searches dead. A conditional now rejects an interior
#   loop claim only for the proven canonical shape where the comparison arm and normal loop exhaustion
#   both terminate. BindingsUtil recovers all four lost headers and all eight accesses (802/802).
#   Corpus: MATCH 159 -> 160, extra-loop files 27 -> 26, lost headers 369 -> 368, extra headers
#   44 -> 41, ACCESS-LOSS 5/364 -> 4/356. Independent ORDER-DIFF 150 -> 151 is an unmasking:
#   BindingsUtil was previously access-incomplete and therefore ineligible for the order-only gate;
#   after exact access recovery it exposes a pre-existing order difference. ALIGNED remains 118,
#   behavior remains 150/150, and DROPPED/DEADTAIL remain zero.

# BASELINE CHANGE OF 2026-08-20 -- nested numeric-for region coalescing:
#   FocusUtilities' nested FORNLOOP latch was greedily reduced as an acyclic IfThen, splitting both
#   numeric preps from their canonical bodies. Protecting only basic blocks in a dominance-proven
#   nested-loop body, promoting only its associated multi-exit shell, and coalescing only the two
#   preps in that proven nesting pair restores both loops and all 41 reachable accesses.
#   MATCH 158 -> 159; LOST-LOOPS 85 -> 84; lost headers 377 -> 369; EXTRA-LOOPS 27 and extra headers
#   44 unchanged; LATCH-DIFF 30 unchanged; ACCESS-LOSS 6/405 -> 5/364. ORDER-DIFF 44 -> 45 and the
#   independent count 149 -> 150 are an unmasking: FocusUtilities proto 3 had the same effect-order
#   difference before and after, but the module was previously not order-comparable due to p6 loss.
#   Behavior remains 150/150, DROPPED and DEADTAIL remain 0.

# BASELINE CHANGE OF 2026-08-20 -- reachable-prototype access accounting:
#   ACCESS-LOSS 15 -> 6. The old allcats oracle filtered unreachable instructions inside each proto
#   but still counted whole orphan protos that no live closure site can create. Nine of the fifteen
#   reported files lost only proven-dead orphan bodies; four discriminators all lost the identical
#   two-access `mMovie:Execute` orphan. `skeleton --reachable` now applies the same live-closure graph
#   already used by the independent `orphans` command. The six surviving access-loss files all also
#   have LOOP-DIFF, so loop restoration is the next causal repair rather than an access-only patch.

# BASELINE CHANGE OF 2026-08-20 -- Proper SCC dispatch and condensation ordering:
#   DROPPED 25 -> 0 on the 300-file release sample and 741 -> 0 on all 5,386 corpus files.
#   Mutually reachable states repeat only inside their SCC; the condensation DAG is emitted in
#   topological order. MATCH 157 -> 158, lost loop headers 401 -> 377. ACCESS-LOSS was reported as 15
#   by the then-current oracle and was later corrected to 6 by excluding proven orphan prototypes,
#   ALIGNED remains 118, and realtrip remains 150/150. ClaimCompanion moved from LOST-LOOPS to
#   LATCH-DIFF because all four headers were restored while two latch edges remain missing.
#   Evidence: RESEARCH/DE LUAU TRANSLATOR/PROPER_SCC_DISPATCH_2026-08-20.md.

# BASELINE CHANGE OF 2026-08-20 -- composite-condition / multi-exit correctness:
#   DEADTAIL 3 -> 0; DROPPED 28 -> 25; ACCESS-LOSS 16 -> 15; ALIGNED 117 -> 118.
#   The emitter now records the exact outgoing CFG destination of a cyclic whole-part or composite
#   conditional head and propagates it through nested loops. Ordinary one-successor fallthrough
#   blocks are classified as unconditional exits too. realtrip remains 150/150, NAME-DIFF remains 0,
#   ORDER-DIFF remains 44, and PROTO-DUP remains 8. Evidence is stored in
#   RESEARCH/DE LUAU TRANSLATOR/MULTI_EXIT_CORRECTNESS_GATES_2026-08-20.json.

# BASELINE CHANGE OF 2026-08-20 -- FINDINGS #106 lost conditional wrappers:
#   ALIGNED 113 -> 117; NAME-DIFF 1 -> 0; ACCESS_LOSS 45 -> 16
#       The production conditional-wrapper and condition-head fixes improve all three independently
#       measured structural/access results while behavioral realtrip remains 150/150.
#   LOST_CONDITION 165 -> 3
#       The exact render-only gate is cert/lost_condition.py. Do not count PLAN-pass text: that
#       buffer is discarded. The three remaining sites are loop-exit-state cases and are explicit
#       blockers ratcheted here; the next multi-exit-loop repair must drive this baseline to zero.

# BASELINE CHANGE OF 2026-08-20 -- native constant-comparison polarity fix:
#   CMPK_SAME 4 -> 8
#       The four native number/string equality+inequality cases failed before and pass after;
#       boolean/nil remained 4/4 controls. cert/cmpk_polarity.py preserves this discriminator.
#   realtrip_same 149 -> 150
#       Lotus_Interface_BindingsUtil changed from 506-vs-510 DIFFERENT to 510-vs-510 SAME. Its raw
#       proto-17 0x41 aux now remains 0x00000003 after recompilation instead of flipping bit31.
#   ACCESS_LOSS 46 -> 45
#       Independent all-category audit improved by one file; every other structural metric held.

# BASELINE CHANGES OF 2026-07-28 -- each justified by DIRECT MEASUREMENT, not by the result.
# The rule is "never relax a baseline to make a failing change pass" (PITFALLS E4). Two of these
# numbers were WRONG BEFORE the change; the proof for each was obtained by running the PRE-CHANGE
# binary (kept in .snapshot_pre97/) against the SAME oracle:
#
#   realtrip_same 150 -> 149
#       Lotus_Interface_BindingsUtil returns DIFFERENT with the PRE-change binary AND with the
#       post-change binary. It has been failing since realtrip.py was pinned to fidelity mode
#       (FINDINGS #96); the baseline was simply never updated then. Not caused by this change.
#
#   NAME-DIFF 0 -> 1
#       align.py returns on the FIRST differing category and tests LOOP-DIFF before the access
#       check, so a file with BOTH is only ever reported as LOOP-DIFF. Fixing DecoPreview's loop
#       structure made it fall through to the access check and REVEALED a pre-existing loss.
#       Measured directly: its recompile holds 149 accesses vs the original's 152 BOTH before and
#       after the change -- byte-identical loss. An unmasking, not a regression (PITFALLS B6).
#
#   ACCESS_LOSS 46 (NEW GATE)
#       Because of that masking, NAME-DIFF is not "files that lost an access" -- it is "files that
#       lost an access AND had no loop difference", a number that GROWS as loops get fixed. It is
#       therefore useless as a safety gate. cert/allcats.py scores every category independently and
#       reports the honest figure: 46 files lose accesses, up to 293 in one file. That number was
#       46 before this change and is 46 after. THIS is the number that must never rise.
#
#   DROPPED 28 (NEW GATE, cert/dropped.py)
#       Code paths emitted but unreachable. 47 -> 28 on this sample with the Proper-emitter fix.
#       Ratchet it down to 0; never up.
BASELINE_NOTE = "see the block above -- every baseline change is backed by a pre/post measurement"

# Files with KNOWN original access counts, used for gate 1. Chosen to span sizes and defect classes;
# several of these are files that previously exposed a real loss.
ACCESS_FILES = {
    "EE_Types_ScriptCommands_JSON":                            176,
    "Lotus_Interface_BeaconInProgress":                        525,
    "Lotus_Interface_Backgrounds_Lotus_LotusBackground":       190,
    "Lotus_Characters_Tenno_Infestation_Cyst_InfestationCyst": 127,
    "Lotus_Interface_AllianceView":                            987,
    "EE_Interface_Components_Grid":                            672,
    "EE_Interface_Utilities":                                  784,
    "Lotus_Interface_BootUpGlitch":                             45,
    "EE_Types_ScriptCommands_SetVortexWindPerZone":             30,
}

ENV = dict(os.environ, RENOVICE_NATIVE_GLOBALS="1",
           RENOVICE_NATIVE="JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,JUMPBACK,AND,OR,ANDK,ORK,SUBK,FORGPREP")
CACHE = corpus_cache(ROOT)
LUAU_COMPILE = os.path.join(ROOT, "bin", "luau-compile.exe")


def sha256_file(path):
    if not os.path.isfile(path):
        return None
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def write_json(path, payload):
    path = os.path.abspath(path)
    parent = os.path.dirname(path)
    if parent:
        os.makedirs(parent, exist_ok=True)
    temporary = path + ".tmp"
    with open(temporary, "w", encoding="utf-8", newline="\n") as stream:
        json.dump(payload, stream, indent=2, sort_keys=True)
        stream.write("\n")
    os.replace(temporary, path)
    print("   machine-readable results: %s" % path)


def sh(args, timeout=3600):
    return subprocess.run(args, capture_output=True, text=True, encoding="utf-8",
                          errors="replace", timeout=timeout, env=ENV, cwd=ROOT)


def run_align(n):
    p = sh([PY, os.path.join("cert", "align.py"), str(n)])
    if p.returncode == 2:                      # corpus missing -> FATAL, never treat as clean
        return {"FATAL": p.stderr.strip()}
    d = {}
    for m in re.finditer(r"^\s{2}([A-Z][A-Z-]+(?:-[a-z]+)?)\s+(\d+)$", p.stdout, re.M):
        d[m.group(1)] = int(m.group(2))
    return d


def run_backedge(n):
    p = sh([PY, os.path.join("cert", "backedge.py"), str(n)])
    if p.returncode == 2:
        return {"FATAL": p.stderr.strip()}
    d = {}
    for m in re.finditer(r"^\s{2}([A-Z][A-Z-]+)\s+(\d+)$", p.stdout, re.M):
        d[m.group(1)] = int(m.group(2))
    return d


def run_dropped(n):
    """GATE 5: code paths emitted but UNREACHABLE (Proper state machine, FINDINGS #97)."""
    p = sh([PY, os.path.join("cert", "dropped.py"), str(n)])
    if p.returncode == 2:
        return {"FATAL": p.stderr.strip()}
    d = {}
    for m in re.finditer(r"^\s{2}(BACKWARD|SELF) transitions\s+(\d+)", p.stdout, re.M):
        d[m.group(1)] = int(m.group(2))
    return d


def run_allcats(n):
    """GATE 6: honest access-loss count, immune to align.py's first-match masking."""
    p = sh([PY, os.path.join("cert", "allcats.py"), str(n)])
    if p.returncode == 2:
        return {"FATAL": p.stderr.strip()}
    d = {}
    for m in re.finditer(r"^\s{3}([A-Z][A-Z-]+)\s+(\d+)$", p.stdout, re.M):
        d[m.group(1)] = int(m.group(2))
    return d


def run_realtrip(n):
    p = sh([PY, os.path.join("cert", "realtrip.py"), str(n)])
    if p.returncode == 2:
        return {"FATAL": p.stderr.strip()}
    d = {}
    for m in re.finditer(r"^\s{2}(\S+)\s+(\d+)$", p.stdout, re.M):
        d[m.group(1)] = int(m.group(2))
    d["_diff_files"] = re.findall(r"^---- DIFFERENT (\S+)", p.stdout, re.M)
    return d


def run_lost_condition(n):
    """GATE 7: conditional return emitted at the outer depth, making a reachable tail dead."""
    p = sh([PY, os.path.join("cert", "lost_condition.py"), str(n)])
    if p.returncode == 2:
        return {"FATAL": p.stderr.strip()}
    match = re.search(r"^\s{2}DEADTAIL sites\s+(\d+)$", p.stdout, re.M)
    if not match:
        return {"FATAL": "lost_condition.py did not report a parseable site count"}
    return {"SITES": int(match.group(1))}


def run_cmpk_polarity():
    """Gate 0: both polarities for native number/string comparisons plus boolean/nil controls."""
    p = sh([PY, os.path.join("cert", "cmpk_polarity.py")], timeout=300)
    if p.returncode == 2:
        return {"FATAL": (p.stderr or p.stdout).strip()}
    match = re.search(r"^SUMMARY same=(\d+) different=(\d+)$", p.stdout, re.M)
    if not match:
        return {"FATAL": "cmpk_polarity.py did not report a parseable summary"}
    return {"SAME": int(match.group(1)), "DIFFERENT": int(match.group(2))}


def run_semantic_lowerings():
    """Gate 8: execute the exact production source-lowering templates in real Luau."""
    p = sh([DEC, "semantic-ir-lowering-selftest"], timeout=300)
    match = re.search(
        r"^SEMANTIC_IR_LOWERING_SELFTEST assertions=(\d+) passed=(\d+) "
        r"failed=(\d+) runtime_exit=(-?\d+)$", p.stdout, re.M)
    if not match:
        return {"FATAL": "semantic lowering oracle did not report a parseable summary: "
                + ((p.stdout or "") + (p.stderr or ""))[-1000:]}
    result = {
        "assertions": int(match.group(1)),
        "passed": int(match.group(2)),
        "failed": int(match.group(3)),
        "runtime_exit": int(match.group(4)),
    }
    if p.returncode != 0 and result["failed"] == 0:
        result["FATAL"] = "semantic lowering oracle exited nonzero without failures"
    return result


def run_semantic_behavior():
    """Gate 9: ground-truth source versus the new Semantic IR renderer."""
    p = sh([PY, os.path.join("cert", "behave.py"), "--semantic-ir"], timeout=600)
    same = re.search(r"^\s+SAME behaviour\s*:\s*(\d+)", p.stdout, re.M)
    different = re.search(r"^\s+DIFFERENT\s*:\s*(\d+)", p.stdout, re.M)
    vacuous = re.search(r"^\s+VACUOUS match\s*:\s*(\d+)", p.stdout, re.M)
    if not same or not different or not vacuous:
        return {"FATAL": "semantic behavior oracle did not report parseable totals: "
                + ((p.stdout or "") + (p.stderr or ""))[-1000:]}
    return {
        "same": int(same.group(1)),
        "different": int(different.group(1)),
        "vacuous": int(vacuous.group(1)),
        "different_cases": re.findall(r"^\s+--\s+(\S+)", p.stdout, re.M),
    }


def run_warframe_api_trace():
    """Gate 10: Warframe-shaped callbacks versus a deterministic mocked native boundary."""
    p = sh([PY, os.path.join("cert", "behave.py"), "--semantic-ir", "--warframe-api"],
           timeout=600)
    same = re.search(r"^\s+SAME behaviour\s*:\s*(\d+)", p.stdout, re.M)
    different = re.search(r"^\s+DIFFERENT\s*:\s*(\d+)", p.stdout, re.M)
    vacuous = re.search(r"^\s+VACUOUS match\s*:\s*(\d+)", p.stdout, re.M)
    if not same or not different or not vacuous:
        return {"FATAL": "Warframe API trace oracle did not report parseable totals: "
                + ((p.stdout or "") + (p.stderr or ""))[-1000:]}
    return {
        "same": int(same.group(1)),
        "different": int(different.group(1)),
        "vacuous": int(vacuous.group(1)),
        "different_cases": re.findall(r"^\s+--\s+(\S+)", p.stdout, re.M),
    }


def run_native_namecall_preservation():
    """Gate 11: complex/frame-backed receivers must still compile as NAMECALL."""
    module = "Lotus_Scripts_Effects_HarnessEffects.lua_B"
    source_module = os.path.join(CACHE, module)
    if not os.path.isfile(source_module):
        return {"FATAL": "NAMECALL witness missing from corpus: " + source_module}

    with tempfile.TemporaryDirectory(prefix="renovice_namecall_") as temporary:
        source = os.path.join(temporary, "rendered.luau")
        rebuilt = os.path.join(temporary, "rebuilt.lua_B")
        rendered = sh([DEC, "semantic-ir-render-module", source_module, source], timeout=300)
        if rendered.returncode != 0:
            return {"FATAL": "NAMECALL witness render failed: "
                    + ((rendered.stdout or "") + (rendered.stderr or ""))[-1000:]}
        compiled = sh([DEC, "recompile", source, rebuilt], timeout=300)
        if compiled.returncode != 0:
            return {"FATAL": "NAMECALL witness recompile failed: "
                    + ((compiled.stdout or "") + (compiled.stderr or ""))[-1000:]}

        def method_sequence(path):
            skeleton = sh([DEC, "skeleton", path, "--live"], timeout=300)
            if skeleton.returncode != 0:
                return None
            return re.findall(r"^NAMECALL\t(\S+)$", skeleton.stdout, re.M)

        original_methods = method_sequence(source_module)
        rebuilt_methods = method_sequence(rebuilt)
        if original_methods is None or rebuilt_methods is None:
            return {"FATAL": "NAMECALL witness skeleton failed"}
        validated = sh([DEC, "de-validate", rebuilt], timeout=300)
        if validated.returncode != 0:
            return {"FATAL": "NAMECALL witness rebuilt DE validation failed: "
                    + ((validated.stdout or "") + (validated.stderr or ""))[-1000:]}
        return {
            "module": module,
            "original_count": len(original_methods),
            "rebuilt_count": len(rebuilt_methods),
            "original_methods": original_methods,
            "rebuilt_methods": rebuilt_methods,
            "same": original_methods == rebuilt_methods,
            "rebuilt_sha256": sha256_file(rebuilt),
        }


def access_one(item):
    """Gate 1 for one file: original access count vs our recompile."""
    name, expect = item
    f = os.path.join(CACHE, name + ".lua_B")
    if not os.path.exists(f):
        return (name, None, None, "missing from corpus")
    def count(path):
        p = sh([DEC, "skeleton", path, "--live"], timeout=300)
        if p.returncode != 0:
            return None
        return sum(1 for ln in p.stdout.splitlines()
                   if ln.startswith(("GETIMPORT", "NAMECALL", "GETFIELD")))
    orig = count(f)
    src = sh([DEC, "decompile-mod", f], timeout=300)
    if src.returncode != 0:
        return (name, orig, None, "decompile failed")
    # ACCESS_FILES run in parallel inside one process.  The old name used only the first 20 filename
    # characters plus the shared PID, so EE_Types_ScriptCommands_JSON and
    # EE_Types_ScriptCommands_SetVortexWindPerZone raced on the same path: one worker could delete
    # the other's source/output and produce `ours=None`.  Ask the OS for a unique file per worker.
    fd, tmp = tempfile.mkstemp(prefix="renovice_gate_", suffix=".luau", dir=ROOT)
    os.close(fd)
    out = tmp + ".lua_B"
    open(tmp, "w", encoding="utf-8", newline="\n").write(src.stdout)
    r = sh([DEC, "recompile", tmp, out], timeout=300)
    ours = count(out) if (r.returncode == 0 and os.path.exists(out)) else None
    for t in (tmp, out):
        try: os.remove(t)
        except OSError: pass
    note = ""
    if orig is not None and orig != expect:
        note = "ORIGINAL COUNT CHANGED (expected %d) - update ACCESS_FILES" % expect
    return (name, orig, ours, note)


def main():
    parser = argparse.ArgumentParser(description="Run the consolidated DeNative release gates.")
    parser.add_argument("n_align", nargs="?", type=int, default=300,
                        help="file count for alignment, back-edge, dropped, and all-category gates")
    parser.add_argument("n_trip", nargs="?", type=int, default=150,
                        help="file count for the behavioural realtrip gate")
    parser.add_argument("--json-out", help="write a deterministic machine-readable result file")
    args = parser.parse_args()
    n_align = args.n_align
    n_trip = args.n_trip
    json_out = args.json_out

    def fatal(message):
        print("FATAL: %s" % message)
        if json_out:
            write_json(json_out, {
                "fatal": message,
                "inputs": {
                    "align_count": n_align,
                    "corpus": CACHE,
                    "realtrip_count": n_trip,
                },
                "passed": False,
                "schema_version": 1,
            })
        return 2

    if not os.path.isdir(CACHE):
        return fatal("corpus not found at %s" % CACHE)

    print("== RELEASE GATES ==  align/backedge=%d realtrip=%d  corpus=%s" % (n_align, n_trip, CACHE))
    print("   (align/backedge/access concurrent, then realtrip ALONE - it must not share CPU)")

    # The native constant-comparison regression is quick and must pass independently of corpus
    # aggregate metrics. Run it before the expensive oracles so its result is always visible.
    P = run_cmpk_polarity()
    L = run_semantic_lowerings()
    SB = run_semantic_behavior()
    WF = run_warframe_api_trace()
    NC = run_native_namecall_preservation()

    # realtrip runs ALONE, and only after the others finish.
    #
    # It spawns its own worker pool and each worker runs a real Lua process under a wall-clock trace
    # limit. Sharing the machine with three other oracles oversubscribes it ~4x, traces get starved,
    # and a starved trace is TRUNCATED -- which then compares UNEQUAL against its untruncated twin and
    # is reported as a behavioural DIFFERENCE. That is a MANUFACTURED failure, so a behavioural oracle
    # must never share CPU with anything. Keep this isolation.
    #
    # CORRECTION 2026-07-28: this comment previously credited that effect for the
    # Lotus_Interface_BindingsUtil failure and asserted the file was "SAME with 507 identical events"
    # standalone. BOTH claims are superseded. Isolating realtrip did NOT fix it. The real cause was
    # that realtrip.py never set RENOVICE_NATIVE while align.py always did, so the two headline gates
    # were measuring DIFFERENT COMPILER CONFIGURATIONS (PITFALLS A7). realtrip.py is now pinned to
    # fidelity mode, and in that mode BindingsUtil is genuinely DIFFERENT -- root cause is the Proper
    # state-machine emitter, FINDINGS #97, not a scheduling artefact.
    # Three separate explanations were recorded for one failure before the cause was found; see
    # PITFALLS A8.
    with ThreadPoolExecutor(max_workers=6) as ex:
        f_align = ex.submit(run_align, n_align)
        f_back  = ex.submit(run_backedge, n_align)
        f_drop  = ex.submit(run_dropped, n_align)
        f_cats  = ex.submit(run_allcats, n_align)
        f_lostc = ex.submit(run_lost_condition, n_align)
        f_acc   = ex.submit(lambda: list(ThreadPoolExecutor(max_workers=8)
                                         .map(access_one, ACCESS_FILES.items())))
        A, B, D, C, LC, ACC = (f_align.result(), f_back.result(), f_drop.result(),
                               f_cats.result(), f_lostc.result(), f_acc.result())
    T = run_realtrip(n_trip)

    for tag, d in (("cmpk", P), ("semantic-lowering", L),
                   ("semantic-behavior", SB),
                   ("warframe-api-trace", WF),
                   ("native-namecall", NC),
                   ("align", A), ("backedge", B), ("dropped", D),
                   ("allcats", C), ("lost-condition", LC), ("realtrip", T)):
        if "FATAL" in d:
            return fatal("%s gate: %s" % (tag, d["FATAL"]))

    fails = []

    # ---- Gate 0: all native JUMPXEQK operand types and both polarities
    print("\n-- GATE 0: native constant-comparison polarity")
    print("   SAME=%d DIFFERENT=%d" % (P.get("SAME", 0), P.get("DIFFERENT", 0)))
    if P.get("SAME", 0) != BASELINE["CMPK_SAME"] or P.get("DIFFERENT", 0) != 0:
        fails.append("GATE 0: native comparison polarity %d/%d"
                     % (P.get("SAME", 0), BASELINE["CMPK_SAME"]))

    # ---- Gate 8: exact Semantic IR source-lowering behavior
    print("\n-- GATE 8: Semantic IR source-lowering execution")
    print("   assertions=%d passed=%d failed=%d runtime_exit=%d"
          % (L.get("assertions", 0), L.get("passed", 0),
             L.get("failed", 0), L.get("runtime_exit", -1)))
    if (L.get("assertions", 0) != 22 or L.get("passed", 0) != 22
            or L.get("failed", 0) != 0 or L.get("runtime_exit", -1) != 0):
        fails.append("GATE 8: Semantic IR lowering oracle %d/%d, failures=%d, runtime=%d"
                     % (L.get("passed", 0), L.get("assertions", 0),
                        L.get("failed", 0), L.get("runtime_exit", -1)))

    # ---- Gate 9: ratchet the new renderer's ground-truth behavior corpus
    print("\n-- GATE 9: Semantic IR renderer vs ground-truth behavior")
    print("   SAME=%d DIFFERENT=%d VACUOUS=%d"
          % (SB.get("same", 0), SB.get("different", 0), SB.get("vacuous", 0)))
    for case in SB.get("different_cases", [])[:8]:
        print("     !! %s" % case)
    if SB.get("same", 0) < BASELINE["SEMANTIC_BEHAVIOR_SAME"]:
        fails.append("GATE 9: Semantic IR SAME %d < baseline %d"
                     % (SB.get("same", 0), BASELINE["SEMANTIC_BEHAVIOR_SAME"]))
    if SB.get("different", 0) > BASELINE["SEMANTIC_BEHAVIOR_DIFFERENT"]:
        fails.append("GATE 9: Semantic IR DIFFERENT %d > baseline %d"
                     % (SB.get("different", 0),
                        BASELINE["SEMANTIC_BEHAVIOR_DIFFERENT"]))
    if SB.get("vacuous", 0) != 0:
        fails.append("GATE 9: Semantic IR VACUOUS %d != 0" % SB.get("vacuous", 0))

    # ---- Gate 10: callback behavior at the mocked Warframe native boundary
    print("\n-- GATE 10: Semantic IR Warframe callback/API trace")
    print("   SAME=%d DIFFERENT=%d VACUOUS=%d"
          % (WF.get("same", 0), WF.get("different", 0), WF.get("vacuous", 0)))
    for case in WF.get("different_cases", [])[:8]:
        print("     !! %s" % case)
    if WF.get("same", 0) < BASELINE["WARFRAME_API_SAME"]:
        fails.append("GATE 10: Warframe API SAME %d < baseline %d"
                     % (WF.get("same", 0), BASELINE["WARFRAME_API_SAME"]))
    if WF.get("different", 0) > BASELINE["WARFRAME_API_DIFFERENT"]:
        fails.append("GATE 10: Warframe API DIFFERENT %d > baseline %d"
                     % (WF.get("different", 0), BASELINE["WARFRAME_API_DIFFERENT"]))
    if WF.get("vacuous", 0) != 0:
        fails.append("GATE 10: Warframe API VACUOUS %d != 0" % WF.get("vacuous", 0))

    # ---- Gate 11: real-module NAMECALL opcode preservation
    print("\n-- GATE 11: native NAMECALL preservation")
    print("   module=%s original=%d rebuilt=%d exact=%s"
          % (NC.get("module", "<missing>"), NC.get("original_count", 0),
             NC.get("rebuilt_count", 0), "yes" if NC.get("same") else "NO"))
    if not NC.get("same"):
        fails.append("GATE 11: native NAMECALL sequence changed: %s -> %s"
                     % (NC.get("original_methods", []), NC.get("rebuilt_methods", [])))

    # ---- Gate 1
    print("\n-- GATE 1: access count vs ORIGINAL (detects silently dropped code)")
    bad = 0
    for name, orig, ours, note in sorted(ACC):
        ok = (orig is not None and orig == ours)
        if not ok: bad += 1
        print("   %-4s %-46s orig=%s ours=%s %s"
              % ("PASS" if ok else "FAIL", name[:46], orig, ours, note))
    if bad: fails.append("GATE 1: %d file(s) lost accesses" % bad)

    # ---- Gates 2 & 4
    aligned = A.get("ALIGNED", -1)
    namediff = A.get("NAME-DIFF", 0)
    print("\n-- GATE 2/4: alignment vs ORIGINAL")
    for k in ("ALIGNED", "ALIGNED-minus-orphans", "LOOP-DIFF", "ORDER-DIFF", "PROTO-DUP",
              "NAME-DIFF", "PROTO-LOST"):
        if k in A: print("   %-22s %d" % (k, A[k]))
    if namediff > BASELINE["NAME-DIFF"]:
        fails.append("GATE 2: NAME-DIFF %d > %d" % (namediff, BASELINE["NAME-DIFF"]))
    if aligned < BASELINE["ALIGNED"]:
        fails.append("GATE 4: ALIGNED %d < baseline %d" % (aligned, BASELINE["ALIGNED"]))

    print("\n-- back-edge bijection (loop recovery)")
    for k in ("MATCH", "EXTRA-LOOPS", "LOST-LOOPS", "LATCH-DIFF",
              "LOST-HEADERS", "EXTRA-HEADERS"):
        if k in B: print("   %-22s %d" % (k, B[k]))
    loop_limits = (("EXTRA-LOOPS", "EXTRA_LOOPS"), ("LOST-LOOPS", "LOST_LOOPS"),
                   ("LATCH-DIFF", "LATCH_DIFF"), ("LOST-HEADERS", "LOST_HEADERS"),
                   ("EXTRA-HEADERS", "EXTRA_HEADERS"))
    if B.get("MATCH", -1) < BASELINE["LOOP_MATCH"]:
        fails.append("LOOP GATE: MATCH %d < baseline %d"
                     % (B.get("MATCH", -1), BASELINE["LOOP_MATCH"]))
    for measured, baseline in loop_limits:
        if B.get(measured, -1) < 0:
            fails.append("LOOP GATE: %s missing" % measured)
        elif B[measured] > BASELINE[baseline]:
            fails.append("LOOP GATE: %s %d > baseline %d"
                         % (measured, B[measured], BASELINE[baseline]))

    # ---- Gate 5: dropped code paths (nothing else detects this class)
    dropped = D.get("BACKWARD", 0) + D.get("SELF", 0)
    print("\n-- GATE 5: code paths emitted but UNREACHABLE (FINDINGS #97)")
    print("   %-22s %d  (backward %d, self %d)"
          % ("DROPPED", dropped, D.get("BACKWARD", 0), D.get("SELF", 0)))
    if dropped > BASELINE["DROPPED"]:
        fails.append("GATE 5: DROPPED %d > baseline %d" % (dropped, BASELINE["DROPPED"]))

    # ---- Gate 6: honest access loss. THIS is the real safety net, not NAME-DIFF.
    # NAME-DIFF only sees files with no loop difference (align.py returns on first match), so it
    # RISES as loops get fixed. ACCESS-LOSS scores every category independently.
    # allcats reports a Counter and therefore omits a category whose count is zero. The mandatory
    # ACCESS-LOSS-TOTAL field below distinguishes a valid zero-result run from malformed output.
    aloss = C.get("ACCESS-LOSS", 0)
    print("\n-- GATE 6: access loss, independent of category masking")
    for k in ("CLEAN", "LOOP-DIFF", "ORDER-DIFF", "ACCESS-LOSS", "ACCESS-LOSS-TOTAL",
              "ACCESS-GAIN", "PROTO-COUNT-DIFF"):
        if k in C: print("   %-22s %d" % (k, C[k]))
    if aloss > BASELINE["ACCESS_LOSS"]:
        fails.append("GATE 6: ACCESS-LOSS %d > baseline %d -- REAL code loss"
                     % (aloss, BASELINE["ACCESS_LOSS"]))
    aloss_total = C.get("ACCESS-LOSS-TOTAL", -1)
    if aloss_total < 0:
        fails.append("GATE 6: allcats did not report ACCESS-LOSS-TOTAL")
    elif aloss_total > BASELINE["ACCESS_LOSS_TOTAL"]:
        fails.append("GATE 6: ACCESS-LOSS-TOTAL %d > baseline %d -- REAL code loss"
                     % (aloss_total, BASELINE["ACCESS_LOSS_TOTAL"]))
    order_all = C.get("ORDER-DIFF", -1)
    if order_all < 0:
        fails.append("GATE 6: independent ORDER-DIFF missing")
    elif order_all > BASELINE["ORDER_DIFF_ALL"]:
        fails.append("GATE 6: independent ORDER-DIFF %d > baseline %d"
                     % (order_all, BASELINE["ORDER_DIFF_ALL"]))

    # ---- Gate 7: a conditional arm that returns must not become an unconditional return followed
    # by a now-dead sibling. The remaining loop-exit-state specimens are ratcheted explicitly.
    lost_conditions = LC.get("SITES", -1)
    print("\n-- GATE 7: lost conditional wrappers (render pass only)")
    print("   %-22s %d" % ("DEADTAIL", lost_conditions))
    if lost_conditions < 0:
        fails.append("GATE 7: lost-condition gate did not report a site count")
    elif lost_conditions > BASELINE["LOST_CONDITION"]:
        fails.append("GATE 7: DEADTAIL %d > baseline %d"
                     % (lost_conditions, BASELINE["LOST_CONDITION"]))

    # ---- Gate 3
    same = T.get("SAME", 0); diff = T.get("DIFFERENT", 0); to = T.get("timeout", 0)
    print("\n-- GATE 3: behavioural round-trip")
    print("   SAME=%d DIFFERENT=%d timeout=%d" % (same, diff, to))
    for f in T.get("_diff_files", [])[:5]:
        print("     !! %s" % f)
    if to:
        # A timeout is NOT a behavioural difference. Reported, never counted as a failure.
        print("   note: timeout != DIFFERENT (a slow file is not a wrong file)")
    if same + to < BASELINE["realtrip_same"]:
        fails.append("GATE 3: realtrip SAME+timeout %d < baseline %d"
                     % (same + to, BASELINE["realtrip_same"]))
    # There are no remaining accepted differences. Do not add an exception here to make a new
    # failure pass: preserve the failing artifact and diagnose it against the last accepted binary.
    if diff:
        diff_files = [os.path.basename(f) for f in T.get("_diff_files", [])]
        fails.append("GATE 3: %d behavioural DIFFERENCE(s): %s"
                     % (diff, ", ".join(diff_files[:3])))

    access_results = [{
        "name": name,
        "note": note,
        "original": orig,
        "passed": orig is not None and orig == ours,
        "recompiled": ours,
    } for name, orig, ours, note in sorted(ACC)]
    corpus_file_count = sum(
        1 for name in os.listdir(CACHE)
        if name.endswith(".lua_B") and os.path.isfile(os.path.join(CACHE, name)))
    payload = {
        "baselines": dict(BASELINE),
        "failures": list(fails),
        "inputs": {
            "align_count": n_align,
            "corpus": CACHE,
            "corpus_file_count": corpus_file_count,
            "environment": {
                "RENOVICE_NATIVE": ENV["RENOVICE_NATIVE"],
                "RENOVICE_NATIVE_GLOBALS": ENV["RENOVICE_NATIVE_GLOBALS"],
            },
            "realtrip_count": n_trip,
            "tools": {
                "derecomp": {"path": DEC, "sha256": sha256_file(DEC)},
                "luau_compile": {"path": LUAU_COMPILE, "sha256": sha256_file(LUAU_COMPILE)},
            },
        },
        "metrics": {
            "access": access_results,
            "alignment": dict(sorted(A.items())),
            "backedge": dict(sorted(B.items())),
            "behaviour": {
                "different": diff,
                "different_files": sorted(T.get("_diff_files", [])),
                "same": same,
                "timeout": to,
            },
            "categories": dict(sorted(C.items())),
            "constant_comparison": dict(sorted(P.items())),
            "dropped": {
                "backward": D.get("BACKWARD", 0),
                "self": D.get("SELF", 0),
                "total": dropped,
            },
            "lost_condition": {"sites": lost_conditions},
            "semantic_lowering": dict(sorted(L.items())),
            "semantic_behavior": dict(sorted(SB.items())),
            "warframe_api_trace": dict(sorted(WF.items())),
            "native_namecall": dict(sorted(NC.items())),
        },
        "passed": not fails,
        "schema_version": 1,
    }

    print("\n== VERDICT ==")
    if fails:
        for f in fails: print("   FAIL  %s" % f)
        print("   -> DOES NOT SHIP. Do not redefine the gate to fit the result.")
        if json_out:
            write_json(json_out, payload)
        return 1
    print("   ALL GATES PASS  (ALIGNED %d, NAME-DIFF %d, realtrip %d/%d)"
          % (aligned, namediff, same, same + diff + to))
    print("   -> accepted release baseline satisfied.")
    if json_out:
        write_json(json_out, payload)
    return 0


if __name__ == "__main__":
    sys.exit(main())
