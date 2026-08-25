#!/usr/bin/env python3
"""
realtrip.py - BEHAVIOURAL round-trip on the REAL corpus, under a mocked engine.

behave.py compares our output against a KNOWN source. Real shipped scripts have no known source, so
the question must be posed differently:

    S'  = decompile(DE)
    S'' = decompile(recompile(S'))
    run both under a mocked engine and compare the execution TRACE

Matching traces mean the decompile->recompile loop preserved what the script DOES on real game code.
It cannot prove S' equals DE's original source (nothing offline can), but it catches any
transformation that changes behaviour - the failure mode that matters for editing and redeploying.

Mechanism note: Luau REMOVED `loadstring`, `setfenv`, `getfenv` and `dofile`, so the environment
cannot be swapped at runtime. Instead the stub globals are pre-declared TEXTUALLY: our emitter
declares every register as a local (`vN` / `cNvM`), so any other bare identifier is provably a global.

Usage:  python cert/realtrip.py [N]      (N = how many corpus files, default 200)
"""
import os, sys, re, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor

from workspace_paths import corpus_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
LUAU = os.path.join(ROOT, "bin", "luau.exe")
DEC  = os.path.join(ROOT, "bin", "derecomp.exe")
# CORPUS LOCATION. Overridable via RENOVICE_CORPUS so the project can be COPIED to an isolated
# workspace and still measure the real corpus. The default is RELATIVE to the project root, and that
# relative path is what silently broke sub-agents working in temp copies: they measured an empty or
# different file set and reported a wrong baseline that nearly caused a correct fix to be discarded.
CACHE = corpus_cache(ROOT)
if not os.path.isdir(CACHE) or not any(x.endswith(".lua_B") for x in os.listdir(CACHE)):
    # FAIL LOUDLY. An oracle that cannot see the corpus must never report "0 differences".
    sys.stderr.write("FATAL: corpus not found or empty at %s\n"
                     "       set RENOVICE_CORPUS to the dir holding *.lua_B\n" % CACHE)
    sys.exit(2)
WORKERS = min(16, (os.cpu_count() or 4) * 2)

# Everything deterministic: proxies carry a stable PATH, never an address, and every metamethod
# returns a fixed value rather than anything derived from identity.
STUB = r"""
local TRACE = {}
-- A loop whose exit depends on a proxy comparison never terminates, because the stub must
-- answer SOME fixed value. Timing out makes the case unjudgeable; BOUNDING the trace makes it
-- comparable -- if S' and S'' agree for the first N operations they are behaving identically
-- as far as anything observable, and the cutoff is symmetric so it cannot favour either.
local BUDGET = 20000
local function emit(s)
  TRACE[#TRACE+1] = s
  if #TRACE > BUDGET then error('TRACE_BUDGET', 0) end
end
local Proxy = {}
local function mkproxy(p) return setmetatable({__path=p}, Proxy) end
local function nameof(v)
  local t = type(v)
  if t == "table" then
    local mt = getmetatable(v)
    if mt == Proxy then return rawget(v, "__path") end
    return "<tbl>"
  elseif t == "function" then return "<fn>"
  elseif t == "number" then if v ~= v then return "nan" end return string.format("%.10g", v)
  elseif t == "string" then return string.format("%q", v) end
  return tostring(v)
end
local function arglist(...)
  local n = select("#", ...); local p = {}
  for i = 1, n do p[#p+1] = nameof((select(i, ...))) end
  return table.concat(p, ",")
end
Proxy.__index = function(s,k) local p = rawget(s,"__path").."."..tostring(k)
  emit("IDX "..p) return mkproxy(p) end
Proxy.__newindex = function(s,k,v) emit("SET "..rawget(s,"__path").."."..tostring(k).." = "..nameof(v)) end
Proxy.__call = function(s,...) emit("CALL "..rawget(s,"__path").."("..arglist(...)..")")
  return mkproxy(rawget(s,"__path").."()") end
Proxy.__tostring = function(s) return rawget(s,"__path") end
Proxy.__len = function(s) emit("LEN "..rawget(s,"__path")) return 0 end
Proxy.__concat = function(a,b) return nameof(a)..nameof(b) end
Proxy.__eq = function(a,b) return rawget(a,"__path") == rawget(b,"__path") end
-- Comparisons must be TOTAL and deterministic, or a script comparing an engine value with a number
-- raises and truncates the trace at a point that reflects nothing meaningful.
Proxy.__lt = function(a,b) emit("LT") return false end
Proxy.__le = function(a,b) emit("LE") return false end
Proxy.__add = function(a,b) emit("ADD") return mkproxy("arith") end
Proxy.__sub = function(a,b) emit("SUB") return mkproxy("arith") end
Proxy.__mul = function(a,b) emit("MUL") return mkproxy("arith") end
Proxy.__div = function(a,b) emit("DIV") return mkproxy("arith") end
Proxy.__mod = function(a,b) emit("MOD") return mkproxy("arith") end
Proxy.__pow = function(a,b) emit("POW") return mkproxy("arith") end
Proxy.__unm = function(a) emit("UNM") return mkproxy("arith") end
"""

