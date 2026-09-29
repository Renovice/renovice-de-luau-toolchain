#!/usr/bin/env python3
"""Build compact, repeatable dossiers for reachable-access-loss modules.

This is a triage tool, not a correctness oracle.  It uses the same reachable semantic skeleton and
fidelity environment as gates.py, locates the original prototype that can account for the module's
missing accesses, matches it to the closest rebuilt prototype by signature and access multiset, and
records compact CFG/loop facts.  Ambiguous matches stay explicitly ambiguous.

Usage:
  python cert/access_dossier.py FILE.lua_B [FILE.lua_B ...]
      [--stage-dir DIR] [--json-out FILE] [--markdown-out FILE]
"""
import argparse
import collections
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import accessdiff
import align


PROTO_HEADER = re.compile(r"proto\[(\d+)\] blocks=(\d+) insns=(\d+) reducible=(\S+)")
LOOP_LINE = re.compile(r"loop\d+ header=(\d+)\s+latch=(\d+)\s+kind=(.*?) body=.* size=(\d+)")
BACKEDGE_LINE = re.compile(r"proto\[(\d+)\] backedges=(\d+) headers=(\d+) map=(\d+)")
SKELETON_PROTO = re.compile(r"proto\[(\d+)\]")


def skeleton_proto_id(header):
    match = SKELETON_PROTO.search(header)
    if not match:
        raise RuntimeError("skeleton header has no explicit prototype id: %s" % header)
    return int(match.group(1))


def skeleton_shape(header):
    """Comparable function signature without the unstable absolute prototype number."""
    return SKELETON_PROTO.sub("proto[*]", header)


def run_checked(args):
    proc = align.run(args)
    if proc.returncode != 0:
        raise RuntimeError("command failed (%d): %s\n%s" %
                           (proc.returncode, " ".join(args), proc.stderr))
    return proc.stdout


def resolve_source(name):
    path = name if os.path.isabs(name) else os.path.join(align.CACHE, name)
    path = os.path.abspath(path)
    if not os.path.isfile(path):
        raise RuntimeError("input does not exist: %s" % path)
    return path


def make_roundtrip(source, stage_root):
    stem = os.path.basename(source)
    if stem.endswith(".lua_B"):
        stem = stem[:-6]
    case_dir = os.path.join(stage_root, stem)
    os.makedirs(case_dir, exist_ok=True)
    source_path = os.path.join(case_dir, stem + ".decompiled.luau")
    rebuilt_path = os.path.join(case_dir, stem + ".recompiled.lua_B")
    text = run_checked([align.DEC, align.DECOMPILE_MODE, source])
    with open(source_path, "w", encoding="utf-8", newline="\n") as stream:
        stream.write(text)
    run_checked([align.DEC, "recompile", source_path, rebuilt_path])
    if not os.path.isfile(rebuilt_path):
        raise RuntimeError("recompiler reported success without output: %s" % rebuilt_path)
    return source_path, rebuilt_path


def coverage_score(body, missing):
    return sum(min(body[key], count) for key, count in missing.items())


def multiset_dice(a, b):
    denom = sum(a.values()) + sum(b.values())
    return 1.0 if denom == 0 else 2.0 * sum((a & b).values()) / denom


def match_rebuilt(original_header, original_body, rebuilt, original_position, index_aligned):
    # When every reachable prototype retains the same signature at the same position, closure/root
    # lineage is stronger evidence than surviving-access similarity. A catastrophically collapsed
    # function has intentionally little content left to match: Dojo original p9 was recreated at the
    # same root closure slot as rebuilt p9, but Dice similarity incorrectly selected unrelated p21.
    if index_aligned:
        header, body = rebuilt[original_position]
        return {
            "reachable_position": original_position,
            "proto_index": skeleton_proto_id(header),
            "header": header,
            "shape_exact": skeleton_shape(header) == skeleton_shape(original_header),
            "dice": round(multiset_dice(original_body, body), 6),
            "confidence_gap": 1.0,
            "ambiguous": False,
            "method": "index-aligned reachable lineage",
        }
    wanted_shape = skeleton_shape(original_header)
    exact_header = [(i, h, b) for i, (h, b) in enumerate(rebuilt)
                    if skeleton_shape(h) == wanted_shape]
    pool = exact_header or [(i, h, b) for i, (h, b) in enumerate(rebuilt)]
    ranked = sorted(((multiset_dice(original_body, body), i, header, body)
                     for i, header, body in pool), reverse=True)
    best = ranked[0]
    second = ranked[1][0] if len(ranked) > 1 else 0.0
    return {
        "reachable_position": best[1],
        "proto_index": skeleton_proto_id(best[2]),
        "header": best[2],
        "shape_exact": skeleton_shape(best[2]) == wanted_shape,
        "dice": round(best[0], 6),
        "confidence_gap": round(best[0] - second, 6),
        "ambiguous": best[0] < 0.50 or best[0] - second < 0.05,
        "method": "shape and access-multiset similarity",
    }


