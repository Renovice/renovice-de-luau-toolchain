#!/usr/bin/env python3
"""Two-cycle and ten-cycle DE Luau idempotence certification.

For cycle N:
    source[N] = decompile(DE[N-1])
    DE[N]     = recompile(source[N])

The strict fixed-point contract is DE[2] == DE[1]. Ten-cycle specimens must then remain equal to
DE[1] through DE[10]. Exact source, bytecode, proto count, maxstack vector, and opcode histogram are
recorded independently so equal byte counts cannot conceal structural drift.

The default two-cycle sample is the first 90 corpus files in deterministic name order, matching the
historical #103 measurement. Use --measure while investigating a known failure; without it, any
failure exits nonzero and can be used as a release gate.
"""
import argparse
import concurrent.futures
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

from workspace_paths import corpus_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEC = os.path.join(ROOT, "bin", "derecomp.exe")
CACHE = corpus_cache(ROOT)
ENV = dict(os.environ, RENOVICE_NATIVE_GLOBALS="1",
           RENOVICE_NATIVE="JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,JUMPBACK,AND,OR,ANDK,ORK,SUBK,FORGPREP")
ENV_KEYS = (
    "RENOVICE_NATIVE",
    "RENOVICE_NATIVE_GLOBALS",
    "RENOVICE_LIVERANGE",
    "RENOVICE_NO_CALLCOALESCE",
    "RENOVICE_NO_FORCOALESCE",
    "RENOVICE_NO_PROLOGUE_NIL",
)

DEFAULT_TEN = (
    "EE_Interface_Utilities.lua_B",
    "EE_Types_ScriptCommands_JSON.lua_B",
    "Lotus_Docs_Loadouts.lua_B",
    "Lotus_Interface_BindingsUtil.lua_B",
    "Lotus_Upgrades_Stickers_Scripts_SporePrimer.lua_B",
)


def sha256(data):
    return hashlib.sha256(data).hexdigest().upper()


def run(args, timeout=600):
    return subprocess.run(args, cwd=ROOT, env=ENV, capture_output=True, text=True,
                          encoding="utf-8", errors="replace", timeout=timeout)


def structural_summary(path):
    proc = run([DEC, "de-summary", path])
    if proc.returncode != 0:
        raise RuntimeError("de-summary failed (%d): %s" %
                           (proc.returncode, (proc.stderr or proc.stdout).strip()))
    lines = proc.stdout.splitlines()
    if not lines:
        raise RuntimeError("de-summary returned empty output")
    head = dict((key, int(value)) for key, value in re.findall(r"(\w+)=(-?\d+)", lines[0]))
    if head.get("dirty_walk") != 0:
        raise RuntimeError("de-summary reported dirty walk")
    stacks = []
    if len(lines) >= 2 and lines[1].startswith("maxstacks="):
        raw = lines[1].partition("=")[2]
        stacks = [int(value) for value in raw.split(",") if value]
    opcodes = {}
    for line in lines[2:]:
        match = re.fullmatch(r"op=(0x[0-9a-f]{2}) count=(\d+)", line)
        if match:
            opcodes[match.group(1)] = int(match.group(2))
    return {
        "bytes": head["bytes"],
        "code_bytes": head["code_bytes"],
        "instructions": head["instructions"],
        "maxstack_max": head["maxstack_max"],
        "maxstack_sum": head["maxstack_sum"],
        "maxstacks": stacks,
        "opcodes": opcodes,
        "protos": head["protos"],
    }


def opcode_delta(before, after):
    keys = sorted(set(before) | set(after))
    return {key: after.get(key, 0) - before.get(key, 0)
            for key in keys if after.get(key, 0) != before.get(key, 0)}