LUA_KW = set("""and break do else elseif end false for function if in local nil not or repeat return
then true until while self""".split())
LUA_STD = set("""string table math os io coroutine bit32 utf8 select type tostring tonumber pairs
ipairs next pcall xpcall error assert setmetatable getmetatable rawget rawset rawequal rawlen unpack
require print typeof newproxy _VERSION buffer vector""".split())
# `_G` is deliberately NOT in that list. Luau FREEZES the real `_G`, and DE modules export through it
# (`v1 = _G  v1.f = v0`), so leaving it unstubbed raises "attempt to modify a readonly table" and
# truncates the trace. Proxying it turns the export into a traced SET, symmetrically for both sources.

IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
LOCAL = re.compile(r"^(v\d+|c\d+v\d+|p\d+_\d+)$")


def globals_of(src):
    """Identifiers that are not our emitted locals, not keywords, and not stdlib => engine globals."""
    out = set()
    for m in IDENT.finditer(src):
        w = m.group(0)
        if w in LUA_KW or w in LUA_STD or LOCAL.match(w):
            continue
        # skip field accesses: `x.field` / `x:method` — those go through the proxy, not a global
        i = m.start()
        if i > 0 and src[i-1] in ".:":
            continue
        out.add(w)
    return sorted(out)


def build_driver(body, gs=None):
    # The entry list must be the SAME for both sources, or the comparison is not apples-to-apples:
    # derived per-source, a name present in one and absent in the other shows as a trace difference
    # that says nothing about behaviour.
    if gs is None: gs = globals_of(body)
    decls = "\n".join('%s = mkproxy("%s")' % (g, g) for g in gs)
    # After the body runs, any of those names that became a function is an ENTRY POINT. Static
    # identifiers are required: globals set by the chunk are not reachable through `_G` here.
    # Observe the RESULT, not the mechanism. A plain global assignment (`X = 1`, SETGLOBAL) fires no
    # metamethod, so the proxy cannot see it, while `_G.X = 1` goes through __newindex and IS traced —
    # two sources writing the same value by different means looked like a behavioural difference.
    # Snapshotting every stub global after the body makes both mechanisms equally visible.
    snapshot = "\n".join('emit("FINAL %s = " .. nameof(%s))' % (g, g) for g in gs)
    entries = "\n".join(
        'if type(%s) == "function" then emit("-- entry %s") '
        'pcall(%s, mkproxy("self"), mkproxy("a1"), mkproxy("a2")) end' % (g, g, g)
        for g in gs)
    entries = snapshot + "\n" + entries
    # The module body ends with `return`, and in Lua `return` must be the LAST statement in a block —
    # appending the entry calls after it makes the parser read them as the return EXPRESSION
    # ("Expected 'else' when parsing if then else expression"). Wrapping the body in a function keeps
    # its `return` local to that function, and `function(...)` preserves chunk-level varargs.
    return (STUB + "\n" + decls +
            "\nlocal __body = function(...)\n" + body + "\nend\n"
            "local __ok, __e = pcall(__body)\n"
            "if not __ok then emit('BODYERR ' .. (tostring(__e):gsub('^.-:%d+: ', ''))) end\n" +
            entries + '\nprint(table.concat(TRACE, "\\n"))\n')


def run_trace(body, gs=None):
    fd, path = tempfile.mkstemp(suffix=".luau")
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(build_driver(body, gs))
        p = subprocess.run([LUAU, path], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=int(os.environ.get('RENOVICE_TRACE_TIMEOUT', '90')))  # 20s was too tight: one corpus
        # file legitimately needs >20s, and under concurrent oracle runs the contention pushed
        # others over too. A timeout truncates ONE trace, which then reads as a spurious
        # DIFFERENT - i.e. the harness manufactured behavioural failures that did not exist.
        out = (p.stdout or "") + (p.stderr or "")
        # An uncaught error makes luau print a stacktrace containing the TEMP FILENAME, which
        # differs per run and per source — that is per-run noise, not behaviour. Normalise it,
        # or two identical programs compare as different for a reason unrelated to what they do.
        out = re.sub(r"[^\s]*tmp\w+\.luau", "<chunk>", out)
        # ...and the LINE number with it. S'' is legitimately longer than S' (materialised temporaries),
        # so identical behaviour still reports different positions. Position is not behaviour.
        out = re.sub(r"<chunk>:\d+", "<chunk>", out)
        return out
    except subprocess.TimeoutExpired:
        return "<TIMEOUT>"
    finally:
        try: os.remove(path)
        except OSError: pass


