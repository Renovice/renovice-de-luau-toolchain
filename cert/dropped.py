#!/usr/bin/env python3
"""
dropped.py - STATIC DETECTOR FOR CODE DROPPED BY THE PROPER-REGION STATE MACHINE.

Why this exists: no other oracle on this project can see this defect class (FINDINGS #97).

  - realtrip  compares our output to ITSELF, so a dropped path is absent from BOTH sides -> passes.
  - NAME-DIFF counts ACCESSES, and a dropped block's names usually appear elsewhere too  -> passes.
  - backedge  compares back edges in the CFG, which is CORRECT here; the loss happens later,
              at emission                                                                 -> passes.
  - align     flags the file, but as a generic ORDER/LOOP difference, never as dropped code.

WHAT IS BEING DETECTED
`src/emit.h` emits a `Proper` region as a synthesized state machine:

    local p29 = 0                         -- p<regionId>, seeded with the first block id
    if p29 == 0 then <block 0> ; if <cond> then p29 = 3 else p29 = 1 end end
    if p29 == 1 then <block 1> ; ... end  -- blocks in ASCENDING id order, a FLAT sequence of ifs

That is only correct if the region is ACYCLIC and ascending block index is a topological order --
which the emitter's comment ASSERTS and nothing CHECKS. Both are false on real corpus data.

Because the chain is flat and ascending, an assignment `p<id> = N` where N <= the guard value of the
block making it targets a guard that has ALREADY been evaluated. Control falls straight out of the
chain: THAT PATH IS NEVER EXECUTED. A backward assignment also proves the region contained a CYCLE.

Real example, Lotus_Interface_Hub (22 backward transitions in that one file):

    if p274 == 3 then
      c74v1 = Sleep ; c74v2 = 0 ; c74v1(c74v2)   -- Sleep(0)
      p274 = 2                                    -- back edge to state 2
    end
    if p274 == 4 then ...                         -- state 2's guard is ABOVE. Already passed.

-> a `while true do ... Sleep(0) ... end` polling loop flattened into a ONE-SHOT.

The check is purely textual over the emitted source, which is exact here: the emitter is the only
thing that writes `p<N>` names, and it always writes the guard and the assignment on their own lines.

Usage:
    python cert/dropped.py            # 300 files
    python cert/dropped.py 600
    python cert/dropped.py 300 -v     # also list every offending site
    RENOVICE_CORPUS=... python cert/dropped.py

Exit codes:  0 = no dropped paths        1 = dropped paths found        2 = could not measure
A non-zero exit from the decompiler is counted as a FAILURE, never as a clean file.
"""
import os, re, sys, subprocess
from concurrent.futures import ThreadPoolExecutor

from workspace_paths import corpus_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC = os.path.join(ROOT, "bin", "derecomp.exe")

# MUST match align.py / realtrip.py exactly. Two oracles running different compiler configurations
# is how a real defect stayed invisible for the whole project (PITFALLS A7).
ENV = dict(os.environ, RENOVICE_NATIVE_GLOBALS="1",
           RENOVICE_NATIVE="JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,JUMPBACK,AND,OR,ANDK,ORK,SUBK,FORGPREP")

CACHE = corpus_cache(ROOT)
if not os.path.isdir(CACHE) or not any(x.endswith(".lua_B") for x in os.listdir(CACHE)):
    # FAIL LOUDLY. An oracle that cannot see the corpus must never report "0 problems".
    sys.stderr.write("FATAL: corpus not found or empty at %s\n"
                     "       set RENOVICE_CORPUS to the dir holding *.lua_B\n" % CACHE)
    sys.exit(2)

GUARD = re.compile(r"^\s*if (p\d+) == (\d+) then\s*$")
ASSIGN = re.compile(r"^\s*(p\d+) = (\d+)\s*$")
SCC_WHILE = re.compile(r"^([ \t]*)while (p\d+) == (\d+)(?: or \2 == \d+)* do[ \t]*$")
SCC_STATE = re.compile(r"(p\d+) == (\d+)")
DECL_LINE = re.compile(r"^[ \t]*local (p\d+) = (\d+)[ \t]*$")
# Two traps this line already sprang, both of which reported a CLEAN-LOOKING number:
#  1. Written first WITHOUT re.M and used with findall() over the whole text -> `^` matched only at
#     position 0, findall returned [], and the summary printed a confident "0 state machines
#     (0.0%)" while the backward count (line-by-line, a different path) was correct. PITFALLS A1.
#  2. Written as `\s*` -> `\s` matches newlines, so `\s*$` swallowed the following line and findall
#     skipped every other declaration: 912 instead of 1011. Use [ \t], never \s, for line anchors.


