#!/usr/bin/env python3
"""Stock-anchored round-trip gate for the U44 raw-hash path (and, for comparison, the U43 path).

For every stock module:
  decompile      decompile-mod-u44 stock -> s1                 (U43 profile: decompile-mod)
  recompile      recompile-u44 s1 -> b1                        (U43 profile: recompile)
  determinism    recompile s1 a second time; bytes must equal b1
  one-pass FP    decompile b1 -> s2, recompile -> b2; source s2==s1 and bytes b2==b1
  closed FP      keep decompiling/recompiling until the source repeats (bounded); report the pass
  CONST-ID       derecomp const-identity stock b1: per-prototype hash multiset, string multiset and
                 name-key use classes (GET/SETGLOBAL, GET/SETFIELD, NAMECALL, GETIMPORT positions)
                 must equal stock. This is the check the source fixed point cannot make: a fixed
                 point compares our output with itself, so a stable hash->string class loss passes it.
  CONST-ID closed  the same gate on the compiler-closed bytecode
  CFG-ID         derecomp cfg-identity stock b1: per-prototype control-flow/operation-order identity
                 (bisimulation of register-free operation labels, documented transcoder lowerings
                 folded, emitter dispatch-state tests decided statically). CONST-ID compares constants
                 only; a reordered or restructured function passes it (SyndicateScarves p13).
  CFG-ID closed  the same gate on the compiler-closed bytecode
  DATAFLOW-ID    (opt-in, --dataflow) derecomp dataflow-identity stock b1: per-prototype reaching value
                 origins of every register operand, live values and CAPTURE facts over the CFG-ID
                 matching (src/dataflow_identity_cmd.h). Reported per module and in the summary; it is
                 an independent property and does not enter the exit status or any other verdict.
  byte identity  b1 == stock (measured separately; not required)

Per-module work happens in a temporary directory; only failing modules keep artifacts (--keep).
Usage:
  python cert/u44_rawhash_roundtrip.py STOCK_DIR OUT_DIR [--profile u44|u43] [--jobs N]
      [--match SUBSTR ...] [--list FILE] [--stride K] [--limit N] [--exe PATH] [--gate-exe PATH] [--keep]
      [--dataflow]
Exit status 0 only when every selected module passes decompile, recompile, determinism, CONST-ID and
CFG-ID on the first recompile.
"""
import argparse, concurrent.futures as cf, hashlib, json, os, re, shutil, subprocess, sys, tempfile, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAX_CLOSE_PASSES = 4


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def run(exe, args, cwd, timeout=300):
    try:
        p = subprocess.run([str(exe)] + [str(a) for a in args], cwd=cwd, capture_output=True,
                           text=True, timeout=timeout)
        return p.returncode, (p.stdout or "") + (p.stderr or "")
    except subprocess.TimeoutExpired:
        return 124, "timeout"


def gate(exe, stock, cand, u44, cwd):
    rc, out = run(exe, ["const-identity", stock, cand] + (["--u44"] if u44 else []), cwd)
    m = re.search(r"CONST_IDENTITY protos_stock=(\d+) protos_candidate=(\d+) hash_equal=(\d+) "
                  r"string_equal=(\d+) keyuse_equal=(\d+) verdict=(\w+)", out)
    code = re.search(r"CODE_DIFF protos_code_equal=(\d+) protos_code_size_differs=(\d+) "
                     r"differing_bytes_by_canonical_op_field=\{([^}]*)\}", out)
    if not m:
        return {"verdict": "ERROR", "detail": out[-400:]}
    r = dict(zip(["protosStock", "protosCandidate", "hashEqual", "stringEqual", "keyUseEqual"],
                 map(int, m.groups()[:5])))
    r["verdict"] = m.group(6)
    if code:
        r["codeEqualProtos"] = int(code.group(1)); r["codeSizeDiffersProtos"] = int(code.group(2))
        r["differingBytes"] = code.group(3)
    swaps = re.search(r"CLASS_SWAPS hash_string_class_swaps=(\d+)", out)
    other = re.search(r"other_keyuse_differences=(\d+)", out)
    if other: r["otherKeyUseDiffs"] = int(other.group(1))
    booleans = re.search(r"BOOLEANS protos_with_boolean_constant_differences=(\d+)", out)
    if swaps: r["classSwaps"] = int(swaps.group(1))
    if booleans: r["booleanDiffProtos"] = int(booleans.group(1))
    diffs = [line for line in out.splitlines() if line.startswith("proto ")]
    if diffs:
        r["firstDiffs"] = diffs[:6]
    return r


