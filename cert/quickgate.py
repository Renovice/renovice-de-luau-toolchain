#!/usr/bin/env python3
"""Quick iteration gate: run a candidate derecomp on the modules a fix targets plus a fixed tripwire sample, and
compare every module against a full-corpus baseline run. Minutes instead of a ~22 min full run.

  python cert/quickgate.py STOCK [--class SUBSTR ...] [--targets FILE] [--exe EXE] [--jobs N]
  python cert/quickgate.py STOCK --promote RESULTS_JSON      # make a finished full run the new baseline

Selection
  targets   : baseline CFG-ID failures (all of them, or only those whose cfgIdentity class contains a --class
              substring), plus any module names in --targets FILE.
  tripwires : baseline modules passing every gate, sampled deterministically (every --tripwire-stride-th by name)
              plus work/me/canary.txt when present. Same sample every run, so results are comparable.

Verdict (per module, against the baseline row)
  BROKEN : a gate that passed in the baseline now fails (decompile, recompile, deterministic, CONST-ID, CFG-ID,
           dataflow). Exit status 1 when any module is BROKEN.
  FIXED  : CFG-ID (and dataflow, when the baseline ran it) fail -> pass.

This is the iteration loop only. It runs first pass (no fixed-point passes). A fix is still proven by one full run
(cert/u44_rawhash_roundtrip.py ... --dataflow) before merge; promote that run as the next baseline.
"""
import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STATE = ROOT / "work" / "quickgate"
BASELINE_PTR = STATE / "BASELINE"


def verdict(row, key):
    v = row.get(key)
    if isinstance(v, dict):
        return v.get("verdict") == "PASS"
    return bool(v)


GATES = [
    ("decompile", lambda r: bool(r.get("decompile"))),
    ("recompile", lambda r: bool(r.get("recompile"))),
    ("deterministic", lambda r: bool(r.get("deterministic"))),
    ("CONST-ID", lambda r: verdict(r, "constIdentity")),
    ("CFG-ID", lambda r: verdict(r, "cfgIdentity")),
    ("dataflow", lambda r: verdict(r, "dataflowIdentity")),
]
CLOSED_GATES = [
    ("closed CONST-ID", lambda r: verdict(r, "closedConstIdentity") if "closedConstIdentity" in r else verdict(r, "constIdentity")),
    ("closed CFG-ID", lambda r: verdict(r, "closedCfgIdentity") if "closedCfgIdentity" in r else verdict(r, "cfgIdentity")),
]