def backedge_table(path):
    text = run_checked([align.DEC, "backedges", path, "-v"])
    out = {}
    for match in BACKEDGE_LINE.finditer(text):
        out[int(match.group(1))] = {
            "backedges": int(match.group(2)),
            "headers": int(match.group(3)),
            "loop_map": int(match.group(4)),
        }
    return out


def struct_summary(path, proto_index, backedges):
    text = run_checked([align.DEC, "struct-dump", path, str(proto_index)])
    header = PROTO_HEADER.search(text)
    if not header:
        raise RuntimeError("struct-dump omitted prototype header for proto %d" % proto_index)
    kinds = collections.Counter()
    sizes = []
    for match in LOOP_LINE.finditer(text):
        kinds[match.group(3).strip()] += 1
        sizes.append(int(match.group(4)))
    be = backedges.get(proto_index, {"backedges": 0, "headers": 0, "loop_map": 0})
    return {
        "blocks": int(header.group(2)),
        "instructions": int(header.group(3)),
        "reducible": header.group(4),
        "loops": sum(kinds.values()),
        "loop_kinds": dict(sorted(kinds.items())),
        "loop_body_sizes": sizes,
        **be,
    }


def shape_signature(before, after, proto_delta):
    retention = 0.0 if not before["blocks"] else after["blocks"] / before["blocks"]
    if retention < 0.25:
        bucket = "lt25pct-blocks"
    elif retention < 0.75:
        bucket = "25to74pct-blocks"
    elif retention > 1.50:
        bucket = "gt150pct-blocks"
    else:
        bucket = "near-size"
    return "%s|headers%+d|backedges%+d|protos%+d|%s>%s" % (
        bucket,
        after["headers"] - before["headers"],
        after["backedges"] - before["backedges"],
        proto_delta,
        ",".join("%s:%d" % item for item in sorted(before["loop_kinds"].items())) or "none",
        ",".join("%s:%d" % item for item in sorted(after["loop_kinds"].items())) or "none",
    )


def classify(before, after, proto_delta, local_missing, module_missing):
    if proto_delta < 0:
        return "prototype/closure loss plus control-flow drift"
    if after["blocks"] < before["blocks"] * 0.50 and after["headers"] < before["headers"]:
        return "large prototype-body collapse with lost loops"
    if (before["headers"] - after["headers"] == 1
            and before["backedges"] - after["backedges"] >= 1
            and local_missing == module_missing):
        return "one loop region and its reachable body lost"
    return "control-flow/access drift requiring region trace"


def counter_rows(counter):
    return [{"access": key, "count": count} for key, count in counter.most_common()]


def dossier(source_name, stage_root):
    source = resolve_source(source_name)
    decompiled_path, rebuilt_path = make_roundtrip(source, stage_root)
    original = accessdiff.normalised_protos(source)
    rebuilt = accessdiff.normalised_protos(rebuilt_path)
    original_total = accessdiff.totals(original)
    rebuilt_total = accessdiff.totals(rebuilt)
    missing = original_total - rebuilt_total
    extra = rebuilt_total - original_total
    module_missing = sum(missing.values())
    if not missing:
        raise RuntimeError("%s has no reachable access loss under the current binary" % source)

    ranked = sorted(((coverage_score(body, missing), sum(body.values()), i, header, body)
                     for i, (header, body) in enumerate(original)), reverse=True)
    candidates = [row for row in ranked if row[0] > 0]
    top = candidates[0]
    original_position, original_header, original_body = top[2], top[3], top[4]
    original_index = skeleton_proto_id(original_header)
    index_aligned = len(original) == len(rebuilt) and all(
        skeleton_shape(before[0]) == skeleton_shape(after[0])
        for before, after in zip(original, rebuilt))
    match = match_rebuilt(original_header, original_body, rebuilt,
                          original_position, index_aligned)
    rebuilt_position = match["reachable_position"]
    rebuilt_index = match["proto_index"]
    rebuilt_body = rebuilt[rebuilt_position][1]
    local_missing_counter = original_body - rebuilt_body
    local_extra_counter = rebuilt_body - original_body

    original_be = backedge_table(source)
    rebuilt_be = backedge_table(rebuilt_path)
    before = struct_summary(source, original_index, original_be)
    after = struct_summary(rebuilt_path, rebuilt_index, rebuilt_be)
    proto_delta = len(rebuilt) - len(original)
    local_missing = sum(local_missing_counter.values())

    return {
        "file": os.path.basename(source),
        "source_path": source,
        "diagnostic_source": decompiled_path,
        "rebuilt_path": rebuilt_path,
        "module": {
            "original_reachable_prototypes": len(original),
            "rebuilt_reachable_prototypes": len(rebuilt),
            "prototype_delta": proto_delta,
            "original_accesses": sum(original_total.values()),
            "rebuilt_accesses": sum(rebuilt_total.values()),
            "missing_accesses": module_missing,
            "extra_accesses": sum(extra.values()),
            "missing": counter_rows(missing),
            "extra": counter_rows(extra),
        },
        "candidate": {
            "original_index": original_index,
            "original_reachable_position": original_position,
            "original_header": original_header,
            "missing_coverage_upper_bound": top[0],
            "coverage_fraction": round(top[0] / module_missing, 6),
            "next_candidate_coverage": candidates[1][0] if len(candidates) > 1 else 0,
            "rebuilt_match": {k: v for k, v in match.items() if k != "body"},
            "local_missing_accesses": local_missing,
            "local_extra_accesses": sum(local_extra_counter.values()),
            "local_missing_equals_module_missing": local_missing_counter == missing,
            "local_missing": counter_rows(local_missing_counter),
            "local_extra": counter_rows(local_extra_counter),
        },
        "structure": {"original": before, "rebuilt": after},
        "classification": classify(before, after, proto_delta, local_missing, module_missing),
        "shape_signature": shape_signature(before, after, proto_delta),
    }


