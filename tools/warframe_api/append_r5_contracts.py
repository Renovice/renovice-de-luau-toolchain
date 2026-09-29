#!/usr/bin/env python3
"""append_r5_contracts.py -- Part B: integrate Round 5 proven evidence into the
authoritative API registry (api/warframe/contracts.tsv), dimension by dimension.

Rules enforced here:
  * Only OBSERVED dimensions are written: explicit argument count (receiver
    excluded) and consumption-proven result behavior.
  * Unknown dimensions use schema-supported uncertainty tokens: unknown /
    opaque / unresolved wording inside notes; never invented native types.
  * Mock-only observations are NOT promoted: GetWeaponInSlot stays UNRESOLVED.
  * Evidence IDs referenced must already exist in evidence.tsv (the checker
    validates this), so this script also appends the two R5 evidence rows
    BEFORE any contract row references them.

Idempotent: re-running detects existing rows and makes no changes.
"""
import io
import sys

CONTRACTS = "contracts.tsv"
EVIDENCE = "evidence.tsv"

EVIDENCE_ROWS = [
    # evidence_id, kind, result, source, observed, limitations
    ("WF-R5-CALLSHAPE-CORPUS", "stock_bytecode", "TRUE",
     "RESEARCH/DE LUAU TRANSLATOR/NATIVE API AND LIVE CANDIDATE CENSUS/"
     "ROUND5_NATIVE_API_CONTRACTS/results/native_api_contracts.tsv",
     "Round-5 audit of rendered stock corpus sources: explicit-argument counts "
     "(receiver excluded) per method - GetCreator 0 args everywhere, "
     "GetUniquePowerIdentifier 0 args, GetAllAttachments exactly 1 filter arg "
     "at all 190 rendered sites (zero zero-arg sites), DistanceToPoint exactly "
     "1 point/ref arg (not two numbers), GetWeaponInSlot 1 slot arg.",
     "Proves observed call shapes and consumption classes only. It proves no "
     "native return type, nilability, or side effects."),
    ("WF-R5-DIFFERENTIAL-V3", "offline_differential", "TRUE",
     "RESEARCH/DE LUAU TRANSLATOR/NATIVE API AND LIVE CANDIDATE CENSUS/"
     "ROUND5_NATIVE_API_CONTRACTS/ROUND5_REPORT.md",
     "Mandatory A/B/C differential (original bytecode vs rebuilt vs re-render) "
     "over 16 input states x both exported fixture functions: pass=32, "
     "divergent=0, vacuous=0, errors=0, exit 0. Protects translator handling of "
     "these call shapes under a typed mock.",
     "Mocks alone do not define the real engine API; offline_fixture-grade "
     "translator evidence only."),
    ("WF-R5-NUMERIC-EVIDENCE", "stock_bytecode", "TRUE",
     "RESEARCH/DE LUAU TRANSLATOR/NATIVE API AND LIVE CANDIDATE CENSUS/"
     "ROUND5_NATIVE_API_CONTRACTS/results/native_api_contracts.tsv",
     "DistanceToPoint numeric-return evidence classes in stock rendered "
     "sources: NullStar orders two results with <=; literal-threshold "
     "comparisons (LastStand if c567v3 < c567v9; SonicEarthQuake c375v11 <= "
     "c375v0); results stored beside numeric constants (NovaDrop 2/100); one "
     "result feeds Vector(0,0,z). A boolean satisfies none of these.",
     "Establishes Luau-facing number only. Exact C++ scalar width/type "
     "remains unresolved from bytecode."),
]

