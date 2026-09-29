// semantic_ir/command.h -- isolated Phase-1 self-test entry point.
#pragma once
#include "adapter.h"
#include "fixtures.h"
#include "lowering_oracle.h"
#include "source_renderer.h"
#include "readable_naming.h"
#include "value_flow.h"
#include "../liveness.h"
#include <filesystem>
#include <fstream>

// Luau source has one visible spelling for both ordinary string-keyed fields/globals and DE's
// hashed name slots.  A module can contain both classes under the same recovered spelling.  The
// name-level RENOVICE_HASH_* directive cannot describe that collision by itself: marking the plain
// spelling would convert both uses to hashes.  Give only the hashed occurrences a lossless source
// alias carrying their exact hash.  resolve_name_hash() consumes the suffix during recompilation,
// while the ordinary spelling remains an ordinary string constant.  This is presentation metadata;
// it never guesses another name or changes the annotated instruction's operation.
static void semantic_ir_disambiguate_mixed_name_metadata(
    std::vector<ir::IProto>& annotated) {
    using NameClass = std::pair<int, std::string>; // 0 = global, 1 = field read
    std::set<NameClass> hashed;
    std::set<NameClass> strings;
    auto classify = [](const ir::IInsn& instruction) {
        if (instruction.op == 0x17 || instruction.op == 0x02) return 0;
        if (instruction.op == 0x3d) return 1;
        return -1;
    };
    for (const ir::IProto& proto : annotated) {
        for (const ir::IInsn& instruction : proto.code) {
            const int category = classify(instruction);
            if (category < 0) continue;
            const uint32_t key = instruction.aux & 0xffffu;
            if (key >= proto.consts.size()) continue;
            const ir::KKind kind = proto.consts[key].kind;
            if (kind == ir::KKind::NameHash)
                hashed.emplace(category, instruction.note);
            else if (kind == ir::KKind::Str)
                strings.emplace(category, instruction.note);
        }
    }
    for (ir::IProto& proto : annotated) {
        for (ir::IInsn& instruction : proto.code) {
            const int category = classify(instruction);
            if (category < 0) continue;
            const uint32_t key = instruction.aux & 0xffffu;
            if (key >= proto.consts.size()) continue;
            const ir::KVal& value = proto.consts[key];
            if (value.kind != ir::KKind::NameHash
                || !strings.count(NameClass{category, instruction.note})) continue;
            char suffix[16];
            std::snprintf(suffix, sizeof suffix, "__%08x", value.hash);
            instruction.note = (ex::is_ident(instruction.note)
                ? instruction.note : std::string("Name")) + suffix;
        }
    }
}

// Preserve DE's otherwise invisible distinction between hashed engine properties and ordinary
// string-keyed module globals/fields at the editable-source boundary. The full 5,386-module corpus
// proves globals are module/name exact; all 286 ability modules prove field reads are too. A future
// non-ability module with a mixed field name fails closed instead of receiving a broad wrong hint.
static bool semantic_ir_add_global_metadata(const std::vector<ir::IProto>& annotated,
                                            std::string& source, std::string& failure) {
    std::set<std::string> hashed_globals, string_globals;
    std::set<std::string> hashed_fields, string_fields;
    for (const ir::IProto& proto : annotated) {
        for (const ir::IInsn& instruction : proto.code) {
            const bool global = instruction.op == 0x17 || instruction.op == 0x02;
            const bool field_read = instruction.op == 0x3d;
            if (!global && !field_read) continue;
            const uint32_t key = instruction.aux & 0xffffu;
            if (key >= proto.consts.size()) {
                failure = "RENDER_GLOBAL_METADATA_KEY_OOB"; return false;
            }
            const ir::KVal& value = proto.consts[key];
            std::set<std::string>& hashed = global ? hashed_globals : hashed_fields;
            std::set<std::string>& strings = global ? string_globals : string_fields;
            if (value.kind == ir::KKind::NameHash) hashed.insert(instruction.note);
            else if (value.kind == ir::KKind::Str) strings.insert(instruction.note);
            else { failure = "RENDER_GLOBAL_METADATA_KIND_UNKNOWN"; return false; }
        }
    }
    auto validate = [&](const std::set<std::string>& hashed,
                        const std::set<std::string>& strings) {
        for (const std::string& name : hashed) {
            if (strings.count(name)) {
                failure = "RENDER_NAME_METADATA_MIXED_NAME"; return false;
            }
            if (!ex::is_ident(name)) {
                failure = "RENDER_HASHED_NAME_NOT_IDENTIFIER"; return false;
            }
        }
        return true;
    };
    if (!validate(hashed_globals, string_globals)
        || !validate(hashed_fields, string_fields)) return false;
    if (hashed_globals.empty() && hashed_fields.empty()) return true;
    std::ostringstream metadata;
    for (const std::string& name : hashed_globals)
        metadata << tc::hashed_global_directive_prefix() << name << '\n';
    for (const std::string& name : hashed_fields)
        metadata << tc::hashed_field_directive_prefix() << name << '\n';
    source = metadata.str() + source;
    return true;
}

static int cmd_semantic_ir_selftest(int argc, char** argv) {
    sir::FixtureResult result = sir::run_fixtures();
    const bool print_json = argc >= 3 && std::string(argv[2]) == "--json";
    if (print_json) std::printf("%s\n", sir::to_json(sir::valid_fixture()).c_str());
    std::printf("SEMANTIC_IR_SELFTEST assertions=%d passed=%d failed=%zu\n",
                result.assertions, result.passed, result.failures.size());
    for (const std::string& failure : result.failures)
        std::printf("FAIL %s\n", failure.c_str());
    return result.failures.empty() ? 0 : 1;
}

static int cmd_semantic_ir_readable_selftest() {
    const sir::readable::SelfTestResult result = sir::readable::run_selftest();
    std::printf("SEMANTIC_IR_READABLE_SELFTEST assertions=%d passed=%d failed=%zu\n",
                result.assertions, result.passed, result.failures.size());
    for (const std::string& failure : result.failures)
        std::printf("FAIL %s\n", failure.c_str());
    return result.failures.empty() ? 0 : 1;
}

static int cmd_semantic_ir_lowering_selftest(int argc, char** argv) {
    const sir::oracle::Result result = sir::oracle::run_open_tail_oracle();
    std::printf("SEMANTIC_IR_LOWERING_SELFTEST assertions=%d passed=%d failed=%d runtime_exit=%d\n",
                result.assertions, result.passed, result.failed, result.runtime_exit);
    for (const std::string& failure : result.failures)
        std::printf("FAIL %s\n", failure.c_str());
    if (result.failed && !result.runtime_output.empty())
        std::printf("RUNTIME_OUTPUT\n%s\n", result.runtime_output.c_str());
    std::string json_path;
    for (int argument = 2; argument < argc; ++argument)
        if (std::string(argv[argument]) == "--json-out" && argument + 1 < argc)
            json_path = argv[++argument];
    if (!json_path.empty()) {
        std::ostringstream json;
        json << "{\n  \"schema\": 1,\n"
             << "  \"assertions\": " << result.assertions << ",\n"
             << "  \"passed\": " << result.passed << ",\n"
             << "  \"failed\": " << result.failed << ",\n"
             << "  \"runtime_exit\": " << result.runtime_exit << ",\n"
             << "  \"failures\": [";
        for (size_t index = 0; index < result.failures.size(); ++index) {
            if (index) json << ',';
            json << "\n    \"" << sir::json_escape(result.failures[index]) << "\"";
        }
        if (!result.failures.empty()) json << '\n';
        json << "  ],\n  \"success\": " << (result.failed ? "false" : "true")
             << "\n}\n";
        if (!write_file(json_path, json.str())) {
            std::fprintf(stderr, "semantic-ir-lowering-selftest: cannot write %s\n",
                         json_path.c_str());
            return 2;
        }
        std::printf("json=%s\n", json_path.c_str());
    }
    return result.failed ? 1 : 0;
}

static int cmd_semantic_ir_verify(int argc, char** argv) {
    ir_load_namebase();
    const std::string path = argv[2];
    g_primary_ability_loop_scope = is_primary_ability_module_path(path);
    de::Module module;
    const std::string bytes = read_file(path);
    try { module = de::walk(bytes); }
    catch (const std::exception& error) {
        std::fprintf(stderr, "semantic-ir-verify: walk error: %s\n", error.what()); return 2;
    }
    const std::vector<std::string> pool = ir::parse_pool(bytes);
    std::vector<ir::IProto> annotated;
    annotated.reserve(module.protos.size());
    for (size_t index = 0; index < module.protos.size(); ++index)
        annotated.push_back(ir_annotate(module.protos[index], (int)index, pool, g_nb));
    const int only = argc >= 4 ? std::atoi(argv[3]) : -1;
    const bool print_model_json = argc >= 5 && std::string(argv[4]) == "--json";
    int failed = 0;
    for (size_t index = 0; index < module.protos.size(); ++index) {
        if (only >= 0 && only != (int)index) continue;
        const ir::IProto& proto = annotated[index];
        if (!proto.ok) {
            ++failed; std::printf("SIR proto=%zu status=FAILED ANNOTATE_FAILED %s\n",
                                  index, proto.why.c_str()); continue;
        }
        const sem::Manifest manifest = semcmd::build_manifest(proto, (int)index);
        const sir::vf::Analysis value_flow = sir::vf::analyze(proto, manifest);
        bool value_flow_ok = value_flow.known && value_flow.converged;
        for (const sir::vf::Use& use : value_flow.uses)
            if (use.reaching.empty()) value_flow_ok = false;
        const sir::vf::TopAnalysis top_flow = sir::vf::analyze_top(proto, manifest);
        const bool top_flow_ok = sir::vf::top_contracts_closed(proto, manifest, top_flow);
        const sir::Adaptation adaptation = sir::adapt_manifest(proto, manifest, annotated);
        const sir::Verification verification = sir::verify(adaptation.model);
        if (print_model_json)
            std::printf("SIR_MODEL_JSON %s\n", sir::to_json(adaptation.model).c_str());
        const bool ok = adaptation.ok() && verification.ok() && value_flow_ok && top_flow_ok;
        std::printf("SIR proto=%zu status=%s blocks=%zu effects=%zu loops=%zu "
                    "adapter_failures=%zu verifier_failures=%zu\n",
                    index, ok ? "VERIFIED" : "FAILED", adaptation.model.reachable_blocks.size(),
                    adaptation.model.observable_effects.size(),
                    adaptation.model.authoritative_loops.size(), adaptation.failures.size(),
                    verification.issues.size());
        if (!value_flow.known) std::printf("FAIL SIR_VALUE_FLOW_UNKNOWN\n");
        if (!value_flow.converged) std::printf("FAIL SIR_VALUE_FLOW_NONCONVERGED\n");
        if (value_flow.known && value_flow.converged)
            for (const sir::vf::Use& use : value_flow.uses)
                if (use.reaching.empty()) {
                    std::printf("FAIL SIR_VALUE_FLOW_MISSING_ORIGIN instruction=%d reg=%d\n",
                                use.instruction, use.reg);
                }
        if (!top_flow_ok) std::printf("FAIL SIR_TOP_FLOW_CONTRACT\n");
        for (const std::string& observation : adaptation.observations)
            std::printf("OBSERVATION %s\n", observation.c_str());
        for (const std::string& failure : adaptation.failures)
            std::printf("FAIL %s\n", failure.c_str());
        for (const sir::Issue& issue_value : verification.issues)
            std::printf("FAIL %s %s\n", issue_value.code.c_str(), issue_value.detail.c_str());
        if (!ok && verification.has("SIR_EDGE_COVERAGE")) {
            std::set<sir::BranchContract> diagnostic_branches;
            for (const auto& node_pair : adaptation.model.nodes) {
                const sir::Node& node = node_pair.second;
                if (node.kind != sir::NodeKind::If && node.kind != sir::NodeKind::IfElse
                    && node.kind != sir::NodeKind::LoopCondition
                    && node.kind != sir::NodeKind::RedundantPredicate
                    && node.kind != sir::NodeKind::BooleanShortCircuit
                    && node.kind != sir::NodeKind::ConditionalBreak
                    && node.kind != sir::NodeKind::ConditionalContinue
                    && node.kind != sir::NodeKind::ConditionalBreakContinue
                    && node.kind != sir::NodeKind::PreservedCyclicBranch
                    && node.kind != sir::NodeKind::PreservedSharedBranch
                    && node.kind != sir::NodeKind::PreservedEscapingBranch
                    && node.kind != sir::NodeKind::UnresolvedBranch) continue;
                std::printf("BRANCH node=%d kind=%s source=%d edges=%zu true=%d false=%d "
                            "join=%d role=%d true_blocks=%zu false_blocks=%zu loop=%d\n",
                            node.id.value, sir::node_kind_name(node.kind),
                            node.control_source.value, node.control_edges.size(),
                            node.branch_true_target.value, node.branch_false_target.value,
                            node.branch_join.value, (int)node.branch_role,
                            node.branch_true_blocks.size(), node.branch_false_blocks.size(),
                            node.control_loop.value);
                sir::BranchContract branch;
                branch.source = node.control_source;
                branch.true_target = node.branch_true_target;
                branch.false_target = node.branch_false_target;
                branch.join = node.branch_join; branch.role = node.branch_role;
                branch.virtual_exit_join = node.branch_virtual_exit_join;
                branch.chain_next = node.branch_chain_next;
                branch.chain_shared_target = node.branch_chain_shared_target;
                branch.true_escapes_region = node.branch_true_escapes_region;
                branch.false_escapes_region = node.branch_false_escapes_region;
                branch.true_has_terminal = node.branch_true_has_terminal;
                branch.false_has_terminal = node.branch_false_has_terminal;
                branch.loop = node.control_loop; branch.true_blocks = node.branch_true_blocks;
                branch.false_blocks = node.branch_false_blocks;
                diagnostic_branches.insert(branch);
            }
            std::printf("BRANCH_CONTRACTS authoritative=%zu semantic=%zu equal=%d\n",
                        adaptation.model.authoritative_branches.size(),
                        diagnostic_branches.size(),
                        adaptation.model.authoritative_branches == diagnostic_branches ? 1 : 0);
        }
        if (!ok) ++failed;
    }
    return failed == 0 ? 0 : 1;
}

static int cmd_semantic_ir_render(int argc, char** argv) {
    ir_load_namebase();
    const std::string input = argv[2];
    const std::string output = argv[3];
    const int selected = argc >= 5 ? std::atoi(argv[4]) : 0;
    g_primary_ability_loop_scope = is_primary_ability_module_path(input);
    de::Module module;
    const std::string bytes = read_file(input);
    try { module = de::walk(bytes); }
    catch (const std::exception& error) {
        std::fprintf(stderr, "semantic-ir-render: walk error: %s\n", error.what()); return 2;
    }
    const std::vector<std::string> pool = ir::parse_pool(bytes);
    std::vector<ir::IProto> annotated;
    annotated.reserve(module.protos.size());
    for (size_t index = 0; index < module.protos.size(); ++index)
        annotated.push_back(ir_annotate(module.protos[index], (int)index, pool, g_nb));
    if (selected < 0 || selected >= (int)annotated.size()) {
        std::fprintf(stderr, "semantic-ir-render: invalid prototype %d\n", selected); return 2;
    }
    const ir::IProto& proto = annotated[(size_t)selected];
    if (!proto.ok) {
        std::fprintf(stderr, "semantic-ir-render: annotation failed: %s\n", proto.why.c_str());
        return 1;
    }
    const sem::Manifest manifest = semcmd::build_manifest(proto, selected);
    const sir::Adaptation adaptation = sir::adapt_manifest(proto, manifest, annotated);
    const sir::Verification verification = sir::verify(adaptation.model);
    if (!adaptation.ok() || !verification.ok()) {
        for (const std::string& failure : adaptation.failures)
            std::fprintf(stderr, "FAIL %s\n", failure.c_str());
        for (const sir::Issue& issue : verification.issues)
            std::fprintf(stderr, "FAIL %s %s\n", issue.code.c_str(), issue.detail.c_str());
        return 1;
    }
    const sir::source::Result rendered = sir::source::render_semantic(adaptation.model);
    if (!rendered.ok) {
        for (const std::string& failure : rendered.failures)
            std::fprintf(stderr, "FAIL %s\n", failure.c_str());
        return 1;
    }
    if (!write_file(output, rendered.source)) {
        std::fprintf(stderr, "semantic-ir-render: cannot write %s\n", output.c_str()); return 2;
    }
    std::printf("SEMANTIC_IR_RENDER proto=%d status=RENDERED bytes=%zu output=%s\n",
                selected, rendered.source.size(), output.c_str());
    return 0;
}

static int cmd_semantic_ir_render_module(int argc, char** argv) {
    ir_load_namebase();
    const std::string input = argv[2];
    const std::string output = argv[3];
    g_primary_ability_loop_scope = is_primary_ability_module_path(input);
    de::Module module;
    const std::string bytes = read_de_input(input);
    try { module = de::walk(bytes); }
    catch (const std::exception& error) {
        std::fprintf(stderr, "semantic-ir-render-module: walk error: %s\n", error.what());
        return 2;
    }
    const std::vector<std::string> pool = ir::parse_pool(bytes);
    std::vector<ir::IProto> annotated;
    annotated.reserve(module.protos.size());
    for (size_t index = 0; index < module.protos.size(); ++index)
        annotated.push_back(ir_annotate(module.protos[index], (int)index, pool, g_nb));
    semantic_ir_disambiguate_mixed_name_metadata(annotated);
    std::map<int, sir::Model> models;
    for (size_t index = 0; index < annotated.size(); ++index) {
        if (!annotated[index].ok) {
            std::fprintf(stderr, "FAIL RENDER_MODULE_ANNOTATION proto=%zu %s\n",
                         index, annotated[index].why.c_str());
            return 1;
        }
        const sem::Manifest manifest = semcmd::build_manifest(annotated[index], (int)index);
        const sir::Adaptation adaptation = sir::adapt_manifest(
            annotated[index], manifest, annotated);
        const sir::Verification verification = sir::verify(adaptation.model);
        if (!adaptation.ok() || !verification.ok()) {
            for (const std::string& failure : adaptation.failures)
                std::fprintf(stderr, "FAIL proto=%zu %s\n", index, failure.c_str());
            for (const sir::Issue& issue : verification.issues)
                std::fprintf(stderr, "FAIL proto=%zu %s %s\n", index,
                             issue.code.c_str(), issue.detail.c_str());
            return 1;
        }
        models.emplace((int)index, adaptation.model);
    }
    size_t trailer_offset = 0;
    int root = -1;
    try { root = (int)de::rd_vi(module.trailer, trailer_offset); }
    catch (...) {
        std::fprintf(stderr, "FAIL RENDER_MODULE_ROOT_DECODE\n"); return 1;
    }
    sir::source::Result rendered = sir::source::render_module(models, root);
    if (!rendered.ok) {
        for (const std::string& failure : rendered.failures)
            std::fprintf(stderr, "FAIL %s\n", failure.c_str());
        return 1;
    }
    std::string metadata_failure;
    if (!semantic_ir_add_global_metadata(annotated, rendered.source, metadata_failure)) {
        std::fprintf(stderr, "FAIL %s\n", metadata_failure.c_str()); return 1;
    }
    if (!write_file(output, rendered.source)) {
        std::fprintf(stderr, "semantic-ir-render-module: cannot write %s\n", output.c_str());
        return 2;
    }
    std::printf("SEMANTIC_IR_RENDER_MODULE root=%d prototypes=%zu status=RENDERED "
                "bytes=%zu output=%s\n", root, models.size(), rendered.source.size(),
                output.c_str());
    return 0;
}