def markdown_report(cases):
    lines = ["# Reachable access-loss dossier", "",
             "Generated from the current production decompiler. Candidate prototype matching is",
             "access-multiset based and is marked ambiguous when its score or separation is weak.", "",
             "| File | Missing | Candidate | Match | Blocks | Headers | Back edges | Classification |",
             "|---|---:|---:|---:|---:|---:|---:|---|"]
    for case in cases:
        mod, cand = case["module"], case["candidate"]
        before, after = case["structure"]["original"], case["structure"]["rebuilt"]
        match = cand["rebuilt_match"]
        match_label = "%d (%.3f%s)" % (match["proto_index"], match["dice"],
                                        ", ambiguous" if match["ambiguous"] else "")
        lines.append("| `%s` | %d | p%d | %s | %d -> %d | %d -> %d | %d -> %d | %s |" % (
            case["file"], mod["missing_accesses"], cand["original_index"], match_label,
            before["blocks"], after["blocks"], before["headers"], after["headers"],
            before["backedges"], after["backedges"], case["classification"]))
    lines.extend(["", "## Structural signatures", ""])
    for case in cases:
        lines.extend(["- `%s`: `%s`" % (case["file"], case["shape_signature"])])
    lines.extend(["", "## Hypothesis result", ""])
    groups = collections.defaultdict(list)
    for case in cases:
        groups[case["shape_signature"]].append(case["file"])
    shared = [members for members in groups.values() if len(members) > 1]
    if shared:
        lines.append("**TRUE:** at least two modules share an exact normalized structural signature.")
        for members in shared:
            lines.append("- " + ", ".join("`%s`" % member for member in members))
    else:
        lines.append("**FALSE at this normalization:** the remaining modules do not share one exact")
        lines.append("prototype/loop-loss signature. They should not receive one speculative repair.")
    lines.extend(["", "The JSON companion contains complete missing-access counters and matching",
                  "confidence. This report is triage evidence, not proof of semantic equivalence.", ""])
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+")
    parser.add_argument("--stage-dir", default=os.path.join(ROOT, "stage", "access_dossiers"))
    parser.add_argument("--json-out")
    parser.add_argument("--markdown-out")
    args = parser.parse_args()
    try:
        cases = [dossier(name, os.path.abspath(args.stage_dir)) for name in args.files]
    except (OSError, RuntimeError) as error:
        sys.stderr.write("FATAL: %s\n" % error)
        return 2
    payload = {"tool": "cert/access_dossier.py", "cases": cases}
    rendered = json.dumps(payload, indent=2, sort_keys=True)
    if args.json_out:
        os.makedirs(os.path.dirname(os.path.abspath(args.json_out)), exist_ok=True)
        with open(args.json_out, "w", encoding="utf-8", newline="\n") as stream:
            stream.write(rendered + "\n")
    if args.markdown_out:
        os.makedirs(os.path.dirname(os.path.abspath(args.markdown_out)), exist_ok=True)
        with open(args.markdown_out, "w", encoding="utf-8", newline="\n") as stream:
            stream.write(markdown_report(cases))
    if not args.json_out:
        print(rendered)
    print("== ACCESS-LOSS DOSSIER ==")
    for case in cases:
        cand = case["candidate"]
        before, after = case["structure"]["original"], case["structure"]["rebuilt"]
        print("  %-58s missing=%-4d p%d->p%d blocks=%d->%d headers=%d->%d backedges=%d->%d" % (
            case["file"], case["module"]["missing_accesses"], cand["original_index"],
            cand["rebuilt_match"]["proto_index"], before["blocks"], after["blocks"],
            before["headers"], after["headers"], before["backedges"], after["backedges"]))
        print("    %s" % case["classification"])
        if cand["rebuilt_match"]["ambiguous"]:
            print("    WARNING: rebuilt prototype match is ambiguous; inspect before causal claims")
    return 0


if __name__ == "__main__":
    sys.exit(main())
