// loop_exit_scan_cmd.h -- structural census of loops with more than one exit destination
// (2026-10-09, two-exit campaign agent). Read-only diagnostics; no decompiler behavior.
//
//   derecomp loop-exit-scan [--u44] FILE...
//
// For every authoritative loop (structur.h find_loops) of every prototype, the NATURAL body is the
// set of loop blocks that reach the latch inside the loop. Every edge from the natural body to a
// block outside it is an exit. The canonical exit C is the FOR latch's fallthrough (for loops) or
// the single target of the header test (while loops: the header's outside successor). Each other
// exit target t is followed through its PRIVATE arm (blocks whose predecessors all lie in the
// natural body or the arm) and classified:
//   RET   every path of the arm ends in RETURN                     (`if c then return x end`)
//   BRK   the arm ends at C (or C's transparent JUMP chain)        (`if c then x = v; break end`)
//   JOIN  the arm ends at one block J that is not C               (-O2 inlined `return v`: r = v; JUMP J)
//   MULTI the arm reaches several non-private blocks
// One line per loop with at least one non-latch exit:
//   LOOPEXIT <file> p<proto> header=<h> kind=<k> C=<c> ret=<n> brk=<n> join=<n> multi=<n> joins=<J,..>
#pragma once
#include <map>
#include <set>
#include <string>
#include <vector>

