// shared_protos.h - one prototype referenced by several closure sites (2026-10-09, agent protos2).
//
// DE's compiler runs at -O2 and inlines small local functions. When the inlined function contains a
// function literal, every inlined copy of the body reuses THE SAME prototype: one stock prototype,
// several closure sites in different functions (44.1.1: 31 prototypes in 29 modules). Luau source
// cannot spell that without inlining, and re-inlining is not reproducible from our emission: the
// inliner decides by an AST cost model, and the register-faithful emission costs more than the
// original source (measured: 11 of the 31 home functions are rejected as "too expensive").
//
// The decompiler therefore writes one literal per closure site, as before, and marks each literal of
// a shared prototype with a trailing comment `-- RENOVICE_SHARED_PROTO <stock index>` on its
// `function(` line (src/m6e_cmd.h, inline_closures). This header is the recompiler half: literals
// carrying the same marker id are located by their `linedefined`, and copies that compiled to the
// SAME prototype (header, code, constants, children - recursively; line/debug info excluded) are merged
// into the first copy. Only verified-identical prototypes are merged, so a mismatching or edited copy
// stays a separate prototype; merging identical prototypes never changes behaviour (each closure
// constant is still its own constant slot, see the refusal below).
// Result: the rebuilt prototype table has stock's count, order and closure references.
//
// Refused (module left unmerged, reported): a merge that would leave one prototype holding two
// closure constants for the same merged prototype (stock would hold one constant, i.e. one shared
// closure object; reproducing that needs constant renumbering, which this pass does not do).
// RENOVICE_NO_SHARED_PROTO_MERGE disables the recompiler half.
#pragma once
#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>
#include "luau_bc.h"