# kind, owner, name, min_args, max_args, parameters, returns,
# callback_arity, callback_parameters, authority, lifetime,
# confidence, status, evidence, notes
CONTRACT_ROWS = [
    ("method", "EngineObject", "GetCreator", "0", "0", "-",
     "unknown_object_ref", "-", "-",
     "local_safe; result_borrows_engine_state",
     "No ownership transfer proven; orphan/nil case unseen",
     "STOCK_BYTECODE", "CONFIRMED",
     "WF-R5-CALLSHAPE-CORPUS;WF-R5-DIFFERENTIAL-V3",
     "ZERO explicit arguments at every rendered corpus site (receiver "
     "excluded). Object-like/reference behavior proven (member calls and "
     "field reads on the result). Exact native type unresolved; nil-orphan "
     "behavior unresolved."),
    ("method", "Ability", "GetUniquePowerIdentifier", "0", "0", "-",
     "opaque", "-", "-",
     "local_safe", "Unknown",
     "STOCK_BYTECODE", "CONFIRMED",
     "WF-R5-CALLSHAPE-CORPUS;WF-R5-DIFFERENTIAL-V3",
     "ZERO explicit arguments. Opaque pass-through value only: no corpus site "
     "lengthens, concatenates, or decomposes it. Earlier string/lengthable "
     "claims RETRACTED in R5 v3; exact native type unknown."),
    ("method", "AvatarOrEntity", "GetAllAttachments", "1", "1",
     "filter:opaque", "list_like_table", "-", "-",
     "local_safe", "Snapshot semantics unproven",
     "STOCK_BYTECODE", "CONFIRMED",
     "WF-R5-CALLSHAPE-CORPUS;WF-R5-DIFFERENTIAL-V3",
     "Exactly ONE explicit argument at ALL 190 rendered corpus sites (zero "
     "zero-arg sites). Iterable/list-like result proven by generic-for and "
     "ipairs consumption; element type UNRESOLVED; filter semantics "
     "UNRESOLVED; nil-versus-empty UNRESOLVED."),
    ("method", "AvatarOrEntity", "DistanceToPoint", "1", "1",
     "point_or_ref:opaque", "number_luau_facing", "-", "-",
     "local_safe", "No side effects observed",
     "STOCK_BYTECODE", "CONFIRMED",
     "WF-R5-CALLSHAPE-CORPUS;WF-R5-NUMERIC-EVIDENCE;WF-R5-DIFFERENTIAL-V3",
     "Exactly ONE explicit point/reference argument (not two numbers). "
     "Luau-facing NUMBER proven by ordered-comparison sites (NullStar <=), "
     "literal-threshold comparisons, and numeric-context feeds (Vector Z). "
     "Exact C++ scalar width/type unresolved."),
    ("method", "InventoryOrAvatar", "GetWeaponInSlot", "1", "1",
     "slot:identifier", "unknown", "-", "-",
     "borrowed_reference_hypothesis", "Miss/nil behavior UNPROVEN",
     "STOCK_BYTECODE", "UNRESOLVED",
     "WF-R5-CALLSHAPE-CORPUS",
     "Observed one-explicit-argument shape retained. Mock object-or-nil "
     "behavior is NOT promoted to native truth: return type and miss "
     "behavior remain unresolved pending independent stock/native/live "
     "evidence."),
]


def read_rows(path):
    text = io.open(path, encoding="utf-8", newline="").read()
    lines = text.splitlines()
    return text, lines


def main():
    etext, elines = read_rows(EVIDENCE)
    eids = {line.split("\t", 1)[0] for line in elines[1:] if line.strip()}
    new_evidence = [row for row in EVIDENCE_ROWS if row[0] not in eids]
    if new_evidence:
        with io.open(EVIDENCE, "a", encoding="utf-8", newline="") as fh:
            for row in new_evidence:
                assert len(row) == 6, row[0]
                fh.write("\t".join(row) + "\n")
        print(f"evidence.tsv: appended {len(new_evidence)} rows")

    ctext, clines = read_rows(CONTRACTS)
    # identity key: kind|owner|name
    existing = set()
    for line in clines[1:]:
        if line.strip():
            f = line.split("\t")
            existing.add((f[0], f[1], f[2]))
    added = 0
    with io.open(CONTRACTS, "a", encoding="utf-8", newline="") as fh:
        for row in CONTRACT_ROWS:
            ident = (row[0], row[1], row[2])
            if ident in existing:
                print(f"contracts.tsv: {ident} already present, skipped")
                continue
            assert len(row) == 15, ident
            fh.write("\t".join(row) + "\n")
            added += 1
    print(f"contracts.tsv: appended {added} rows")


if __name__ == "__main__":
    sys.exit(main())