def cfg_gate(exe, stock, cand, u44, cwd):
    rc, out = run(exe, ["cfg-identity", stock, cand] + (["--u44"] if u44 else []), cwd)
    m = re.search(r"CFG_IDENTITY protos_stock=(\d+) protos_candidate=(\d+) cfg_equal=(\d+) "
                  r"model_errors=(\d+) candidate_dispatch_webs=(\d+) verdict=(\w+)", out)
    if not m:
        return {"verdict": "ERROR", "detail": out[-400:]}
    r = dict(zip(["protosStock", "protosCandidate", "cfgEqual", "modelErrors", "dispatchWebs"],
                 map(int, m.groups()[:5])))
    r["verdict"] = m.group(6)
    classes = re.search(r"^CFG_CLASSES \{([^}]*)\}", out, re.M)
    r["classes"] = {}
    if classes and classes.group(1):
        for item in classes.group(1).split(";"):
            name, _, count = item.rpartition(":")
            r["classes"][name] = int(count)
    diffs = [line for line in out.splitlines() if line.startswith("proto ")]
    if diffs:
        r["firstDiffs"] = diffs[:6]
    return r


def dataflow_gate(exe, stock, cand, u44, cwd):
    rc, out = run(exe, ["dataflow-identity", stock, cand] + (["--u44"] if u44 else []), cwd)
    m = re.search(r"DATAFLOW_IDENTITY protos_stock=(\d+) protos_candidate=(\d+) df_equal=(\d+) df_diff=(\d+) "
                  r"df_unpaired=(\d+) df_model_errors=(\d+) product_nodes=(\d+) slots=(\d+) verdict=(\w+)", out)
    if not m:
        return {"verdict": "ERROR", "detail": out[-400:]}
    r = dict(zip(["protosStock", "protosCandidate", "dfEqual", "dfDiff", "dfUnpaired", "dfModelErrors",
                  "productNodes", "slots"], map(int, m.groups()[:8])))
    r["verdict"] = m.group(9)
    classes = re.search(r"^DF_CLASSES \{([^}]*)\}", out, re.M)
    r["classes"] = {}
    if classes and classes.group(1):
        for item in classes.group(1).split(";"):
            name, _, count = item.rpartition(":")
            r["classes"][name] = int(count)
    diffs = [line for line in out.splitlines() if line.startswith("proto ")]
    if diffs:
        r["firstDiffs"] = diffs[:6]
    return r