def scan_source(text):
    """Return (machines, states_per_machine, backward_sites, self_sites, shadow_sites).

    REGION IDS ARE NOT UNIQUE PER FILE. `p9` is emitted 5 times in Lotus_Interface_ChatRedux --
    region ids restart per proto, so keying state counts by variable NAME merges unrelated machines
    and inflates the size distribution (this produced a bogus "max=489"). PITFALLS C1.
    Each `local pN = k` therefore OPENS A NEW MACHINE for that name; later guards attribute to it.

    Backward/self detection is unaffected by the collision and is the number that matters: a
    machine's guards and assignments are lexically contiguous, so the nearest preceding
    `if pN == g` with the same name is always within the same machine.

    A transition is judged only when the assigned variable matches the enclosing guard's variable,
    so a machine nested inside another cannot be compared against the wrong numbering. That makes
    the count a LOWER BOUND -- the right direction for a gate.
    """
    machines = []          # list of (name, set_of_guard_values, guard_value_to_source_line)
    open_by_name = {}      # name -> index into `machines`
    back, selfa, shadow, cur = [], [], [], None
    lines = text.splitlines()
    # Generated cyclic-SCC dispatchers deliberately contain backward state assignments, but unlike
    # the old flat chain their guards are re-evaluated by an enclosing `while p==A or p==B ... do`.
    # Identify those exact indentation-bounded ranges up front. A transition is exempt only when its
    # source guard, assignment, source state, and target state all belong to the same generated loop.
    repeated = []          # (first_line_index, last_line_index, var, member_states)
    for wi, line in enumerate(lines):
        wm = SCC_WHILE.match(line)
        if not wm:
            continue
        indent, var = wm.group(1), wm.group(2)
        members = {int(v) for n, v in SCC_STATE.findall(line) if n == var}
        end_index = None
        for ei in range(wi + 1, len(lines)):
            if lines[ei] == indent + "end":
                end_index = ei
                break
        if end_index is not None and members:
            repeated.append((wi, end_index, var, members))

    def repeated_transition(var, guard, target, guard_line, assign_line):
        gi, ai = guard_line - 1, assign_line - 1
        return any(first < gi <= ai < last and name == var
                   and guard in members and target in members
                   for first, last, name, members in repeated)

    def enclosing_guard(assign_index, var):
        """Return (value, 1-based line, indent) for the lexical guard owning an assignment.

        Region ids restart in nested closures, so the last textual `if pN == ...` may belong to a
        closure that has already ended. Generated indentation is exact: a statement owned by a guard
        is deeper than that guard. Walk backward to the nearest same-variable guard at a shallower
        indentation instead of carrying a stale guard across `end`.
        """
        assign_indent = len(lines[assign_index]) - len(lines[assign_index].lstrip(" \t"))
        for gi in range(assign_index - 1, -1, -1):
            gm = GUARD.match(lines[gi])
            if not gm or gm.group(1) != var:
                continue
            guard_indent = len(lines[gi]) - len(lines[gi].lstrip(" \t"))
            if guard_indent < assign_indent:
                return int(gm.group(2)), gi + 1, guard_indent
        return None

    def target_guard_already_passed(assign_index, var, target, guard_indent):
        for gi in range(assign_index - 1, -1, -1):
            dm = DECL_LINE.match(lines[gi])
            line_indent = len(lines[gi]) - len(lines[gi].lstrip(" \t"))
            if dm and dm.group(1) == var and line_indent <= guard_indent:
                return False
            gm = GUARD.match(lines[gi])
            if (gm and gm.group(1) == var and int(gm.group(2)) == target
                    and line_indent == guard_indent):
                return True
        return False
    for i, ln in enumerate(lines):
        m = DECL_LINE.match(ln)
        if m:
            name = m.group(1)
            # Re-declaring a name that already has states is normal ACROSS protos (region ids
            # restart per proto). It is only a bug if the redeclaration lands in the SAME Lua scope
            # as the machine it shadows.
            #
            # CHECKED, 2026-07-28: every one of the 20 sites in the first 300 files has a `function`
            # keyword between the enclosing guard and the redeclaration -- the inner machine is
            # inside a NESTED CLOSURE, which is its own scope, so nothing is shadowed. This was a
            # FALSE POSITIVE and is deliberately NOT reported as a failure. The check is kept
            # because a same-scope redeclaration WOULD be a real defect: the outer machine's later
            # guards would read the inner machine's final value and misdispatch.
            if cur and cur[0] == name and "function" not in "\n".join(lines[cur[2] - 1:i]):
                shadow.append((name, cur[1], cur[2], int(m.group(2)), i + 1))
            machines.append((name, set(), {}))
            open_by_name[name] = len(machines) - 1
            continue
        m = GUARD.match(ln)
        if m:
            name, val = m.group(1), int(m.group(2))
            cur = (name, val, i + 1)
            if name in open_by_name:
                machines[open_by_name[name]][1].add(val)
                machines[open_by_name[name]][2][val] = i + 1
            continue
        m = ASSIGN.match(ln)
        if m:
            owner = enclosing_guard(i, m.group(1))
            if owner is None:
                continue
            guard_value, guard_line, guard_indent = owner
            tgt = int(m.group(2))
            site = (m.group(1), guard_value, guard_line, tgt, i + 1)
            if repeated_transition(m.group(1), guard_value, tgt, guard_line, i + 1):
                continue
            if tgt == guard_value:
                selfa.append(site)
            # State ids are block identities, not execution order. The SCC repair topologically
            # orders guards, so a valid 23 -> 12 transition can now target a numerically lower guard
            # that appears LATER in source. It is dropped only if that target guard has ACTUALLY
            # already executed in this same machine.
            elif target_guard_already_passed(i, m.group(1), tgt, guard_indent):
                back.append(site)
    return len(machines), [len(s) for _, s, _ in machines if s], back, selfa, shadow