namespace sp {

inline const char* shared_proto_marker() { return "-- RENOVICE_SHARED_PROTO "; }

// linedefined (1-based source line) -> marker id, for lines holding a function literal header.
inline std::map<uint32_t, int>& shared_proto_lines() {
    static std::map<uint32_t, int> lines;
    return lines;
}

inline std::map<uint32_t, int> parse_shared_proto_markers(const std::string& source) {
    std::map<uint32_t, int> out;
    const std::string marker = shared_proto_marker();
    uint32_t line = 1;
    size_t start = 0;
    while (start <= source.size()) {
        size_t end = source.find('\n', start);
        if (end == std::string::npos) end = source.size();
        std::string text = source.substr(start, end - start);
        if (!text.empty() && text.back() == '\r') text.pop_back();
        const size_t at = text.rfind(marker);
        const size_t fn = text.find("function(");
        if (at != std::string::npos && fn != std::string::npos && fn < at) {
            const std::string id = text.substr(at + marker.size());
            bool digits = !id.empty() && id.size() < 9;
            for (char c : id) if (c < '0' || c > '9') digits = false;
            if (digits) out[line] = std::atoi(id.c_str());
        }
        if (end == source.size()) break;
        start = end + 1;
        ++line;
    }
    return out;
}

struct MergeReport {
    int groups = 0;           // marker groups with >= 2 compiled members
    int merged = 0;           // prototypes removed (copies, including their subtrees)
    int unequal = 0;          // marked copies left separate because they did not compile identically
    std::string refused;      // non-empty: the whole merge was refused, module unchanged
};

inline bool same_const_payload(const luau::Const& a, const luau::Const& b) {
    if (a.tag != b.tag) return false;
    switch (a.tag) {
    case luau::C_NIL: return true;
    case luau::C_BOOL: return a.bval == b.bval;
    case luau::C_NUM: return std::memcmp(&a.num, &b.num, sizeof a.num) == 0;
    case luau::C_STR: case luau::C_IMPORT: return a.u == b.u;
    case luau::C_TABLE: return a.keys == b.keys;
    case luau::C_VEC: return std::memcmp(a.vec, b.vec, sizeof a.vec) == 0;
    case luau::C_TABLEK: return a.items == b.items;
    case luau::C_INT: return a.inum == b.inum;
    default: return false;    // C_CLOSURE handled by the caller; unknown tags never merge
    }
}

// Is prototype b (a copy) the same compiled prototype as a? Children and closure constants are
// compared recursively and their correspondence is recorded in `map` (copy -> canonical).
inline bool same_proto(const luau::Module& m, uint32_t a, uint32_t b, const std::vector<uint32_t>& rep,
                       std::map<uint32_t, uint32_t>& map) {
    if (a >= m.protos.size() || b >= m.protos.size()) return false;
    if (rep[a] == rep[b]) return true;
    const auto known = map.find(b);
    if (known != map.end()) return known->second == a;
    const luau::Proto& x = m.protos[a];
    const luau::Proto& y = m.protos[b];
    if (x.mx != y.mx || x.npar != y.npar || x.nups != y.nups || x.isvararg != y.isvararg
        || x.flags != y.flags || x.insns.size() != y.insns.size() || x.consts.size() != y.consts.size()
        || x.kids.size() != y.kids.size())
        return false;
    for (size_t i = 0; i < x.insns.size(); ++i)
        if (x.insns[i].word != y.insns[i].word || x.insns[i].has_aux != y.insns[i].has_aux
            || x.insns[i].aux != y.insns[i].aux)
            return false;
    map[b] = a;   // tentative; a failure below discards the whole map
    for (size_t i = 0; i < x.kids.size(); ++i)
        if (!same_proto(m, x.kids[i], y.kids[i], rep, map)) return false;
    for (size_t i = 0; i < x.consts.size(); ++i) {
        const luau::Const& p = x.consts[i];
        const luau::Const& q = y.consts[i];
        if (p.tag == luau::C_CLOSURE || q.tag == luau::C_CLOSURE) {
            if (p.tag != q.tag || !same_proto(m, p.u, q.u, rep, map)) return false;
        } else if (!same_const_payload(p, q)) {
            return false;
        }
    }
    return true;
}

inline MergeReport merge_shared_protos(luau::Module& m, const std::map<uint32_t, int>& line_group) {
    MergeReport report;
    if (line_group.empty() || std::getenv("RENOVICE_NO_SHARED_PROTO_MERGE")) return report;
    const uint32_t count = (uint32_t)m.protos.size();
    std::map<int, std::vector<uint32_t>> groups;
    for (uint32_t index = 0; index < count; ++index) {
        const auto found = line_group.find(m.protos[index].linedefined);
        if (found != line_group.end()) groups[found->second].push_back(index);
    }
    std::vector<uint32_t> rep(count);
    for (uint32_t index = 0; index < count; ++index) rep[index] = index;
    // Children are numbered before their parents, so merging groups in ascending order of their
    // first member settles every nested shared prototype before an enclosing one is compared.
    std::vector<std::vector<uint32_t>> ordered;
    for (auto& entry : groups) if (entry.second.size() >= 2) ordered.push_back(entry.second);
    std::sort(ordered.begin(), ordered.end());
    for (const std::vector<uint32_t>& members : ordered) {
        ++report.groups;
        const uint32_t canonical = members.front();
        for (size_t k = 1; k < members.size(); ++k) {
            std::map<uint32_t, uint32_t> map;
            if (!same_proto(m, canonical, members[k], rep, map)) { ++report.unequal; continue; }
            for (const auto& pair : map) rep[pair.first] = rep[pair.second];
        }
    }
    for (uint32_t index = 0; index < count; ++index) {
        uint32_t root = index;
        while (rep[root] != root) root = rep[root];
        rep[index] = root;
    }
    if (rep[m.mainid] != m.mainid) { report.refused = "main prototype marked as a copy"; return report; }
    // Refuse a merge that would give one prototype two closure constants of the same prototype.
    for (uint32_t index = 0; index < count; ++index) {
        if (rep[index] != index) continue;
        std::set<uint32_t> seen;
        for (const luau::Const& constant : m.protos[index].consts)
            if (constant.tag == luau::C_CLOSURE && constant.u < count && !seen.insert(rep[constant.u]).second) {
                report.refused = "prototype " + std::to_string(index)
                               + " would hold two closure constants of one merged prototype";
                return report;
            }
    }
    std::vector<int64_t> renumber(count, -1);
    uint32_t next = 0;
    for (uint32_t index = 0; index < count; ++index)
        if (rep[index] == index) renumber[index] = next++;
    if (next == count) return report;
    std::vector<luau::Proto> kept;
    kept.reserve(next);
    for (uint32_t index = 0; index < count; ++index) {
        if (rep[index] != index) continue;
        luau::Proto proto = m.protos[index];
        // Child list: map, then keep the first occurrence of each prototype (the compiler adds a
        // child once, at its first reference); NEWCLOSURE operands index this list.
        std::vector<uint32_t> kids;
        std::vector<int> position(proto.kids.size(), -1);
        for (size_t k = 0; k < proto.kids.size(); ++k) {
            const uint32_t target = proto.kids[k] < count ? (uint32_t)renumber[rep[proto.kids[k]]] : proto.kids[k];
            const auto it = std::find(kids.begin(), kids.end(), target);
            if (it == kids.end()) { position[k] = (int)kids.size(); kids.push_back(target); }
            else position[k] = (int)(it - kids.begin());
        }
        proto.kids = kids;
        for (luau::Insn& insn : proto.insns) {
            if (std::string(insn.name()) != "NEWCLOSURE") continue;
            const int child = insn.D;
            if (child < 0 || child >= (int)position.size()) continue;
            insn.D = position[(size_t)child];
            insn.word = (insn.word & 0xFFFFu) | ((uint32_t)(insn.D & 0xFFFF) << 16);
            insn.B = (insn.word >> 16) & 0xFF;
            insn.C = (insn.word >> 24) & 0xFF;
        }
        for (luau::Const& constant : proto.consts)
            if (constant.tag == luau::C_CLOSURE && constant.u < count)
                constant.u = (uint32_t)renumber[rep[constant.u]];
        kept.push_back(std::move(proto));
    }
    report.merged = (int)(count - next);
    m.mainid = (uint32_t)renumber[m.mainid];
    m.protos = std::move(kept);
    return report;
}

} // namespace sp
