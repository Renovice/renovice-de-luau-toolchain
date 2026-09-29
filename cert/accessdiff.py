#!/usr/bin/env python3
"""accessdiff.py <file.lua_B> - localise named-access loss across one round-trip.

Uses the same live semantic skeleton and fidelity environment as align.py/allcats.py, but prints the
complete missing/extra access counters and the original/recompiled proto owners.  This is diagnostic:
it does not weaken or replace any gate.
"""
import collections
import os
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import align


def normalised_protos(path):
    protos = align.skeleton(path, reachable=True)
    if protos is None:
        raise RuntimeError("skeleton failed: %s" % path)
    result = []
    for header, lines in protos:
        result.append((header, collections.Counter(align.norm(lines))))
    return result


def totals(protos):
    out = collections.Counter()
    for _, body in protos:
        out.update(body)
    return out


def owners(protos, access):
    return [(header, body[access]) for header, body in protos if body[access]]


def print_proto_differences(original, rebuilt):
    """Print index-local counters when reachable prototype headers remain index-compatible.

    The module totals prove that an access vanished; they do not identify the function that lost it
    because the same access often occurs in dozens of prototypes. Matching counts and headers are a
    necessary but not sufficient lineage check: same-signature sibling closures can reorder. Fail
    closed on an obvious mismatch, and label the surviving output diagnostic rather than proof.
    """
    if len(original) != len(rebuilt):
        print("-- PER-PROTO --")
        print("  unavailable: reachable prototype counts differ (%d vs %d)" %
              (len(original), len(rebuilt)))
        return
    if any(a[0] != b[0] for a, b in zip(original, rebuilt)):
        print("-- PER-PROTO --")
        print("  unavailable: reachable prototype headers are not index-aligned")
        return

    print("-- PER-INDEX DIAGNOSTIC (not lineage proof; same-signature closures may reorder) --")
    changed = False
    for index, ((header, before), (_, after)) in enumerate(zip(original, rebuilt)):
        missing, extra = before - after, after - before
        if not missing and not extra:
            continue
        changed = True
        print("  proto[%d] %s missing=%d extra=%d" %
              (index, header, sum(missing.values()), sum(extra.values())))
        for label, differences in (("missing", missing), ("extra", extra)):
            for access, count in differences.most_common():
                print("      %s x%-3d %s" % (label, count, access.replace("\t", " ")))
    if not changed:
        print("  (none)")


def main():
    if len(sys.argv) not in (2, 4) or (len(sys.argv) == 4 and sys.argv[2] != "--keep-dir"):
        sys.stderr.write("usage: python cert/accessdiff.py <file.lua_B> "
                         "[--keep-dir <diagnostic-dir>]\n")
        return 2
    source = sys.argv[1]
    if not os.path.isabs(source):
        source = os.path.join(align.CACHE, source)
    source = os.path.abspath(source)

    original = normalised_protos(source)
    decompiled = align.run([align.DEC, align.DECOMPILE_MODE, source])
    if decompiled.returncode != 0:
        sys.stderr.write(decompiled.stderr)
        return 1

    keep_dir = os.path.abspath(sys.argv[3]) if len(sys.argv) == 4 else None
    if keep_dir:
        os.makedirs(keep_dir, exist_ok=True)
        stem = os.path.splitext(os.path.basename(source))[0]
        source_path = os.path.join(keep_dir, stem + ".decompiled.luau")
        output_path = os.path.join(keep_dir, stem + ".recompiled.lua_B")
    else:
        fd, source_path = tempfile.mkstemp(suffix=".luau")
        os.close(fd)
        output_path = source_path + ".lua_B"
    try:
        with open(source_path, "w", encoding="utf-8", newline="\n") as stream:
            stream.write(decompiled.stdout)
        compiled = align.run([align.DEC, "recompile", source_path, output_path])
        if compiled.returncode != 0 or not os.path.exists(output_path):
            sys.stderr.write(compiled.stderr)
            return 1
        rebuilt = normalised_protos(output_path)
    finally:
        if not keep_dir:
            for path in (source_path, output_path):
                try:
                    os.remove(path)
                except OSError:
                    pass

    original_total, rebuilt_total = totals(original), totals(rebuilt)
    missing, extra = original_total - rebuilt_total, rebuilt_total - original_total
    print("== %s ==" % os.path.basename(source))
    print("original protos=%d accesses=%d; rebuilt protos=%d accesses=%d" %
          (len(original), sum(original_total.values()), len(rebuilt), sum(rebuilt_total.values())))
    print("missing=%d extra=%d" % (sum(missing.values()), sum(extra.values())))
    if keep_dir:
        print("diagnostic source=%s" % source_path)
        print("diagnostic bytecode=%s" % output_path)
    for label, differences, protos in (("MISSING", missing, original), ("EXTRA", extra, rebuilt)):
        print("-- %s --" % label)
        if not differences:
            print("  (none)")
        for access, count in differences.most_common():
            print("  x%-3d %s" % (count, access.replace("\t", " ")))
            for header, owner_count in owners(protos, access):
                print("        owner x%d %s" % (owner_count, header))
    print_proto_differences(original, rebuilt)
    return 0 if not missing else 1


if __name__ == "__main__":
    sys.exit(main())
