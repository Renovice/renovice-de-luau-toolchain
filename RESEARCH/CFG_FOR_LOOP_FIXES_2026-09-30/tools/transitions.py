"""Scratch: module/prototype/closure transitions between two u44_rawhash_roundtrip result files."""
import json, sys, collections
b = json.load(open(sys.argv[1])); a = json.load(open(sys.argv[2]))
keys = ["exeSha256", "modules", "decompile", "recompile", "deterministic", "cfgIdentityFirstPass",
        "constIdentityFirstPass", "constAndCfgIdentityFirstPass", "cfgProtosEqual", "cfgProtosCompared",
        "cfgModulesProtoAligned", "protoCountMismatch", "classSwapsFirstPass", "compilerClosed",
        "cfgIdentityClosed", "constIdentityClosed", "sourceFixedPoint", "bytecodeFixedPoint", "seconds"]
out = {"summary": {k: [b["summary"].get(k), a["summary"].get(k)] for k in keys}}
B = {r["module"]: r for r in b["results"]}; A = {r["module"]: r for r in a["results"]}
v = lambda r, k: (r.get(k) or {}).get("verdict")
tr = collections.Counter()
for key in ["cfgIdentity", "constIdentity", "closedConstIdentity", "closedCfgIdentity"]:
    for m in B:
        x, y = v(B[m], key), v(A.get(m, {}), key)
        if x != y: tr["%s %s->%s" % (key, x, y)] += 1
out["transitions"] = dict(tr)
lost, gain = [], []
for m in B:
    cb = B[m].get("cfgIdentity") or {}; ca = A[m].get("cfgIdentity") or {}
    if cb.get("cfgEqual") is None or ca.get("cfgEqual") is None: continue
    aligned = cb.get("protosStock") == cb.get("protosCandidate") and ca.get("protosStock") == ca.get("protosCandidate")
    if ca["cfgEqual"] < cb["cfgEqual"]: lost.append([m, cb["cfgEqual"], ca["cfgEqual"], aligned])
    if ca["cfgEqual"] > cb["cfgEqual"]: gain.append(m)
out["protoGainModules"] = len(gain); out["protoLossModules"] = lost
cl = {"openToClosed": [], "closedToOpen": []}
for m in B:
    x, y = B[m].get("closedAtPass"), A[m].get("closedAtPass")
    if x is None and y is not None: cl["openToClosed"].append(m)
    if x is not None and y is None: cl["closedToOpen"].append(m)
out["closure"] = cl
json.dump(out, open(sys.argv[3], "w"), indent=1)
for k, (x, y) in out["summary"].items(): print(k, x, "->", y)
print(out["transitions"]); print("proto gain modules", len(gain), "loss", lost)
print("closure open->closed", len(cl["openToClosed"]), "closed->open", len(cl["closedToOpen"]))
print(cl["closedToOpen"])
