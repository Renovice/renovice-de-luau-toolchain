#!/usr/bin/env python3
"""
behave.py - THE BEHAVIOURAL ORACLE.

Every check before this one asked "is the output well-formed?". This one asks the only question that
matters: DOES IT DO THE SAME THING? For each ground-truth case we run the known source S and our
decompiled S' under the real Luau interpreter with identical inputs and compare observable results.

This exists because 100% compilability caught none of:
  #34 every `if` inverted        -> different branch taken -> different result
  #37 while/repeat loops lost    -> body runs once instead of N times -> different result
Both fail LOUDLY here, automatically, instead of waiting to be spotted by eye.

Usage:  python cert/behave.py [--only NAME] [--verbose]
        python cert/behave.py --semantic-ir --warframe-api
"""
import json, os, re, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SRC  = os.path.join(HERE, "rt", "src")
DE   = os.path.join(HERE, "rt", "de")
LUAU = os.path.join(ROOT, "bin", "luau.exe")
DEC  = os.path.join(ROOT, "bin", "derecomp.exe")
WARFRAME_API_DIR = os.path.join(HERE, "warframe_api")

# The Luau CLI FREEZES `_G`, so the `_G.f = f` that the ground-truth bytecode really contains raises
# "attempt to modify a readonly table" and kills the chunk before the probe runs. That is an artefact
# of the interpreter's sandbox, not of the decompiler, so shadow `_G` with a writable table that reads
# through to the real globals. Applied to BOTH drivers so the comparison stays symmetric.
PRELUDE = "local _G = setmetatable({}, {__index = _G})\n"

# A deterministic value dumper. `tostring` on a table yields an ADDRESS, which differs run to run and
# would make every table-returning case a false mismatch.
PROBE = r"""
local function dump(v, d)
  local t = type(v)
  if t == "table" then
    if d > 3 then return "<deep>" end
    -- A table used as a KEY renders via tostring as an ADDRESS, which differs every run and made
    -- three tbl_* cases report a false mismatch. Keys need the same canonicalisation as values --
    -- including for the sort, or the ORDER is unstable too.
    local function keytext(k)
      local kt = type(k)
      if kt == "table" then return "<tbl>" elseif kt == "function" then return "<fn>" end
      return tostring(k)
    end
    local ks = {}
    for k in pairs(v) do ks[#ks+1] = k end
    table.sort(ks, function(a,b) return keytext(a) < keytext(b) end)
    local parts = {}
    for _, k in ipairs(ks) do parts[#parts+1] = keytext(k) .. "=" .. dump(v[k], d+1) end
    return "{" .. table.concat(parts, ",") .. "}"
  elseif t == "function" then return "<fn>"
  elseif t == "number" then
    if v ~= v then return "nan" end
    return string.format("%.10g", v)
  elseif t == "string" then
    -- `tostring(someTable)` RETURNS a string containing a pointer, which differs every run. The
    -- value is a legitimate result, so canonicalise the address rather than discard the case.
    return (v:gsub("0x%x+", "<addr>"))
  else return (tostring(v):gsub("0x%x+", "<addr>")) end
end

-- Arities and shapes must actually FIT the functions under test. Tuples that only ever produce
-- "attempt to perform arithmetic on nil" make S and S' agree on failure and prove nothing.
local ARGS = {
  {}, {1}, {0}, {3}, {-1}, {2,3}, {5,2}, {1,1}, {10,4}, {0,0},
  {true}, {false}, {true,false}, {"a","b"}, {"abc"},
  {1,2,3}, {2,3,4}, {6,3,2}, {1,2,3,4}, {"a","b","c","d"},
  {{1,2,3}}, {{a=1,b=2}}, {{},{}},
  {{1,2,3}, 2, 99}, {{a=1,b=2}, "a", 7}, {{}, "x", 5}, {{}, 1, "v"},
  {3,0}, {0,3},
  -- Shapes the functions under test actually require, so the case observes a real VALUE instead of
  -- agreeing with itself about an error: a callable first argument, a nested field chain, and an
  -- object with a method.
  {function(...) return ... end, 7, 8},
  {{a = {b = {c = 42}}}},
  {setmetatable({v = 5}, {__index = {get = function(s) return s.v end}})},
  {{get = function(s) return 11 end, v = 3}},
}

if type(f) ~= "function" then print("NO_F:" .. type(f)) return end

-- Observe SIDE EFFECTS, not just return values. `glob_write` returns nothing at all: its entire
-- observable behaviour is a global assignment, so without this the case can never be more than a
-- vacuous match. Same for functions that MUTATE a table argument in place.
local ENV = (getfenv and getfenv(1)) or _G
local base = {}
for k, v in pairs(ENV) do base[k] = v end

for i, a in ipairs(ARGS) do
  local res = table.pack(pcall(f, table.unpack(a, 1, 4)))
  local out = {}
  if res[1] then
    for j = 2, res.n do out[#out+1] = dump(res[j], 0) end
  else
    -- strip "chunk:line: " so S and S' are not distinguished by mere position
    local m = tostring(res[2]):gsub("^.-:%d+: ", "")
    out[#out+1] = "ERR " .. m
  end
  -- in-place mutation of any table argument
  for j = 1, 4 do
    if type(a[j]) == "table" then out[#out+1] = "arg" .. j .. "=" .. dump(a[j], 0) end
  end
  -- globals created or changed by the call
  local gs = {}
  for k, v in pairs(ENV) do
    if base[k] ~= v and k ~= "f" then gs[#gs+1] = tostring(k) .. "=" .. dump(v, 0) end
  end
  table.sort(gs)
  if #gs > 0 then out[#out+1] = "G{" .. table.concat(gs, ",") .. "}" end
  print(i .. "|" .. table.concat(out, "|"))
end
"""


