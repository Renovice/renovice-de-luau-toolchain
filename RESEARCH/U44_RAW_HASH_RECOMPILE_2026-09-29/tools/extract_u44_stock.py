#!/usr/bin/env python3
"""Read-only extraction of current stock DE Luau modules from the Steam Warframe cache.

Writes only into the output directory given on the command line (default: the toolchain's
gitignored work/ folder). The game install is opened read-only; nothing is written there.

Usage:
  python extract_u44_stock.py --list                      # print every .lua path in B.Font.toc
  python extract_u44_stock.py OUTDIR [substr ...]         # extract matching modules (all if none)

Output files use the corpus naming convention: /A/B/C.lua -> A_B_C.lua_B. A manifest.json records
path, size, SHA-256, and the TOC entry for every extracted module. Entries whose TOC path occurs
more than once are reported and the LAST entry is used (it is the one the client resolves last).
"""
import ctypes, hashlib, json, struct, sys
from pathlib import Path

CACHE_DIR = Path(r"C:\Program Files (x86)\Steam\steamapps\common\Warframe\Cache.Windows")
OODLE_DLL = Path(__file__).resolve().parents[6] / r"vendor\tools\misc-legacy\warframe-cache-tools\lib\oo2core_9.dll"
_oodle = None


def oodle_decompress(data, dec_size):
    if len(data) == dec_size:                       # block stored uncompressed
        return bytes(data)
    global _oodle
    if _oodle is None:
        lib = ctypes.CDLL(str(OODLE_DLL))
        lib.OodleLZ_Decompress.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_void_p,
            ctypes.c_size_t] + [ctypes.c_int] * 3 + [ctypes.c_size_t] * 6 + [ctypes.c_int]
        lib.OodleLZ_Decompress.restype = ctypes.c_int
        _oodle = lib
    src = ctypes.create_string_buffer(bytes(data), len(data))
    dst = ctypes.create_string_buffer(dec_size)
    n = _oodle.OodleLZ_Decompress(src, len(data), dst, dec_size, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3)
    if n <= 0:
        raise RuntimeError(f"Oodle decompress failed ret={n}")
    return dst.raw[:n]


def toc_decode(b):
    i, entries = 8, []
    while i + 96 <= len(b):
        co, _ts, comp, dec, _res, par = struct.unpack_from("<QQIIII", b, i)
        name = b[i + 32:i + 96].split(b"\x00", 1)[0].decode("utf-8", "replace")
        entries.append((co, comp, dec, par, name))
        i += 96
    return entries


def build_paths(entries):
    cache = {0: ""}
    def get(idx):
        if idx not in cache:
            _co, _comp, _dec, par, name = entries[idx - 1]
            cache[idx] = get(par) + "/" + name
        return cache[idx]
    return [get(i + 1) for i in range(len(entries))]


def extract(cache_file, co, comp, dec):
    with open(cache_file, "rb") as f:
        f.seek(co)
        raw = f.read(comp)
    if comp == dec:
        return raw[:dec]
    out, i = bytearray(), 0
    while len(out) < dec and i + 8 <= len(raw):
        bi = raw[i:i + 8]; i += 8
        if bi[0] != 0x80 or (bi[7] & 0x0F) != 0x01:
            raise RuntimeError(f"bad SHCC block header at {i - 8}")
        bcs = (int.from_bytes(bi[0:4], "big") >> 2) & 0xFFFFFF
        bds = (int.from_bytes(bi[4:8], "big") >> 5) & 0xFFFFFF
        out += oodle_decompress(raw[i:i + bcs], bds)
        i += bcs
    return bytes(out[:dec])


def main():
    toc = CACHE_DIR / "B.Font.toc"
    entries = toc_decode(toc.read_bytes())
    paths = build_paths(entries)
    lua = {}
    dup = []
    for k, p in enumerate(paths):
        if p.endswith(".lua") and entries[k][2] > 0:
            if p in lua: dup.append(p)
            lua[p] = k
    if sys.argv[1:2] == ["--list"]:
        for p in sorted(lua): print(p)
        print(f"# lua={len(lua)} duplicates={len(dup)}", file=sys.stderr)
        return
    out = Path(sys.argv[1]); out.mkdir(parents=True, exist_ok=True)
    subs = [s.lower() for s in sys.argv[2:]]
    manifest = {"toc": str(toc), "tocSha256": hashlib.sha256(toc.read_bytes()).hexdigest(),
                "duplicatesLastWins": sorted(set(dup)), "modules": []}
    for p in sorted(lua):
        if subs and not any(s in p.lower() for s in subs): continue
        co, comp, dec, _par, _name = entries[lua[p]]
        rec = {"path": p}
        try:
            body = extract(toc.with_suffix(".cache"), co, comp, dec)
        except Exception as e:
            rec["error"] = str(e); manifest["modules"].append(rec); continue
        name = p.strip("/").replace("/", "_") + "_B"
        (out / name).write_bytes(body)
        rec.update(file=name, size=len(body), sha256=hashlib.sha256(body).hexdigest(), head=body[:2].hex())
        manifest["modules"].append(rec)
    (out / "manifest.json").write_text(json.dumps(manifest, indent=1))
    bad = [m for m in manifest["modules"] if "error" in m or m.get("head") != "0903"]
    print(f"extracted={len(manifest['modules']) - len(bad)} failed_or_not_0903={len(bad)} out={out}")


if __name__ == "__main__":
    main()