def load_results(path):
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    return data, {r["module"]: r for r in data["results"]}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("stock")
    ap.add_argument("--baseline", default=None, help="full-run results-u44.json (default: work/quickgate/BASELINE)")
    ap.add_argument("--promote", default=None, help="record this full-run results json as the baseline and exit")
    ap.add_argument("--class", dest="classes", action="append", default=[],
                    help="only baseline CFG failures whose class label contains this substring (repeatable)")
    ap.add_argument("--targets", default=None, help="extra module names, one per line")
    ap.add_argument("--no-targets", action="store_true", help="tripwires only")
    ap.add_argument("--all", action="store_true",
                    help="every module of the baseline (routine full check, first pass unless --closed)")
    ap.add_argument("--tripwire-stride", type=int, default=12)
    ap.add_argument("--exe", default=str(ROOT / "bin" / "derecomp.exe"))
    ap.add_argument("--jobs", type=int, default=None)
    ap.add_argument("--out", default=str(STATE / "last"))
    ap.add_argument("--closed", action="store_true", help="also run the fixed-point passes and gate closed CONST/CFG-ID")
    args = ap.parse_args()

    STATE.mkdir(parents=True, exist_ok=True)
    if args.promote:
        data, rows = load_results(args.promote)
        if data.get("firstPassOnly") or len(rows) < 5000:
            sys.exit(f"refusing: {args.promote} is not a full-corpus run ({len(rows)} modules, "
                     f"firstPassOnly={data.get('firstPassOnly')})")
        BASELINE_PTR.write_text(str(Path(args.promote).resolve()) + "\n", encoding="utf-8")
        print(f"baseline = {args.promote} ({len(rows)} modules)")
        return 0

    base_path = args.baseline or (BASELINE_PTR.read_text(encoding="utf-8").strip() if BASELINE_PTR.exists() else None)
    if not base_path:
        sys.exit("no baseline: pass --baseline or run --promote on a full run first")
    base_data, base = load_results(base_path)
    has_df = any("dataflowIdentity" in r for r in base.values())

    targets = set()
    if not args.no_targets:
        for m, r in base.items():
            if verdict(r, "cfgIdentity"):
                continue
            labels = list((r.get("cfgIdentity") or {}).get("classes") or {})
            if not args.classes or any(c in l for c in args.classes for l in labels):
                targets.add(m)
        if args.targets:
            targets |= {l.strip() for l in Path(args.targets).read_text(encoding="utf-8").splitlines() if l.strip()}

    clean = sorted(m for m, r in base.items() if all(g(r) for name, g in GATES if name != "dataflow" or has_df))
    tripwires = set(clean[:: max(1, args.tripwire_stride)])
    canary = ROOT / "work" / "me" / "canary.txt"
    if canary.exists():
        tripwires |= {l.strip() for l in canary.read_text(encoding="utf-8").splitlines() if l.strip() in base}
    tripwires -= targets

    if args.all:
        tripwires = set(base) - targets
    selection = sorted(targets | tripwires)
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    lst = out / "selection.txt"
    lst.write_text("\n".join(selection) + "\n", encoding="utf-8")
    print(f"baseline {base_path}\n  targets {len(targets)}  tripwires {len(tripwires)}  total {len(selection)}",
          flush=True)

    cmd = [sys.executable, str(ROOT / "cert" / "u44_rawhash_roundtrip.py"), args.stock, str(out / "run"),
           "--list", str(lst), "--exe", args.exe] + ([] if args.closed else ["--first-pass-only"])
    if has_df:
        cmd.append("--dataflow")
    if args.jobs:
        cmd += ["--jobs", str(args.jobs)]
    log = out / "run.log"
    with open(log, "w", encoding="utf-8") as fh:
        subprocess.run(cmd, stdout=fh, stderr=subprocess.STDOUT, cwd=ROOT)
    res = out / "run" / "results-u44.json"
    if not res.exists():
        sys.exit(f"roundtrip produced no results; see {log}")
    new_data, new = load_results(res)

    broken, fixed, missing = [], [], sorted(set(selection) - set(new))
    for m in selection:
        if m not in new:
            continue
        b, n = base[m], new[m]
        gates = GATES + (CLOSED_GATES if args.closed else [])
        lost = [name for name, g in gates if (name != "dataflow" or has_df) and g(b) and not g(n)]
        if lost:
            broken.append((m, lost, list((n.get("cfgIdentity") or {}).get("classes") or {})[:3]))
        if not verdict(b, "cfgIdentity") and verdict(n, "cfgIdentity") and (not has_df or verdict(n, "dataflowIdentity")):
            fixed.append(m)

    still = [m for m in targets if m in new and not verdict(new[m], "cfgIdentity")]
    report = {"baseline": base_path, "exe": args.exe, "exeSha256": new_data.get("exeSha256"),
              "targets": len(targets), "tripwires": len(tripwires), "fixed": fixed,
              "broken": [{"module": m, "lost": l, "classes": c} for m, l, c in broken],
              "stillFailing": len(still), "missing": missing}
    (out / "report.json").write_text(json.dumps(report, indent=1), encoding="utf-8")

    print(f"FIXED  {len(fixed)}   (CFG-ID{' + dataflow' if has_df else ''} fail -> pass)")
    print(f"BROKEN {len(broken)}   (any gate pass -> fail)")
    for m, l, c in broken:
        print(f"  {m}: lost {', '.join(l)}  {'; '.join(c)}")
    print(f"still failing targets {len(still)} / {len(targets)}")
    if missing:
        print(f"MISSING rows {len(missing)} (crash or timeout): {', '.join(missing[:10])}")
    print(f"report {out / 'report.json'}")
    return 1 if broken or missing else 0


if __name__ == "__main__":
    sys.exit(main())