def run_luau(text, timeout=10):
    """Run a Luau chunk, returning (status, output). Timeout matters: a wrongly-recovered loop can
    spin forever, and a hung harness is indistinguishable from a slow one."""
    fd, path = tempfile.mkstemp(suffix=".luau")
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(text)
        p = subprocess.run([LUAU, path], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=timeout)
        return ("ok" if p.returncode == 0 else "fail"), (p.stdout or "") + (p.stderr or "")
    except subprocess.TimeoutExpired:
        return "timeout", "<TIMEOUT>"
    finally:
        try: os.remove(path)
        except OSError: pass


def decompile(lua_b):
    p = subprocess.run([DEC, "decompile", lua_b], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=120)
    return p.stdout



# Cases are fully independent (separate processes, separate temp files), and subprocess.run releases
# the GIL, so evaluating them concurrently is safe and turns a spawn-bound minutes-long run into
# seconds. Batching many chunks into ONE luau.exe invocation would be faster still, but they would
# share global state and contaminate each other -- isolation is worth more than the extra speed.
WORKERS = min(16, (os.cpu_count() or 4) * 2)


ROUNDTRIP = False
SEMANTIC_IR = False
WARFRAME_API = False


def roundtrip_de(lua_b):
    """decompile-mod -> recompile -> the resulting DE file. Proves the FULL edit loop, not just the
    read direction: if the recompiled module still behaves like the original source, the pipeline is
    faithful end to end."""
    src = subprocess.run([DEC, "decompile-mod", lua_b], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=120)
    if src.returncode != 0:
        return None
    fd, sp = tempfile.mkstemp(suffix=".luau"); os.close(fd)
    with open(sp, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(src.stdout)
    outp = sp + ".lua_B"
    r = subprocess.run([DEC, "recompile", sp, outp], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=120)
    try: os.remove(sp)
    except OSError: pass
    return outp if r.returncode == 0 and os.path.exists(outp) else None


def prep(name):
    """Return (s_text, emitted, entry) or None if the case cannot be set up."""
    spath = os.path.join(SRC, name + ".luau")
    if not os.path.exists(spath):
        return None
    target = os.path.join(DE, name + ".lua_B")
    if ROUNDTRIP:
        rt = roundtrip_de(target)
        if rt is None:
            return ("", "", None)
        target = rt
    if SEMANTIC_IR:
        fd, rendered_path = tempfile.mkstemp(suffix=".luau"); os.close(fd)
        try:
            rendered = subprocess.run(
                [DEC, "semantic-ir-render-module", target, rendered_path],
                capture_output=True, text=True, encoding="utf-8", errors="replace",
                timeout=120)
            if rendered.returncode != 0:
                return (open(spath, encoding="utf-8").read(),
                        (rendered.stdout or "") + (rendered.stderr or ""), None)
            body = open(rendered_path, encoding="utf-8").read()
            emitted = "local function __load_semantic_module()\n" + "\n".join(
                "    " + line for line in body.splitlines())
            emitted += "\nend\n__load_semantic_module()\n"
            return (open(spath, encoding="utf-8").read(), emitted, "")
        finally:
            try: os.remove(rendered_path)
            except OSError: pass
    emitted = decompile(target)
    idxs = [int(m) for m in re.findall(r"^function proto_(\d+)\(", emitted, re.M)]
    if not idxs:
        return ("", emitted, None)
    return (open(spath, encoding="utf-8").read(), emitted, "proto_%d()\n" % max(idxs))


def eval_case(name):
    got = prep(name)
    if got is None:
        return (name, "skip", None, None, None, None, None)
    s_text, emitted, entry = got
    if entry is None:
        return (name, "noproto", None, None, None, None, emitted)
    st_s, out_s = run_luau(PRELUDE + s_text + "\n" + PROBE)
    st_p, out_p = run_luau(PRELUDE + emitted + "\n" + entry + PROBE)
    return (name, "ok", st_s, out_s, st_p, out_p, (emitted, entry))


# Semantic mutations. Each one changes MEANING, so a case that still reports SAME after mutation is
# not actually discriminating - it is passing by luck, and would not catch a real regression either.
MUTATIONS = [
    (" + ", " - "), (" - ", " + "), (" * ", " + "), (" .. ", " .. 'X' .. "),
    (" < ", " <= "), (" <= ", " < "), (" > ", " >= "), (" == ", " ~= "), (" ~= ", " == "),
    ("true", "false"), ("not ", ""),
]


def mutate_audit(names, verbose):
    """Adversarial check on the cases that PASS: corrupt the decompiled source and confirm the oracle
    notices. A pass that survives mutation proves nothing about the decompiler."""
    checked = killed = survived = 0
    weakcases = []
    for name in names:
        spath = os.path.join(SRC, name + ".luau")
        if not os.path.exists(spath):
            continue
        s_text = open(spath, encoding="utf-8").read()
        emitted = decompile(os.path.join(DE, name + ".lua_B"))
        idxs = [int(m) for m in re.findall(r"^function proto_(\d+)\(", emitted, re.M)]
        if not idxs:
            continue
        entry = "proto_%d()\n" % max(idxs)
        st_s, out_s = run_luau(PRELUDE + s_text + "\n" + PROBE)
        st_p, out_p = run_luau(PRELUDE + emitted + "\n" + entry + PROBE)
        if out_s != out_p or st_s != st_p:
            continue                                   # already failing; not the subject here
        applied = 0
        detected = 0
        for a, b in MUTATIONS:
            if a not in emitted:
                continue
            # ALL occurrences. The emitted text contains each function TWICE - the standalone
            # `function proto_N` and the copy inlined into the module chunk, which is the one the
            # probe actually runs. Mutating only the first hits the dead standalone copy and the
            # mutation "survives" for a reason that has nothing to do with the decompiler.
            mutated = emitted.replace(a, b)
            if mutated == emitted:
                continue
            applied += 1
            st_m, out_m = run_luau(PRELUDE + mutated + "\n" + entry + PROBE)
            if out_m != out_s or st_m != st_s:
                detected += 1
        if applied == 0:
            continue
        checked += 1
        if detected == 0:
            survived += 1
            weakcases.append(name)
        else:
            killed += 1
    print("== MUTATION AUDIT (do the PASSING cases actually discriminate?) ==")
    print("  cases with an applicable mutation : %d" % checked)
    print("  mutation DETECTED (case is real)  : %d" % killed)
    print("  mutation SURVIVED (case is weak)  : %d" % survived)
    for n in weakcases:
        print("      !! %s" % n)
    return 0 if survived == 0 else 1


def main():
    global ROUNDTRIP, SEMANTIC_IR, WARFRAME_API, SRC, DE, PRELUDE, PROBE
    only = None
    verbose = "--verbose" in sys.argv
    if "--only" in sys.argv:
        only = sys.argv[sys.argv.index("--only") + 1]
    json_out = None
    if "--json-out" in sys.argv:
        json_out = sys.argv[sys.argv.index("--json-out") + 1]

    for tool in (LUAU, DEC):
        if not os.path.exists(tool):
            print("missing tool: " + tool); return 2

    ROUNDTRIP = "--roundtrip" in sys.argv
    SEMANTIC_IR = "--semantic-ir" in sys.argv
    WARFRAME_API = "--warframe-api" in sys.argv
    if WARFRAME_API:
        SRC = os.path.join(WARFRAME_API_DIR, "src")
        DE = os.path.join(WARFRAME_API_DIR, "de")
        with open(os.path.join(WARFRAME_API_DIR, "mock_prelude.luau"),
                  encoding="utf-8") as stream:
            PRELUDE = stream.read()
        with open(os.path.join(WARFRAME_API_DIR, "probe.luau"),
                  encoding="utf-8") as stream:
            PROBE = stream.read()

    names = sorted(x[:-6] for x in os.listdir(DE) if x.endswith(".lua_B"))
    if only:
        names = [n for n in names if n == only]

    if "--mutate" in sys.argv:
        return mutate_audit(names, verbose)

    same = diff = skipped = weak = 0
    failures = []
    weaks = []
    with ThreadPoolExecutor(max_workers=WORKERS) as ex:
        results = list(ex.map(eval_case, names))
    for name, kind, st_s, out_s, st_p, out_p, extra in results:
        if kind == "skip":
            skipped += 1; continue
        if kind == "noproto":
            failures.append((name, "no protos emitted", "", "")); diff += 1; continue

        if out_s == out_p and st_s == st_p:
            # A match is only EVIDENCE if the probe actually observed something. If `f` was never
            # defined, or every argument tuple raised, then S and S' agree on nothing but failure and
            # the case would still "pass" after arbitrary corruption. Count those separately - a
            # vacuous pass is not a pass.
            informative = [ln for ln in out_s.strip().splitlines()
                           if "|" in ln and "ERR" not in ln and ln.split("|", 1)[1].strip()]
            if "NO_F" in out_s or not informative:
                weak += 1
                weaks.append((name, (out_s.strip().splitlines() or ["<empty>"])[0]))
            else:
                same += 1
        else:
            diff += 1
            failures.append((name, "%s vs %s" % (st_s, st_p), out_s, out_p))

    total = same + diff + weak
    renderer_name = "Semantic IR" if SEMANTIC_IR else "legacy"
    if WARFRAME_API:
        renderer_name += "; mocked Warframe API trace"
    print("== BEHAVIOURAL ORACLE (real Luau interpreter; %s renderer) =="
          % renderer_name)
    print("cases=%d  skipped(no source)=%d" % (total, skipped))
    pct = (100.0 * same / total) if total else 0.0
    print("  SAME behaviour : %d  (%.4f%%)" % (same, pct))
    print("  DIFFERENT      : %d" % diff)
    print("  VACUOUS match  : %d  (identical but proves nothing - no observed value)" % weak)
    for nm, ln in weaks[:20]: print("      ~~ %-26s %s" % (nm, ln))
    for name, why, a, b in failures[: (len(failures) if verbose else 12)]:
        print("  -- %-28s %s" % (name, why))
        if verbose:
            al, bl = a.strip().splitlines(), b.strip().splitlines()
            for i in range(max(len(al), len(bl))):
                x = al[i] if i < len(al) else "<none>"
                y = bl[i] if i < len(bl) else "<none>"
                if x != y:
                    print("       S : %s" % x)
                    print("       S': %s" % y)
    if len(failures) > 12 and not verbose:
        print("  ... %d more (use --verbose)" % (len(failures) - 12))
    if json_out:
        payload = {
            "schema": 1,
            "renderer": (("semantic_ir" if SEMANTIC_IR else "legacy")
                         + ("_warframe_api" if WARFRAME_API else "")),
            "cases": total,
            "same": same,
            "different": diff,
            "vacuous": weak,
            "skipped": skipped,
            "failures": [
                {"name": name, "reason": why}
                for name, why, _source, _rendered in sorted(failures)
            ],
            "weak_cases": [
                {"name": name, "observation": observation}
                for name, observation in sorted(weaks)
            ],
            "success": diff == 0,
        }
        parent = os.path.dirname(os.path.abspath(json_out))
        if parent:
            os.makedirs(parent, exist_ok=True)
        temporary = os.path.abspath(json_out) + ".tmp"
        with open(temporary, "w", encoding="utf-8", newline="\n") as stream:
            json.dump(payload, stream, indent=2, sort_keys=True)
            stream.write("\n")
        os.replace(temporary, os.path.abspath(json_out))
        print("json=%s" % json_out)
    return 0 if diff == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
