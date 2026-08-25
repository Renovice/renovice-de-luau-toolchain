// m6c_cmd.h — M6c driver commands.  Included from main.cpp AFTER ir_annotate/build_cfg exist.
//
//   expr <file.lua_B> [proto]   print reconstructed expressions and statements
//   expr-validate <dir>         THE ACCEPTANCE METRIC
//
// The metric is deliberately harsh: every instruction must land in exactly one of
// expr / stmt / ctrl / skip. Anything else is COUNTED and NAMED, never silently dropped —
// silence is precisely how a decompiler ends up emitting plausible, wrong source.
#pragma once

// Rebuild a raw code span from the annotated IR so build_cfg (which works on bytes) can be reused
// unchanged. Branch instructions must be re-packed with Bx, not B/C, or the offsets are destroyed.
static std::string ir_code_bytes(const ir::IProto& ip) {
    std::string code;
    for (const ir::IInsn& in : ip.code) {
        uint32_t w;
        if (in.branch) w = (uint32_t)in.op | ((uint32_t)in.A << 8) | ((uint32_t)in.Bx << 16);
        else           w = (uint32_t)in.op | ((uint32_t)in.A << 8) |
                           ((uint32_t)in.B << 16) | ((uint32_t)in.C << 24);
        char b[4]; std::memcpy(b, &w, 4); code.append(b, 4);
        if (in.wide) { char c[4]; std::memcpy(c, &in.aux, 4); code.append(c, 4); }
    }
    return code;
}

static ex::ProtoOut reconstruct_proto(const ir::IProto& ip) {
    ex::ProtoOut out;
    std::vector<Blk> bl; std::string why;
    std::string code = ir_code_bytes(ip);
    if (!build_cfg(code, bl, why)) {
        ex::BlockOut bo; bo.first = 0; bo.last = (int)ip.code.size() - 1;
        if (bo.last >= 0) ex::reconstruct_block(ip, bo.first, bo.last, out, bo);
        out.blocks.push_back(std::move(bo));
        return out;
    }
    for (const Blk& b : bl) {
        ex::BlockOut bo; bo.first = b.first; bo.last = b.last;
        ex::reconstruct_block(ip, b.first, b.last, out, bo);
        out.blocks.push_back(std::move(bo));
    }
    return out;
}

static void print_stmt(const ex::Stmt& s) {
    switch (s.k) {
        case ex::SK::Assign:
            std::printf("     %s = %s\n", ex::render(s.lhs).c_str(), ex::render(s.rhs).c_str());
            break;
        case ex::SK::ExprStmt:
            std::printf("     %s\n", ex::render(s.rhs).c_str());
            break;
        case ex::SK::Return: {
            std::string v;
            for (size_t q = 0; q < s.list.size(); ++q) { if (q) v += ", "; v += ex::render(s.list[q]); }
            std::printf("     return %s\n", v.c_str());
            break;
        }
        case ex::SK::Branch:
            std::printf("     [ctrl] %s   -> insn %d\n", s.text.c_str(), s.target);
            break;
        default:
            std::printf("     %s\n", s.text.c_str());
            break;
    }
}

static int cmd_expr(int argc, char** argv) {
    ir_load_namebase();
    std::string b = read_file(argv[2]);
    de::Module m;
    try { m = de::walk(b); }
    catch (const std::exception& e) { std::fprintf(stderr, "walk error: %s\n", e.what()); return 1; }
    std::vector<std::string> pool = ir::parse_pool(b);
    int only = (argc >= 4) ? std::atoi(argv[3]) : -1;
    for (size_t i = 0; i < m.protos.size(); ++i) {
        if (only >= 0 && (int)i != only) continue;
        ir::IProto ip = ir_annotate(m.protos[i], (int)i, pool, g_nb);
        if (!ip.ok) { std::printf("== proto[%zu] DECODE FAILED: %s ==\n", i, ip.why.c_str()); continue; }
        ex::ProtoOut po = reconstruct_proto(ip);
        std::printf("== proto[%zu]  nparams=%d nups=%d vararg=%d  blocks=%zu ==\n",
                    i, ip.nparams, ip.nups, ip.vararg ? 1 : 0, po.blocks.size());
        for (size_t bi = 0; bi < po.blocks.size(); ++bi) {
            const ex::BlockOut& bo = po.blocks[bi];
            std::printf("  -- block %zu  [%d..%d]\n", bi, bo.first, bo.last);
            for (const ex::Stmt& s : bo.stmts) print_stmt(s);
        }
        std::printf("  consumed: expr=%lld stmt=%lld ctrl=%lld skip=%lld  UNHANDLED=%lld\n",
                    po.n_expr, po.n_stmt, po.n_ctrl, po.n_skip, po.n_unhandled);
        for (auto& kv : po.unhandled) std::printf("      unhandled %-16s %lld\n", kv.first.c_str(), kv.second);
    }
    return 0;
}

static int cmd_expr_validate(int argc, char** argv) {
    ir_load_namebase();
    fs::path dir = argv[2];
    long long files = 0, protos = 0, e = 0, st = 0, ct = 0, sk = 0, un = 0, badproto = 0;
    std::map<std::string, long long> unh;
    auto do_file = [&](const std::string& path) {
        std::string b = read_file(path);
        if (b.size() < 2 || (uint8_t)b[0] != 0x09 || (uint8_t)b[1] != 0x03) return;
        de::Module m;
        try { m = de::walk(b); } catch (...) { return; }
        std::vector<std::string> pool = ir::parse_pool(b);
        ++files;
        for (size_t i = 0; i < m.protos.size(); ++i) {
            ir::IProto ip = ir_annotate(m.protos[i], (int)i, pool, g_nb);
            ++protos;
            if (!ip.ok) { ++badproto; continue; }
            ex::ProtoOut po = reconstruct_proto(ip);
            e += po.n_expr; st += po.n_stmt; ct += po.n_ctrl; sk += po.n_skip; un += po.n_unhandled;
            for (auto& kv : po.unhandled) unh[kv.first] += kv.second;
        }
    };
    if (fs::is_directory(dir)) {
        for (auto& en : fs::directory_iterator(dir))
            if (en.is_regular_file() && en.path().extension() == ".lua_B") do_file(en.path().string());
    } else do_file(dir.string());
    long long tot = e + st + ct + sk + un;
    std::printf("== M6c EXPRESSION RECONSTRUCTION ==\n");
    std::printf("files=%lld protos=%lld instructions=%lld  (decode-failed protos: %lld)\n",
                files, protos, tot, badproto);
    std::printf("  expressions  : %lld\n", e);
    std::printf("  statements   : %lld\n", st);
    std::printf("  control flow : %lld\n", ct);
    std::printf("  skipped      : %lld\n", sk);
    std::printf("  UNHANDLED    : %lld  (%.4f%%)\n", un, tot ? 100.0 * un / tot : 0.0);
    std::vector<std::pair<long long, std::string>> v;
    for (auto& kv : unh) v.push_back({kv.second, kv.first});
    std::sort(v.rbegin(), v.rend());
    for (size_t i = 0; i < v.size() && i < 20; ++i)
        std::printf("      %-16s %lld\n", v[i].second.c_str(), v[i].first);
    std::printf("\n  VERDICT: %s\n",
                un == 0 ? "every instruction consumed into an expression or statement"
                        : "some instructions unhandled - see the breakdown above");
    return un == 0 ? 0 : 1;
}