static int cmd_semantic_ir_render_module_readable(int argc, char** argv) {
    ir_load_namebase();
    const std::string input = argv[2];
    const std::string fidelity_output = argv[3];
    const std::string readable_output = argv[4];
    const std::string mapping_output = argv[5];
    std::string contracts_path = "api/warframe/contracts.tsv";
    std::string catalog_path = "api/warframe/selected_catalog.tsv";
    std::string semantic_sdk_path;
    std::string failure_readable_output;
    std::string callsite_output;
    for (int argument = 6; argument < argc; ++argument) {
        const std::string value = argv[argument];
        if (value == "--contracts" && argument + 1 < argc)
            contracts_path = argv[++argument];
        else if (value == "--catalog" && argument + 1 < argc)
            catalog_path = argv[++argument];
        else if (value == "--semantic-sdk" && argument + 1 < argc)
            semantic_sdk_path = argv[++argument];
        else if (value == "--failure-readable" && argument + 1 < argc)
            failure_readable_output = argv[++argument];
        else if (value == "--call-map" && argument + 1 < argc)
            callsite_output = argv[++argument];
        else {
            std::fprintf(stderr,
                "semantic-ir-render-module-readable: unknown/incomplete option %s\n",
                value.c_str());
            return 2;
        }
    }

    g_primary_ability_loop_scope = is_primary_ability_module_path(input);
    de::Module module;
    const std::string bytes = read_file(input);
    try { module = de::walk(bytes); }
    catch (const std::exception& error) {
        std::fprintf(stderr,
            "semantic-ir-render-module-readable: walk error: %s\n", error.what());
        return 2;
    }
    const std::vector<std::string> pool = ir::parse_pool(bytes);
    std::vector<ir::IProto> annotated;
    annotated.reserve(module.protos.size());
    for (size_t index = 0; index < module.protos.size(); ++index)
        annotated.push_back(ir_annotate(module.protos[index], (int)index, pool, g_nb));
    semantic_ir_disambiguate_mixed_name_metadata(annotated);
    std::map<int, sir::Model> models;
    for (size_t index = 0; index < annotated.size(); ++index) {
        if (!annotated[index].ok) {
            std::fprintf(stderr, "FAIL READABLE_MODULE_ANNOTATION proto=%zu %s\n",
                         index, annotated[index].why.c_str());
            return 1;
        }
        const sem::Manifest manifest = semcmd::build_manifest(annotated[index], (int)index);
        const sir::Adaptation adaptation = sir::adapt_manifest(
            annotated[index], manifest, annotated);
        const sir::Verification verification = sir::verify(adaptation.model);
        if (!adaptation.ok() || !verification.ok()) {
            for (const std::string& failure : adaptation.failures)
                std::fprintf(stderr, "FAIL proto=%zu %s\n", index, failure.c_str());
            for (const sir::Issue& issue : verification.issues)
                std::fprintf(stderr, "FAIL proto=%zu %s %s\n", index,
                             issue.code.c_str(), issue.detail.c_str());
            return 1;
        }
        models.emplace((int)index, adaptation.model);
    }
    size_t trailer_offset = 0;
    int root = -1;
    try { root = (int)de::rd_vi(module.trailer, trailer_offset); }
    catch (...) {
        std::fprintf(stderr, "FAIL READABLE_MODULE_ROOT_DECODE\n"); return 1;
    }

    sir::source::Result fidelity = sir::source::render_module(models, root);
    if (!fidelity.ok) {
        for (const std::string& failure : fidelity.failures)
            std::fprintf(stderr, "FAIL FIDELITY_%s\n", failure.c_str());
        return 1;
    }
    for (const int prototype : fidelity.omitted_orphan_prototypes)
        std::fprintf(stderr,
            "WARN FIDELITY_RENDER_ORPHAN_PROTOTYPE_OMITTED proto=%d\n", prototype);
    const sir::readable::Plan naming = sir::readable::build_plan(
        models, contracts_path, catalog_path, semantic_sdk_path);
    if (naming.semantic_sdk_requested && !naming.semantic_sdk_loaded) {
        for (const std::string& diagnostic : naming.diagnostics)
            std::fprintf(stderr, "FAIL %s\n", diagnostic.c_str());
        return 1;
    }
    sir::source::Result readable = sir::source::render_module(
        models, root, &naming.naming);
    if (!readable.ok) {
        for (const std::string& failure : readable.failures)
            std::fprintf(stderr, "FAIL READABLE_%s\n", failure.c_str());
        return 1;
    }
    if (readable.omitted_orphan_prototypes != fidelity.omitted_orphan_prototypes) {
        std::fprintf(stderr, "FAIL READABLE_ORPHAN_PROTOTYPE_SET_DRIFT\n");
        return 1;
    }
    if (fidelity.used_dispatcher != readable.used_dispatcher
        || fidelity.used_frame_storage != readable.used_frame_storage) {
        std::fprintf(stderr, "FAIL READABLE_RENDER_STRATEGY_DRIFT\n");
        return 1;
    }

    const std::string readable_preamble = "-- RENOVICE_READABLE_VIEW_V1\n"
        "-- Identifier aliases are evidence-backed presentation only. "
        "Use the fidelity twin and TSV sidecar for exact provenance.\n";
    readable.source = readable_preamble + readable.source;
    sir::source::shift_call_spans(readable, readable_preamble.size());
    std::string metadata_failure;
    const size_t fidelity_before_metadata = fidelity.source.size();
    const size_t readable_before_metadata = readable.source.size();
    if (!semantic_ir_add_global_metadata(annotated, fidelity.source, metadata_failure)
        || !semantic_ir_add_global_metadata(annotated, readable.source,
                                            metadata_failure)) {
        std::fprintf(stderr, "FAIL %s\n", metadata_failure.c_str()); return 1;
    }
    sir::source::shift_call_spans(
        fidelity, fidelity.source.size() - fidelity_before_metadata);
    sir::source::shift_call_spans(
        readable, readable.source.size() - readable_before_metadata);

    // A readable view is only useful if its aliases remain valid Luau.  Gate
    // this before publishing any of the three coordinated artifacts.
    const std::string validation_source = "_readable_validate_"
        + std::to_string((long long)GetCurrentProcessId()) + ".luau";
    if (!write_file(validation_source, readable.source)) {
        std::fprintf(stderr, "FAIL READABLE_VALIDATION_TEMP_WRITE\n"); return 2;
    }
    std::string compile_error;
    const std::string compiled = compile_luau(validation_source, compile_error);
    std::remove(validation_source.c_str());
    if (compiled.empty()) {
        if (!failure_readable_output.empty()) {
            if (!write_file(failure_readable_output, readable.source)) {
                std::fprintf(stderr,
                    "FAIL READABLE_FAILURE_SOURCE_WRITE path=%s\n",
                    failure_readable_output.c_str());
                return 2;
            }
            std::fprintf(stderr, "INFO READABLE_FAILURE_SOURCE path=%s\n",
                         failure_readable_output.c_str());
        }
        std::fprintf(stderr, "FAIL READABLE_SOURCE_COMPILE %s\n",
                     compile_error.c_str());
        return 1;
    }

    const std::string mapping = sir::readable::to_tsv(naming);
    std::string callsite_failure;
    const std::string callsites = callsite_output.empty() ? std::string()
        : sir::readable::callsites_to_tsv(
            models, naming, fidelity, readable, callsite_failure);
    if (!callsite_output.empty() && callsites.empty()) {
        std::fprintf(stderr, "FAIL %s\n", callsite_failure.c_str());
        return 1;
    }
    if (!write_file(fidelity_output, fidelity.source)
        || !write_file(readable_output, readable.source)
        || !write_file(mapping_output, mapping)
        || (!callsite_output.empty() && !write_file(callsite_output, callsites))) {
        std::fprintf(stderr,
            "semantic-ir-render-module-readable: cannot write coordinated outputs\n");
        return 2;
    }
    for (const std::string& diagnostic : naming.diagnostics)
        std::fprintf(stderr, "WARN %s\n", diagnostic.c_str());
    std::printf("SEMANTIC_IR_RENDER_MODULE_READABLE root=%d prototypes=%zu "
                "aliases=%zu types=%zu sdk=%s status=RENDERED "
                "fidelity=%s readable=%s map=%s calls=%s\n",
                root, models.size(), naming.aliases.size(), naming.types.size(),
                naming.semantic_sdk_loaded ? "loaded" : "legacy-inputs",
                fidelity_output.c_str(), readable_output.c_str(),
                mapping_output.c_str(),
                callsite_output.empty() ? "disabled" : callsite_output.c_str());
    return 0;
}

