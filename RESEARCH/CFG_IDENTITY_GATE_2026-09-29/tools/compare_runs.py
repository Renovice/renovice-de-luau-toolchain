#!/usr/bin/env python3
"""Compare two cert/u44_rawhash_roundtrip.py result files (before/after a decompiler change).

Usage: compare_runs.py BEFORE.json AFTER.json OUT.json
Reports the PASS/FAIL partitions of CONST-ID and CFG-ID (first pass and compiler-closed), the
module transitions between the runs, and the CFG failure classes of each run (by prototype and by
module, first-mismatch class). Numbers only; no interpretation.
"""
import collections
import json
import sys


def load(path):
    data = json.load(open(path, encoding="utf-8"))
    return data["summary"], {r["module"]: r for r in data["results"]}


def verdict(result, key):
    return (result.get(key) or {}).get("verdict")


def partition(results, key):
    counts = collections.Counter(verdict(r, key) or "NOT_RUN" for r in results.values())
    return dict(sorted(counts.items()))


def module_classes(results):
    counts = collections.Counter()
    for r in results.values():
        c = r.get("cfgIdentity") or {}
        if c.get("verdict") != "FAIL":
            continue
        if c.get("protosStock") != c.get("protosCandidate"):
            counts["PROTO_COUNT"] += 1
            continue
        first = (c.get("firstDiffs") or [""])[0]
        cls = first.split('class="')[-1].rstrip('"') if 'class="' in first else "OTHER"
        counts[cls] += 1
    return dict(counts.most_common())


def main():
    before_summary, before = load(sys.argv[1])
    after_summary, after = load(sys.argv[2])
    report = {"before": {}, "after": {}, "transitions": {}}
    for tag, summary, results in (("before", before_summary, before), ("after", after_summary, after)):
        report[tag] = {
            "exe": summary.get("exeSha256"), "gateExe": summary.get("gateExeSha256"),
            "modules": summary.get("modules"), "decompile": summary.get("decompile"),
            "recompile": summary.get("recompile"), "deterministic": summary.get("deterministic"),
            "constIdFirstPass": partition(results, "constIdentity"),
            "cfgIdFirstPass": partition(results, "cfgIdentity"),
            "cfgIdClosed": summary.get("cfgIdentityClosed"),
            "constIdClosed": summary.get("constIdentityClosed"),
            "compilerClosed": summary.get("compilerClosed"),
            "sourceFixedPoint": summary.get("sourceFixedPoint"),
            "constAndCfgFirstPass": summary.get("constAndCfgIdentityFirstPass"),
            "cfgProtosEqual": summary.get("cfgProtosEqual"),
            "cfgProtosCompared": summary.get("cfgProtosCompared"),
            "cfgModulesProtoAligned": summary.get("cfgModulesProtoAligned"),
            "classSwaps": summary.get("classSwapsFirstPass"),
            "cfgClassesByProto": dict(list(summary.get("cfgFailureClassesByProto", {}).items())[:25]),
            "cfgFirstClassByModule": dict(list(module_classes(results).items())[:25]),
        }
    moves = collections.Counter()
    examples = collections.defaultdict(list)
    for module in sorted(set(before) | set(after)):
        for key, name in (("cfgIdentity", "cfg"), ("constIdentity", "const")):
            a, b = verdict(before.get(module, {}), key), verdict(after.get(module, {}), key)
            if a != b:
                label = "%s %s->%s" % (name, a, b)
                moves[label] += 1
                if len(examples[label]) < 40:
                    examples[label].append(module)
        pa = (before.get(module, {}).get("cfgIdentity") or {}).get("cfgEqual")
        pb = (after.get(module, {}).get("cfgIdentity") or {}).get("cfgEqual")
        if pa is not None and pb is not None and pa != pb:
            moves["cfg protos equal %s" % ("up" if pb > pa else "down")] += 1
            label = "cfg protos equal %s" % ("up" if pb > pa else "down")
            if len(examples[label]) < 40:
                examples[label].append("%s %d->%d" % (module, pa, pb))
    report["transitions"] = {"counts": dict(sorted(moves.items())), "examples": dict(examples)}
    json.dump(report, open(sys.argv[3], "w", encoding="utf-8"), indent=1)
    print(json.dumps({k: {x: y for x, y in v.items() if x not in ("cfgClassesByProto", "cfgFirstClassByModule")}
                      if k != "transitions" else v["counts"] for k, v in report.items()}, indent=1))


if __name__ == "__main__":
    main()