def cycle_file(path, cycles, artifact_dir=None):
    name = os.path.basename(path)
    result = {"cycles_requested": cycles, "file": name, "passed": False}
    try:
        with tempfile.TemporaryDirectory(prefix="renovice-idempotence-") as temp:
            previous = path
            records = []
            for index in range(1, cycles + 1):
                source_path = os.path.join(temp, "%02d.luau" % index)
                output_path = os.path.join(temp, "%02d.lua_B" % index)
                decompile = run([DEC, "decompile-mod", previous])
                if decompile.returncode != 0 or not decompile.stdout:
                    raise RuntimeError("cycle %d decompile failed (%d): %s" %
                                       (index, decompile.returncode,
                                        (decompile.stderr or "empty source").strip()))
                source_bytes = decompile.stdout.encode("utf-8")
                with open(source_path, "wb") as stream:
                    stream.write(source_bytes)
                recompile = run([DEC, "recompile", source_path, output_path])
                if recompile.returncode != 0 or not os.path.isfile(output_path):
                    raise RuntimeError("cycle %d recompile failed (%d): %s" %
                                       (index, recompile.returncode,
                                        (recompile.stderr or recompile.stdout).strip()))
                with open(output_path, "rb") as stream:
                    bytecode = stream.read()
                summary = structural_summary(output_path)
                summary.update({
                    "bytecode_sha256": sha256(bytecode),
                    "cycle": index,
                    "source_bytes": len(source_bytes),
                    "source_sha256": sha256(source_bytes),
                })
                records.append(summary)
                if artifact_dir:
                    os.makedirs(artifact_dir, exist_ok=True)
                    shutil.copyfile(source_path, os.path.join(artifact_dir, "%02d.luau" % index))
                    shutil.copyfile(output_path, os.path.join(artifact_dir, "%02d.lua_B" % index))
                previous = output_path

            first = records[0]
            second = records[1]
            byte_fixed = second["bytecode_sha256"] == first["bytecode_sha256"]
            source_fixed = second["source_sha256"] == first["source_sha256"]
            structural_fixed = all(second[key] == first[key] for key in (
                "bytes", "protos", "maxstacks", "opcodes"))
            all_byte_fixed = all(record["bytecode_sha256"] == first["bytecode_sha256"]
                                 for record in records[1:])
            all_source_fixed = all(record["source_sha256"] == first["source_sha256"]
                                   for record in records[1:])
            result.update({
                "bytecode_fixed_at_cycle_1": byte_fixed,
                "cycles": records,
                "cycle_1_to_2": {
                    "byte_delta": second["bytes"] - first["bytes"],
                    "instruction_delta": second["instructions"] - first["instructions"],
                    "maxstack_max_delta": second["maxstack_max"] - first["maxstack_max"],
                    "maxstack_sum_delta": second["maxstack_sum"] - first["maxstack_sum"],
                    "opcode_delta": opcode_delta(first["opcodes"], second["opcodes"]),
                    "proto_delta": second["protos"] - first["protos"],
                    "source_byte_delta": second["source_bytes"] - first["source_bytes"],
                },
                "passed": byte_fixed and source_fixed and structural_fixed
                          and all_byte_fixed and all_source_fixed,
                "source_fixed_at_cycle_1": source_fixed,
                "stable_through_requested_cycle": all_byte_fixed and all_source_fixed,
                "structural_fixed_at_cycle_1": structural_fixed,
            })
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        result["error"] = str(error)
    return result


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


def run_group(paths, cycles, workers, artifact_root=None):
    ordered = sorted(paths, key=lambda path: os.path.basename(path).lower())
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
        futures = [pool.submit(cycle_file, path, cycles,
                               os.path.join(artifact_root, os.path.basename(path))
                               if artifact_root else None) for path in ordered]
        results = [future.result() for future in concurrent.futures.as_completed(futures)]
    return sorted(results, key=lambda item: item["file"].lower())


def print_group(label, results):
    passed = sum(1 for item in results if item["passed"])
    errors = [item for item in results if "error" in item]
    print("%s files=%d passed=%d failed=%d errors=%d" %
          (label, len(results), passed, len(results) - passed, len(errors)))
    for item in results:
        if item["passed"]:
            continue
        if "error" in item:
            print("  ERROR %-55s %s" % (item["file"], item["error"]))
            continue
        delta = item["cycle_1_to_2"]
        ops = ",".join("%s:%+d" % pair for pair in sorted(delta["opcode_delta"].items())) or "none"
        print("  DRIFT %-55s bytes=%+d stack_sum=%+d stack_max=%+d protos=%+d ops=%s" %
              (item["file"], delta["byte_delta"], delta["maxstack_sum_delta"],
               delta["maxstack_max_delta"], delta["proto_delta"], ops))


