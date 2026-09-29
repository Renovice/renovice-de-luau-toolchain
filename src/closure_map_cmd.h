#pragma once

// Machine-readable closure ownership map for large DE modules. This command is
// deliberately built on the same fail-closed annotated IR used by the
// decompiler. It keeps four index namespaces separate: instruction index,
// NEWCLOSURE child slot, DUPCLOSURE constant slot, and resolved flat/global
// prototype index.

static std::string closure_map_capture_text(const ir::IInsn& capture, int slot)
{
    const char* mode = "INVALID";
    const char* source = "?";
    if (capture.A == 0) { mode = "VAL"; source = "R"; }
    else if (capture.A == 1) { mode = "REF"; source = "R"; }
    else if (capture.A == 2) { mode = "UPVAL"; source = "U"; }
    return std::to_string(slot) + "=" + mode + ":" + source
        + std::to_string((int)capture.B);
}

static int cmd_closure_map(int argc, char** argv)
{
    if (argc < 4) {
        std::fprintf(stderr, "usage: derecomp closure-map <in.lua_B> <out.tsv>\n");
        return 2;
    }

    const std::string bytes = read_file(argv[2]);
    if (bytes.size() < 2 || (uint8_t)bytes[0] != 0x09 || (uint8_t)bytes[1] != 0x03) {
        std::fprintf(stderr, "[derecomp] closure-map input is not a DE 09 03 container: %s\n", argv[2]);
        return 2;
    }

    de::Module module;
    try { module = de::walk(bytes); }
    catch (const std::exception& e) {
        std::fprintf(stderr, "[derecomp] closure-map parse failed: %s\n", e.what());
        return 2;
    }

    ir_load_namebase();
    const std::vector<std::string> pool = ir::parse_pool(bytes);
    std::vector<ir::IProto> protos;
    protos.reserve(module.protos.size());
    int failures = 0;
    for (size_t i = 0; i < module.protos.size(); ++i) {
        protos.push_back(ir_annotate(module.protos[i], (int)i, pool, g_nb));
        if (!protos.back().ok) {
            ++failures;
            std::fprintf(stderr, "[derecomp] closure-map proto[%zu] decode failed: %s\n",
                         i, protos.back().why.c_str());
        }
    }

    std::ostringstream out;
    out << "parent_proto\tinstruction\top\tdestination_register\toperand_namespace"
           "\toperand_index\ttarget_proto\ttarget_params\ttarget_upvalues"
           "\ttarget_maxstack\tcapture_count\tcaptures\tstatus\n";

    long long sites = 0;
    long long captures = 0;
    for (size_t parent_index = 0; parent_index < protos.size(); ++parent_index) {
        const ir::IProto& parent = protos[parent_index];
        for (size_t instruction_index = 0; instruction_index < parent.code.size(); ++instruction_index) {
            const ir::IInsn& instruction = parent.code[instruction_index];
            if (instruction.op != 0x16 && instruction.op != 0x42) continue;
            ++sites;

            const char* operation = instruction.op == 0x16 ? "NEWCLOSURE" : "DUPCLOSURE";
            const char* operand_namespace = instruction.op == 0x16 ? "child" : "const";
            int target = -1;
            std::string status = "PASS";
            if (instruction.op == 0x16) {
                if ((size_t)instruction.Bx < parent.kids.size())
                    target = (int)parent.kids[(size_t)instruction.Bx];
                else status = "FAIL_CHILD_INDEX_OOB";
            } else {
                if ((size_t)instruction.Bx >= parent.consts.size())
                    status = "FAIL_CONST_INDEX_OOB";
                else if (parent.consts[(size_t)instruction.Bx].kind != ir::KKind::Closure)
                    status = "FAIL_CONST_NOT_CLOSURE";
                else target = (int)parent.consts[(size_t)instruction.Bx].sub;
            }
            if (target < 0 || target >= (int)protos.size()) {
                if (status == "PASS") status = "FAIL_TARGET_PROTO_OOB";
            }

            const int expected_captures = target >= 0 && target < (int)protos.size()
                ? protos[(size_t)target].nups : -1;
            std::vector<const ir::IInsn*> observed;
            for (size_t q = instruction_index + 1;
                 q < parent.code.size() && parent.code[q].op == 0x35; ++q)
                observed.push_back(&parent.code[q]);

            std::string capture_text;
            for (size_t slot = 0; slot < observed.size(); ++slot) {
                if (!capture_text.empty()) capture_text += ";";
                capture_text += closure_map_capture_text(*observed[slot], (int)slot);
                const ir::IInsn& capture = *observed[slot];
                if (capture.A > 2) status = "FAIL_CAPTURE_MODE";
                else if (capture.A < 2 && capture.B >= parent.maxstack)
                    status = "FAIL_CAPTURE_REGISTER_OOB";
                else if (capture.A == 2 && capture.B >= parent.nups)
                    status = "FAIL_CAPTURE_UPVALUE_OOB";
            }
            captures += (long long)observed.size();
            if (expected_captures >= 0 && (int)observed.size() != expected_captures)
                status = "FAIL_CAPTURE_COUNT";
            if (status != "PASS") ++failures;

            const ir::IProto* target_proto = target >= 0 && target < (int)protos.size()
                ? &protos[(size_t)target] : nullptr;
            out << parent_index << '\t' << instruction_index << '\t' << operation << '\t'
                << (int)instruction.A << '\t' << operand_namespace << '\t'
                << instruction.Bx << '\t' << target << '\t'
                << (target_proto ? target_proto->nparams : -1) << '\t'
                << (target_proto ? target_proto->nups : -1) << '\t'
                << (target_proto ? target_proto->maxstack : -1) << '\t'
                << observed.size() << '\t' << capture_text << '\t' << status << '\n';
        }
    }

    if (!write_file(argv[3], out.str())) {
        std::fprintf(stderr, "[derecomp] closure-map cannot write: %s\n", argv[3]);
        return 2;
    }
    std::printf("CLOSURE_MAP %s protos=%zu sites=%lld captures=%lld failures=%d output=%s\n",
                failures == 0 ? "PASS" : "FAIL", protos.size(), sites, captures,
                failures, argv[3]);
    return failures == 0 ? 0 : 1;
}