def one(stock, args):
    u44 = args.profile == "u44"
    decomp = "decompile-mod-u44" if u44 else "decompile-mod"
    recomp = "recompile-u44" if u44 else "recompile"
    res = {"module": stock.name}
    work = Path(tempfile.mkdtemp(prefix="u44rt-", dir=args.tmp))
    t0 = time.time()
    try:
        s1, b1, b1r = work / "s1.luau", work / "b1.lua_B", work / "b1r.lua_B"
        rc, out = run(args.exe, [decomp, stock, s1], work)
        res["decompile"] = rc == 0 and s1.exists()
        if not res["decompile"]:
            res["error"] = "decompile: " + out[-300:]; return res
        text = s1.read_text(encoding="utf-8", errors="replace")
        res["directives"] = {k: len(re.findall(r"^-- RENOVICE_" + k + ": ", text, re.M))
                             for k in ("NAME_HASH_SEED", "HASH_GLOBAL", "HASH_FIELD", "IMPORT_CLASS")}
        res["rawHashSpellings"] = len(set(re.findall(r"\b\w+__[0-9a-fA-F]{8}\b", text)))
        rc, out = run(args.exe, [recomp, s1, b1], work)
        res["recompile"] = rc == 0 and b1.exists()
        if not res["recompile"]:
            res["error"] = "recompile: " + out[-300:]; return res
        rc2, _ = run(args.exe, [recomp, s1, b1r], work)
        res["deterministic"] = rc2 == 0 and b1r.read_bytes() == b1.read_bytes()
        res["constIdentity"] = gate(args.gate_exe, stock, b1, u44, work)
        res["cfgIdentity"] = cfg_gate(args.gate_exe, stock, b1, u44, work)
        if args.dataflow:
            res["dataflowIdentity"] = dataflow_gate(args.gate_exe, stock, b1, u44, work)
        res["byteIdentical"] = b1.read_bytes() == stock.read_bytes()
        # one-pass and compiler-closed fixed points (skipped with --first-pass-only)
        sources, binaries = [s1.read_bytes()], [b1]
        closed_at = None
        for k in range(2, (MAX_CLOSE_PASSES + 2) if not args.first_pass_only else 2):
            sk, bk = work / f"s{k}.luau", work / f"b{k}.lua_B"
            rc, out = run(args.exe, [decomp, binaries[-1], sk], work)
            if rc != 0:
                res["fixedPointError"] = f"decompile pass {k}: " + out[-200:]; break
            rc, out = run(args.exe, [recomp, sk, bk], work)
            if rc != 0:
                res["fixedPointError"] = f"recompile pass {k}: " + out[-200:]; break
            text = sk.read_bytes()
            if k == 2:
                res["sourceFixedPoint"] = text == sources[0]
                res["bytecodeFixedPoint"] = bk.read_bytes() == b1.read_bytes()
            if text == sources[-1]:
                closed_at = k - 1; binaries.append(bk); break
            sources.append(text); binaries.append(bk)
        res["closedAtPass"] = closed_at
        if closed_at is not None and closed_at > 1:
            final = binaries[closed_at - 1]
            res["closedConstIdentity"] = gate(args.gate_exe, stock, final, u44, work)
            res["closedCfgIdentity"] = cfg_gate(args.gate_exe, stock, final, u44, work)
            res["closedByteIdentical"] = final.read_bytes() == stock.read_bytes()
        return res
    finally:
        res["seconds"] = round(time.time() - t0, 2)
        failed = not (res.get("decompile") and res.get("recompile") and res.get("deterministic")
                      and res.get("constIdentity", {}).get("verdict") == "PASS"
                      and res.get("cfgIdentity", {}).get("verdict") == "PASS")
        if args.keep and failed:
            dest = Path(args.out) / "failures" / stock.name
            shutil.rmtree(dest, ignore_errors=True)
            shutil.copytree(work, dest)
        shutil.rmtree(work, ignore_errors=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("stock"); ap.add_argument("out")
    ap.add_argument("--profile", choices=["u44", "u43"], default="u44")
    ap.add_argument("--jobs", type=int, default=max(1, (os.cpu_count() or 2) - 2))
    ap.add_argument("--match", action="append", default=[])
    ap.add_argument("--list", default=None, help="file with one module file name per line (exclusive selection)")
    ap.add_argument("--stride", type=int, default=1)
    ap.add_argument("--limit", type=int, default=0)
    ap.add_argument("--exe", default=str(ROOT / "bin" / "derecomp.exe"))
    ap.add_argument("--gate-exe", default=None, help="derecomp providing const-identity (default: --exe)")
    ap.add_argument("--tmp", default=None)
    ap.add_argument("--keep", action="store_true")
    ap.add_argument("--dataflow", action="store_true",
                    help="also run dataflow-identity on the first rebuild (reported only; not in the exit status)")
    ap.add_argument("--first-pass-only", action="store_true",
                    help="skip the fixed-point/compiler-closed passes (release-gate sampling)")
    args = ap.parse_args()
    args.exe = str(Path(args.exe).resolve())
    args.gate_exe = str(Path(args.gate_exe).resolve()) if args.gate_exe else args.exe
    Path(args.out).mkdir(parents=True, exist_ok=True)
    files = sorted(p for p in Path(args.stock).iterdir() if p.suffix == ".lua_B")
    picked = [p for i, p in enumerate(files) if i % args.stride == 0]
    for sub in args.match:
        picked += [p for p in files if sub.lower() in p.name.lower() and p not in picked]
    picked = sorted(set(picked))
    if args.list:
        wanted = {line.strip() for line in open(args.list, encoding="utf-8") if line.strip()}
        picked = [p for p in files if p.name in wanted]
    if args.limit:
        picked = picked[:args.limit]
    t0 = time.time()
    with cf.ThreadPoolExecutor(args.jobs) as pool:
        results = list(pool.map(lambda p: one(p.resolve(), args), picked))
    n = len(results)
    def count(pred): return sum(1 for r in results if pred(r))
    summary = {
        "profile": args.profile, "firstPassOnly": args.first_pass_only, "exe": args.exe, "exeSha256": sha(args.exe), "gateExeSha256": sha(args.gate_exe),
        "stockDir": str(Path(args.stock).resolve()), "modules": n,
        "decompile": count(lambda r: r.get("decompile")),
        "recompile": count(lambda r: r.get("recompile")),
        "deterministic": count(lambda r: r.get("deterministic")),
        "sourceFixedPoint": count(lambda r: r.get("sourceFixedPoint")),
        "bytecodeFixedPoint": count(lambda r: r.get("bytecodeFixedPoint")),
        "compilerClosed": count(lambda r: r.get("closedAtPass") is not None),
        "constIdentityFirstPass": count(lambda r: r.get("constIdentity", {}).get("verdict") == "PASS"),
        "constIdentityClosed": count(lambda r: (r.get("closedConstIdentity") or r.get("constIdentity", {})).get("verdict") == "PASS"
                                     and r.get("closedAtPass") is not None),
        "cfgIdentityFirstPass": count(lambda r: r.get("cfgIdentity", {}).get("verdict") == "PASS"),
        "cfgIdentityClosed": count(lambda r: (r.get("closedCfgIdentity") or r.get("cfgIdentity", {})).get("verdict") == "PASS"
                                   and r.get("closedAtPass") is not None),
        "constAndCfgIdentityFirstPass": count(lambda r: r.get("constIdentity", {}).get("verdict") == "PASS"
                                              and r.get("cfgIdentity", {}).get("verdict") == "PASS"),
        "byteIdenticalFirstPass": count(lambda r: r.get("byteIdentical")),
        "seconds": round(time.time() - t0, 1),
    }
    summary["modulesWithDirective"] = {k: count(lambda r, k=k: r.get("directives", {}).get(k, 0) > 0)
                                       for k in ("NAME_HASH_SEED", "HASH_GLOBAL", "HASH_FIELD", "IMPORT_CLASS")}
    summary["directiveLines"] = {k: sum(r.get("directives", {}).get(k, 0) for r in results)
                                 for k in ("HASH_GLOBAL", "HASH_FIELD", "IMPORT_CLASS")}
    summary["distinctRawHashSpellingsSum"] = sum(r.get("rawHashSpellings", 0) for r in results)
    summary["modulesWithClassSwapsFirstPass"] = count(lambda r: r.get("constIdentity", {}).get("classSwaps", 0) > 0)
    summary["classSwapsFirstPass"] = sum(r.get("constIdentity", {}).get("classSwaps", 0) for r in results)
    summary["protoCountMismatch"] = count(lambda r: "protosStock" in r.get("constIdentity", {})
                                          and r["constIdentity"]["protosStock"] != r["constIdentity"]["protosCandidate"])
    # Prototype totals only over modules whose prototype counts agree: when a prototype is lost or
    # duplicated, same-index comparison pairs different functions (PITFALLS C2).
    aligned = [r.get("cfgIdentity", {}) for r in results
               if r.get("cfgIdentity", {}).get("protosStock") is not None
               and r["cfgIdentity"]["protosStock"] == r["cfgIdentity"]["protosCandidate"]]
    summary["cfgModulesProtoAligned"] = len(aligned)
    summary["cfgProtosCompared"] = sum(c["protosStock"] for c in aligned)
    summary["cfgProtosEqual"] = sum(c.get("cfgEqual", 0) for c in aligned)
    proto_classes, module_classes = {}, {}
    for r in results:
        classes = r.get("cfgIdentity", {}).get("classes", {})
        for name, n_protos in classes.items():
            proto_classes[name] = proto_classes.get(name, 0) + n_protos
            module_classes[name] = module_classes.get(name, 0) + 1
        c = r.get("cfgIdentity", {})
        if c.get("verdict") == "FAIL" and c.get("protosStock") != c.get("protosCandidate"):
            module_classes["PROTO_COUNT"] = module_classes.get("PROTO_COUNT", 0) + 1
    summary["cfgFailureClassesByProto"] = dict(sorted(proto_classes.items(), key=lambda kv: -kv[1]))
    summary["cfgFailureClassesByModule"] = dict(sorted(module_classes.items(), key=lambda kv: -kv[1]))
    if args.dataflow:
        summary["dataflowIdentityFirstPass"] = count(lambda r: r.get("dataflowIdentity", {}).get("verdict") == "PASS")
        summary["cfgAndDataflowIdentityFirstPass"] = count(
            lambda r: r.get("cfgIdentity", {}).get("verdict") == "PASS"
            and r.get("dataflowIdentity", {}).get("verdict") == "PASS")
        summary["dataflowFailAmongCfgPass"] = count(
            lambda r: r.get("cfgIdentity", {}).get("verdict") == "PASS"
            and r.get("dataflowIdentity", {}).get("verdict") != "PASS")
        df_classes = {}
        for r in results:
            for name in r.get("dataflowIdentity", {}).get("classes", {}):
                df_classes[name] = df_classes.get(name, 0) + 1
        summary["dataflowClassesByModule"] = dict(sorted(df_classes.items(), key=lambda kv: -kv[1]))
    summary["hashClassOk"] = count(lambda r: r.get("constIdentity", {}).get("hashEqual") is not None
                                   and r["constIdentity"]["hashEqual"] == r["constIdentity"]["protosStock"]
                                   and r["constIdentity"]["stringEqual"] == r["constIdentity"]["protosStock"])
    (Path(args.out) / f"results-{args.profile}.json").write_text(json.dumps({"summary": summary, "results": results}, indent=1))
    with open(Path(args.out) / f"results-{args.profile}.tsv", "w", encoding="utf-8") as f:
        f.write("module\tdecompile\trecompile\tdeterministic\tsrcFP\tbcFP\tclosedAt\tconstId\thashEq\tstrEq\tkeyEq\tprotos\tclosedConstId\tbyteIdentical\tcfgId\tcfgEq\tclosedCfgId\terror\n")
        for r in results:
            c = r.get("constIdentity", {})
            f.write("\t".join(str(x) for x in [r["module"], r.get("decompile"), r.get("recompile"), r.get("deterministic"),
                    r.get("sourceFixedPoint"), r.get("bytecodeFixedPoint"), r.get("closedAtPass"), c.get("verdict"),
                    c.get("hashEqual"), c.get("stringEqual"), c.get("keyUseEqual"), c.get("protosStock"),
                    (r.get("closedConstIdentity") or {}).get("verdict"), r.get("byteIdentical"),
                    r.get("cfgIdentity", {}).get("verdict"), r.get("cfgIdentity", {}).get("cfgEqual"),
                    (r.get("closedCfgIdentity") or {}).get("verdict"),
                    (r.get("error") or r.get("fixedPointError") or "").replace("\t", " ").replace("\n", " ")[:200]]) + "\n")
    print(json.dumps(summary, indent=1))
    ok = (summary["decompile"] == summary["recompile"] == summary["deterministic"]
          == summary["constIdentityFirstPass"] == summary["cfgIdentityFirstPass"] == n)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