def summarize_group(results):
    opcode_totals = {}
    for item in results:
        if "cycle_1_to_2" not in item:
            continue
        for opcode, delta in item["cycle_1_to_2"]["opcode_delta"].items():
            opcode_totals[opcode] = opcode_totals.get(opcode, 0) + delta
    return {
        "byte_delta_total": sum(item.get("cycle_1_to_2", {}).get("byte_delta", 0)
                                for item in results),
        "errors": sum(1 for item in results if "error" in item),
        "files": len(results),
        "maxstack_sum_delta_total": sum(
            item.get("cycle_1_to_2", {}).get("maxstack_sum_delta", 0) for item in results),
        "opcode_delta_total": {key: value for key, value in sorted(opcode_totals.items()) if value},
        "passed": sum(1 for item in results if item["passed"]),
        "proto_delta_total": sum(item.get("cycle_1_to_2", {}).get("proto_delta", 0)
                                 for item in results),
    }


def main():
    parser = argparse.ArgumentParser(description="Certify DE Luau round-trip idempotence.")
    parser.add_argument("n2", nargs="?", type=int, default=90,
                        help="deterministic corpus size for the two-cycle gate (default: 90)")
    parser.add_argument("--ten-file", action="append", default=[],
                        help="ten-cycle corpus filename; repeat to override the default specimen set")
    parser.add_argument("--ten-all", action="store_true",
                        help="run the ten-cycle gate across the same deterministic corpus as n2")
    parser.add_argument("--long-cycles", type=int, default=10,
                        help="cycle depth for the long gate (default: 10, minimum: 2)")
    parser.add_argument("--workers", type=int, default=min(8, os.cpu_count() or 1))
    parser.add_argument("--json-out", help="write deterministic machine-readable results")
    parser.add_argument("--artifact-dir",
                        help="copy each generated source/DE cycle into this research directory")
    parser.add_argument("--measure", action="store_true",
                        help="report known drift but exit zero unless setup/execution fails")
    args = parser.parse_args()

    if args.long_cycles < 2:
        print("FATAL: --long-cycles must be at least 2", file=sys.stderr)
        return 2

    if not os.path.isfile(DEC):
        print("FATAL: missing binary: %s" % DEC, file=sys.stderr)
        return 2
    if not os.path.isdir(CACHE):
        print("FATAL: missing corpus: %s" % CACHE, file=sys.stderr)
        return 2
    corpus = sorted((os.path.join(CACHE, name) for name in os.listdir(CACHE)
                     if name.endswith(".lua_B")), key=lambda path: os.path.basename(path).lower())
    if len(corpus) < args.n2:
        print("FATAL: requested %d files but corpus has %d" % (args.n2, len(corpus)), file=sys.stderr)
        return 2
    if args.ten_all and args.ten_file:
        print("FATAL: --ten-all and --ten-file are mutually exclusive", file=sys.stderr)
        return 2
    ten_names = (tuple(os.path.basename(path) for path in corpus[:args.n2])
                 if args.ten_all else tuple(args.ten_file) if args.ten_file else DEFAULT_TEN)
    ten_paths = [os.path.join(CACHE, name) for name in ten_names]
    missing = [path for path in ten_paths if not os.path.isfile(path)]
    if missing:
        print("FATAL: missing ten-cycle specimens: %s" % ", ".join(missing), file=sys.stderr)
        return 2

    with open(DEC, "rb") as stream:
        binary_hash = sha256(stream.read())
    print("== IDEMPOTENCE CERT == corpus=%s binary=%s" % (CACHE, binary_hash))
    artifact_root = os.path.abspath(args.artifact_dir) if args.artifact_dir else None
    two = run_group(corpus[:args.n2], 2, args.workers,
                    os.path.join(artifact_root, "cycle2") if artifact_root else None)
    ten = run_group(ten_paths, args.long_cycles, min(args.workers, len(ten_paths)),
                    os.path.join(artifact_root, "cycle10") if artifact_root else None)
    print_group("CYCLE2", two)
    print_group("CYCLE%d" % args.long_cycles, ten)

    payload = {
        "binary_sha256": binary_hash,
        "corpus": CACHE,
        "cycle2": two,
        "cycle2_summary": summarize_group(two),
        "cycle10": ten,
        "cycle10_summary": summarize_group(ten),
        "long_cycle_depth": args.long_cycles,
        "environment": {key: ENV.get(key) for key in ENV_KEYS},
        "passed": all(item["passed"] for item in two + ten),
        "schema_version": 1,
    }
    if args.json_out:
        write_json(args.json_out, payload)
        print("machine-readable results: %s" % os.path.abspath(args.json_out))
    execution_error = any("error" in item for item in two + ten)
    if execution_error:
        return 2
    return 0 if (payload["passed"] or args.measure) else 1


if __name__ == "__main__":
    raise SystemExit(main())