static int cmd_semantic_ir_render_module_corpus(int argc, char** argv) {
    namespace fs2 = std::filesystem;
    ir_load_namebase();
    const fs2::path directory = argv[2];
    bool abilities_only = false, compile_rendered = false, readable_views = false;
    int limit = -1;
    int progress_every = 100;
    std::string json_path;
    std::string semantic_sdk_path;
    for (int argument = 3; argument < argc; ++argument) {
        const std::string value = argv[argument];
        if (value == "--abilities") abilities_only = true;
        else if (value == "--compile-rendered") compile_rendered = true;
        else if (value == "--readable") readable_views = true;
        else if (value == "--limit" && argument + 1 < argc)
            limit = std::atoi(argv[++argument]);
        else if (value == "--progress-every" && argument + 1 < argc)
            progress_every = std::max(1, std::atoi(argv[++argument]));
        else if (value == "--json-out" && argument + 1 < argc)
            json_path = argv[++argument];
        else if (value == "--semantic-sdk" && argument + 1 < argc)
            semantic_sdk_path = argv[++argument];
        else {
            std::fprintf(stderr,
                "semantic-ir-render-module-corpus: unknown/incomplete option %s\n",
                value.c_str());
            return 2;
        }
    }
    if (!fs2::is_directory(directory) || limit == 0) {
        std::fprintf(stderr, "semantic-ir-render-module-corpus: invalid directory or zero limit\n");
        return 2;
    }
    std::vector<fs2::path> files;
    for (const auto& entry : fs2::directory_iterator(directory)) {
        if (!entry.is_regular_file() || entry.path().extension() != ".lua_B") continue;
        if (abilities_only && !is_primary_ability_module_path(entry.path().string())) continue;
        files.push_back(entry.path());
    }
    std::sort(files.begin(), files.end());
    long long attempted_modules = 0, accepted_modules = 0, rejected_modules = 0;
    long long attempted_prototypes = 0, accepted_prototypes = 0;
    long long compiled_modules = 0, compile_failed = 0, source_bytes = 0;
    long long readable_attempted = 0, readable_rendered = 0;
    long long readable_failed = 0, readable_compiled = 0;
    long long readable_compile_failed = 0, readable_source_bytes = 0;
    long long readable_aliases = 0, readable_diagnostics = 0;
    long long readable_types = 0;
    long long semantic_failures = 0;
    long long contextual_attempted = 0, contextual_accepted = 0;
    long long contextual_rejected = 0, contextual_compiled = 0;
    long long contextual_compile_failed = 0, contextual_source_bytes = 0;
    long long contextual_dispatcher = 0;
    long long contextual_frame_storage = 0;
    std::map<std::string, long long> contextual_categories;
    std::map<std::string, long long> contextual_pure_categories;
    std::map<std::string, std::vector<std::string>> contextual_examples;
    std::map<std::string, long long> contextual_compile_categories;
    std::map<std::string, std::vector<std::string>> contextual_compile_examples;
    long long short_chain_nodes = 0;
    std::map<std::string, long long> short_terminal_roles;
    long long pure_escaping_prototypes = 0, pure_escaping_contracts = 0;
    std::map<std::string, long long> pure_escaping_shapes;
    std::map<std::string, long long> pure_escaping_dimensions;
    std::map<std::string, std::vector<std::string>> pure_escaping_examples;
    long long pure_shared_prototypes = 0, pure_shared_contracts = 0;
    std::map<std::string, long long> pure_shared_reasons;
    std::map<std::string, long long> pure_shared_shapes;
    std::map<std::string, std::vector<std::string>> pure_shared_examples;
    long long pure_shared_invalid_join_contracts = 0;
    std::map<std::string, long long> pure_shared_invalid_join_shapes;
    std::map<std::string, std::vector<std::string>>
        pure_shared_invalid_join_examples;
    long long pure_cyclic_prototypes = 0, pure_cyclic_contracts = 0;
    std::map<std::string, long long> pure_cyclic_shapes;
    std::map<std::string, std::vector<std::string>> pure_cyclic_examples;
    long long pure_duplicate_prototypes = 0;
    std::set<std::string> pure_duplicate_sites;
    std::map<std::string, long long> pure_duplicate_shapes;
    std::map<std::string, std::vector<std::string>> pure_duplicate_examples;
    std::map<std::string, long long> categories;
    std::vector<std::string> examples;
    std::vector<std::string> accepted_module_examples;
    for (const fs2::path& file : files) {
        if (limit > 0 && attempted_modules >= limit) break;
        ++attempted_modules;
        if (attempted_modules == 1 || attempted_modules % progress_every == 0) {
            std::fprintf(stderr,
                "semantic-ir-render-module-corpus: progress=%lld/%zu file=%s\n",
                attempted_modules, files.size(), file.filename().string().c_str());
            std::fflush(stderr);
        }
        try {
        g_primary_ability_loop_scope = is_primary_ability_module_path(file.string());
        const std::string bytes = read_file(file.string());
        de::Module module;
        try { module = de::walk(bytes); }
        catch (...) {
            ++semantic_failures; ++categories["RENDER_MODULE_WALK_FAILED"]; continue;
        }
        attempted_prototypes += (long long)module.protos.size();
        const std::vector<std::string> pool = ir::parse_pool(bytes);
        std::vector<ir::IProto> annotated;
        annotated.reserve(module.protos.size());
        for (size_t index = 0; index < module.protos.size(); ++index)
            annotated.push_back(ir_annotate(module.protos[index], (int)index, pool, g_nb));
        std::map<int, sir::Model> models;
        std::set<std::string> module_failures;
        for (size_t index = 0; index < annotated.size(); ++index) {
            if (!annotated[index].ok) {
                module_failures.insert("RENDER_MODULE_ANNOTATION_FAILED"); continue;
            }
            const sem::Manifest manifest = semcmd::build_manifest(annotated[index], (int)index);
            const sir::Adaptation adaptation = sir::adapt_manifest(
                annotated[index], manifest, annotated);
            const sir::Verification verification = sir::verify(adaptation.model);
            if (!adaptation.ok() || !verification.ok()) {
                module_failures.insert("RENDER_MODULE_SEMANTIC_IR_FAILED");
                continue;
            }
            models.emplace((int)index, adaptation.model);
        }
        if (!module_failures.empty() || models.size() != module.protos.size()) {
            ++semantic_failures; ++rejected_modules;
            for (const std::string& failure : module_failures) ++categories[failure];
            continue;
        }
        for (const auto& model : models) {
            std::map<int, const sir::BranchContract*> branches;
            for (const sir::BranchContract& branch : model.second.authoritative_branches)
                branches[branch.source.value] = &branch;
            auto role_name = [](sir::BranchRole role) {
                switch (role) {
                    case sir::BranchRole::Region: return "region";
                    case sir::BranchRole::LoopCondition: return "loop_condition";
                    case sir::BranchRole::Redundant: return "redundant";
                    case sir::BranchRole::ShortCircuitSharedTrue: return "short_true";
                    case sir::BranchRole::ShortCircuitSharedFalse: return "short_false";
                    case sir::BranchRole::ConditionalBreak: return "conditional_break";
                    case sir::BranchRole::ConditionalContinue: return "conditional_continue";
                    case sir::BranchRole::ConditionalBreakContinue:
                        return "conditional_break_continue";
                    case sir::BranchRole::PreservedCyclic: return "preserved_cyclic";
                    case sir::BranchRole::PreservedShared: return "preserved_shared";
                    case sir::BranchRole::PreservedEscaping: return "preserved_escaping";
                    case sir::BranchRole::Unresolved: return "unresolved";
                }
                return "invalid";
            };
            for (const sir::BranchContract& branch : model.second.authoritative_branches) {
                if (branch.role != sir::BranchRole::ShortCircuitSharedTrue
                    && branch.role != sir::BranchRole::ShortCircuitSharedFalse) continue;
                ++short_chain_nodes;
                const sir::BranchContract* terminal = &branch;
                std::set<int> seen;
                while ((terminal->role == sir::BranchRole::ShortCircuitSharedTrue
                        || terminal->role == sir::BranchRole::ShortCircuitSharedFalse)
                       && seen.insert(terminal->source.value).second) {
                    auto child = branches.find(terminal->chain_next.value);
                    if (child == branches.end()) break;
                    terminal = child->second;
                }
                ++short_terminal_roles[role_name(terminal->role)];
            }
            ++contextual_attempted;
            const sir::source::Result contextual =
                sir::source::render_semantic_with_module_context(model.second, models);
            if (!contextual.ok) {
                ++contextual_rejected;
                std::set<std::string> unique(contextual.failures.begin(),
                                             contextual.failures.end());
                if (unique.size() == 1) ++contextual_pure_categories[*unique.begin()];
                if (unique.size() == 1
                    && *unique.begin() == "RENDER_BLOCK_EMITTED_TWICE") {
                    ++pure_duplicate_prototypes;
                    const sir::BlockId duplicate = contextual.first_duplicate_block;
                    const int duplicate_prototype =
                        contextual.first_duplicate_prototype >= 0
                        ? contextual.first_duplicate_prototype : model.first;
                    auto duplicate_model_item = models.find(duplicate_prototype);
                    const sir::Model& duplicate_model =
                        duplicate_model_item != models.end()
                        ? duplicate_model_item->second : model.second;
                    pure_duplicate_sites.insert(file.filename().string()
                        + "#proto=" + std::to_string(duplicate_prototype)
                        + "#block=" + std::to_string(duplicate.value));
                    std::map<int, const sir::BranchContract*> duplicate_branches;
                    for (const sir::BranchContract& branch
                         : duplicate_model.authoritative_branches)
                        duplicate_branches[branch.source.value] = &branch;
                    int true_memberships = 0, false_memberships = 0;
                    int shared_memberships = 0, join_owners = 0;
                    int target_owners = 0, incoming = 0, outgoing = 0;
                    std::set<std::string> membership_roles;
                    for (const sir::BranchContract& branch
                         : duplicate_model.authoritative_branches) {
                        const bool in_true = branch.true_blocks.count(duplicate) != 0;
                        const bool in_false = branch.false_blocks.count(duplicate) != 0;
                        if (in_true) ++true_memberships;
                        if (in_false) ++false_memberships;
                        if (in_true && in_false) ++shared_memberships;
                        if (in_true || in_false)
                            membership_roles.insert(role_name(branch.role));
                        if (branch.join == duplicate) ++join_owners;
                        if (branch.true_target == duplicate
                            || branch.false_target == duplicate) ++target_owners;
                    }
                    for (const sir::Edge& edge : duplicate_model.cfg_edges) {
                        if (edge.target == duplicate) ++incoming;
                        if (edge.source == duplicate) ++outgoing;
                    }
                    std::string source_role = "linear";
                    auto duplicate_branch = duplicate_branches.find(duplicate.value);
                    if (duplicate_branch != duplicate_branches.end())
                        source_role = role_name(duplicate_branch->second->role);
                    const sir::AuthoritativeLoop* loop_owner = nullptr;
                    for (const auto& candidate
                         : duplicate_model.authoritative_loops) {
                        if (!candidate.second.body.count(duplicate)) continue;
                        if (!loop_owner
                            || candidate.second.body.size()
                                < loop_owner->body.size())
                            loop_owner = &candidate.second;
                    }
                    std::string loop_role = "outside";
                    if (loop_owner) {
                        if (duplicate.value == loop_owner->id.value)
                            loop_role = "header";
                        else if (duplicate == loop_owner->canonical_latch)
                            loop_role = "canonical_latch";
                        else if (loop_owner->latches.count(duplicate))
                            loop_role = "other_latch";
                        else loop_role = "body";
                    }
                    bool has_effect = false, has_return = false;
                    auto range = duplicate_model.block_instruction_ranges.find(
                        duplicate.value);
                    if (range != duplicate_model.block_instruction_ranges.end()) {
                        for (sir::EffectId effect
                             : duplicate_model.observable_effects)
                            if (effect.value >= range->second.first
                                && effect.value <= range->second.second)
                                has_effect = true;
                        for (const sir::ReturnContract& returned
                             : duplicate_model.authoritative_returns)
                            if (returned.instruction >= range->second.first
                                && returned.instruction <= range->second.second)
                                has_return = true;
                    }
                    std::string roles;
                    for (const std::string& role : membership_roles) {
                        if (!roles.empty()) roles += '+';
                        roles += role;
                    }
                    if (roles.empty()) roles = "none";
                    auto region_role = [&](sir::BlockId start, sir::BlockId stop) {
                        std::string value;
                        if (!start.valid()) value = "direct";
                        else {
                            auto branch = duplicate_branches.find(start.value);
                            value = branch == duplicate_branches.end()
                                ? "linear" : role_name(branch->second->role);
                        }
                        value += ':';
                        if (!stop.valid()) value += "exit";
                        else if (stop == duplicate) value += "duplicate";
                        else value += "other";
                        return value;
                    };
                    const std::string first_region = region_role(
                        contextual.duplicate_first_region_start,
                        contextual.duplicate_first_region_stop);
                    const std::string second_region = region_role(
                        contextual.duplicate_second_region_start,
                        contextual.duplicate_second_region_stop);
                    const std::string shape = "valid="
                        + std::string(duplicate.valid() ? "yes" : "no")
                        + ";source=" + source_role
                        + ";loop=" + loop_role
                        + ";memberships=" + std::to_string(true_memberships)
                        + "/" + std::to_string(false_memberships)
                        + ";shared=" + std::to_string(shared_memberships)
                        + ";member_roles=" + roles
                        + ";joins=" + std::to_string(join_owners)
                        + ";targets=" + std::to_string(target_owners)
                        + ";degree=" + std::to_string(incoming) + "/"
                        + std::to_string(outgoing)
                        + ";owners=" + first_region + "/" + second_region
                        + ";effect=" + (has_effect ? "yes" : "no")
                        + ";return=" + (has_return ? "yes" : "no");
                    ++pure_duplicate_shapes[shape];
                    auto& duplicate_examples = pure_duplicate_examples[shape];
                    if (duplicate_examples.size() < 5)
                        duplicate_examples.push_back(file.filename().string()
                            + "#proto=" + std::to_string(duplicate_prototype)
                            + "#block=" + std::to_string(duplicate.value)
                            + "#first="
                            + std::to_string(contextual.duplicate_first_region_start.value)
                            + "-"
                            + std::to_string(contextual.duplicate_first_region_stop.value)
                            + "#second="
                            + std::to_string(contextual.duplicate_second_region_start.value)
                            + "-"
                            + std::to_string(contextual.duplicate_second_region_stop.value));
                }
                if (unique.size() == 1
                    && *unique.begin() == "RENDER_PRESERVED_ESCAPING_SHAPE_PENDING") {
                    ++pure_escaping_prototypes;
                    for (const sir::BranchContract& branch
                         : model.second.authoritative_branches) {
                        if (branch.role != sir::BranchRole::PreservedEscaping) continue;
                        ++pure_escaping_contracts;
                        const std::string join_kind = branch.virtual_exit_join
                            ? "virtual_exit" : (branch.join.valid() ? "real" : "invalid");
                        const std::string escape_mode = branch.true_escapes_region
                            ? (branch.false_escapes_region ? "both" : "true")
                            : (branch.false_escapes_region ? "false" : "none");
                        const bool true_empty = branch.true_blocks.empty();
                        const bool false_empty = branch.false_blocks.empty();
                        const bool true_at_join = branch.join.valid()
                            && branch.true_target == branch.join;
                        const bool false_at_join = branch.join.valid()
                            && branch.false_target == branch.join;
                        auto bounded_recovery = [&](sir::BlockId start) {
                            if (!branch.join.valid()) return false;
                            std::set<sir::BlockId> blocks;
                            std::vector<sir::BlockId> pending;
                            if (start != branch.join) pending.push_back(start);
                            while (!pending.empty()) {
                                const sir::BlockId block = pending.back();
                                pending.pop_back();
                                if (block == branch.join || blocks.count(block)) continue;
                                if (!model.second.reachable_blocks.count(block)) return false;
                                blocks.insert(block);
                                bool has_successor = false;
                                for (const sir::Edge& edge : model.second.cfg_edges) {
                                    if (edge.source != block || !edge.target.valid()) continue;
                                    has_successor = true;
                                    if (edge.target == branch.join) continue;
                                    auto dominators = model.second.block_dominators.find(
                                        block.value);
                                    if (dominators != model.second.block_dominators.end()
                                        && dominators->second.count(edge.target.value))
                                        return false;
                                    pending.push_back(edge.target);
                                }
                                if (!has_successor) return false;
                            }
                            return true;
                        };
                        const bool true_bounded = branch.true_escapes_region && true_empty
                            && bounded_recovery(branch.true_target);
                        const bool false_bounded = branch.false_escapes_region && false_empty
                            && bounded_recovery(branch.false_target);
                        std::string loop_relation = "outside_loop";
                        const sir::AuthoritativeLoop* owner = nullptr;
                        for (const auto& candidate : model.second.authoritative_loops) {
                            if (!candidate.second.body.count(branch.source)) continue;
                            if (!owner || candidate.second.body.size() < owner->body.size())
                                owner = &candidate.second;
                        }
                        if (owner) {
                            const bool true_inside = owner->body.count(branch.true_target) != 0;
                            const bool false_inside = owner->body.count(branch.false_target) != 0;
                            const bool true_transfer = branch.true_target.value == owner->id.value
                                || branch.true_target == owner->canonical_latch;
                            const bool false_transfer = branch.false_target.value == owner->id.value
                                || branch.false_target == owner->canonical_latch;
                            if (true_transfer || false_transfer)
                                loop_relation = "loop_continue_target";
                            else if (true_inside != false_inside)
                                loop_relation = "loop_exit_split";
                            else if (true_inside && false_inside)
                                loop_relation = "both_inside_loop";
                            else loop_relation = "both_outside_loop";
                        }
                        const sir::BranchContract* enclosing = nullptr;
                        bool child_in_enclosing_true = false;
                        size_t enclosing_arm_size = (size_t)-1;
                        for (const sir::BranchContract& candidate
                             : model.second.authoritative_branches) {
                            if (candidate.source == branch.source) continue;
                            const bool in_true = candidate.true_blocks.count(
                                branch.source) != 0;
                            const bool in_false = candidate.false_blocks.count(
                                branch.source) != 0;
                            if (in_true == in_false) continue;
                            const size_t arm_size = in_true ? candidate.true_blocks.size()
                                                            : candidate.false_blocks.size();
                            if (!enclosing || arm_size < enclosing_arm_size) {
                                enclosing = &candidate;
                                child_in_enclosing_true = in_true;
                                enclosing_arm_size = arm_size;
                            }
                        }
                        std::string enclosing_shape = "none";
                        if (enclosing) {
                            const sir::BlockId escape_target = branch.true_escapes_region
                                ? branch.true_target : branch.false_target;
                            const sir::BlockId direct_target = branch.true_escapes_region
                                ? branch.false_target : branch.true_target;
                            const bool enclosing_other_direct_join = child_in_enclosing_true
                                ? (enclosing->false_target == enclosing->join
                                   && enclosing->false_blocks.empty())
                                : (enclosing->true_target == enclosing->join
                                   && enclosing->true_blocks.empty());
                            const bool child_direct_join = branch.join.valid()
                                && direct_target == branch.join;
                            const bool escape_is_enclosing_join = enclosing->join.valid()
                                && escape_target == enclosing->join;
                            const bool child_join_in_owner_arm = child_in_enclosing_true
                                ? enclosing->true_blocks.count(branch.join) != 0
                                : enclosing->false_blocks.count(branch.join) != 0;
                            enclosing_shape = "role="
                                + std::string(role_name(enclosing->role))
                                + ";arm=" + (child_in_enclosing_true ? "true" : "false")
                                + ";other_direct_join="
                                + (enclosing_other_direct_join ? "yes" : "no")
                                + ";child_direct_join="
                                + (child_direct_join ? "yes" : "no")
                                + ";escape_owner_join="
                                + (escape_is_enclosing_join ? "yes" : "no")
                                + ";child_join_in_arm="
                                + (child_join_in_owner_arm ? "yes" : "no");
                        }
                        ++pure_escaping_dimensions["join." + join_kind];
                        ++pure_escaping_dimensions["escape." + escape_mode];
                        ++pure_escaping_dimensions[std::string("true_blocks.")
                            + (true_empty ? "empty" : "nonempty")];
                        ++pure_escaping_dimensions[std::string("false_blocks.")
                            + (false_empty ? "empty" : "nonempty")];
                        ++pure_escaping_dimensions[std::string("true_terminal.")
                            + (branch.true_has_terminal ? "yes" : "no")];
                        ++pure_escaping_dimensions[std::string("false_terminal.")
                            + (branch.false_has_terminal ? "yes" : "no")];
                        ++pure_escaping_dimensions[std::string("true_target_join.")
                            + (true_at_join ? "yes" : "no")];
                        ++pure_escaping_dimensions[std::string("false_target_join.")
                            + (false_at_join ? "yes" : "no")];
                        ++pure_escaping_dimensions[std::string("true_escape_bounded.")
                            + (true_bounded ? "yes" : "no")];
                        ++pure_escaping_dimensions[std::string("false_escape_bounded.")
                            + (false_bounded ? "yes" : "no")];
                        ++pure_escaping_dimensions["loop." + loop_relation];
                        ++pure_escaping_dimensions["enclosing." + enclosing_shape];
                        const std::string shape = "join=" + join_kind
                            + ";escape=" + escape_mode
                            + ";empty=" + (true_empty ? "T" : "-")
                            + (false_empty ? "F" : "-")
                            + ";terminal=" + (branch.true_has_terminal ? "T" : "-")
                            + (branch.false_has_terminal ? "F" : "-")
                            + ";at_join=" + (true_at_join ? "T" : "-")
                            + (false_at_join ? "F" : "-")
                            + ";bounded=" + (true_bounded ? "T" : "-")
                            + (false_bounded ? "F" : "-")
                            + ";loop=" + loop_relation
                            + ";enclosing=" + enclosing_shape;
                        ++pure_escaping_shapes[shape];
                        auto& shape_examples = pure_escaping_examples[shape];
                        if (shape_examples.size() < 3)
                            shape_examples.push_back(file.filename().string()
                                + "#proto=" + std::to_string(model.first)
                                + "#block=" + std::to_string(branch.source.value));
                    }
                }
                if (unique.size() == 1
                    && *unique.begin() == "RENDER_PRESERVED_SHARED_PENDING") {
                    ++pure_shared_prototypes;
                    for (const sir::BranchContract& shared
                         : model.second.authoritative_branches) {
                        if (shared.role != sir::BranchRole::PreservedShared) continue;
                        ++pure_shared_contracts;
                        std::set<sir::BlockId> overlap, true_prefix, false_prefix;
                        std::set_intersection(shared.true_blocks.begin(),
                                              shared.true_blocks.end(),
                                              shared.false_blocks.begin(),
                                              shared.false_blocks.end(),
                                              std::inserter(overlap, overlap.begin()));
                        std::set_difference(shared.true_blocks.begin(),
                                            shared.true_blocks.end(),
                                            overlap.begin(), overlap.end(),
                                            std::inserter(true_prefix,
                                                          true_prefix.begin()));
                        std::set_difference(shared.false_blocks.begin(),
                                            shared.false_blocks.end(),
                                            overlap.begin(), overlap.end(),
                                            std::inserter(false_prefix,
                                                          false_prefix.begin()));
                        std::set<sir::BlockId> entries;
                        if (overlap.count(shared.true_target))
                            entries.insert(shared.true_target);
                        if (overlap.count(shared.false_target))
                            entries.insert(shared.false_target);
                        for (const sir::Edge& edge : model.second.cfg_edges)
                            if (edge.target.valid() && overlap.count(edge.target)
                                && !overlap.count(edge.source))
                                entries.insert(edge.target);
                        const bool terminal_shared_tail = !shared.join.valid()
                            && shared.virtual_exit_join
                            && shared.true_has_terminal
                            && shared.false_has_terminal;
                        if (!shared.join.valid() && shared.virtual_exit_join
                            && !terminal_shared_tail) {
                            ++pure_shared_invalid_join_contracts;
                            size_t shared_returns = 0, true_prefix_returns = 0;
                            size_t false_prefix_returns = 0, internal_backedges = 0;
                            std::set<sir::BlockId> shared_exit_targets;
                            std::set<std::string> shared_exit_kinds;
                            std::set<std::string> shared_exit_loop_roles;
                            auto edge_kind_name = [](sir::EdgeKind kind) {
                                switch (kind) {
                                    case sir::EdgeKind::Sequence: return "sequence";
                                    case sir::EdgeKind::Unconditional: return "jump";
                                    case sir::EdgeKind::BranchTrue: return "true";
                                    case sir::EdgeKind::BranchFalse: return "false";
                                    case sir::EdgeKind::LoopBack: return "loopback";
                                    case sir::EdgeKind::LoopExit: return "loopexit";
                                    case sir::EdgeKind::Break: return "break";
                                    case sir::EdgeKind::Continue: return "continue";
                                    case sir::EdgeKind::Return: return "return";
                                }
                                return "unknown";
                            };
                            for (const sir::Edge& edge : model.second.cfg_edges) {
                                if (overlap.count(edge.source)) {
                                    if (!edge.target.valid()) {
                                        ++shared_returns;
                                        shared_exit_kinds.insert(edge_kind_name(edge.kind));
                                    } else if (!overlap.count(edge.target)) {
                                        shared_exit_targets.insert(edge.target);
                                        shared_exit_kinds.insert(edge_kind_name(edge.kind));
                                        const sir::AuthoritativeLoop* edge_loop = nullptr;
                                        for (const auto& loop_item
                                             : model.second.authoritative_loops) {
                                            if (!loop_item.second.body.count(edge.source))
                                                continue;
                                            if (!edge_loop || loop_item.second.body.size()
                                                < edge_loop->body.size())
                                                edge_loop = &loop_item.second;
                                        }
                                        if (!edge_loop) {
                                            shared_exit_loop_roles.insert("outside_loop");
                                        } else if (edge.target.value
                                                   == edge_loop->id.value) {
                                            shared_exit_loop_roles.insert(
                                                "own_loop_header");
                                        } else if (edge.target
                                                   == edge_loop->canonical_latch) {
                                            shared_exit_loop_roles.insert(
                                                "own_canonical_latch");
                                        } else if (edge_loop->latches.count(
                                                       edge.target)) {
                                            shared_exit_loop_roles.insert(
                                                "own_other_latch");
                                        } else if (edge_loop->body.count(edge.target)) {
                                            shared_exit_loop_roles.insert(
                                                "own_loop_body");
                                        } else {
                                            shared_exit_loop_roles.insert(
                                                "outside_own_loop");
                                        }
                                    } else {
                                        auto dominators = model.second.block_dominators.find(
                                            edge.source.value);
                                        if (edge.kind == sir::EdgeKind::LoopBack
                                            || (dominators
                                                != model.second.block_dominators.end()
                                                && dominators->second.count(
                                                    edge.target.value)))
                                            ++internal_backedges;
                                    }
                                } else if (!edge.target.valid()) {
                                    if (true_prefix.count(edge.source))
                                        ++true_prefix_returns;
                                    if (false_prefix.count(edge.source))
                                        ++false_prefix_returns;
                                }
                            }
                            std::set<std::string> target_owners;
                            for (sir::BlockId target : shared_exit_targets) {
                                std::string owner = "external";
                                size_t best_arm_size = (size_t)-1;
                                for (const sir::BranchContract& candidate
                                     : model.second.authoritative_branches) {
                                    if (candidate.source == shared.source) continue;
                                    const std::set<sir::BlockId>* arm = nullptr;
                                    if (candidate.true_blocks.count(shared.source))
                                        arm = &candidate.true_blocks;
                                    if (candidate.false_blocks.count(shared.source)
                                        && (!arm || candidate.false_blocks.size()
                                            < arm->size()))
                                        arm = &candidate.false_blocks;
                                    if (!arm || arm->size() >= best_arm_size) continue;
                                    if (target == candidate.join) {
                                        owner = "enclosing_join";
                                        best_arm_size = arm->size();
                                    } else if (target == candidate.source) {
                                        owner = "enclosing_source";
                                        best_arm_size = arm->size();
                                    } else if (arm->count(target)) {
                                        owner = "same_enclosing_arm";
                                        best_arm_size = arm->size();
                                    }
                                }
                                target_owners.insert(owner);
                            }
                            std::string kinds, owners, loop_roles;
                            for (const std::string& kind : shared_exit_kinds) {
                                if (!kinds.empty()) kinds += '+';
                                kinds += kind;
                            }
                            for (const std::string& owner : target_owners) {
                                if (!owners.empty()) owners += '+';
                                owners += owner;
                            }
                            for (const std::string& loop_role
                                 : shared_exit_loop_roles) {
                                if (!loop_roles.empty()) loop_roles += '+';
                                loop_roles += loop_role;
                            }
                            if (kinds.empty()) kinds = "none";
                            if (owners.empty()) owners = "none";
                            if (loop_roles.empty()) loop_roles = "none";
                            const std::string invalid_shape = "terminal="
                                + std::string(shared.true_has_terminal ? "T" : "-")
                                + (shared.false_has_terminal ? "F" : "-")
                                + ";overlap=" + std::to_string(overlap.size())
                                + ";entries=" + std::to_string(entries.size())
                                + ";shared_returns="
                                + std::to_string(shared_returns)
                                + ";shared_targets="
                                + std::to_string(shared_exit_targets.size())
                                + ";exit_kinds=" + kinds
                                + ";target_owners=" + owners
                                + ";target_loop_roles=" + loop_roles
                                + ";internal_backedges="
                                + std::to_string(internal_backedges)
                                + ";prefix_returns="
                                + std::to_string(true_prefix_returns) + "/"
                                + std::to_string(false_prefix_returns);
                            ++pure_shared_invalid_join_shapes[invalid_shape];
                            auto& invalid_examples =
                                pure_shared_invalid_join_examples[invalid_shape];
                            if (invalid_examples.size() < 5)
                                invalid_examples.push_back(file.filename().string()
                                    + "#proto=" + std::to_string(model.first)
                                    + "#block="
                                    + std::to_string(shared.source.value));
                        }
                        auto escape_description = [&](const sir::Edge& edge,
                                                      const std::string& area) {
                            const char* kind = "unknown";
                            switch (edge.kind) {
                                case sir::EdgeKind::Sequence: kind = "sequence"; break;
                                case sir::EdgeKind::Unconditional: kind = "jump"; break;
                                case sir::EdgeKind::BranchTrue: kind = "true"; break;
                                case sir::EdgeKind::BranchFalse: kind = "false"; break;
                                case sir::EdgeKind::LoopBack: kind = "loopback"; break;
                                case sir::EdgeKind::LoopExit: kind = "loopexit"; break;
                                case sir::EdgeKind::Break: kind = "break"; break;
                                case sir::EdgeKind::Continue: kind = "continue"; break;
                                case sir::EdgeKind::Return: kind = "return"; break;
                            }
                            std::string target = "external";
                            if (!edge.target.valid()) target = "function_exit";
                            else if (overlap.count(edge.target)) target = "shared";
                            else if (true_prefix.count(edge.target)) target = "true_prefix";
                            else if (false_prefix.count(edge.target)) target = "false_prefix";
                            else if (edge.target == shared.source) target = "source";
                            else if (edge.target == shared.join) target = "join";
                            else {
                                size_t best_loop_size = (size_t)-1;
                                for (const auto& loop_item
                                     : model.second.authoritative_loops) {
                                    const sir::AuthoritativeLoop& loop = loop_item.second;
                                    if (!loop.body.count(edge.source)
                                        || loop.body.size() >= best_loop_size) continue;
                                    if (edge.target.value == loop.id.value) {
                                        target = "own_loop_header";
                                        best_loop_size = loop.body.size();
                                    } else if (loop.latches.count(edge.target)) {
                                        target = "own_loop_latch";
                                        best_loop_size = loop.body.size();
                                    }
                                }
                                size_t best_branch_size = (size_t)-1;
                                for (const sir::BranchContract& other
                                     : model.second.authoritative_branches) {
                                    if (other.source == shared.source) continue;
                                    const std::set<sir::BlockId>* owner_arm = nullptr;
                                    if (other.true_blocks.count(shared.source))
                                        owner_arm = &other.true_blocks;
                                    if (other.false_blocks.count(shared.source)
                                        && (!owner_arm
                                            || other.false_blocks.size()
                                                < owner_arm->size()))
                                        owner_arm = &other.false_blocks;
                                    if (!owner_arm
                                        || owner_arm->size() >= best_branch_size) continue;
                                    if (edge.target == other.join) {
                                        target = "enclosing_branch_join";
                                        best_branch_size = owner_arm->size();
                                    } else if (edge.target == other.source) {
                                        target = "enclosing_branch_source";
                                        best_branch_size = owner_arm->size();
                                    } else if (owner_arm->count(edge.target)) {
                                        target = "same_enclosing_arm";
                                        best_branch_size = owner_arm->size();
                                    }
                                }
                                if (target == "external") {
                                    for (const sir::BranchContract& other
                                         : model.second.authoritative_branches) {
                                        if (edge.target == other.source) {
                                            target = "unrelated_branch_source";
                                            break;
                                        }
                                        if (edge.target == other.join)
                                            target = "unrelated_branch_join";
                                    }
                                }
                            }
                            return area + "_" + kind + "_" + target;
                        };
                        std::string escape = "none";
                        std::string reason = "accepted";
                        if (!shared.join.valid() && !terminal_shared_tail)
                            reason = "join_invalid";
                        else if (overlap.empty()) reason = "overlap_empty";
                        else if (entries.size() != 1)
                            reason = "entry_count_" + std::to_string(entries.size());
                        else {
                            const sir::BlockId entry = *entries.begin();
                            if ((!true_prefix.empty()
                                 && !true_prefix.count(shared.true_target))
                                || (true_prefix.empty()
                                    && shared.true_target != entry))
                                reason = "true_prefix_target";
                            else if ((!false_prefix.empty()
                                      && !false_prefix.count(shared.false_target))
                                     || (false_prefix.empty()
                                         && shared.false_target != entry))
                                reason = "false_prefix_target";
                            else {
                                auto structural_exit = [](const sir::Edge& edge) {
                                    return edge.kind == sir::EdgeKind::LoopBack
                                        || edge.kind == sir::EdgeKind::LoopExit
                                        || edge.kind == sir::EdgeKind::Break
                                        || edge.kind == sir::EdgeKind::Continue
                                        || edge.kind == sir::EdgeKind::Return;
                                };
                                if (terminal_shared_tail) {
                                    bool saw_return = false;
                                    for (const sir::Edge& edge
                                         : model.second.cfg_edges) {
                                        if (!overlap.count(edge.source)) continue;
                                        if (!edge.target.valid()) {
                                            if (edge.kind != sir::EdgeKind::Return) {
                                                reason = "terminal_nonreturn_exit";
                                                escape = escape_description(edge, "shared");
                                                break;
                                            }
                                            saw_return = true;
                                        } else if (!overlap.count(edge.target)) {
                                            reason = "terminal_shared_edge_escape";
                                            escape = escape_description(edge, "shared");
                                            break;
                                        }
                                    }
                                    if (reason == "accepted" && !saw_return)
                                        reason = "terminal_return_missing";
                                }
                                for (const sir::Edge& edge : model.second.cfg_edges) {
                                    if (reason != "accepted") break;
                                    if (overlap.count(edge.source)) {
                                        if (edge.target.valid()
                                            && edge.target != shared.join
                                            && !overlap.count(edge.target)
                                            && (!structural_exit(edge)
                                                || terminal_shared_tail)) {
                                            reason = "shared_edge_escape";
                                            escape = escape_description(edge, "shared");
                                            break;
                                        }
                                    } else if (true_prefix.count(edge.source)) {
                                        if (edge.target.valid()
                                            && edge.target != shared.join
                                            && edge.target != entry
                                            && !true_prefix.count(edge.target)
                                            && !structural_exit(edge)) {
                                            reason = "true_prefix_edge_escape";
                                            escape = escape_description(edge, "true_prefix");
                                            break;
                                        }
                                    } else if (false_prefix.count(edge.source)) {
                                        if (edge.target.valid()
                                            && edge.target != shared.join
                                            && edge.target != entry
                                            && !false_prefix.count(edge.target)
                                            && !structural_exit(edge)) {
                                            reason = "false_prefix_edge_escape";
                                            escape = escape_description(edge, "false_prefix");
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        std::set<sir::BlockId> rejected_escape_targets;
                        std::set<sir::BlockId> rejected_escape_sources;
                        std::set<std::string> escape_decisions;
                        size_t rejected_escape_edges = 0;
                        size_t local_join_edges = 0;
                        auto is_structural_exit = [](const sir::Edge& edge) {
                            return edge.kind == sir::EdgeKind::LoopBack
                                || edge.kind == sir::EdgeKind::LoopExit
                                || edge.kind == sir::EdgeKind::Break
                                || edge.kind == sir::EdgeKind::Continue
                                || edge.kind == sir::EdgeKind::Return;
                        };
                        for (const sir::Edge& edge : model.second.cfg_edges) {
                            const bool partition_source = overlap.count(edge.source)
                                || true_prefix.count(edge.source)
                                || false_prefix.count(edge.source);
                            if (partition_source && shared.join.valid()
                                && edge.target == shared.join)
                                ++local_join_edges;
                            bool rejected_escape = false;
                            if (reason == "terminal_shared_edge_escape"
                                && overlap.count(edge.source)
                                && edge.target.valid()
                                && !overlap.count(edge.target))
                                rejected_escape = true;
                            else if (reason == "shared_edge_escape"
                                     && overlap.count(edge.source)
                                     && edge.target.valid()
                                     && edge.target != shared.join
                                     && !overlap.count(edge.target)
                                     && !is_structural_exit(edge))
                                rejected_escape = true;
                            else if (reason == "true_prefix_edge_escape"
                                     && true_prefix.count(edge.source)
                                     && edge.target.valid()
                                     && edge.target != shared.join
                                     && (entries.empty()
                                         || edge.target != *entries.begin())
                                     && !true_prefix.count(edge.target)
                                     && !is_structural_exit(edge))
                                rejected_escape = true;
                            else if (reason == "false_prefix_edge_escape"
                                     && false_prefix.count(edge.source)
                                     && edge.target.valid()
                                     && edge.target != shared.join
                                     && (entries.empty()
                                         || edge.target != *entries.begin())
                                     && !false_prefix.count(edge.target)
                                     && !is_structural_exit(edge))
                                rejected_escape = true;
                            if (rejected_escape) {
                                ++rejected_escape_edges;
                                rejected_escape_targets.insert(edge.target);
                                rejected_escape_sources.insert(edge.source);
                                auto decision = branches.find(edge.source.value);
                                if (decision == branches.end()) {
                                    escape_decisions.insert("linear");
                                } else {
                                    const sir::BranchContract& selector = *decision->second;
                                    const bool true_escape = selector.true_target == edge.target;
                                    const bool false_escape = selector.false_target == edge.target;
                                    const sir::BlockId other = true_escape && !false_escape
                                        ? selector.false_target : selector.true_target;
                                    std::string other_role = "external";
                                    if (!other.valid()) other_role = "function_exit";
                                    else if (other == shared.join) other_role = "local_join";
                                    else if (overlap.count(other)) other_role = "shared";
                                    else if (true_prefix.count(other))
                                        other_role = "true_prefix";
                                    else if (false_prefix.count(other))
                                        other_role = "false_prefix";
                                    else if (rejected_escape_targets.count(other))
                                        other_role = "continuation";
                                    escape_decisions.insert(
                                        std::string(role_name(selector.role)) + "_"
                                        + (true_escape && false_escape ? "both"
                                           : true_escape ? "true"
                                           : false_escape ? "false" : "nonbranch")
                                        + "_other_" + other_role);
                                }
                            }
                        }
                        std::string decision_shape;
                        for (const std::string& decision : escape_decisions) {
                            if (!decision_shape.empty()) decision_shape += "+";
                            decision_shape += decision;
                        }
                        if (decision_shape.empty()) decision_shape = "none";
                        std::set<sir::BlockId> false_chain_sources;
                        const sir::BranchContract* false_chain_terminal = nullptr;
                        if (!false_prefix.empty()) {
                            auto chain = branches.find(shared.false_target.value);
                            std::set<int> chain_seen;
                            while (chain != branches.end()
                                   && (chain->second->role
                                           == sir::BranchRole::ShortCircuitSharedTrue
                                       || chain->second->role
                                           == sir::BranchRole::ShortCircuitSharedFalse)
                                   && chain_seen.insert(
                                       chain->second->source.value).second) {
                                false_chain_sources.insert(chain->second->source);
                                chain = branches.find(
                                    chain->second->chain_next.value);
                            }
                            if (chain != branches.end()) {
                                false_chain_sources.insert(chain->second->source);
                                false_chain_terminal = chain->second;
                            }
                        }
                        size_t rejected_sources_in_false_chain = 0;
                        for (sir::BlockId source : rejected_escape_sources)
                            if (false_chain_sources.count(source))
                                ++rejected_sources_in_false_chain;
                        size_t false_prefix_chain_sources = 0;
                        for (sir::BlockId source : false_chain_sources)
                            if (false_prefix.count(source))
                                ++false_prefix_chain_sources;
                        size_t false_prefix_effect_blocks = 0;
                        for (sir::BlockId block : false_prefix) {
                            auto range = model.second.block_instruction_ranges.find(
                                block.value);
                            if (range == model.second.block_instruction_ranges.end())
                                continue;
                            bool has_effect = false;
                            for (sir::EffectId effect
                                 : model.second.observable_effects)
                                if (effect.value >= range->second.first
                                    && effect.value <= range->second.second) {
                                    has_effect = true;
                                    break;
                                }
                            if (has_effect) ++false_prefix_effect_blocks;
                        }
                        std::string false_chain_shared_side = "none";
                        std::string false_chain_escape_side = "none";
                        if (false_chain_terminal && entries.size() == 1) {
                            if (false_chain_terminal->true_target == *entries.begin())
                                false_chain_shared_side = "true";
                            else if (false_chain_terminal->false_target
                                     == *entries.begin())
                                false_chain_shared_side = "false";
                            if (rejected_escape_targets.size() == 1) {
                                const sir::BlockId escape_target =
                                    *rejected_escape_targets.begin();
                                if (false_chain_terminal->true_target
                                    == escape_target)
                                    false_chain_escape_side = "true";
                                else if (false_chain_terminal->false_target
                                         == escape_target)
                                    false_chain_escape_side = "false";
                            }
                        }
                        ++pure_shared_reasons[reason];
                        const std::string shape = "reason=" + reason
                            + ";join=" + (shared.join.valid() ? "real" : "invalid")
                            + ";virtual=" + (shared.virtual_exit_join ? "T" : "-")
                            + ";terminal="
                            + (shared.true_has_terminal ? "T" : "-")
                            + (shared.false_has_terminal ? "F" : "-")
                            + ";overlap=" + std::to_string(overlap.size())
                            + ";entries=" + std::to_string(entries.size())
                            + ";prefix=" + (true_prefix.empty() ? "-" : "T")
                            + (false_prefix.empty() ? "-" : "F")
                            + ";target_shared="
                            + (overlap.count(shared.true_target) ? "T" : "-")
                            + (overlap.count(shared.false_target) ? "F" : "-")
                            + ";escape=" + escape
                            + ";escape_edges="
                            + std::to_string(rejected_escape_edges)
                            + ";escape_targets="
                            + std::to_string(rejected_escape_targets.size())
                            + ";escape_sources="
                            + std::to_string(rejected_escape_sources.size())
                            + ";local_join_edges="
                            + std::to_string(local_join_edges)
                            + ";decisions=" + decision_shape
                            + ";false_prefix_blocks="
                            + std::to_string(false_prefix.size())
                            + ";false_prefix_effect_blocks="
                            + std::to_string(false_prefix_effect_blocks)
                            + ";false_chain_sources="
                            + std::to_string(false_chain_sources.size())
                            + ";false_prefix_chain_sources="
                            + std::to_string(false_prefix_chain_sources)
                            + ";rejected_sources_in_false_chain="
                            + std::to_string(rejected_sources_in_false_chain)
                            + ";false_chain_terminal="
                            + (false_chain_terminal
                               ? std::string(role_name(false_chain_terminal->role))
                               : "none")
                            + ";false_chain_shared=" + false_chain_shared_side
                            + ";false_chain_escape=" + false_chain_escape_side;
                        ++pure_shared_shapes[shape];
                        auto& shape_examples = pure_shared_examples[shape];
                        if (shape_examples.size() < 3)
                            shape_examples.push_back(file.filename().string()
                                + "#proto=" + std::to_string(model.first)
                                + "#block=" + std::to_string(shared.source.value));
                    }
                }
                if (unique.size() == 1
                    && *unique.begin() == "RENDER_PRESERVED_CYCLIC_PENDING") {
                    ++pure_cyclic_prototypes;
                    for (const sir::BranchContract& cyclic
                         : model.second.authoritative_branches) {
                        if (cyclic.role != sir::BranchRole::PreservedCyclic) continue;
                        ++pure_cyclic_contracts;
                        const bool true_self = cyclic.true_blocks.count(
                            cyclic.source) != 0;
                        const bool false_self = cyclic.false_blocks.count(
                            cyclic.source) != 0;
                        const sir::AuthoritativeLoop* owner = nullptr;
                        for (const auto& candidate : model.second.authoritative_loops) {
                            if (!candidate.second.body.count(cyclic.source)) continue;
                            if (!owner || candidate.second.body.size() < owner->body.size())
                                owner = &candidate.second;
                        }
                        std::string owner_relation = "none";
                        std::string target_relation = "no_loop";
                        std::string loop_kind = "none";
                        std::string true_role = "no_loop", false_role = "no_loop";
                        std::string true_reaches = "-", false_reaches = "-";
                        size_t iteration_true_blocks = 0;
                        size_t iteration_false_blocks = 0;
                        size_t iteration_overlap = 0;
                        size_t iteration_overlap_entries = 0;
                        std::string iteration_true_outcomes = "-";
                        std::string iteration_false_outcomes = "-";
                        bool iteration_true_closed = false;
                        bool iteration_false_closed = false;
                        if (owner) {
                            if (cyclic.source.value == owner->id.value)
                                owner_relation = "header";
                            else if (cyclic.source == owner->canonical_latch)
                                owner_relation = "canonical_latch";
                            else if (owner->latches.count(cyclic.source))
                                owner_relation = "other_latch";
                            else owner_relation = "body";
                            const bool true_inside = owner->body.count(
                                cyclic.true_target) != 0;
                            const bool false_inside = owner->body.count(
                                cyclic.false_target) != 0;
                            if (true_inside && false_inside) target_relation = "both_inside";
                            else if (true_inside) target_relation = "true_inside";
                            else if (false_inside) target_relation = "false_inside";
                            else target_relation = "both_outside";
                            for (const auto& node : model.second.nodes) {
                                if (node.second.loop.value != owner->id.value) continue;
                                if (node.second.kind == sir::NodeKind::While
                                    || node.second.kind == sir::NodeKind::Repeat
                                    || node.second.kind == sir::NodeKind::NumericFor
                                    || node.second.kind == sir::NodeKind::GenericFor) {
                                    loop_kind = sir::node_kind_name(node.second.kind);
                                    break;
                                }
                            }
                            auto target_role = [&](sir::BlockId target) {
                                if (target.value == owner->id.value) return std::string("header");
                                if (target == owner->canonical_latch)
                                    return std::string("canonical_latch");
                                if (owner->latches.count(target)) return std::string("other_latch");
                                if (model.second.authoritative_loops.count(
                                        sir::LoopId(target.value)))
                                    return std::string("nested_header");
                                bool exits = false;
                                for (const sir::Edge& edge : model.second.cfg_edges)
                                    if (edge.source == target && edge.target.valid()
                                        && !owner->body.count(edge.target)) exits = true;
                                return exits ? std::string("exit_proxy")
                                             : std::string("body");
                            };
                            auto reach_summary = [&](sir::BlockId target) {
                                bool reaches_header = false, reaches_exit = false;
                                bool reaches_return = false, reaches_latch = false;
                                std::set<sir::BlockId> visited;
                                std::vector<sir::BlockId> pending{target};
                                while (!pending.empty()) {
                                    const sir::BlockId block = pending.back();
                                    pending.pop_back();
                                    if (block == cyclic.source && block != target) {
                                        reaches_header = true; continue;
                                    }
                                    if (!owner->body.count(block)) {
                                        reaches_exit = true; continue;
                                    }
                                    if (!visited.insert(block).second) continue;
                                    if (owner->latches.count(block)) reaches_latch = true;
                                    bool had_edge = false;
                                    for (const sir::Edge& edge : model.second.cfg_edges) {
                                        if (edge.source != block) continue;
                                        had_edge = true;
                                        if (!edge.target.valid()) {
                                            if (edge.kind == sir::EdgeKind::Return)
                                                reaches_return = true;
                                            continue;
                                        }
                                        if (edge.target == cyclic.source) {
                                            reaches_header = true; continue;
                                        }
                                        if (!owner->body.count(edge.target)) {
                                            reaches_exit = true; continue;
                                        }
                                        pending.push_back(edge.target);
                                    }
                                    if (!had_edge) reaches_return = true;
                                }
                                std::string summary;
                                if (reaches_header) summary += 'H';
                                if (reaches_exit) summary += 'E';
                                if (reaches_return) summary += 'R';
                                if (reaches_latch) summary += 'L';
                                return summary.empty() ? std::string("-") : summary;
                            };
                            true_role = target_role(cyclic.true_target);
                            false_role = target_role(cyclic.false_target);
                            true_reaches = reach_summary(cyclic.true_target);
                            false_reaches = reach_summary(cyclic.false_target);

                            struct IterationArm {
                                std::set<sir::BlockId> blocks;
                                bool header = false;
                                bool latch = false;
                                bool exit = false;
                                bool terminal = false;
                                bool internal_cycle = false;
                            };
                            auto iteration_arm = [&](sir::BlockId target) {
                                IterationArm arm;
                                std::vector<sir::BlockId> pending{target};
                                while (!pending.empty()) {
                                    const sir::BlockId block = pending.back();
                                    pending.pop_back();
                                    if (block == cyclic.source) {
                                        arm.header = true;
                                        continue;
                                    }
                                    if (owner->latches.count(block)) {
                                        arm.latch = true;
                                        continue;
                                    }
                                    if (!owner->body.count(block)) {
                                        arm.exit = true;
                                        continue;
                                    }
                                    if (!arm.blocks.insert(block).second) continue;
                                    bool had_successor = false;
                                    for (const sir::Edge& edge
                                         : model.second.cfg_edges) {
                                        if (edge.source != block) continue;
                                        had_successor = true;
                                        if (!edge.target.valid()) {
                                            arm.terminal = true;
                                            continue;
                                        }
                                        if (edge.target == cyclic.source) {
                                            arm.header = true;
                                            continue;
                                        }
                                        if (owner->latches.count(edge.target)) {
                                            arm.latch = true;
                                            continue;
                                        }
                                        if (!owner->body.count(edge.target)) {
                                            arm.exit = true;
                                            continue;
                                        }
                                        auto dominators =
                                            model.second.block_dominators.find(
                                                block.value);
                                        if (dominators
                                                != model.second.block_dominators.end()
                                            && dominators->second.count(
                                                edge.target.value))
                                            arm.internal_cycle = true;
                                        pending.push_back(edge.target);
                                    }
                                    if (!had_successor) arm.terminal = true;
                                }
                                return arm;
                            };
                            const IterationArm true_iteration = iteration_arm(
                                cyclic.true_target);
                            const IterationArm false_iteration = iteration_arm(
                                cyclic.false_target);
                            iteration_true_blocks = true_iteration.blocks.size();
                            iteration_false_blocks = false_iteration.blocks.size();
                            std::set<sir::BlockId> iteration_shared;
                            std::set_intersection(
                                true_iteration.blocks.begin(),
                                true_iteration.blocks.end(),
                                false_iteration.blocks.begin(),
                                false_iteration.blocks.end(),
                                std::inserter(iteration_shared,
                                              iteration_shared.begin()));
                            iteration_overlap = iteration_shared.size();
                            std::set<sir::BlockId> iteration_entries;
                            if (iteration_shared.count(cyclic.true_target))
                                iteration_entries.insert(cyclic.true_target);
                            if (iteration_shared.count(cyclic.false_target))
                                iteration_entries.insert(cyclic.false_target);
                            for (const sir::Edge& edge : model.second.cfg_edges)
                                if (edge.target.valid()
                                    && iteration_shared.count(edge.target)
                                    && !iteration_shared.count(edge.source)
                                    && (true_iteration.blocks.count(edge.source)
                                        || false_iteration.blocks.count(
                                            edge.source)))
                                    iteration_entries.insert(edge.target);
                            iteration_overlap_entries = iteration_entries.size();
                            auto outcome_summary = [](const IterationArm& arm) {
                                std::string value;
                                if (arm.header) value += 'H';
                                if (arm.latch) value += 'L';
                                if (arm.exit) value += 'E';
                                if (arm.terminal) value += 'R';
                                if (arm.internal_cycle) value += 'C';
                                return value.empty() ? std::string("-") : value;
                            };
                            iteration_true_outcomes = outcome_summary(true_iteration);
                            iteration_false_outcomes = outcome_summary(false_iteration);
                            iteration_true_closed =
                                (true_iteration.header || true_iteration.latch)
                                && !true_iteration.exit && !true_iteration.terminal;
                            iteration_false_closed =
                                (false_iteration.header || false_iteration.latch)
                                && !false_iteration.exit && !false_iteration.terminal;
                        }
                        int incoming_to_source = 0;
                        int backedge_to_source = 0;
                        for (const sir::Edge& edge : model.second.cfg_edges) {
                            if (edge.target != cyclic.source) continue;
                            ++incoming_to_source;
                            auto dominators = model.second.block_dominators.find(
                                edge.source.value);
                            if (dominators != model.second.block_dominators.end()
                                && dominators->second.count(cyclic.source.value))
                                ++backedge_to_source;
                        }
                        const bool true_target_join = cyclic.join.valid()
                            && cyclic.true_target == cyclic.join;
                        const bool false_target_join = cyclic.join.valid()
                            && cyclic.false_target == cyclic.join;
                        const std::string shape = "join="
                            + std::string(cyclic.join.valid() ? "real"
                                : (cyclic.virtual_exit_join ? "virtual" : "invalid"))
                            + ";self=" + (true_self ? "T" : "-")
                            + (false_self ? "F" : "-")
                            + ";owner=" + owner_relation
                            + ";kind=" + loop_kind
                            + ";targets=" + target_relation
                            + ";roles=" + true_role + "/" + false_role
                            + ";reaches=" + true_reaches + "/" + false_reaches
                            + ";incoming=" + std::to_string(incoming_to_source)
                            + ";backedges=" + std::to_string(backedge_to_source)
                            + ";target_join=" + (true_target_join ? "T" : "-")
                            + (false_target_join ? "F" : "-")
                            + ";terminal=" + (cyclic.true_has_terminal ? "T" : "-")
                            + (cyclic.false_has_terminal ? "F" : "-")
                            + ";iter_blocks="
                            + std::to_string(iteration_true_blocks) + "/"
                            + std::to_string(iteration_false_blocks)
                            + ";iter_overlap="
                            + std::to_string(iteration_overlap)
                            + ";iter_entries="
                            + std::to_string(iteration_overlap_entries)
                            + ";iter_outcomes=" + iteration_true_outcomes + "/"
                            + iteration_false_outcomes
                            + ";iter_closed="
                            + (iteration_true_closed ? "T" : "-")
                            + (iteration_false_closed ? "F" : "-");
                        ++pure_cyclic_shapes[shape];
                        auto& shape_examples = pure_cyclic_examples[shape];
                        if (shape_examples.size() < 3)
                            shape_examples.push_back(file.filename().string()
                                + "#proto=" + std::to_string(model.first)
                                + "#block=" + std::to_string(cyclic.source.value));
                    }
                }
                for (const std::string& failure : unique) {
                    ++contextual_categories[failure];
                    auto& failure_examples = contextual_examples[failure];
                    if (failure_examples.size() < 3)
                        failure_examples.push_back(file.filename().string()
                            + "#proto=" + std::to_string(model.first));
                }
                continue;
            }
            ++contextual_accepted;
            if (contextual.used_dispatcher) ++contextual_dispatcher;
            if (contextual.used_frame_storage) ++contextual_frame_storage;
            contextual_source_bytes += (long long)contextual.source.size();
            if (compile_rendered) {
                const std::string temporary_source = "_sir_context_"
                    + std::to_string((long long)GetCurrentProcessId()) + ".luau";
                std::string error;
                if (!write_file(temporary_source, contextual.source)) {
                    ++contextual_compile_failed;
                    ++contextual_categories["RENDER_CONTEXT_TEMP_WRITE_FAILED"];
                } else {
                    const std::string bytecode = compile_luau(temporary_source, error);
                    std::remove(temporary_source.c_str());
                    if (bytecode.empty()) {
                        ++contextual_compile_failed;
                        ++contextual_categories["RENDER_CONTEXT_COMPILE_FAILED"];
                        auto& failure_examples = contextual_examples[
                            "RENDER_CONTEXT_COMPILE_FAILED"];
                        if (failure_examples.size() < 50)
                            failure_examples.push_back(file.filename().string()
                                + "#proto=" + std::to_string(model.first));
                        const std::string compile_category =
                            error.find("exceeded limit 200") != std::string::npos
                                ? "LUAU_ALLOCATOR_LIMIT_200"
                            : error.find("SyntaxError") != std::string::npos
                                ? "LUAU_SYNTAX_ERROR"
                            : error.find("CompileError") != std::string::npos
                                ? "LUAU_COMPILE_ERROR_OTHER"
                                : "LUAU_COMPILER_FAILURE_OTHER";
                        ++contextual_compile_categories[compile_category];
                        auto& compile_examples =
                            contextual_compile_examples[compile_category];
                        if (compile_examples.size() < 10) {
                            std::string first_line = error.substr(0, error.find('\n'));
                            compile_examples.push_back(file.filename().string()
                                + "#proto=" + std::to_string(model.first)
                                + "#diagnostic=" + first_line);
                        }
                    } else ++contextual_compiled;
                }
            }
        }
        size_t trailer_offset = 0;
        int root = -1;
        try { root = (int)de::rd_vi(module.trailer, trailer_offset); }
        catch (...) { module_failures.insert("RENDER_MODULE_ROOT_DECODE"); }
        sir::source::Result rendered;
        if (module_failures.empty()) rendered = sir::source::render_module(models, root);
        else rendered = {false, "", std::vector<std::string>(
            module_failures.begin(), module_failures.end())};
        if (!rendered.ok) {
            ++rejected_modules;
            std::set<std::string> unique(rendered.failures.begin(), rendered.failures.end());
            for (const std::string& failure : unique) {
                ++categories[failure];
                if (examples.size() < 100)
                    examples.push_back(file.filename().string() + "\t" + failure);
            }
            continue;
        }
        std::string metadata_failure;
        if (!semantic_ir_add_global_metadata(annotated, rendered.source, metadata_failure)) {
            ++rejected_modules;
            ++categories[metadata_failure];
            if (examples.size() < 100)
                examples.push_back(file.filename().string() + "\t" + metadata_failure);
            continue;
        }
        if (readable_views) {
            ++readable_attempted;
            const sir::readable::Plan naming = sir::readable::build_plan(
                models, "api/warframe/contracts.tsv",
                "api/warframe/selected_catalog.tsv", semantic_sdk_path);
            readable_aliases += (long long)naming.aliases.size();
            readable_types += (long long)naming.types.size();
            readable_diagnostics += (long long)naming.diagnostics.size();
            if (naming.semantic_sdk_requested && !naming.semantic_sdk_loaded) {
                ++readable_failed;
                ++categories["READABLE_SEMANTIC_SDK_LOAD_FAILED"];
                continue;
            }
            sir::source::Result readable = sir::source::render_module(
                models, root, &naming.naming);
            if (!readable.ok
                || readable.used_dispatcher != rendered.used_dispatcher
                || readable.used_frame_storage != rendered.used_frame_storage) {
                ++readable_failed;
                ++categories[!readable.ok
                    ? "READABLE_MODULE_RENDER_FAILED"
                    : "READABLE_MODULE_STRATEGY_DRIFT"];
            } else {
                readable.source = "-- RENOVICE_READABLE_VIEW_V1\n" + readable.source;
                std::string readable_metadata_failure;
                if (!semantic_ir_add_global_metadata(
                        annotated, readable.source, readable_metadata_failure)) {
                    ++readable_failed;
                    ++categories[readable_metadata_failure];
                } else {
                    ++readable_rendered;
                    readable_source_bytes += (long long)readable.source.size();
                    if (compile_rendered) {
                        const std::string temporary_source = "_sir_readable_"
                            + std::to_string((long long)GetCurrentProcessId())
                            + ".luau";
                        std::string error;
                        if (!write_file(temporary_source, readable.source)) {
                            ++readable_compile_failed;
                            ++categories["READABLE_MODULE_TEMP_WRITE_FAILED"];
                        } else {
                            const std::string bytecode = compile_luau(
                                temporary_source, error);
                            std::remove(temporary_source.c_str());
                            if (bytecode.empty()) {
                                ++readable_compile_failed;
                                ++categories["READABLE_MODULE_COMPILE_FAILED"];
                            } else {
                                try {
                                    const luau::Module compiled = luau::read(bytecode);
                                    if (compiled.protos.size() != module.protos.size()
                                        || compiled.mainid != (uint32_t)root) {
                                        ++readable_compile_failed;
                                        ++categories[
                                            "READABLE_MODULE_PROTOTYPE_TREE_CHANGED"];
                                    } else ++readable_compiled;
                                } catch (...) {
                                    ++readable_compile_failed;
                                    ++categories[
                                        "READABLE_MODULE_COMPILED_PARSE_FAILED"];
                                }
                            }
                        }
                    }
                }
            }
        }
        ++accepted_modules;
        accepted_module_examples.push_back(file.filename().string());
        accepted_prototypes += (long long)module.protos.size();
        source_bytes += (long long)rendered.source.size();
        if (compile_rendered) {
            const std::string temporary_source = "_sir_module_"
                + std::to_string((long long)GetCurrentProcessId()) + ".luau";
            std::string error;
            if (!write_file(temporary_source, rendered.source)) {
                ++compile_failed; ++categories["RENDER_MODULE_TEMP_WRITE_FAILED"];
            } else {
                const std::string bytecode = compile_luau(temporary_source, error);
                std::remove(temporary_source.c_str());
                if (bytecode.empty()) {
                    ++compile_failed; ++categories["RENDER_MODULE_COMPILE_FAILED"];
                } else {
                    try {
                        const luau::Module compiled = luau::read(bytecode);
                        if (compiled.protos.size() != module.protos.size()
                            || compiled.mainid != (uint32_t)root) {
                            ++compile_failed;
                            ++categories["RENDER_MODULE_PROTOTYPE_TREE_CHANGED"];
                        } else ++compiled_modules;
                    } catch (...) {
                        ++compile_failed; ++categories["RENDER_MODULE_COMPILED_PARSE_FAILED"];
                    }
                }
            }
        }
        } catch (const std::exception& exception) {
            ++semantic_failures;
            ++rejected_modules;
            ++categories["RENDER_MODULE_UNHANDLED_EXCEPTION"];
            if (examples.size() < 100)
                examples.push_back(file.filename().string()
                    + "\tRENDER_MODULE_UNHANDLED_EXCEPTION\t" + exception.what());
        } catch (...) {
            ++semantic_failures;
            ++rejected_modules;
            ++categories["RENDER_MODULE_UNHANDLED_NONSTANDARD_EXCEPTION"];
            if (examples.size() < 100)
                examples.push_back(file.filename().string()
                    + "\tRENDER_MODULE_UNHANDLED_NONSTANDARD_EXCEPTION");
        }
    }
    std::printf("== SEMANTIC IR MODULE RENDER CORPUS ==\n");
    std::printf("scope=%s modules=%lld accepted=%lld rejected=%lld semantic_failed=%lld\n",
                abilities_only ? "abilities" : "all", attempted_modules,
                accepted_modules, rejected_modules, semantic_failures);
    std::printf("prototypes=%lld accepted=%lld source_bytes=%lld\n",
                attempted_prototypes, accepted_prototypes, source_bytes);
        std::printf("context_renderer=attempted:%lld,accepted:%lld,rejected:%lld,source_bytes:%lld,frame_storage:%lld\n",
                    contextual_attempted, contextual_accepted, contextual_rejected,
                    contextual_source_bytes, contextual_frame_storage);
    if (compile_rendered)
        std::printf("context_renderer_compile=passed:%lld,failed:%lld\n",
                    contextual_compiled, contextual_compile_failed);
    std::printf("short_chain_nodes=%lld", short_chain_nodes);
    for (const auto& role : short_terminal_roles)
        std::printf(" %s:%lld", role.first.c_str(), role.second);
    std::printf("\n");
    if (compile_rendered)
        std::printf("module_compile=passed:%lld,failed:%lld\n",
                    compiled_modules, compile_failed);
    if (readable_views) {
        std::printf("readable=attempted:%lld,rendered:%lld,failed:%lld,aliases:%lld,"
                    "types:%lld,diagnostics:%lld,source_bytes:%lld\n",
                    readable_attempted, readable_rendered, readable_failed,
                    readable_aliases, readable_types, readable_diagnostics,
                    readable_source_bytes);
        if (compile_rendered)
            std::printf("readable_compile=passed:%lld,failed:%lld\n",
                        readable_compiled, readable_compile_failed);
    }
    for (const auto& category : categories)
        std::printf("MODULE_REJECTION %-44s modules=%lld\n",
                    category.first.c_str(), category.second);
    if (!json_path.empty()) {
        std::ostringstream json;
        json << "{\n  \"schema\": 1,\n  \"scope\": \""
             << (abilities_only ? "abilities" : "all") << "\",\n"
             << "  \"module_limit\": " << limit << ",\n"
             << "  \"modules\": " << attempted_modules << ",\n"
             << "  \"accepted_modules\": " << accepted_modules << ",\n"
             << "  \"rejected_modules\": " << rejected_modules << ",\n"
             << "  \"semantic_failed_modules\": " << semantic_failures << ",\n"
             << "  \"prototypes\": " << attempted_prototypes << ",\n"
             << "  \"accepted_prototypes\": " << accepted_prototypes << ",\n"
             << "  \"source_bytes\": " << source_bytes << ",\n"
             << "  \"context_renderer\": {\n"
             << "    \"attempted\": " << contextual_attempted << ",\n"
             << "    \"accepted\": " << contextual_accepted << ",\n"
             << "    \"dispatcher\": " << contextual_dispatcher << ",\n"
             << "    \"frame_storage\": " << contextual_frame_storage << ",\n"
             << "    \"rejected\": " << contextual_rejected << ",\n"
             << "    \"source_bytes\": " << contextual_source_bytes << ",\n"
             << "    \"compiled\": " << contextual_compiled << ",\n"
             << "    \"compile_failed\": " << contextual_compile_failed << ",\n"
             << "    \"rejection_categories\": {";
        bool context_first = true;
        for (const auto& category : contextual_categories) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(category.first)
                 << "\": " << category.second;
        }
        if (!contextual_categories.empty()) json << '\n';
        json << "    },\n    \"pure_rejection_categories\": {";
        context_first = true;
        for (const auto& category : contextual_pure_categories) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(category.first)
                 << "\": " << category.second;
        }
        if (!contextual_pure_categories.empty()) json << '\n';
        json << "    },\n    \"compile_failure_categories\": {";
        context_first = true;
        for (const auto& category : contextual_compile_categories) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(category.first)
                 << "\": " << category.second;
        }
        if (!contextual_compile_categories.empty()) json << '\n';
        json << "    },\n    \"compile_failure_examples\": {";
        context_first = true;
        for (const auto& category : contextual_compile_examples) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(category.first) << "\": [";
            for (size_t example = 0; example < category.second.size(); ++example) {
                if (example) json << ',';
                json << '"' << sir::json_escape(category.second[example]) << '"';
            }
            json << ']';
        }
        if (!contextual_compile_examples.empty()) json << '\n';
        json << "    },\n    \"rejection_examples\": {";
        context_first = true;
        for (const auto& category : contextual_examples) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(category.first) << "\": [";
            for (size_t example = 0; example < category.second.size(); ++example) {
                if (example) json << ',';
                json << '"' << sir::json_escape(category.second[example]) << '"';
            }
            json << ']';
        }
        if (!contextual_examples.empty()) json << '\n';
        json << "    }\n  },\n"
             << "  \"short_chain_terminal_roles\": {\n"
             << "    \"nodes\": " << short_chain_nodes << ",\n"
             << "    \"roles\": {";
        context_first = true;
        for (const auto& role : short_terminal_roles) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(role.first)
                 << "\": " << role.second;
        }
        if (!short_terminal_roles.empty()) json << '\n';
        json << "    }\n  },\n"
             << "  \"pure_preserved_cyclic_census\": {\n"
             << "    \"prototypes\": " << pure_cyclic_prototypes << ",\n"
             << "    \"contracts\": " << pure_cyclic_contracts << ",\n"
             << "    \"shapes\": {";
        context_first = true;
        for (const auto& shape : pure_cyclic_shapes) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(shape.first)
                 << "\": " << shape.second;
        }
        if (!pure_cyclic_shapes.empty()) json << '\n';
        json << "    },\n    \"examples\": {";
        context_first = true;
        for (const auto& shape : pure_cyclic_examples) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(shape.first) << "\": [";
            for (size_t example = 0; example < shape.second.size(); ++example) {
                if (example) json << ',';
                json << '\"' << sir::json_escape(shape.second[example]) << '\"';
            }
            json << ']';
        }
        if (!pure_cyclic_examples.empty()) json << '\n';
        json << "    }\n  },\n"
             << "  \"pure_block_emitted_twice_census\": {\n"
             << "    \"prototypes\": " << pure_duplicate_prototypes << ",\n"
             << "    \"unique_sites\": " << pure_duplicate_sites.size() << ",\n"
             << "    \"shapes\": {";
        context_first = true;
        for (const auto& shape : pure_duplicate_shapes) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(shape.first)
                 << "\": " << shape.second;
        }
        if (!pure_duplicate_shapes.empty()) json << '\n';
        json << "    },\n    \"examples\": {";
        context_first = true;
        for (const auto& shape : pure_duplicate_examples) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(shape.first) << "\": [";
            for (size_t example = 0; example < shape.second.size(); ++example) {
                if (example) json << ',';
                json << '\"' << sir::json_escape(shape.second[example]) << '\"';
            }
            json << ']';
        }
        if (!pure_duplicate_examples.empty()) json << '\n';
        json << "    }\n  },\n"
             << "  \"pure_preserved_shared_census\": {\n"
             << "    \"prototypes\": " << pure_shared_prototypes << ",\n"
             << "    \"contracts\": " << pure_shared_contracts << ",\n"
             << "    \"reasons\": {";
        context_first = true;
        for (const auto& reason : pure_shared_reasons) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(reason.first)
                 << "\": " << reason.second;
        }
        if (!pure_shared_reasons.empty()) json << '\n';
        json << "    },\n    \"shapes\": {";
        context_first = true;
        for (const auto& shape : pure_shared_shapes) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(shape.first)
                 << "\": " << shape.second;
        }
        if (!pure_shared_shapes.empty()) json << '\n';
        json << "    },\n    \"examples\": {";
        context_first = true;
        for (const auto& shape : pure_shared_examples) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(shape.first) << "\": [";
            for (size_t example = 0; example < shape.second.size(); ++example) {
                if (example) json << ',';
                json << '\"' << sir::json_escape(shape.second[example]) << '\"';
            }
            json << ']';
        }
        if (!pure_shared_examples.empty()) json << '\n';
        json << "    }\n  },\n"
             << "  \"pure_shared_invalid_join_census\": {\n"
             << "    \"contracts\": "
             << pure_shared_invalid_join_contracts << ",\n"
             << "    \"shapes\": {";
        context_first = true;
        for (const auto& shape : pure_shared_invalid_join_shapes) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(shape.first)
                 << "\": " << shape.second;
        }
        if (!pure_shared_invalid_join_shapes.empty()) json << '\n';
        json << "    },\n    \"examples\": {";
        context_first = true;
        for (const auto& shape : pure_shared_invalid_join_examples) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(shape.first) << "\": [";
            for (size_t example = 0; example < shape.second.size(); ++example) {
                if (example) json << ',';
                json << '\"' << sir::json_escape(shape.second[example]) << '\"';
            }
            json << ']';
        }
        if (!pure_shared_invalid_join_examples.empty()) json << '\n';
        json << "    }\n  },\n"
             << "  \"pure_preserved_escaping_census\": {\n"
             << "    \"prototypes\": " << pure_escaping_prototypes << ",\n"
             << "    \"contracts\": " << pure_escaping_contracts << ",\n"
             << "    \"dimensions\": {";
        context_first = true;
        for (const auto& dimension : pure_escaping_dimensions) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(dimension.first)
                 << "\": " << dimension.second;
        }
        if (!pure_escaping_dimensions.empty()) json << '\n';
        json << "    },\n    \"shapes\": {";
        context_first = true;
        for (const auto& shape : pure_escaping_shapes) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(shape.first)
                 << "\": " << shape.second;
        }
        if (!pure_escaping_shapes.empty()) json << '\n';
        json << "    },\n    \"examples\": {";
        context_first = true;
        for (const auto& shape : pure_escaping_examples) {
            if (!context_first) json << ',';
            context_first = false;
            json << "\n      \"" << sir::json_escape(shape.first) << "\": [";
            for (size_t example = 0; example < shape.second.size(); ++example) {
                if (example) json << ',';
                json << '\"' << sir::json_escape(shape.second[example]) << '\"';
            }
            json << ']';
        }
        if (!pure_escaping_examples.empty()) json << '\n';
        json << "    }\n  },\n"
             << "  \"compile_requested\": " << (compile_rendered ? "true" : "false") << ",\n"
             << "  \"compiled_modules\": " << compiled_modules << ",\n"
             << "  \"compile_failed\": " << compile_failed << ",\n"
             << "  \"readable_requested\": " << (readable_views ? "true" : "false") << ",\n"
             << "  \"readable_attempted\": " << readable_attempted << ",\n"
             << "  \"readable_rendered\": " << readable_rendered << ",\n"
             << "  \"readable_failed\": " << readable_failed << ",\n"
             << "  \"readable_aliases\": " << readable_aliases << ",\n"
             << "  \"readable_types\": " << readable_types << ",\n"
             << "  \"readable_diagnostics\": " << readable_diagnostics << ",\n"
             << "  \"readable_source_bytes\": " << readable_source_bytes << ",\n"
             << "  \"readable_compiled\": " << readable_compiled << ",\n"
             << "  \"readable_compile_failed\": " << readable_compile_failed << ",\n"
             << "  \"rejection_categories\": {";
        bool first = true;
        for (const auto& category : categories) {
            if (!first) json << ',';
            first = false;
            json << "\n    \"" << sir::json_escape(category.first)
                 << "\": " << category.second;
        }
        if (!categories.empty()) json << '\n';
        json << "  },\n  \"accepted_module_examples\": [";
        for (size_t index = 0; index < accepted_module_examples.size(); ++index) {
            if (index) json << ',';
            json << "\n    \"" << sir::json_escape(accepted_module_examples[index]) << '"';
        }
        if (!accepted_module_examples.empty()) json << '\n';
        json << "  ],\n  \"examples\": [";
        for (size_t index = 0; index < examples.size(); ++index) {
            if (index) json << ',';
            json << "\n    \"" << sir::json_escape(examples[index]) << '"';
        }
        if (!examples.empty()) json << '\n';
        json << "  ]\n}\n";
        const fs2::path destination = json_path;
        std::error_code error;
        if (destination.has_parent_path()) fs2::create_directories(
            destination.parent_path(), error);
        if (error || !write_file(json_path, json.str())) {
            std::fprintf(stderr, "semantic-ir-render-module-corpus: cannot write JSON\n");
            return 2;
        }
        std::printf("json=%s\n", json_path.c_str());
    }
    return attempted_modules > 0 && semantic_failures == 0 && compile_failed == 0
        && contextual_compile_failed == 0 && readable_failed == 0
        && readable_compile_failed == 0 ? 0 : 1;
}