def one(fn):
    p = subprocess.run([DEC, "decompile-mod", os.path.join(CACHE, fn)],
                       capture_output=True, text=True, encoding="utf-8",
                       errors="replace", timeout=300, env=ENV, cwd=ROOT)
    if p.returncode != 0:
        return (fn, None)
    return (fn, scan_source(p.stdout))


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else 300
    verbose = "-v" in sys.argv
    files = sorted(f for f in os.listdir(CACHE) if f.endswith(".lua_B"))[:n]

    print("== DROPPED-PATH SCAN ==  files=%d  corpus=%s" % (len(files), CACHE))
    with ThreadPoolExecutor(max_workers=min(8, (os.cpu_count() or 4))) as ex:
        res = list(ex.map(one, files))

    failed = [f for f, r in res if r is None]
    ok = [(f, r) for f, r in res if r is not None]
    if not ok:
        sys.stderr.write("FATAL: every decompile failed - measuring nothing\n")
        return 2

    withsm = [(f, r) for f, r in ok if r[0] > 0]
    sizes = sorted(s for _, r in withsm for s in r[1])
    nback = sum(len(r[2]) for _, r in ok)
    nself = sum(len(r[3]) for _, r in ok)
    nshadow = sum(len(r[4]) for _, r in ok)
    hit = [(f, r) for f, r in ok if r[2] or r[3]]

    print("  files scanned            %d   (decompile FAILED: %d)" % (len(ok), len(failed)))
    print("  files with state machine %d   (%.1f%%)" % (len(withsm), 100.0 * len(withsm) / len(ok)))
    print("  state machines           %d" % sum(r[0] for _, r in withsm))
    print("  synthesized states       %d" % sum(sizes))
    if sizes:
        print("  states per machine       min=%d median=%d max=%d"
              % (sizes[0], sizes[len(sizes) // 2], sizes[-1]))
    print("  BACKWARD transitions     %d   <-- each one is a DROPPED code path" % nback)
    print("  SELF transitions         %d   <-- a loop flattened to a single pass" % nself)
    print("  name SHADOWING           %d   <-- same p-name redeclared INSIDE its own chain" % nshadow)
    print("  affected files           %d" % len(hit))

    if hit:
        print("\n  worst files:")
        for f, r in sorted(hit, key=lambda x: -(len(x[1][2]) + len(x[1][3])))[:10]:
            print("    %-56s backward=%-3d self=%d" % (f[:56], len(r[2]), len(r[3])))
    if verbose:
        for f, r in hit:
            for v, g, gl, t, al in r[2] + r[3]:
                print("    %s  guard %s == %-4d (line %-6d) -> assigns %s = %-4d (line %-6d) %s"
                      % (f, v, g, gl, v, t, al, "SELF" if t == g else "BACKWARD"))

    if failed:
        print("\n  DECOMPILE FAILED (not counted as clean): %s" % ", ".join(failed[:5]))

    print("\n== VERDICT ==")
    if failed:
        print("   FAIL  %d file(s) could not be decompiled - a failure is never a clean result" % len(failed))
        return 1
    if nback or nself or nshadow:
        print("   FAIL  %d code path(s) are emitted but UNREACHABLE, in %d file(s)."
              % (nback + nself, len(hit)))
        if nshadow: print("   FAIL  %d p-name shadowing site(s) - nested machines reuse a name" % nshadow)
        print("   -> The Proper emitter assumes its region is acyclic and never checks (FINDINGS #97).")
        print("   -> Do not redefine the gate to fit the result.")
        return 1
    print("   PASS  no dropped paths in %d files" % len(ok))
    return 0


if __name__ == "__main__":
    sys.exit(main())