static int cmd_loop_exit_scan(int argc, char** argv) {
    ir_load_namebase();
    int files = 0, protos = 0;
    for (int a = 2; a < argc; ++a) {
        const std::string path = argv[a];
        if (path == "--u44") { g_input_profile_u44 = true; continue; }
        const std::string b = read_de_input(path);
        if (b.empty()) { std::printf("LOOPEXIT_ERROR %s read\n", path.c_str()); continue; }
        de::Module m;
        try { m = de::walk(b); } catch (const std::exception& e) {
            std::printf("LOOPEXIT_ERROR %s walk %s\n", path.c_str(), e.what()); continue; }
        ++files;
        const std::vector<std::string> pool = ir::parse_pool(b);
        std::string name = path;
        const size_t slash = name.find_last_of("/\\");
        if (slash != std::string::npos) name = name.substr(slash + 1);
        for (size_t i = 0; i < m.protos.size(); ++i) {
            ir::IProto ip = ir_annotate(m.protos[i], (int)i, pool, g_nb);
            st::Graph g;
            if (!ip.ok || !build_graph(ip, g) || g.n.empty()) continue;
            st::compute_dom(g);
            ++protos;
            const int N = (int)g.n.size();
            for (const st::Loop& loop : st::find_loops(g)) {
                if (loop.latch < 0 || loop.latch >= N || loop.header < 0) continue;
                // natural body: loop blocks that reach the latch without leaving the loop
                // (a generic for is headed AT its FORGLOOP latch: seed from the back-edge sources)
                std::set<int> nat{loop.latch};
                std::vector<int> work{loop.latch};
                for (int p : g.n[loop.header].preds)
                    if (loop.body.count(p) && g.n[p].reach && nat.insert(p).second) work.push_back(p);
                while (!work.empty()) {
                    const int x = work.back(); work.pop_back();
                    if (x == loop.header) continue;
                    for (int p : g.n[x].preds)
                        if (loop.body.count(p) && g.n[p].reach && nat.insert(p).second) work.push_back(p);
                }
                nat.insert(loop.header);
                int canonical = -1;
                const bool is_for = loop.kind == st::Loop::ForNum || loop.kind == st::Loop::ForGen;
                if (is_for) canonical = g.n[loop.latch].succ_false;
                else {
                    const st::Node& h = g.n[loop.header];
                    for (int s : {h.succ_true, h.succ_false})
                        if (s >= 0 && !nat.count(s)) canonical = s;
                    if (canonical < 0) {
                        const st::Node& l = g.n[loop.latch];
                        for (int s : {l.succ_true, l.succ_false})
                            if (s >= 0 && !nat.count(s)) canonical = s;
                    }
                }
                // C followed through pure single-JUMP blocks
                std::set<int> canonical_chain;
                for (int c = canonical, guard = 0; c >= 0 && c < N && guard < 16; ++guard) {
                    if (!canonical_chain.insert(c).second) break;
                    const st::Node& node = g.n[c];
                    if (node.first != node.last || node.term != 0x40 || node.succ_true < 0) break;
                    c = node.succ_true;
                }
                std::set<int> targets;
                for (int b0 : nat) {
                    if (is_for && b0 == loop.latch) continue;
                    for (int s : {g.n[b0].succ_true, g.n[b0].succ_false})
                        if (s >= 0 && !nat.count(s) && s != canonical) targets.insert(s);
                }
                if (targets.empty()) continue;
                int ret = 0, brk = 0, join = 0, multi = 0;
                std::set<int> joins;
                for (int t : targets) {
                    if (canonical_chain.count(t)) { ++brk; continue; }
                    // private arm from t: grow while every predecessor is in the body or the arm
                    // (cycles inside the arm are allowed: start from everything reachable from t
                    // and shrink to a fixpoint)
                    std::set<int> arm, outs;
                    {
                        std::vector<int> stack{t};
                        while (!stack.empty()) {
                            const int x = stack.back(); stack.pop_back();
                            if (x < 0 || x >= N || nat.count(x) || !g.n[x].reach
                                || canonical_chain.count(x) || !arm.insert(x).second) continue;
                            for (int s : {g.n[x].succ_true, g.n[x].succ_false}) if (s >= 0) stack.push_back(s);
                        }
                        for (bool shrunk = true; shrunk;) {
                            shrunk = false;
                            for (int x : std::set<int>(arm)) {
                                bool priv = true;
                                for (int p : g.n[x].preds)
                                    if (g.n[p].reach && !nat.count(p) && !arm.count(p)) { priv = false; break; }
                                if (!priv) { arm.erase(x); shrunk = true; }
                            }
                            // keep only what is still reachable from t inside the arm
                            std::set<int> live;
                            std::vector<int> st2;
                            if (arm.count(t)) st2.push_back(t);
                            while (!st2.empty()) {
                                const int x = st2.back(); st2.pop_back();
                                if (!arm.count(x) || !live.insert(x).second) continue;
                                for (int s : {g.n[x].succ_true, g.n[x].succ_false}) if (s >= 0) st2.push_back(s);
                            }
                            if (live.size() != arm.size()) { arm.swap(live); shrunk = true; }
                        }
                        for (int x : arm)
                            for (int s : {g.n[x].succ_true, g.n[x].succ_false})
                                if (s >= 0 && !arm.count(s)) outs.insert(s);
                        if (arm.empty()) outs.insert(t);
                    }
                    if (outs.empty()) ++ret;
                    else if (outs.size() == 1 && canonical_chain.count(*outs.begin())) ++brk;
                    else if (outs.size() == 1) { ++join; joins.insert(*outs.begin()); }
                    else { ++multi; joins.insert(outs.begin(), outs.end()); }
                }
                const char* kind = loop.kind == st::Loop::ForNum ? "fornum"
                    : loop.kind == st::Loop::ForGen ? "forgen" : loop.kind == st::Loop::While ? "while" : "repeat";
                std::printf("LOOPEXIT %s p%zu header=%d kind=%s C=%d ret=%d brk=%d join=%d multi=%d joins=",
                            name.c_str(), i, loop.header, kind, canonical, ret, brk, join, multi);
                bool first = true;
                for (int j : joins) { std::printf("%s%d", first ? "" : ",", j); first = false; }
                std::printf("\n");
            }
        }
    }
    std::printf("LOOPEXIT_SUMMARY files=%d protos=%d\n", files, protos);
    return 0;
}