# PIN THE CONFIGURATION. This oracle used to inherit whatever the shell happened to export, and that
# silently changed what it measured: with RENOVICE_NATIVE_GLOBALS unset, the transcoder LOWERS global
# access to `_G.X`, so recompiling S' and decompiling again yields `_G.Run = v` where S' had `Run = v`.
# S' and S'' were then never the same program, and the traces differed on a `SET _G.Run` event that
# only one side produced. That alone accounted for 29 of 30 failures — the score went 120/150 -> 149/150
# purely by pinning the env. An oracle whose result depends on the caller's shell is not an oracle.
# MUST match align.py EXACTLY. For the whole project realtrip ran WITHOUT RENOVICE_NATIVE while
# align.py always ran WITH it, so the two headline oracles were measuring DIFFERENT CONFIGURATIONS of
# the compiler and nobody noticed. Lotus_Interface_BindingsUtil is SAME without it and DIFFERENT with
# it — a real fidelity-mode defect that passed for months because this gate tested the other mode.
# Two oracles that disagree about what they are measuring cannot corroborate each other.
ENV = dict(os.environ, RENOVICE_NATIVE_GLOBALS="1",
           RENOVICE_NATIVE="JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,JUMPBACK,AND,OR,ANDK,ORK,SUBK,FORGPREP")


def dec_mod(f):
    p = subprocess.run([DEC, "decompile-mod", f], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=120, env=ENV)
    return p.stdout if p.returncode == 0 else None


def one(f):
    s1 = dec_mod(f)
    if s1 is None:
        return (f, "decompile-fail", None, None)
    fd, sp = tempfile.mkstemp(suffix=".luau"); os.close(fd)
    with open(sp, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(s1)
    de2 = sp + ".lua_B"
    r = subprocess.run([DEC, "recompile", sp, de2], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=120, env=ENV)
    try: os.remove(sp)
    except OSError: pass
    if r.returncode != 0 or not os.path.exists(de2):
        return (f, "recompile-fail", None, None)
    s2 = dec_mod(de2)
    try: os.remove(de2)
    except OSError: pass
    if s2 is None:
        return (f, "decompile2-fail", None, None)
    artifact_dir = os.environ.get("RENOVICE_REALTRIP_ARTIFACT_DIR")
    artifact_filter = os.environ.get("RENOVICE_REALTRIP_ARTIFACT_FILTER")
    if artifact_dir and (not artifact_filter or artifact_filter in os.path.basename(f)):
        os.makedirs(artifact_dir, exist_ok=True)
        stem = os.path.basename(f)
        for suffix, text in (("cycle1.luau", s1), ("cycle2.luau", s2)):
            with open(os.path.join(artifact_dir, stem + "." + suffix), "w",
                      encoding="utf-8", newline="\n") as fh:
                fh.write(text)
    gs = sorted(set(globals_of(s1)) | set(globals_of(s2)))   # shared entry list
    t1, t2 = run_trace(s1, gs), run_trace(s2, gs)
    if "<TIMEOUT>" in t1 or "<TIMEOUT>" in t2:
        return (f, "timeout", t1, t2)
    if "SyntaxError" in t1 or "SyntaxError" in t2:
        return (f, "syntax-error", t1, t2)
    if not t1.strip():
        return (f, "empty-trace", t1, t2)
    return (f, "SAME" if t1 == t2 else "DIFFERENT", t1, t2)


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 200
    files = sorted(os.path.join(CACHE, x) for x in os.listdir(CACHE) if x.endswith(".lua_B"))[:n]
    with ThreadPoolExecutor(max_workers=WORKERS) as ex:
        res = list(ex.map(one, files))
    tally = {}
    for _, k, _, _ in res:
        tally[k] = tally.get(k, 0) + 1
    print("== REAL-CORPUS BEHAVIOURAL ROUND-TRIP (mocked engine) ==")
    print("files=%d" % len(files))
    for k in sorted(tally, key=lambda z: -tally[z]):
        print("  %-18s %d" % (k, tally[k]))
    shown = 0
    for f, k, t1, t2 in res:
        if k in ("DIFFERENT", "syntax-error") and shown < 20:
            shown += 1
            print("---- %s %s" % (k, os.path.basename(f)))
            a, b = (t1 or "").splitlines(), (t2 or "").splitlines()
            for i in range(max(len(a), len(b))):
                x = a[i] if i < len(a) else "<none>"
                y = b[i] if i < len(b) else "<none>"
                if x != y:
                    print("     S' : %s" % x[:150]); print("     S'': %s" % y[:150]); break
    return 0 if tally.get("DIFFERENT", 0) == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