static int cmd_semantic_ir_verify_corpus(int argc, char** argv) {
    namespace fs2 = std::filesystem;
    ir_load_namebase();
    const fs2::path directory = argv[2];
    bool abilities_only = false;
    bool compile_rendered = false;
    int limit = -1;
    std::string json_path;
    for (int argument = 3; argument < argc; ++argument) {
        const std::string value = argv[argument];
        if (value == "--abilities") abilities_only = true;
        else if (value == "--compile-rendered") compile_rendered = true;
        else if (value == "--limit" && argument + 1 < argc) limit = std::atoi(argv[++argument]);
        else if (value == "--json-out" && argument + 1 < argc) json_path = argv[++argument];
    }
    if (!fs2::is_directory(directory) || limit == 0) {
        std::fprintf(stderr, "semantic-ir-verify-corpus: invalid directory or zero limit\n");
        return 2;
    }
    std::vector<fs2::path> files;
    for (const auto& entry : fs2::directory_iterator(directory)) {
        if (!entry.is_regular_file() || entry.path().extension() != ".lua_B") continue;
        if (abilities_only && !is_primary_ability_module_path(entry.path().string())) continue;
        files.push_back(entry.path());
    }
    std::sort(files.begin(), files.end());
    long long attempted = 0, verified = 0, failed = 0, blocks = 0, effects = 0, loops = 0;
    long long closure_sites = 0, captures = 0, declared_upvalues = 0;
    long long value_captures = 0, reference_captures = 0, upvalue_captures = 0;
    long long control_edges = 0, branch_nodes = 0, return_nodes = 0, fallthrough_nodes = 0;
    long long loop_entry_nodes = 0, boolean_skip_nodes = 0;
    long long linear_transfer_nodes = 0, join_transfer_nodes = 0;
    long long loop_latch_nodes = 0, loop_exit_transfer_nodes = 0;
    long long loop_condition_nodes = 0, redundant_predicate_nodes = 0;
    long long short_circuit_true_nodes = 0, short_circuit_false_nodes = 0;
    long long conditional_break_nodes = 0, conditional_continue_nodes = 0;
    long long conditional_break_continue_nodes = 0;
    long long preserved_cyclic_nodes = 0, preserved_shared_nodes = 0;
    long long preserved_escaping_nodes = 0;
    long long unresolved_branch_nodes = 0;
    long long unresolved_control_nodes = 0;
    long long unresolved_unconditional = 0, unresolved_loopback = 0;
    long long unresolved_loopexit = 0, unresolved_other = 0;
    long long unconditional_forward = 0, unconditional_backward = 0, unconditional_self = 0;
    long long unconditional_single_predecessor = 0, unconditional_multi_predecessor = 0;
    long long unconditional_source_dominates_target = 0, unconditional_target_ipostdom = 0;
    long long unconditional_same_loop = 0, unconditional_enters_loop = 0;
    long long unconditional_exits_loop = 0, unconditional_outside_loops = 0;
    long long unconditional_targets_header = 0, unconditional_targets_prep = 0;
    long long unconditional_reducible = 0, unconditional_irreducible = 0;
    std::map<std::string, long long> unconditional_opcodes;
    std::map<std::string, long long> unresolved_shape_masks;
    long long predicates = 0, proven_branch_regions = 0, proven_loop_conditions = 0;
    long long redundant_predicates = 0;
    long long proven_virtual_exit_regions = 0;
    long long proven_shared_entry_regions = 0;
    long long proven_short_circuit_true = 0, proven_short_circuit_false = 0;
    long long proven_conditional_break = 0, proven_conditional_continue = 0;
    long long proven_break_continue = 0;
    long long explicit_preserved_cyclic = 0, explicit_preserved_shared = 0;
    long long explicit_preserved_escaping = 0;
    long long reducible_prototypes = 0, irreducible_prototypes = 0;
    long long preserved_in_reducible = 0, preserved_in_irreducible = 0;
    long long reachable_instructions = 0, value_effect_unknown = 0;
    long long instructions_with_uses = 0, instructions_with_defs = 0;
    long long register_uses = 0, register_defs = 0;
    long long calls = 0, calls_open_arguments = 0, calls_open_results = 0;
    long long owned_calls = 0, owned_method_calls = 0, owned_ordinary_calls = 0;
    long long owned_open_arguments = 0, owned_open_results = 0;
    long long owned_call_callee_links = 0, owned_call_receiver_links = 0;
    long long owned_call_argument_values = 0, owned_call_argument_links = 0;
    long long owned_call_multi_origin_arguments = 0;
    long long owned_returns = 0, owned_fixed_returns = 0, owned_open_returns = 0;
    long long owned_return_values = 0, owned_return_origin_links = 0;
    long long owned_return_multi_origin_values = 0;
    long long owned_table_operations = 0, owned_table_allocations = 0;
    long long owned_table_writes = 0, owned_table_setlist_fixed = 0;
    long long owned_table_setlist_open = 0, owned_table_origin_links = 0;
    long long owned_table_value_links = 0, owned_table_key_links = 0;
    long long owned_table_fixed_list_values = 0;
    long long capture_value_origin_links = 0, capture_reference_origin_links = 0;
    long long capture_reference_cells = 0, capture_parent_upvalue_links = 0;
    long long scope_close_boundaries = 0;
    long long local_values = 0, local_parameters = 0, local_definitions = 0;
    long long local_dead_values = 0, local_use_links = 0, local_intervals = 0;
    long long local_multiblock_values = 0, local_hoisted_declarations = 0;
    long long local_live_in_intervals = 0, local_live_out_intervals = 0;
    long long local_reused_registers = 0, local_reuse_identities = 0;
    long long local_capture_copy_links = 0, local_capture_share_links = 0;
    long long value_webs = 0, singleton_value_webs = 0, merged_value_webs = 0;
    long long value_web_members = 0, value_web_hoisted = 0;
    long long value_merges = 0, conditional_merges = 0, loop_merges = 0;
    long long conditional_loop_merges = 0, preserved_merges = 0;
    long long expression_definitions = 0, expression_operand_slots = 0;
    long long expression_origin_links = 0, expression_multi_origin_operands = 0;
    long long expression_open_results = 0, expression_open_operands = 0;
    long long expression_scaffolding = 0, expression_preserved = 0;
    std::map<std::string, long long> expression_kinds;
    long long selected_definitions = 0, explicit_statement_definitions = 0;
    long long statement_owners = 0, grouped_statement_members = 0;
    long long inline_literals = 0, inline_literals_cross_block = 0;
    long long structural_definitions = 0;
    long long literal_candidates = 0, literal_blocked_multiuse = 0;
    long long literal_blocked_multi_origin = 0, literal_blocked_capture = 0;
    long long literal_blocked_dominance = 0, literal_blocked_merged_web = 0;
    std::map<std::string, long long> inline_expression_kinds;
    long long returns = 0, returns_open_results = 0;
    long long vararg_reads = 0, vararg_open_results = 0;
    std::map<std::string, long long> opcode_instructions;
    std::map<std::string, long long> opcode_with_uses, opcode_with_defs;
    std::map<std::string, long long> opcode_register_uses, opcode_register_defs;
    std::map<std::string, long long> opcode_unknown_effects;
    long long value_flow_known = 0, value_flow_unknown = 0, value_flow_nonconverged = 0;
    long long value_definitions = 0, open_value_definitions = 0;
    long long value_uses = 0, value_links = 0, single_origin_uses = 0;
    long long multiple_origin_uses = 0, missing_origin_uses = 0;
    long long parameter_origin_uses = 0, entry_origin_uses = 0;
    long long open_range_uses = 0;
    long long top_known = 0, top_unknown = 0, top_nonconverged = 0;
    long long top_consumers = 0, top_single_origin = 0, top_multiple_origin = 0;
    long long top_missing_origin = 0, top_from_fixed = 0, top_from_call = 0;
    long long top_from_vararg = 0, top_cross_block = 0;
    long long top_call_consumers = 0, top_return_consumers = 0;
    long long top_setlist_consumers = 0, top_open_producers = 0;
    long long top_unconsumed_producers = 0, top_multiply_consumed_producers = 0;
    long long predicate_no_join = 0, predicate_overlap = 0, predicate_escape = 0;
    long long predicate_source_cycle = 0;
    long long predicate_expression_trees = 0, predicate_expression_nodes = 0;
    long long predicate_expression_leaves = 0, compound_predicate_trees = 0;
    long long predicate_expression_max_leaves = 0, predicate_expression_mismatches = 0;
    long long predicate_empty_true = 0, predicate_empty_false = 0;
    long long predicate_both_nonempty = 0, predicate_terminal_arms = 0;
    long long overlap_unresolved = 0, overlap_with_escape = 0;
    long long overlap_with_source_cycle = 0, overlap_with_no_real_join = 0;
    long long overlap_true_target_shared = 0, overlap_false_target_shared = 0;
    long long overlap_both_targets_shared = 0, overlap_neither_target_shared = 0;
    long long overlap_true_exclusive_empty = 0, overlap_false_exclusive_empty = 0;
    long long overlap_both_exclusive_nonempty = 0;
    long long overlap_blocks_total = 0, overlap_blocks_maximum = 0;
    long long chain_true_to_predicate = 0, chain_false_to_predicate = 0;
    long long chain_and_same_false = 0, chain_or_same_true = 0;
    long long chain_true_cross_outcome = 0, chain_false_cross_outcome = 0;
    long long loop_local_unresolved = 0, loop_break_candidates = 0;
    long long loop_continue_candidates = 0, loop_break_continue_candidates = 0;
    long long loop_two_inside_candidates = 0, loop_two_outside_candidates = 0;
    long long loop_source_header_or_latch = 0;
    size_t files_touched = 0;
    std::map<std::string, long long> categories;
    std::map<std::string, long long> observation_categories;
    long long renderer_accepted = 0, renderer_rejected = 0;
    long long renderer_source_bytes = 0;
    long long renderer_compiled = 0, renderer_compile_failed = 0;
    std::map<std::string, long long> renderer_rejection_categories;
    std::map<std::string, std::vector<std::string>> renderer_rejection_examples;
    std::map<std::string, long long> renderer_missing_block_shapes;
    long long renderer_pure_block_coverage = 0;
    std::map<std::string, long long> renderer_block_coverage_companions;
    std::vector<std::string> examples;
    for (const fs2::path& file : files) {
        if (limit > 0 && attempted >= limit) break;
        ++files_touched;
        const std::string path = file.string();
        g_primary_ability_loop_scope = is_primary_ability_module_path(path);
        const std::string bytes = read_file(path);
        de::Module module;
        try { module = de::walk(bytes); }
        catch (...) { ++categories["WALK_FAILED"]; continue; }
        const std::vector<std::string> pool = ir::parse_pool(bytes);
        std::vector<ir::IProto> annotated;
        annotated.reserve(module.protos.size());
        for (size_t index = 0; index < module.protos.size(); ++index)
            annotated.push_back(ir_annotate(module.protos[index], (int)index, pool, g_nb));
        for (size_t index = 0; index < module.protos.size(); ++index) {
            if (limit > 0 && attempted >= limit) break;
            ++attempted;
            const ir::IProto& proto = annotated[index];
            if (!proto.ok) {
                ++failed; ++categories["ANNOTATE_FAILED"];
                if (examples.size() < 100) examples.push_back(file.filename().string()
                    + "\tproto=" + std::to_string(index) + "\tANNOTATE_FAILED");
                continue;
            }
            const sem::Manifest manifest = semcmd::build_manifest(proto, (int)index);
            const sir::vf::Analysis value_flow = sir::vf::analyze(proto, manifest);
            bool value_flow_ok = value_flow.known && value_flow.converged;
            const sir::vf::TopAnalysis top_flow = sir::vf::analyze_top(proto, manifest);
            bool top_flow_ok = sir::vf::top_contracts_closed(proto, manifest, top_flow);
            if (!value_flow.known) ++value_flow_unknown;
            else if (!value_flow.converged) ++value_flow_nonconverged;
            else {
                ++value_flow_known;
                value_definitions += (long long)value_flow.definitions.size();
                for (const sir::vf::Definition& definition : value_flow.definitions)
                    if (definition.open_range) ++open_value_definitions;
                value_uses += (long long)value_flow.uses.size();
                for (const sir::vf::Use& use : value_flow.uses) {
                    value_links += (long long)use.reaching.size();
                    if (use.open_range) ++open_range_uses;
                    if (use.reaching.empty()) {
                        ++missing_origin_uses;
                        value_flow_ok = false;
                    }
                    else if (use.reaching.size() == 1) ++single_origin_uses;
                    else ++multiple_origin_uses;
                    bool parameter = false, entry = false;
                    for (const sir::vf::Origin& origin : use.reaching) {
                        if (origin.kind == sir::vf::OriginKind::Parameter) parameter = true;
                        else if (origin.kind == sir::vf::OriginKind::EntryRegister) entry = true;
                    }
                    if (parameter) ++parameter_origin_uses;
                    if (entry) ++entry_origin_uses;
                }
            }
            if (!top_flow.known) ++top_unknown;
            else if (!top_flow.converged) ++top_nonconverged;
            else {
                ++top_known;
                std::map<int, int> instruction_block;
                std::set<int> open_producers;
                for (const auto& range_item : manifest.block_instruction_ranges)
                    for (int instruction = range_item.second.first;
                         instruction <= range_item.second.second; ++instruction)
                        instruction_block[instruction] = range_item.first;
                for (const auto& instruction_item : instruction_block) {
                    const ir::IInsn& candidate = proto.code[instruction_item.first];
                    if ((candidate.op == 0x54 && candidate.C == 0)
                        || (candidate.op == 0x4c && candidate.B == 0))
                        open_producers.insert(instruction_item.first);
                }
                top_open_producers += (long long)open_producers.size();
                std::map<int, int> producer_consumption;
                top_consumers += (long long)top_flow.uses.size();
                for (const sir::vf::TopUse& use : top_flow.uses) {
                    if (use.opcode == 0x54) ++top_call_consumers;
                    else if (use.opcode == 0x29) ++top_return_consumers;
                    else if (use.opcode == 0x3f) ++top_setlist_consumers;
                    if (use.reaching.empty()) {
                        ++top_missing_origin;
                        top_flow_ok = false;
                    } else if (use.reaching.size() == 1) ++top_single_origin;
                    else ++top_multiple_origin;
                    bool fixed = false, call = false, vararg = false, cross = false;
                    for (const sir::vf::TopOrigin& origin : use.reaching) {
                        if (origin.kind == sir::vf::TopKind::Fixed) fixed = true;
                        else if (origin.kind == sir::vf::TopKind::OpenCall) call = true;
                        else if (origin.kind == sir::vf::TopKind::OpenVararg) vararg = true;
                        if (origin.kind == sir::vf::TopKind::OpenCall
                            || origin.kind == sir::vf::TopKind::OpenVararg)
                            ++producer_consumption[origin.instruction];
                        if (origin.instruction >= 0
                            && instruction_block[origin.instruction]
                                != instruction_block[use.instruction]) cross = true;
                    }
                    if (fixed) ++top_from_fixed;
                    if (call) ++top_from_call;
                    if (vararg) ++top_from_vararg;
                    if (cross) ++top_cross_block;
                }
                for (int producer : open_producers) {
                    const int count = producer_consumption[producer];
                    if (count == 0) ++top_unconsumed_producers;
                    else if (count > 1) ++top_multiply_consumed_producers;
                }
            }
            if (manifest.reducible) ++reducible_prototypes;
            else ++irreducible_prototypes;
            std::set<int> reachable_instruction_indices;
            for (const auto& range_item : manifest.block_instruction_ranges)
                for (int instruction = range_item.second.first;
                     instruction <= range_item.second.second
                         && instruction < (int)proto.code.size(); ++instruction)
                    if (instruction >= 0) reachable_instruction_indices.insert(instruction);
            for (int instruction : reachable_instruction_indices) {
                const ir::IInsn& insn = proto.code[instruction];
                const std::string& opcode = insn.name;
                ++reachable_instructions;
                ++opcode_instructions[opcode];
                std::set<int> uses, defs;
                if (!lv::register_effects(proto, insn, uses, defs)) {
                    ++value_effect_unknown;
                    ++opcode_unknown_effects[opcode];
                } else {
                    if (!uses.empty()) {
                        ++instructions_with_uses;
                        ++opcode_with_uses[opcode];
                    }
                    if (!defs.empty()) {
                        ++instructions_with_defs;
                        ++opcode_with_defs[opcode];
                    }
                    register_uses += (long long)uses.size();
                    register_defs += (long long)defs.size();
                    opcode_register_uses[opcode] += (long long)uses.size();
                    opcode_register_defs[opcode] += (long long)defs.size();
                }
                if (insn.op == 0x54) {
                    ++calls;
                    if (insn.B == 0) ++calls_open_arguments;
                    if (insn.C == 0) ++calls_open_results;
                } else if (insn.op == 0x29) {
                    ++returns;
                    if (insn.B == 0) ++returns_open_results;
                } else if (insn.op == 0x4c) {
                    ++vararg_reads;
                    if (insn.B == 0) ++vararg_open_results;
                }
            }
            std::map<int, const sem::PredicatePlan*> predicate_by_block;
            for (const sem::PredicatePlan& predicate : manifest.predicates)
                predicate_by_block[predicate.block] = &predicate;
            for (const sem::PredicatePlan& predicate : manifest.predicates) {
                ++predicates;
                if (predicate.role == "loop_condition" && predicate.proven)
                    ++proven_loop_conditions;
                else if (predicate.role == "redundant_predicate" && predicate.proven)
                    ++redundant_predicates;
                else if (predicate.role == "branch_region" && predicate.proven)
                    ++proven_branch_regions;
                else if (predicate.role == "short_circuit_shared_true"
                         && predicate.proven) ++proven_short_circuit_true;
                else if (predicate.role == "short_circuit_shared_false"
                         && predicate.proven) ++proven_short_circuit_false;
                else if (predicate.role == "conditional_break" && predicate.proven)
                    ++proven_conditional_break;
                else if (predicate.role == "conditional_continue" && predicate.proven)
                    ++proven_conditional_continue;
                else if (predicate.role == "conditional_break_continue" && predicate.proven)
                    ++proven_break_continue;
                else if (predicate.role == "preserved_cyclic")
                    ++explicit_preserved_cyclic;
                else if (predicate.role == "preserved_shared")
                    ++explicit_preserved_shared;
                else if (predicate.role == "preserved_escaping")
                    ++explicit_preserved_escaping;
                if (predicate.explicitly_preserved) {
                    if (manifest.reducible) ++preserved_in_reducible;
                    else ++preserved_in_irreducible;
                }
                if (predicate.role == "branch_region" && predicate.proven
                    && predicate.virtual_exit_join)
                    ++proven_virtual_exit_regions;
                if (predicate.role == "branch_region" && predicate.proven
                    && predicate.shared_entry_join)
                    ++proven_shared_entry_regions;
                if (predicate.join < 0) ++predicate_no_join;
                if (!predicate.overlap_blocks.empty()) ++predicate_overlap;
                if (predicate.true_escapes_region || predicate.false_escapes_region)
                    ++predicate_escape;
                if (predicate.true_blocks.count(predicate.block)
                    || predicate.false_blocks.count(predicate.block))
                    ++predicate_source_cycle;
                if (predicate.true_blocks.empty()) ++predicate_empty_true;
                if (predicate.false_blocks.empty()) ++predicate_empty_false;
                if (!predicate.true_blocks.empty() && !predicate.false_blocks.empty())
                    ++predicate_both_nonempty;
                if (predicate.true_has_terminal || predicate.false_has_terminal)
                    ++predicate_terminal_arms;
                if (!predicate.proven && !predicate.overlap_blocks.empty()) {
                    ++overlap_unresolved;
                    overlap_blocks_total += (long long)predicate.overlap_blocks.size();
                    overlap_blocks_maximum = std::max(overlap_blocks_maximum,
                        (long long)predicate.overlap_blocks.size());
                    if (predicate.true_escapes_region || predicate.false_escapes_region)
                        ++overlap_with_escape;
                    if (predicate.true_blocks.count(predicate.block)
                        || predicate.false_blocks.count(predicate.block))
                        ++overlap_with_source_cycle;
                    if (predicate.join < 0) ++overlap_with_no_real_join;
                    const bool true_shared = predicate.overlap_blocks.count(
                        predicate.true_target) != 0;
                    const bool false_shared = predicate.overlap_blocks.count(
                        predicate.false_target) != 0;
                    if (true_shared) ++overlap_true_target_shared;
                    if (false_shared) ++overlap_false_target_shared;
                    if (true_shared && false_shared) ++overlap_both_targets_shared;
                    else if (!true_shared && !false_shared) ++overlap_neither_target_shared;
                    std::set<int> true_exclusive, false_exclusive;
                    std::set_difference(predicate.true_blocks.begin(), predicate.true_blocks.end(),
                                        predicate.overlap_blocks.begin(),
                                        predicate.overlap_blocks.end(),
                                        std::inserter(true_exclusive, true_exclusive.begin()));
                    std::set_difference(predicate.false_blocks.begin(), predicate.false_blocks.end(),
                                        predicate.overlap_blocks.begin(),
                                        predicate.overlap_blocks.end(),
                                        std::inserter(false_exclusive, false_exclusive.begin()));
                    if (true_exclusive.empty()) ++overlap_true_exclusive_empty;
                    if (false_exclusive.empty()) ++overlap_false_exclusive_empty;
                    if (!true_exclusive.empty() && !false_exclusive.empty())
                        ++overlap_both_exclusive_nonempty;
                }
                if (!predicate.proven) {
                    std::string residual_mask;
                    if (predicate.join < 0) residual_mask += 'N';
                    if (predicate.virtual_exit_join) residual_mask += 'V';
                    if (!predicate.overlap_blocks.empty()) residual_mask += 'O';
                    if (predicate.true_escapes_region || predicate.false_escapes_region)
                        residual_mask += 'E';
                    if (predicate.true_blocks.count(predicate.block)
                        || predicate.false_blocks.count(predicate.block)) residual_mask += 'C';
                    if (predicate.true_has_terminal || predicate.false_has_terminal)
                        residual_mask += 'T';
                    if (residual_mask.empty()) residual_mask = "clean_residual";
                    ++unresolved_shape_masks[residual_mask];
                    auto true_child = predicate_by_block.find(predicate.true_target);
                    if (true_child != predicate_by_block.end()) {
                        ++chain_true_to_predicate;
                        if (predicate.false_target == true_child->second->false_target)
                            ++chain_and_same_false;
                        if (predicate.false_target == true_child->second->true_target)
                            ++chain_true_cross_outcome;
                    }
                    auto false_child = predicate_by_block.find(predicate.false_target);
                    if (false_child != predicate_by_block.end()) {
                        ++chain_false_to_predicate;
                        if (predicate.true_target == false_child->second->true_target)
                            ++chain_or_same_true;
                        if (predicate.true_target == false_child->second->false_target)
                            ++chain_false_cross_outcome;
                    }
                    const sem::LoopPlan* owner = nullptr;
                    for (const auto& loop_item : manifest.loops) {
                        const sem::LoopPlan& candidate = loop_item.second;
                        if (!candidate.body.count(predicate.block)) continue;
                        if (!owner || candidate.body.size() < owner->body.size())
                            owner = &candidate;
                    }
                    if (owner) {
                        ++loop_local_unresolved;
                        if (predicate.block == owner->header
                            || owner->latches.count(predicate.block))
                            ++loop_source_header_or_latch;
                        const bool true_inside = owner->body.count(
                            predicate.true_target) != 0;
                        const bool false_inside = owner->body.count(
                            predicate.false_target) != 0;
                        const bool true_continue = predicate.true_target == owner->header
                            || predicate.true_target == owner->canonical_latch;
                        const bool false_continue = predicate.false_target == owner->header
                            || predicate.false_target == owner->canonical_latch;
                        const bool one_outside = true_inside != false_inside;
                        const bool one_continue = true_continue != false_continue
                            && ((true_continue && false_inside)
                                || (false_continue && true_inside));
                        if (one_outside) ++loop_break_candidates;
                        if (one_continue) ++loop_continue_candidates;
                        if ((true_continue && !false_inside)
                            || (false_continue && !true_inside))
                            ++loop_break_continue_candidates;
                        if (true_inside && false_inside) ++loop_two_inside_candidates;
                        if (!true_inside && !false_inside) ++loop_two_outside_candidates;
                    }
                }
            }
            const sir::Adaptation adaptation = sir::adapt_manifest(proto, manifest, annotated);
            const sir::Verification verification = sir::verify(adaptation.model);
            std::set<std::string> prototype_observations(adaptation.observations.begin(),
                                                         adaptation.observations.end());
            for (const std::string& observation : prototype_observations)
                ++observation_categories[observation];
            blocks += (long long)adaptation.model.reachable_blocks.size();
            effects += (long long)adaptation.model.observable_effects.size();
            loops += (long long)adaptation.model.authoritative_loops.size();
            predicate_expression_trees += (long long)
                adaptation.model.authoritative_predicate_expressions.size();
            if (adaptation.model.authoritative_predicate_expressions.size()
                != manifest.predicates.size()) ++predicate_expression_mismatches;
            for (const sir::PredicateExpressionContract& expression :
                 adaptation.model.authoritative_predicate_expressions) {
                predicate_expression_nodes += (long long)expression.nodes.size();
                long long leaves = 0;
                for (const sir::PredicateExpressionNodeContract& node : expression.nodes)
                    if (node.kind == sir::PredicateExpressionKind::Test) ++leaves;
                predicate_expression_leaves += leaves;
                if (leaves > 1) ++compound_predicate_trees;
                predicate_expression_max_leaves = std::max(
                    predicate_expression_max_leaves, leaves);
            }
            closure_sites += (long long)adaptation.model.authoritative_closures.size();
            captures += (long long)adaptation.model.authoritative_captures.size();
            declared_upvalues += adaptation.model.authoritative_upvalue_count;
            owned_calls += (long long)adaptation.model.authoritative_calls.size();
            for (const sir::CallContract& call : adaptation.model.authoritative_calls) {
                if (call.method_call) ++owned_method_calls;
                else ++owned_ordinary_calls;
                if (call.argument_count < 0) ++owned_open_arguments;
                if (call.result_count < 0) ++owned_open_results;
                owned_call_callee_links += (long long)call.callee_origins.size();
                owned_call_receiver_links += (long long)call.receiver_origins.size();
                owned_call_argument_values +=
                    (long long)call.fixed_argument_origins.size();
                for (const auto& origins : call.fixed_argument_origins) {
                    owned_call_argument_links += (long long)origins.size();
                    if (origins.size() > 1) ++owned_call_multi_origin_arguments;
                }
            }
            owned_returns += (long long)adaptation.model.authoritative_returns.size();
            for (const sir::ReturnContract& value : adaptation.model.authoritative_returns) {
                if (value.value_count < 0) ++owned_open_returns;
                else {
                    ++owned_fixed_returns;
                    owned_return_values += value.value_count;
                    for (const auto& origins : value.fixed_values) {
                        owned_return_origin_links += (long long)origins.size();
                        if (origins.size() > 1) ++owned_return_multi_origin_values;
                    }
                }
            }
            owned_table_operations +=
                (long long)adaptation.model.authoritative_table_operations.size();
            for (const sir::TableOperationContract& operation :
                 adaptation.model.authoritative_table_operations) {
                if (operation.kind == sir::TableOperationKind::NewTable
                    || operation.kind == sir::TableOperationKind::DuplicateTemplate)
                    ++owned_table_allocations;
                else ++owned_table_writes;
                if (operation.kind == sir::TableOperationKind::SetList) {
                    if (operation.list_value_count < 0) ++owned_table_setlist_open;
                    else ++owned_table_setlist_fixed;
                }
                owned_table_origin_links += (long long)operation.table_origins.size();
                owned_table_value_links += (long long)operation.value_origins.size();
                owned_table_key_links += (long long)operation.key_origins.size();
                for (const auto& origins : operation.list_fixed_values) {
                    ++owned_table_fixed_list_values;
                    owned_table_value_links += (long long)origins.size();
                }
            }
            for (const sir::CaptureContract& capture : adaptation.model.authoritative_captures) {
                if (capture.mode == sir::CaptureMode::Value) {
                    ++value_captures;
                    capture_value_origin_links += (long long)capture.source_origins.size();
                } else if (capture.mode == sir::CaptureMode::Reference) {
                    ++reference_captures; ++capture_reference_cells;
                    capture_reference_origin_links += (long long)capture.source_origins.size();
                } else if (capture.mode == sir::CaptureMode::Upvalue) {
                    ++upvalue_captures; ++capture_parent_upvalue_links;
                }
            }
            scope_close_boundaries +=
                (long long)adaptation.model.authoritative_scope_closes.size();
            local_values += (long long)adaptation.model.authoritative_local_values.size();
            std::map<int, long long> identities_per_register;
            for (const sir::LocalValueContract& value :
                 adaptation.model.authoritative_local_values) {
                ++identities_per_register[value.identity.reg];
                if (value.parameter) ++local_parameters; else ++local_definitions;
                if (value.uses.empty()) ++local_dead_values;
                local_use_links += (long long)value.uses.size();
                local_intervals += (long long)value.lifetimes.size();
                if (value.lifetimes.size() > 1) ++local_multiblock_values;
                if (value.declaration_block != value.definition_block)
                    ++local_hoisted_declarations;
                for (const sir::LocalBlockLifetime& lifetime : value.lifetimes) {
                    if (lifetime.live_in) ++local_live_in_intervals;
                    if (lifetime.live_out) ++local_live_out_intervals;
                }
                local_capture_copy_links +=
                    (long long)value.copied_by_captures.size();
                local_capture_share_links +=
                    (long long)value.shared_by_captures.size();
            }
            for (const auto& identities : identities_per_register)
                if (identities.second > 1) {
                    ++local_reused_registers;
                    local_reuse_identities += identities.second;
                }
            value_webs += (long long)adaptation.model.authoritative_value_webs.size();
            std::map<sir::ValueOriginContract, sir::BlockId> local_definition_blocks;
            std::map<int, size_t> selection_web_member_counts;
            for (const sir::LocalValueContract& local :
                 adaptation.model.authoritative_local_values)
                local_definition_blocks[local.identity] = local.definition_block;
            for (const sir::ValueWebContract& web :
                 adaptation.model.authoritative_value_webs) {
                selection_web_member_counts[web.id] = web.members.size();
                value_web_members += (long long)web.members.size();
                if (web.members.size() == 1) ++singleton_value_webs;
                else ++merged_value_webs;
                bool differs = false;
                for (const sir::ValueOriginContract& member : web.members)
                    if (local_definition_blocks[member] != web.declaration_block) {
                        differs = true; break;
                    }
                if (differs) ++value_web_hoisted;
            }
            value_merges += (long long)adaptation.model.authoritative_value_merges.size();
            for (const sir::ValueMergeContract& merge :
                 adaptation.model.authoritative_value_merges) {
                if (merge.kind == sir::ValueMergeKind::Conditional) ++conditional_merges;
                else if (merge.kind == sir::ValueMergeKind::LoopCarried) ++loop_merges;
                else if (merge.kind == sir::ValueMergeKind::ConditionalLoop)
                    ++conditional_loop_merges;
                else ++preserved_merges;
            }
            expression_definitions +=
                (long long)adaptation.model.authoritative_expressions.size();
            for (const sir::ExpressionDefinitionContract& expression :
                 adaptation.model.authoritative_expressions) {
                ++expression_kinds[sir::expressions::kind_name(expression.kind)];
                expression_operand_slots += (long long)expression.operands.size();
                for (const auto& operand : expression.operands) {
                    expression_origin_links += (long long)operand.size();
                    if (operand.size() > 1) ++expression_multi_origin_operands;
                }
                if (expression.open_result) ++expression_open_results;
                if (expression.open_operands) ++expression_open_operands;
                if (expression.compiler_scaffolding) ++expression_scaffolding;
                if (expression.kind == sir::ExpressionKind::Preserved)
                    ++expression_preserved;
            }
            std::map<sir::ValueOriginContract,
                     const sir::ExpressionDefinitionContract*> selection_expressions;
            for (const sir::ExpressionDefinitionContract& expression :
                 adaptation.model.authoritative_expressions) {
                selection_expressions[expression.identity] = &expression;
                if (sir::selection::literal_kind(expression.kind)) ++literal_candidates;
            }
            selected_definitions += (long long)
                adaptation.model.authoritative_definition_emissions.size();
            for (const sir::DefinitionEmissionContract& emission :
                 adaptation.model.authoritative_definition_emissions) {
                const auto expression = selection_expressions.find(emission.identity);
                if (emission.disposition == sir::EmissionDisposition::ExplicitStatement) {
                    ++explicit_statement_definitions;
                    if (emission.emits_statement) ++statement_owners;
                    else ++grouped_statement_members;
                } else if (emission.disposition == sir::EmissionDisposition::InlineLiteral) {
                    ++inline_literals;
                    if (expression != selection_expressions.end()) {
                        ++inline_expression_kinds[sir::expressions::kind_name(
                            expression->second->kind)];
                        if (expression->second->block != emission.inline_use.block)
                            ++inline_literals_cross_block;
                    }
                } else ++structural_definitions;
                if (expression != selection_expressions.end()
                    && sir::selection::literal_kind(expression->second->kind)
                    && emission.disposition != sir::EmissionDisposition::InlineLiteral) {
                    if (!emission.single_use) ++literal_blocked_multiuse;
                    if (!emission.single_origin_at_use) ++literal_blocked_multi_origin;
                    if (!emission.capture_free) ++literal_blocked_capture;
                    if (!emission.dominance_proven) ++literal_blocked_dominance;
                    auto web_size = selection_web_member_counts.find(emission.web_id);
                    if (web_size == selection_web_member_counts.end()
                        || web_size->second != 1) ++literal_blocked_merged_web;
                }
            }
            for (const auto& node_pair : adaptation.model.nodes) {
                const sir::Node& node = node_pair.second;
                control_edges += (long long)node.control_edges.size();
                if (node.kind == sir::NodeKind::If || node.kind == sir::NodeKind::IfElse)
                    ++branch_nodes;
                else if (node.kind == sir::NodeKind::Return) ++return_nodes;
                else if (node.kind == sir::NodeKind::Fallthrough) ++fallthrough_nodes;
                else if (node.kind == sir::NodeKind::LoopEntry) ++loop_entry_nodes;
                else if (node.kind == sir::NodeKind::BooleanSkipTransfer) ++boolean_skip_nodes;
                else if (node.kind == sir::NodeKind::LinearTransfer) ++linear_transfer_nodes;
                else if (node.kind == sir::NodeKind::JoinTransfer) ++join_transfer_nodes;
                else if (node.kind == sir::NodeKind::LoopLatch) ++loop_latch_nodes;
                else if (node.kind == sir::NodeKind::LoopExitTransfer)
                    ++loop_exit_transfer_nodes;
                else if (node.kind == sir::NodeKind::LoopCondition) ++loop_condition_nodes;
                else if (node.kind == sir::NodeKind::RedundantPredicate)
                    ++redundant_predicate_nodes;
                else if (node.kind == sir::NodeKind::BooleanShortCircuit) {
                    if (node.branch_role == sir::BranchRole::ShortCircuitSharedTrue)
                        ++short_circuit_true_nodes;
                    else if (node.branch_role == sir::BranchRole::ShortCircuitSharedFalse)
                        ++short_circuit_false_nodes;
                }
                else if (node.kind == sir::NodeKind::ConditionalBreak)
                    ++conditional_break_nodes;
                else if (node.kind == sir::NodeKind::ConditionalContinue)
                    ++conditional_continue_nodes;
                else if (node.kind == sir::NodeKind::ConditionalBreakContinue)
                    ++conditional_break_continue_nodes;
                else if (node.kind == sir::NodeKind::PreservedCyclicBranch)
                    ++preserved_cyclic_nodes;
                else if (node.kind == sir::NodeKind::PreservedSharedBranch)
                    ++preserved_shared_nodes;
                else if (node.kind == sir::NodeKind::PreservedEscapingBranch)
                    ++preserved_escaping_nodes;
                else if (node.kind == sir::NodeKind::UnresolvedBranch)
                    ++unresolved_branch_nodes;
                else if (node.kind == sir::NodeKind::UnresolvedControl) {
                    ++unresolved_control_nodes;
                    bool unconditional = false, loopback = false, loopexit = false;
                    for (const sir::Edge& edge : node.control_edges) {
                        if (edge.kind == sir::EdgeKind::Unconditional) unconditional = true;
                        else if (edge.kind == sir::EdgeKind::LoopBack) loopback = true;
                        else if (edge.kind == sir::EdgeKind::LoopExit) loopexit = true;
                    }
                    if (unconditional) ++unresolved_unconditional;
                    if (loopback) ++unresolved_loopback;
                    if (loopexit) ++unresolved_loopexit;
                    if (!unconditional && !loopback && !loopexit) ++unresolved_other;
                    if (unconditional) {
                        ++unconditional_opcodes[node.control_opcode];
                        const sir::Edge* transfer = nullptr;
                        for (const sir::Edge& edge : node.control_edges)
                            if (edge.kind == sir::EdgeKind::Unconditional) {
                                transfer = &edge; break;
                            }
                        if (transfer) {
                            const int source = transfer->source.value;
                            const int target = transfer->target.value;
                            auto target_range = manifest.block_instruction_ranges.find(target);
                            const int target_instruction = target_range ==
                                manifest.block_instruction_ranges.end() ? -1
                                : target_range->second.first;
                            if (target_instruction > node.control_instruction) ++unconditional_forward;
                            else if (target_instruction < node.control_instruction)
                                ++unconditional_backward;
                            else ++unconditional_self;
                            const size_t predecessor_count =
                                manifest.block_predecessors.at(target).size();
                            if (predecessor_count == 1) ++unconditional_single_predecessor;
                            else if (predecessor_count > 1) ++unconditional_multi_predecessor;
                            if (manifest.block_dominators.at(target).count(source))
                                ++unconditional_source_dominates_target;
                            if (manifest.immediate_postdominator.at(source) == target)
                                ++unconditional_target_ipostdom;
                            if (manifest.reducible) ++unconditional_reducible;
                            else ++unconditional_irreducible;
                            auto deepest_loop = [&](int block) {
                                int header = -1; size_t size = (size_t)-1;
                                for (const auto& loop_item : manifest.loops)
                                    if (loop_item.second.body.count(block)
                                        && loop_item.second.body.size() < size) {
                                        header = loop_item.first;
                                        size = loop_item.second.body.size();
                                    }
                                return header;
                            };
                            const int source_loop = deepest_loop(source);
                            const int target_loop = deepest_loop(target);
                            if (source_loop >= 0 && source_loop == target_loop)
                                ++unconditional_same_loop;
                            else if (source_loop < 0 && target_loop >= 0)
                                ++unconditional_enters_loop;
                            else if (source_loop >= 0 && target_loop < 0)
                                ++unconditional_exits_loop;
                            else if (source_loop < 0 && target_loop < 0)
                                ++unconditional_outside_loops;
                            if (manifest.loops.count(target)) ++unconditional_targets_header;
                            for (const auto& loop_item : manifest.loops)
                                if (loop_item.second.prep == target) {
                                    ++unconditional_targets_prep; break;
                                }
                        }
                    }
                }
            }
            const bool ok = adaptation.ok() && verification.ok() && value_flow_ok
                && top_flow_ok;
            if (ok) {
                ++verified;
                const sir::source::Result rendered =
                    sir::source::render_semantic(adaptation.model);
                if (rendered.ok) {
                    ++renderer_accepted;
                    renderer_source_bytes += (long long)rendered.source.size();
                    if (compile_rendered) {
                        const std::string temporary_source = "_sir_render_"
                            + std::to_string((long long)GetCurrentProcessId()) + ".luau";
                        std::string compile_error;
                        if (!write_file(temporary_source, rendered.source)) {
                            ++renderer_compile_failed;
                            ++renderer_rejection_categories["RENDER_TEMP_SOURCE_WRITE_FAILED"];
                        } else {
                            const std::string bytecode = compile_luau(
                                temporary_source, compile_error);
                            std::remove(temporary_source.c_str());
                            if (bytecode.empty()) {
                                ++renderer_compile_failed;
                                ++renderer_rejection_categories["RENDER_SOURCE_COMPILE_FAILED"];
                            } else ++renderer_compiled;
                        }
                    }
                } else {
                    ++renderer_rejected;
                    for (const std::string& category : rendered.failures) {
                        ++renderer_rejection_categories[category];
                        auto& category_examples = renderer_rejection_examples[category];
                        if (category_examples.size() < 3)
                            category_examples.push_back(file.filename().string()
                                + "#proto=" + std::to_string(index));
                    }
                    const bool pure_block_coverage = rendered.failures.size() == 1
                        && rendered.failures[0] == "RENDER_BLOCK_COVERAGE";
                    const bool has_block_coverage = std::find(rendered.failures.begin(),
                        rendered.failures.end(), "RENDER_BLOCK_COVERAGE")
                        != rendered.failures.end();
                    if (pure_block_coverage) ++renderer_pure_block_coverage;
                    if (has_block_coverage)
                        for (const std::string& category : rendered.failures)
                            if (category != "RENDER_BLOCK_COVERAGE")
                                ++renderer_block_coverage_companions[category];
                    if (pure_block_coverage) for (sir::BlockId missing : rendered.missing_blocks) {
                        const sir::Node* control = nullptr;
                        for (const auto& node : adaptation.model.nodes)
                            if (node.second.control_source == missing
                                && node.second.control_instruction >= 0) {
                                control = &node.second; break;
                            }
                        int loop_depth = 0;
                        for (const auto& loop : adaptation.model.authoritative_loops)
                            if (loop.second.body.count(missing)) ++loop_depth;
                        int effect_count = 0;
                        auto range = adaptation.model.block_instruction_ranges.find(
                            missing.value);
                        if (range != adaptation.model.block_instruction_ranges.end())
                            for (sir::EffectId effect : adaptation.model.observable_effects)
                                if (effect.value >= range->second.first
                                    && effect.value <= range->second.second)
                                    ++effect_count;
                        const std::string shape = std::string("control=")
                            + (control ? sir::node_kind_name(control->kind) : "none")
                            + "/op=" + (control ? control->control_opcode : "none")
                            + "/loops=" + std::to_string(loop_depth)
                            + "/effects=" + std::to_string(effect_count);
                        ++renderer_missing_block_shapes[shape];
                    }
                }
                continue;
            }
            ++failed;
            std::set<std::string> prototype_categories;
            prototype_categories.insert(adaptation.failures.begin(), adaptation.failures.end());
            if (!value_flow.known) prototype_categories.insert("SIR_VALUE_FLOW_UNKNOWN");
            if (!value_flow.converged)
                prototype_categories.insert("SIR_VALUE_FLOW_NONCONVERGED");
            for (const sir::vf::Use& use : value_flow.uses)
                if (use.reaching.empty()) {
                    prototype_categories.insert("SIR_VALUE_FLOW_MISSING_ORIGIN");
                    break;
                }
            if (!top_flow.known) prototype_categories.insert("SIR_TOP_FLOW_UNKNOWN");
            if (!top_flow.converged)
                prototype_categories.insert("SIR_TOP_FLOW_NONCONVERGED");
            if (!top_flow_ok) prototype_categories.insert("SIR_TOP_FLOW_CONTRACT");
            for (const sir::vf::TopUse& use : top_flow.uses)
                if (use.reaching.empty()) {
                    prototype_categories.insert("SIR_TOP_FLOW_MISSING_ORIGIN");
                    break;
                }
            for (const sir::Issue& issue_value : verification.issues)
                prototype_categories.insert(issue_value.code);
            for (const std::string& category : prototype_categories) ++categories[category];
            if (examples.size() < 100)
                for (const std::string& category : prototype_categories) {
                    examples.push_back(file.filename().string() + "\tproto="
                        + std::to_string(index) + "\t" + category);
                    if (examples.size() >= 100) break;
                }
        }
    }
    std::printf("== SEMANTIC IR CORPUS ==\n");
    std::printf("scope=%s files_touched=%zu prototypes=%lld verified=%lld failed=%lld\n",
                abilities_only ? "abilities" : "all", files_touched, attempted, verified, failed);
    std::printf("blocks=%lld effects=%lld loops=%lld\n", blocks, effects, loops);
    std::printf("isolated_renderer=accepted:%lld,rejected:%lld,source_bytes:%lld\n",
                renderer_accepted, renderer_rejected, renderer_source_bytes);
    if (compile_rendered)
        std::printf("isolated_renderer_compile=passed:%lld,failed:%lld\n",
                    renderer_compiled, renderer_compile_failed);
    for (const auto& category : renderer_rejection_categories)
        std::printf("RENDER_REJECTION %-40s prototypes=%lld\n",
                    category.first.c_str(), category.second);
    std::printf("closures=%lld captures=%lld declared_upvalues=%lld "
                "capture_modes=value:%lld,reference:%lld,upvalue:%lld\n",
                closure_sites, captures, declared_upvalues, value_captures,
                reference_captures, upvalue_captures);
    std::printf("control_edges=%lld branch_nodes=%lld return_nodes=%lld "
                "fallthrough_nodes=%lld unresolved_control_nodes=%lld\n", control_edges,
                branch_nodes, return_nodes, fallthrough_nodes, unresolved_control_nodes);
    std::printf("classified_unconditional=loop_entry:%lld,boolean_skip:%lld,linear:%lld,join:%lld\n",
                loop_entry_nodes, boolean_skip_nodes, linear_transfer_nodes,
                join_transfer_nodes);
    std::printf("classified_loop_transfers=latch:%lld,exit:%lld\n",
                loop_latch_nodes, loop_exit_transfer_nodes);
    std::printf("structured_predicates=branch:%lld,loop_condition:%lld,redundant:%lld,"
                "short_true:%lld,short_false:%lld,break:%lld,continue:%lld,"
                "break_continue:%lld,preserved_cyclic:%lld,preserved_shared:%lld,"
                "preserved_escaping:%lld,unresolved:%lld\n",
                branch_nodes, loop_condition_nodes, redundant_predicate_nodes,
                short_circuit_true_nodes, short_circuit_false_nodes,
                conditional_break_nodes, conditional_continue_nodes,
                conditional_break_continue_nodes,
                preserved_cyclic_nodes, preserved_shared_nodes,
                preserved_escaping_nodes,
                unresolved_branch_nodes);
    std::printf("unresolved_kinds=unconditional:%lld,loopback:%lld,loopexit:%lld,other:%lld\n",
                unresolved_unconditional, unresolved_loopback, unresolved_loopexit,
                unresolved_other);
    std::printf("unconditional_direction=forward:%lld,backward:%lld,self:%lld "
                "preds=single:%lld,multi:%lld dominates:%lld ipostdom:%lld\n",
                unconditional_forward, unconditional_backward, unconditional_self,
                unconditional_single_predecessor, unconditional_multi_predecessor,
                unconditional_source_dominates_target, unconditional_target_ipostdom);
    std::printf("unconditional_loops=same:%lld,enters:%lld,exits:%lld,outside:%lld "
                "target_header:%lld,target_prep:%lld reducible:%lld,irreducible:%lld\n",
                unconditional_same_loop, unconditional_enters_loop, unconditional_exits_loop,
                unconditional_outside_loops, unconditional_targets_header,
                unconditional_targets_prep, unconditional_reducible, unconditional_irreducible);
    for (const auto& opcode : unconditional_opcodes)
        std::printf("UNCONDITIONAL_OPCODE %-24s nodes=%lld\n", opcode.first.c_str(),
                    opcode.second);
    std::printf("predicate_regions=total:%lld,branch_proven:%lld,loop_condition:%lld "
                "redundant:%lld,short_true:%lld,short_false:%lld,break:%lld,continue:%lld,break_continue:%lld,preserved_cyclic:%lld,preserved_shared:%lld,preserved_escaping:%lld,virtual_exit:%lld,shared_entry:%lld,no_join:%lld,overlap:%lld,escape:%lld,source_cycle:%lld\n", predicates,
                proven_branch_regions, proven_loop_conditions, redundant_predicates,
                proven_short_circuit_true, proven_short_circuit_false,
                proven_conditional_break, proven_conditional_continue,
                proven_break_continue,
                explicit_preserved_cyclic, explicit_preserved_shared,
                explicit_preserved_escaping,
                proven_virtual_exit_regions, proven_shared_entry_regions, predicate_no_join,
                predicate_overlap, predicate_escape, predicate_source_cycle);
    std::printf("predicate_expressions=trees:%lld,compound:%lld,nodes:%lld,leaves:%lld,"
                "max_leaves:%lld,mismatches:%lld\n", predicate_expression_trees,
                compound_predicate_trees, predicate_expression_nodes,
                predicate_expression_leaves, predicate_expression_max_leaves,
                predicate_expression_mismatches);
    std::printf("predicate_arms=empty_true:%lld,empty_false:%lld,both_nonempty:%lld,terminal:%lld\n",
                predicate_empty_true, predicate_empty_false, predicate_both_nonempty,
                predicate_terminal_arms);
    std::printf("predicate_overlap=unresolved:%lld,escape:%lld,source_cycle:%lld,no_real_join:%lld "
                "true_target_shared:%lld,false_target_shared:%lld,both_targets_shared:%lld,"
                "neither_target_shared:%lld,true_exclusive_empty:%lld,false_exclusive_empty:%lld,"
                "both_exclusive_nonempty:%lld,blocks_total:%lld,blocks_max:%lld\n",
                overlap_unresolved, overlap_with_escape, overlap_with_source_cycle,
                overlap_with_no_real_join, overlap_true_target_shared,
                overlap_false_target_shared, overlap_both_targets_shared,
                overlap_neither_target_shared, overlap_true_exclusive_empty,
                overlap_false_exclusive_empty, overlap_both_exclusive_nonempty,
                overlap_blocks_total, overlap_blocks_maximum);
    std::printf("predicate_chains=true_to_predicate:%lld,false_to_predicate:%lld,"
                "and_same_false:%lld,or_same_true:%lld,true_cross:%lld,false_cross:%lld\n",
                chain_true_to_predicate, chain_false_to_predicate, chain_and_same_false,
                chain_or_same_true, chain_true_cross_outcome, chain_false_cross_outcome);
    std::printf("predicate_loop_local=unresolved:%lld,break:%lld,continue:%lld,"
                "break_continue:%lld,two_inside:%lld,two_outside:%lld,"
                "source_header_or_latch:%lld\n", loop_local_unresolved,
                loop_break_candidates, loop_continue_candidates,
                loop_break_continue_candidates, loop_two_inside_candidates,
                loop_two_outside_candidates, loop_source_header_or_latch);
    for (const auto& shape : unresolved_shape_masks)
        std::printf("UNRESOLVED_SHAPE %-16s predicates=%lld\n", shape.first.c_str(),
                    shape.second);
    std::printf("cfg_reducibility=reducible_prototypes:%lld,irreducible_prototypes:%lld,"
                "preserved_in_reducible:%lld,preserved_in_irreducible:%lld\n",
                reducible_prototypes, irreducible_prototypes,
                preserved_in_reducible, preserved_in_irreducible);
    std::printf("value_opcode_census=instructions:%lld,with_uses:%lld,with_defs:%lld,"
                "register_uses:%lld,register_defs:%lld,unknown_effects:%lld\n",
                reachable_instructions, instructions_with_uses, instructions_with_defs,
                register_uses, register_defs, value_effect_unknown);
    std::printf("call_result_census=calls:%lld,open_arguments:%lld,open_results:%lld,"
                "returns:%lld,open_returns:%lld,vararg_reads:%lld,open_varargs:%lld\n",
                calls, calls_open_arguments, calls_open_results, returns,
                returns_open_results, vararg_reads, vararg_open_results);
    std::printf("semantic_call_contracts=owned:%lld,method:%lld,ordinary:%lld,"
                "open_arguments:%lld,open_results:%lld,callee_links:%lld,"
                "receiver_links:%lld,argument_values:%lld,argument_links:%lld,"
                "multi_origin_arguments:%lld\n", owned_calls,
                owned_method_calls, owned_ordinary_calls, owned_open_arguments,
                owned_open_results, owned_call_callee_links,
                owned_call_receiver_links, owned_call_argument_values,
                owned_call_argument_links, owned_call_multi_origin_arguments);
    std::printf("semantic_return_contracts=owned:%lld,fixed:%lld,open:%lld,"
                "fixed_values:%lld,origin_links:%lld,multi_origin_values:%lld\n",
                owned_returns, owned_fixed_returns, owned_open_returns,
                owned_return_values, owned_return_origin_links,
                owned_return_multi_origin_values);
    std::printf("semantic_table_contracts=owned:%lld,allocations:%lld,writes:%lld,"
                "fixed_setlist:%lld,open_setlist:%lld,table_links:%lld,"
                "value_links:%lld,key_links:%lld,fixed_list_values:%lld\n",
                owned_table_operations, owned_table_allocations, owned_table_writes,
                owned_table_setlist_fixed, owned_table_setlist_open,
                owned_table_origin_links, owned_table_value_links,
                owned_table_key_links, owned_table_fixed_list_values);
    std::printf("semantic_capture_links=value_origins:%lld,reference_origins:%lld,"
                "reference_cells:%lld,parent_upvalues:%lld,scope_closes:%lld\n",
                capture_value_origin_links, capture_reference_origin_links,
                capture_reference_cells, capture_parent_upvalue_links,
                scope_close_boundaries);
    std::printf("semantic_local_lifetimes=values:%lld,parameters:%lld,definitions:%lld,"
                "dead:%lld,use_links:%lld,intervals:%lld,multiblock:%lld,hoisted:%lld,"
                "live_in:%lld,live_out:%lld,reused_registers:%lld,reuse_identities:%lld,"
                "capture_copy_links:%lld,capture_share_links:%lld\n",
                local_values, local_parameters, local_definitions, local_dead_values,
                local_use_links, local_intervals, local_multiblock_values,
                local_hoisted_declarations, local_live_in_intervals,
                local_live_out_intervals, local_reused_registers,
                local_reuse_identities, local_capture_copy_links,
                local_capture_share_links);
    std::printf("semantic_value_webs=webs:%lld,singleton:%lld,merged:%lld,members:%lld,"
                "hoisted:%lld,merges:%lld,conditional:%lld,loop:%lld,"
                "conditional_loop:%lld,preserved:%lld\n",
                value_webs, singleton_value_webs, merged_value_webs,
                value_web_members, value_web_hoisted, value_merges,
                conditional_merges, loop_merges, conditional_loop_merges,
                preserved_merges);
    std::printf("semantic_expression_contracts=definitions:%lld,operand_slots:%lld,"
                "origin_links:%lld,multi_origin_operands:%lld,open_results:%lld,"
                "open_operands:%lld,scaffolding:%lld,preserved:%lld\n",
                expression_definitions, expression_operand_slots,
                expression_origin_links, expression_multi_origin_operands,
                expression_open_results, expression_open_operands,
                expression_scaffolding, expression_preserved);
    for (const auto& item : expression_kinds)
        std::printf("EXPRESSION_KIND %-24s definitions=%lld\n",
                    item.first.c_str(), item.second);
    std::printf("semantic_statement_selection=definitions:%lld,explicit_definitions:%lld,"
                "statement_owners:%lld,grouped_members:%lld,inline_literals:%lld,"
                "inline_cross_block:%lld,structural:%lld,literal_candidates:%lld,"
                "blocked_multiuse:%lld,blocked_multi_origin:%lld,blocked_capture:%lld,"
                "blocked_dominance:%lld,blocked_merged_web:%lld\n",
                selected_definitions, explicit_statement_definitions,
                statement_owners, grouped_statement_members, inline_literals,
                inline_literals_cross_block, structural_definitions,
                literal_candidates, literal_blocked_multiuse,
                literal_blocked_multi_origin, literal_blocked_capture,
                literal_blocked_dominance, literal_blocked_merged_web);
    for (const auto& item : inline_expression_kinds)
        std::printf("INLINE_KIND %-28s definitions=%lld\n",
                    item.first.c_str(), item.second);
    std::printf("value_flow=known:%lld,unknown:%lld,nonconverged:%lld,definitions:%lld,"
                "uses:%lld,links:%lld,single_origin:%lld,multiple_origin:%lld,"
                "missing_origin:%lld,open_definitions:%lld,open_uses:%lld,"
                "parameter_uses:%lld,entry_uses:%lld\n", value_flow_known,
                value_flow_unknown, value_flow_nonconverged, value_definitions,
                value_uses, value_links, single_origin_uses, multiple_origin_uses,
                missing_origin_uses, open_value_definitions, open_range_uses,
                parameter_origin_uses, entry_origin_uses);
    std::printf("vm_top_flow=known:%lld,unknown:%lld,nonconverged:%lld,consumers:%lld,"
                "single_origin:%lld,multiple_origin:%lld,missing_origin:%lld,"
                "from_fixed:%lld,from_call:%lld,from_vararg:%lld,cross_block:%lld,"
                "call_consumers:%lld,return_consumers:%lld,setlist_consumers:%lld,"
                "open_producers:%lld,unconsumed:%lld,multiply_consumed:%lld\n",
                top_known, top_unknown, top_nonconverged, top_consumers,
                top_single_origin, top_multiple_origin, top_missing_origin,
                top_from_fixed, top_from_call, top_from_vararg, top_cross_block,
                top_call_consumers, top_return_consumers, top_setlist_consumers,
                top_open_producers, top_unconsumed_producers,
                top_multiply_consumed_producers);
    for (const auto& category : categories)
        std::printf("FAILURE %-40s prototypes=%lld\n", category.first.c_str(), category.second);
    for (const auto& category : observation_categories)
        std::printf("OBSERVATION %-36s prototypes=%lld\n", category.first.c_str(),
                    category.second);
    if (!json_path.empty()) {
        std::ostringstream json;
        bool first = true;
        json << "{\n  \"schema\": 1,\n  \"scope\": \""
             << (abilities_only ? "abilities" : "all") << "\",\n  \"limit\": " << limit
             << ",\n  \"files_touched\": " << files_touched
             << ",\n  \"prototypes\": " << attempted << ",\n  \"verified\": " << verified
             << ",\n  \"failed\": " << failed
             << ",\n  \"isolated_renderer\": {\n"
             << "    \"accepted\": " << renderer_accepted << ",\n"
             << "    \"rejected\": " << renderer_rejected << ",\n"
             << "    \"source_bytes\": " << renderer_source_bytes << ",\n"
             << "    \"compile_requested\": " << (compile_rendered ? "true" : "false") << ",\n"
             << "    \"compiled\": " << renderer_compiled << ",\n"
             << "    \"compile_failed\": " << renderer_compile_failed << ",\n"
             << "    \"rejection_categories\": {";
        first = true;
        for (const auto& category : renderer_rejection_categories) {
            if (!first) json << ',';
            first = false;
            json << "\n      \"" << sir::json_escape(category.first)
                 << "\": " << category.second;
        }
        if (!renderer_rejection_categories.empty()) json << '\n';
        json << "    },\n    \"rejection_examples\": {";
        first = true;
        for (const auto& category : renderer_rejection_examples) {
            if (!first) json << ',';
            first = false;
            json << "\n      \"" << sir::json_escape(category.first) << "\": [";
            for (size_t example = 0; example < category.second.size(); ++example) {
                if (example) json << ',';
                json << "\"" << sir::json_escape(category.second[example]) << "\"";
            }
            json << ']';
        }
        if (!renderer_rejection_examples.empty()) json << '\n';
        json << "    },\n    \"pure_block_coverage_prototypes\": "
             << renderer_pure_block_coverage
             << ",\n    \"missing_block_shapes\": {";
        first = true;
        for (const auto& shape : renderer_missing_block_shapes) {
            if (!first) json << ',';
            first = false;
            json << "\n      \"" << sir::json_escape(shape.first)
                 << "\": " << shape.second;
        }
        if (!renderer_missing_block_shapes.empty()) json << '\n';
        json << "    },\n    \"block_coverage_companions\": {";
        first = true;
        for (const auto& category : renderer_block_coverage_companions) {
            if (!first) json << ',';
            first = false;
            json << "\n      \"" << sir::json_escape(category.first)
                 << "\": " << category.second;
        }
        if (!renderer_block_coverage_companions.empty()) json << '\n';
        json << "    }\n  }"
             << ",\n  \"blocks\": " << blocks
             << ",\n  \"effects\": " << effects << ",\n  \"loops\": " << loops
             << ",\n  \"closure_sites\": " << closure_sites
             << ",\n  \"captures\": " << captures
             << ",\n  \"declared_upvalues\": " << declared_upvalues
             << ",\n  \"capture_modes\": {\n"
             << "    \"value\": " << value_captures << ",\n"
             << "    \"reference\": " << reference_captures << ",\n"
             << "    \"upvalue\": " << upvalue_captures << "\n  }"
             << ",\n  \"control_edges\": " << control_edges
             << ",\n  \"branch_nodes\": " << branch_nodes
             << ",\n  \"return_nodes\": " << return_nodes
             << ",\n  \"fallthrough_nodes\": " << fallthrough_nodes
             << ",\n  \"classified_unconditional\": {\n"
             << "    \"loop_entry\": " << loop_entry_nodes << ",\n"
             << "    \"boolean_skip\": " << boolean_skip_nodes << ",\n"
             << "    \"linear\": " << linear_transfer_nodes << ",\n"
             << "    \"join\": " << join_transfer_nodes << "\n  }"
             << ",\n  \"classified_loop_transfers\": {\n"
             << "    \"latch\": " << loop_latch_nodes << ",\n"
             << "    \"exit\": " << loop_exit_transfer_nodes << "\n  }"
             << ",\n  \"structured_predicates\": {\n"
             << "    \"branch\": " << branch_nodes << ",\n"
             << "    \"loop_condition\": " << loop_condition_nodes << ",\n"
             << "    \"redundant\": " << redundant_predicate_nodes << ",\n"
             << "    \"short_circuit_shared_true\": " << short_circuit_true_nodes << ",\n"
             << "    \"short_circuit_shared_false\": " << short_circuit_false_nodes << ",\n"
             << "    \"conditional_break\": " << conditional_break_nodes << ",\n"
             << "    \"conditional_continue\": " << conditional_continue_nodes << ",\n"
             << "    \"conditional_break_continue\": "
             << conditional_break_continue_nodes << ",\n"
             << "    \"preserved_cyclic\": " << preserved_cyclic_nodes << ",\n"
             << "    \"preserved_shared\": " << preserved_shared_nodes << ",\n"
             << "    \"preserved_escaping\": " << preserved_escaping_nodes << ",\n"
             << "    \"unresolved\": " << unresolved_branch_nodes << "\n  }"
             << ",\n  \"unresolved_control_nodes\": " << unresolved_control_nodes
             << ",\n  \"unresolved_kinds\": {\n"
             << "    \"unconditional\": " << unresolved_unconditional << ",\n"
             << "    \"loopback\": " << unresolved_loopback << ",\n"
             << "    \"loopexit\": " << unresolved_loopexit << ",\n"
             << "    \"other\": " << unresolved_other << "\n  }"
             << ",\n  \"unconditional_census\": {\n"
             << "    \"forward\": " << unconditional_forward << ",\n"
             << "    \"backward\": " << unconditional_backward << ",\n"
             << "    \"self\": " << unconditional_self << ",\n"
             << "    \"single_predecessor_target\": " << unconditional_single_predecessor << ",\n"
             << "    \"multi_predecessor_target\": " << unconditional_multi_predecessor << ",\n"
             << "    \"source_dominates_target\": " << unconditional_source_dominates_target << ",\n"
             << "    \"target_is_immediate_postdominator\": " << unconditional_target_ipostdom << ",\n"
             << "    \"same_loop\": " << unconditional_same_loop << ",\n"
             << "    \"enters_loop\": " << unconditional_enters_loop << ",\n"
             << "    \"exits_loop\": " << unconditional_exits_loop << ",\n"
             << "    \"outside_loops\": " << unconditional_outside_loops << ",\n"
             << "    \"targets_loop_header\": " << unconditional_targets_header << ",\n"
             << "    \"targets_loop_prep\": " << unconditional_targets_prep << ",\n"
             << "    \"reducible\": " << unconditional_reducible << ",\n"
             << "    \"irreducible\": " << unconditional_irreducible << ",\n"
             << "    \"opcodes\": {";
        first = true;
        for (const auto& opcode : unconditional_opcodes) {
            if (!first) json << ',';
            first = false;
            json << "\n      \"" << sir::json_escape(opcode.first) << "\": " << opcode.second;
        }
        if (!unconditional_opcodes.empty()) json << '\n';
        json << "    }\n  }"
             << ",\n  \"predicate_regions\": {\n"
             << "    \"total\": " << predicates << ",\n"
             << "    \"proven_branch\": " << proven_branch_regions << ",\n"
             << "    \"proven_loop_condition\": " << proven_loop_conditions << ",\n"
             << "    \"redundant\": " << redundant_predicates << ",\n"
             << "    \"short_circuit_shared_true\": " << proven_short_circuit_true << ",\n"
             << "    \"short_circuit_shared_false\": " << proven_short_circuit_false << ",\n"
             << "    \"conditional_break\": " << proven_conditional_break << ",\n"
             << "    \"conditional_continue\": " << proven_conditional_continue << ",\n"
             << "    \"conditional_break_continue\": "
             << proven_break_continue << ",\n"
             << "    \"preserved_cyclic\": " << explicit_preserved_cyclic << ",\n"
             << "    \"preserved_shared\": " << explicit_preserved_shared << ",\n"
             << "    \"preserved_escaping\": " << explicit_preserved_escaping << ",\n"
             << "    \"virtual_exit\": " << proven_virtual_exit_regions << ",\n"
             << "    \"shared_entry\": " << proven_shared_entry_regions << ",\n"
             << "    \"no_join\": " << predicate_no_join << ",\n"
             << "    \"overlap\": " << predicate_overlap << ",\n"
             << "    \"escape\": " << predicate_escape << ",\n"
             << "    \"source_cycle\": " << predicate_source_cycle << ",\n"
             << "    \"empty_true\": " << predicate_empty_true << ",\n"
             << "    \"empty_false\": " << predicate_empty_false << ",\n"
             << "    \"both_nonempty\": " << predicate_both_nonempty << ",\n"
             << "    \"terminal_arm\": " << predicate_terminal_arms << "\n  }"
             << ",\n  \"predicate_expressions\": {\n"
             << "    \"trees\": " << predicate_expression_trees << ",\n"
             << "    \"compound_trees\": " << compound_predicate_trees << ",\n"
             << "    \"nodes\": " << predicate_expression_nodes << ",\n"
             << "    \"leaves\": " << predicate_expression_leaves << ",\n"
             << "    \"maximum_leaves\": " << predicate_expression_max_leaves << ",\n"
             << "    \"manifest_mismatches\": " << predicate_expression_mismatches
             << "\n  }"
             << ",\n  \"predicate_overlap\": {\n"
             << "    \"unresolved\": " << overlap_unresolved << ",\n"
             << "    \"with_escape\": " << overlap_with_escape << ",\n"
             << "    \"with_source_cycle\": " << overlap_with_source_cycle << ",\n"
             << "    \"with_no_real_join\": " << overlap_with_no_real_join << ",\n"
             << "    \"true_target_shared\": " << overlap_true_target_shared << ",\n"
             << "    \"false_target_shared\": " << overlap_false_target_shared << ",\n"
             << "    \"both_targets_shared\": " << overlap_both_targets_shared << ",\n"
             << "    \"neither_target_shared\": " << overlap_neither_target_shared << ",\n"
             << "    \"true_exclusive_empty\": " << overlap_true_exclusive_empty << ",\n"
             << "    \"false_exclusive_empty\": " << overlap_false_exclusive_empty << ",\n"
             << "    \"both_exclusive_nonempty\": " << overlap_both_exclusive_nonempty << ",\n"
             << "    \"blocks_total\": " << overlap_blocks_total << ",\n"
             << "    \"blocks_maximum\": " << overlap_blocks_maximum << "\n  }"
             << ",\n  \"predicate_chains\": {\n"
             << "    \"true_to_predicate\": " << chain_true_to_predicate << ",\n"
             << "    \"false_to_predicate\": " << chain_false_to_predicate << ",\n"
             << "    \"and_same_false\": " << chain_and_same_false << ",\n"
             << "    \"or_same_true\": " << chain_or_same_true << ",\n"
             << "    \"true_cross_outcome\": " << chain_true_cross_outcome << ",\n"
             << "    \"false_cross_outcome\": " << chain_false_cross_outcome << "\n  }"
             << ",\n  \"predicate_loop_local\": {\n"
             << "    \"unresolved\": " << loop_local_unresolved << ",\n"
             << "    \"break_candidate\": " << loop_break_candidates << ",\n"
             << "    \"continue_candidate\": " << loop_continue_candidates << ",\n"
             << "    \"break_continue_candidate\": "
             << loop_break_continue_candidates << ",\n"
             << "    \"two_inside\": " << loop_two_inside_candidates << ",\n"
             << "    \"two_outside\": " << loop_two_outside_candidates << ",\n"
             << "    \"source_header_or_latch\": "
             << loop_source_header_or_latch << "\n  }"
             << ",\n  \"unresolved_shape_masks\": {";
        first = true;
        for (const auto& shape : unresolved_shape_masks) {
            if (!first) json << ',';
            first = false;
            json << "\n    \"" << sir::json_escape(shape.first) << "\": " << shape.second;
        }
        if (!unresolved_shape_masks.empty()) json << '\n';
        json << "  }"
             << ",\n  \"value_opcode_census\": {\n"
             << "    \"reachable_instructions\": " << reachable_instructions << ",\n"
             << "    \"instructions_with_uses\": " << instructions_with_uses << ",\n"
             << "    \"instructions_with_defs\": " << instructions_with_defs << ",\n"
             << "    \"register_uses\": " << register_uses << ",\n"
             << "    \"register_defs\": " << register_defs << ",\n"
             << "    \"unknown_effects\": " << value_effect_unknown << ",\n"
             << "    \"opcodes\": {";
        first = true;
        for (const auto& opcode_item : opcode_instructions) {
            if (!first) json << ',';
            first = false;
            const std::string& opcode = opcode_item.first;
            json << "\n      \"" << sir::json_escape(opcode) << "\": {"
                 << "\"instructions\":" << opcode_item.second
                 << ",\"with_uses\":" << opcode_with_uses[opcode]
                 << ",\"with_defs\":" << opcode_with_defs[opcode]
                 << ",\"register_uses\":" << opcode_register_uses[opcode]
                 << ",\"register_defs\":" << opcode_register_defs[opcode]
                 << ",\"unknown_effects\":" << opcode_unknown_effects[opcode] << '}';
        }
        if (!opcode_instructions.empty()) json << '\n';
        json << "    }\n  }"
             << ",\n  \"semantic_return_contracts\": {\n"
             << "    \"owned\": " << owned_returns << ",\n"
             << "    \"fixed\": " << owned_fixed_returns << ",\n"
             << "    \"open\": " << owned_open_returns << ",\n"
             << "    \"fixed_values\": " << owned_return_values << ",\n"
             << "    \"origin_links\": " << owned_return_origin_links << ",\n"
             << "    \"multi_origin_values\": "
             << owned_return_multi_origin_values << "\n  }"
             << ",\n  \"semantic_table_contracts\": {\n"
             << "    \"owned\": " << owned_table_operations << ",\n"
             << "    \"allocations\": " << owned_table_allocations << ",\n"
             << "    \"writes\": " << owned_table_writes << ",\n"
             << "    \"fixed_setlist\": " << owned_table_setlist_fixed << ",\n"
             << "    \"open_setlist\": " << owned_table_setlist_open << ",\n"
             << "    \"table_origin_links\": " << owned_table_origin_links << ",\n"
             << "    \"value_origin_links\": " << owned_table_value_links << ",\n"
             << "    \"key_origin_links\": " << owned_table_key_links << ",\n"
             << "    \"fixed_list_values\": "
             << owned_table_fixed_list_values << "\n  }"
             << ",\n  \"semantic_capture_links\": {\n"
             << "    \"value_origins\": " << capture_value_origin_links << ",\n"
             << "    \"reference_origins\": " << capture_reference_origin_links << ",\n"
             << "    \"reference_cells\": " << capture_reference_cells << ",\n"
             << "    \"parent_upvalues\": " << capture_parent_upvalue_links << ",\n"
             << "    \"scope_closes\": " << scope_close_boundaries << "\n  }"
             << ",\n  \"semantic_local_lifetimes\": {\n"
             << "    \"values\": " << local_values << ",\n"
             << "    \"parameters\": " << local_parameters << ",\n"
             << "    \"definitions\": " << local_definitions << ",\n"
             << "    \"dead_values\": " << local_dead_values << ",\n"
             << "    \"use_links\": " << local_use_links << ",\n"
             << "    \"intervals\": " << local_intervals << ",\n"
             << "    \"multiblock_values\": " << local_multiblock_values << ",\n"
             << "    \"hoisted_declarations\": " << local_hoisted_declarations << ",\n"
             << "    \"live_in_intervals\": " << local_live_in_intervals << ",\n"
             << "    \"live_out_intervals\": " << local_live_out_intervals << ",\n"
             << "    \"reused_registers\": " << local_reused_registers << ",\n"
             << "    \"reuse_identities\": " << local_reuse_identities << ",\n"
             << "    \"capture_copy_links\": " << local_capture_copy_links << ",\n"
             << "    \"capture_share_links\": " << local_capture_share_links << "\n  }"
             << ",\n  \"semantic_value_webs\": {\n"
             << "    \"webs\": " << value_webs << ",\n"
             << "    \"singleton\": " << singleton_value_webs << ",\n"
             << "    \"merged\": " << merged_value_webs << ",\n"
             << "    \"members\": " << value_web_members << ",\n"
             << "    \"hoisted\": " << value_web_hoisted << ",\n"
             << "    \"merges\": " << value_merges << ",\n"
             << "    \"conditional\": " << conditional_merges << ",\n"
             << "    \"loop\": " << loop_merges << ",\n"
             << "    \"conditional_loop\": " << conditional_loop_merges << ",\n"
             << "    \"preserved\": " << preserved_merges << "\n  }"
             << ",\n  \"semantic_expression_contracts\": {\n"
             << "    \"definitions\": " << expression_definitions << ",\n"
             << "    \"operand_slots\": " << expression_operand_slots << ",\n"
             << "    \"origin_links\": " << expression_origin_links << ",\n"
             << "    \"multi_origin_operands\": "
             << expression_multi_origin_operands << ",\n"
             << "    \"open_results\": " << expression_open_results << ",\n"
             << "    \"open_operands\": " << expression_open_operands << ",\n"
             << "    \"compiler_scaffolding\": " << expression_scaffolding << ",\n"
             << "    \"preserved\": " << expression_preserved << ",\n"
             << "    \"kinds\": {";
        bool first_expression_kind = true;
        for (const auto& item : expression_kinds) {
            if (!first_expression_kind) json << ',';
            first_expression_kind = false;
            json << "\n      \"" << sir::json_escape(item.first) << "\": " << item.second;
        }
        if (!expression_kinds.empty()) json << '\n';
        json << "    }\n  }"
             << ",\n  \"semantic_statement_selection\": {\n"
             << "    \"definitions\": " << selected_definitions << ",\n"
             << "    \"explicit_definitions\": "
             << explicit_statement_definitions << ",\n"
             << "    \"statement_owners\": " << statement_owners << ",\n"
             << "    \"grouped_statement_members\": "
             << grouped_statement_members << ",\n"
             << "    \"inline_literals\": " << inline_literals << ",\n"
             << "    \"inline_literals_cross_block\": "
             << inline_literals_cross_block << ",\n"
             << "    \"structural_definitions\": " << structural_definitions << ",\n"
             << "    \"literal_candidates\": " << literal_candidates << ",\n"
             << "    \"literal_blocked_multiuse\": "
             << literal_blocked_multiuse << ",\n"
             << "    \"literal_blocked_multi_origin\": "
             << literal_blocked_multi_origin << ",\n"
             << "    \"literal_blocked_capture\": "
             << literal_blocked_capture << ",\n"
             << "    \"literal_blocked_dominance\": "
             << literal_blocked_dominance << ",\n"
             << "    \"literal_blocked_merged_web\": "
             << literal_blocked_merged_web << ",\n"
             << "    \"inline_kinds\": {";
        bool first_inline_kind = true;
        for (const auto& item : inline_expression_kinds) {
            if (!first_inline_kind) json << ',';
            first_inline_kind = false;
            json << "\n      \"" << sir::json_escape(item.first)
                 << "\": " << item.second;
        }
        if (!inline_expression_kinds.empty()) json << '\n';
        json << "    }\n  }"
             << ",\n  \"vm_top_flow\": {\n"
             << "    \"known_prototypes\": " << top_known << ",\n"
             << "    \"unknown_prototypes\": " << top_unknown << ",\n"
             << "    \"nonconverged_prototypes\": " << top_nonconverged << ",\n"
             << "    \"consumers\": " << top_consumers << ",\n"
             << "    \"single_origin\": " << top_single_origin << ",\n"
             << "    \"multiple_origin\": " << top_multiple_origin << ",\n"
             << "    \"missing_origin\": " << top_missing_origin << ",\n"
             << "    \"from_fixed\": " << top_from_fixed << ",\n"
             << "    \"from_call\": " << top_from_call << ",\n"
             << "    \"from_vararg\": " << top_from_vararg << ",\n"
             << "    \"cross_block\": " << top_cross_block << ",\n"
             << "    \"call_consumers\": " << top_call_consumers << ",\n"
             << "    \"return_consumers\": " << top_return_consumers << ",\n"
             << "    \"setlist_consumers\": " << top_setlist_consumers << ",\n"
             << "    \"open_producers\": " << top_open_producers << ",\n"
             << "    \"unconsumed_producers\": " << top_unconsumed_producers << ",\n"
             << "    \"multiply_consumed_producers\": "
             << top_multiply_consumed_producers << "\n  }"
             << ",\n  \"value_flow\": {\n"
             << "    \"known_prototypes\": " << value_flow_known << ",\n"
             << "    \"unknown_prototypes\": " << value_flow_unknown << ",\n"
             << "    \"nonconverged_prototypes\": " << value_flow_nonconverged << ",\n"
             << "    \"definitions\": " << value_definitions << ",\n"
             << "    \"uses\": " << value_uses << ",\n"
             << "    \"reaching_links\": " << value_links << ",\n"
             << "    \"single_origin_uses\": " << single_origin_uses << ",\n"
             << "    \"multiple_origin_uses\": " << multiple_origin_uses << ",\n"
             << "    \"missing_origin_uses\": " << missing_origin_uses << ",\n"
             << "    \"open_definitions\": " << open_value_definitions << ",\n"
             << "    \"open_uses\": " << open_range_uses << ",\n"
             << "    \"parameter_origin_uses\": " << parameter_origin_uses << ",\n"
             << "    \"entry_origin_uses\": " << entry_origin_uses << "\n  }"
             << ",\n  \"semantic_call_contracts\": {\n"
             << "    \"owned\": " << owned_calls << ",\n"
             << "    \"method\": " << owned_method_calls << ",\n"
             << "    \"ordinary\": " << owned_ordinary_calls << ",\n"
             << "    \"open_arguments\": " << owned_open_arguments << ",\n"
             << "    \"open_results\": " << owned_open_results << ",\n"
             << "    \"callee_origin_links\": " << owned_call_callee_links << ",\n"
             << "    \"receiver_origin_links\": " << owned_call_receiver_links << ",\n"
             << "    \"fixed_argument_values\": " << owned_call_argument_values << ",\n"
             << "    \"argument_origin_links\": " << owned_call_argument_links << ",\n"
             << "    \"multi_origin_arguments\": "
             << owned_call_multi_origin_arguments << "\n  }"
             << ",\n  \"call_result_census\": {\n"
             << "    \"calls\": " << calls << ",\n"
             << "    \"open_arguments\": " << calls_open_arguments << ",\n"
             << "    \"open_results\": " << calls_open_results << ",\n"
             << "    \"returns\": " << returns << ",\n"
             << "    \"open_returns\": " << returns_open_results << ",\n"
             << "    \"vararg_reads\": " << vararg_reads << ",\n"
             << "    \"open_varargs\": " << vararg_open_results << "\n  }"
             << ",\n  \"cfg_reducibility\": {\n"
             << "    \"reducible_prototypes\": " << reducible_prototypes << ",\n"
             << "    \"irreducible_prototypes\": " << irreducible_prototypes << ",\n"
             << "    \"preserved_in_reducible\": " << preserved_in_reducible << ",\n"
             << "    \"preserved_in_irreducible\": "
             << preserved_in_irreducible << "\n  }"
             << ",\n  \"failure_categories\": {";
        first = true;
        for (const auto& category : categories) {
            if (!first) json << ',';
            first = false;
            json << "\n    \"" << sir::json_escape(category.first) << "\": " << category.second;
        }
        if (!categories.empty()) json << '\n';
        json << "  },\n  \"observation_categories\": {";
        first = true;
        for (const auto& category : observation_categories) {
            if (!first) json << ',';
            first = false;
            json << "\n    \"" << sir::json_escape(category.first) << "\": " << category.second;
        }
        if (!observation_categories.empty()) json << '\n';
        json << "  },\n  \"examples\": [";
        for (size_t index = 0; index < examples.size(); ++index) {
            if (index) json << ',';
            json << "\n    \"" << sir::json_escape(examples[index]) << '"';
        }
        if (!examples.empty()) json << '\n';
        json << "  ]\n}\n";
        const fs2::path destination = json_path;
        std::error_code error;
        if (destination.has_parent_path()) fs2::create_directories(destination.parent_path(), error);
        if (error || !write_file(json_path, json.str())) {
            std::fprintf(stderr, "semantic-ir-verify-corpus: cannot write JSON\n"); return 2;
        }
        std::printf("json=%s\n", json_path.c_str());
    }
    return failed == 0 && attempted > 0 ? 0 : 1;
}
