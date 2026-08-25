// semantic_ir/model.h -- renderer-independent semantic source model.
#pragma once
#include <cstdint>
#include <map>
#include <set>
#include <string>
#include <vector>

namespace sir {

template<class Tag>
struct Id {
    int value = -1;
    Id() = default;
    explicit Id(int v) : value(v) {}
    bool valid() const { return value >= 0; }
    bool operator<(const Id& other) const { return value < other.value; }
    bool operator==(const Id& other) const { return value == other.value; }
    bool operator!=(const Id& other) const { return !(*this == other); }
};

struct NodeTag {}; struct FunctionTag {}; struct BlockTag {}; struct LoopTag {};
struct EffectTag {}; struct PrototypeTag {}; struct CaptureTag {};
using NodeId = Id<NodeTag>; using FunctionId = Id<FunctionTag>;
using BlockId = Id<BlockTag>; using LoopId = Id<LoopTag>;
using EffectId = Id<EffectTag>; using PrototypeId = Id<PrototypeTag>;
using CaptureId = Id<CaptureTag>;

enum class NodeKind {
    Module, Function, Sequence, Statement, If, IfElse, While, Repeat,
    NumericFor, GenericFor, Break, Continue, Return, Call, Assignment,
    TableConstructor, Closure, ScopeClose, UnknownPreservedOperation, Fallthrough, LoopEntry,
    BooleanSkipTransfer, LinearTransfer, JoinTransfer, LoopCondition, LoopLatch,
    LoopExitTransfer, RedundantPredicate, BooleanShortCircuit, ConditionalBreak,
    ConditionalContinue, ConditionalBreakContinue, PreservedCyclicBranch,
    PreservedSharedBranch, PreservedEscapingBranch, UnresolvedBranch, UnresolvedControl
};

enum class EdgeKind {
    Sequence, Unconditional, BranchTrue, BranchFalse, LoopBack, LoopExit, Break,
    Continue, Return
};

enum class ExitKind { Normal, Break, Return, Exceptional };
enum class CaptureMode { Value = 0, Reference = 1, Upvalue = 2 };
enum class BranchRole {
    Region, LoopCondition, Redundant, ShortCircuitSharedTrue,
    ShortCircuitSharedFalse, ConditionalBreak, ConditionalContinue,
    ConditionalBreakContinue, PreservedCyclic, PreservedShared,
    PreservedEscaping, Unresolved
};

struct Edge {
    BlockId source;
    BlockId target; // invalid for Return
    EdgeKind kind = EdgeKind::Sequence;
    bool operator<(const Edge& other) const {
        if (source != other.source) return source < other.source;
        if (target != other.target) return target < other.target;
        return (int)kind < (int)other.kind;
    }
    bool operator==(const Edge& other) const {
        return source == other.source && target == other.target && kind == other.kind;
    }
};

struct Exit {
    BlockId source;
    BlockId target; // invalid for Return
    ExitKind kind = ExitKind::Normal;
    bool operator<(const Exit& other) const {
        if (source != other.source) return source < other.source;
        if (target != other.target) return target < other.target;
        return (int)kind < (int)other.kind;
    }
    bool operator==(const Exit& other) const {
        return source == other.source && target == other.target && kind == other.kind;
    }
};

struct AuthoritativeLoop {
    LoopId id;
    LoopId parent;
    BlockId prep;
    BlockId canonical_latch;
    std::set<LoopId> children;
    std::set<BlockId> body;
    std::set<BlockId> latches;
    std::set<Exit> exits;
};

struct ValueOriginContract {
    int kind = 0; // 0 parameter, 1 entry register, 2 instruction definition
    int instruction = -1;
    int reg = -1;
    bool operator<(const ValueOriginContract& other) const {
        if (kind != other.kind) return kind < other.kind;
        if (instruction != other.instruction) return instruction < other.instruction;
        return reg < other.reg;
    }
    bool operator==(const ValueOriginContract& other) const {
        return kind == other.kind && instruction == other.instruction && reg == other.reg;
    }
};

struct CallContract {
    PrototypeId owner;
    BlockId block;
    int instruction = -1;
    int effect_order = -1;
    int base_register = -1;
    bool method_call = false;
    int namecall_instruction = -1;
    int receiver_register = -1;
    int argument_first = -1;
    int argument_count = 0; // -1 means open through the current VM top
    int explicit_argument_first = -1;
    int explicit_argument_count = 0; // excludes NAMECALL's implicit receiver
    int result_first = -1;
    int result_count = 0; // -1 means open through the resulting VM top
    std::set<ValueOriginContract> callee_origins;
    std::set<ValueOriginContract> receiver_origins;
    std::vector<std::set<ValueOriginContract>> fixed_argument_origins;
    int open_argument_origin_kind = -1;
    int open_argument_origin_instruction = -1;
    int open_argument_origin_base = -1;
    bool operator<(const CallContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (instruction != other.instruction) return instruction < other.instruction;
        if (block != other.block) return block < other.block;
        if (effect_order != other.effect_order) return effect_order < other.effect_order;
        if (base_register != other.base_register) return base_register < other.base_register;
        if (method_call != other.method_call) return method_call < other.method_call;
        if (namecall_instruction != other.namecall_instruction)
            return namecall_instruction < other.namecall_instruction;
        if (receiver_register != other.receiver_register)
            return receiver_register < other.receiver_register;
        if (argument_first != other.argument_first)
            return argument_first < other.argument_first;
        if (argument_count != other.argument_count)
            return argument_count < other.argument_count;
        if (explicit_argument_first != other.explicit_argument_first)
            return explicit_argument_first < other.explicit_argument_first;
        if (explicit_argument_count != other.explicit_argument_count)
            return explicit_argument_count < other.explicit_argument_count;
        if (result_first != other.result_first) return result_first < other.result_first;
        if (result_count != other.result_count) return result_count < other.result_count;
        if (callee_origins != other.callee_origins)
            return callee_origins < other.callee_origins;
        if (receiver_origins != other.receiver_origins)
            return receiver_origins < other.receiver_origins;
        if (fixed_argument_origins != other.fixed_argument_origins)
            return fixed_argument_origins < other.fixed_argument_origins;
        if (open_argument_origin_kind != other.open_argument_origin_kind)
            return open_argument_origin_kind < other.open_argument_origin_kind;
        if (open_argument_origin_instruction != other.open_argument_origin_instruction)
            return open_argument_origin_instruction < other.open_argument_origin_instruction;
        return open_argument_origin_base < other.open_argument_origin_base;
    }
    bool operator==(const CallContract& other) const {
        return owner == other.owner && block == other.block
            && instruction == other.instruction && effect_order == other.effect_order
            && base_register == other.base_register && method_call == other.method_call
            && namecall_instruction == other.namecall_instruction
            && receiver_register == other.receiver_register
            && argument_first == other.argument_first
            && argument_count == other.argument_count
            && explicit_argument_first == other.explicit_argument_first
            && explicit_argument_count == other.explicit_argument_count
            && result_first == other.result_first && result_count == other.result_count
            && callee_origins == other.callee_origins
            && receiver_origins == other.receiver_origins
            && fixed_argument_origins == other.fixed_argument_origins
            && open_argument_origin_kind == other.open_argument_origin_kind
            && open_argument_origin_instruction == other.open_argument_origin_instruction
            && open_argument_origin_base == other.open_argument_origin_base;
    }
};

struct ReturnContract {
    PrototypeId owner;
    BlockId block;
    int instruction = -1;
    int effect_order = -1;
    int first_register = -1;
    int value_count = 0; // -1 means symbolic open results
    std::vector<std::set<ValueOriginContract>> fixed_values;
    int open_origin_kind = -1; // vf::TopKind, only for value_count == -1
    int open_origin_instruction = -1;
    int open_origin_base = -1;
    bool operator<(const ReturnContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (instruction != other.instruction) return instruction < other.instruction;
        if (block != other.block) return block < other.block;
        if (effect_order != other.effect_order) return effect_order < other.effect_order;
        if (first_register != other.first_register) return first_register < other.first_register;
        if (value_count != other.value_count) return value_count < other.value_count;
        if (fixed_values != other.fixed_values) return fixed_values < other.fixed_values;
        if (open_origin_kind != other.open_origin_kind)
            return open_origin_kind < other.open_origin_kind;
        if (open_origin_instruction != other.open_origin_instruction)
            return open_origin_instruction < other.open_origin_instruction;
        return open_origin_base < other.open_origin_base;
    }
    bool operator==(const ReturnContract& other) const {
        return owner == other.owner && block == other.block
            && instruction == other.instruction && effect_order == other.effect_order
            && first_register == other.first_register && value_count == other.value_count
            && fixed_values == other.fixed_values
            && open_origin_kind == other.open_origin_kind
            && open_origin_instruction == other.open_origin_instruction
            && open_origin_base == other.open_origin_base;
    }
};

enum class TableOperationKind {
    NewTable = 0, DuplicateTemplate = 1, SetField = 2, SetIndex = 3,
    SetNumber = 4, SetList = 5
};

enum class StoreOperationKind { Global = 0, Upvalue = 1 };

struct StoreOperationContract {
    PrototypeId owner;
    BlockId block;
    int instruction = -1;
    int effect_order = -1;
    StoreOperationKind kind = StoreOperationKind::Global;
    std::set<ValueOriginContract> value_origins;
    std::string name;
    int upvalue_slot = -1;
    int raw_a = 0, raw_b = 0;
    bool operator<(const StoreOperationContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (instruction != other.instruction) return instruction < other.instruction;
        if (block != other.block) return block < other.block;
        if (effect_order != other.effect_order) return effect_order < other.effect_order;
        if (kind != other.kind) return (int)kind < (int)other.kind;
        if (value_origins != other.value_origins)
            return value_origins < other.value_origins;
        if (name != other.name) return name < other.name;
        if (upvalue_slot != other.upvalue_slot) return upvalue_slot < other.upvalue_slot;
        if (raw_a != other.raw_a) return raw_a < other.raw_a;
        return raw_b < other.raw_b;
    }
    bool operator==(const StoreOperationContract& other) const {
        return !(*this < other) && !(other < *this);
    }
};

struct TableOperationContract {
    PrototypeId owner;
    BlockId block;
    int instruction = -1;
    int effect_order = -1; // -1 for pure allocation identity
    TableOperationKind kind = TableOperationKind::NewTable;
    int table_register = -1;
    std::set<ValueOriginContract> table_origins;
    int value_register = -1;
    std::set<ValueOriginContract> value_origins;
    int key_register = -1;
    std::set<ValueOriginContract> key_origins;
    std::string field_name;
    int numeric_key = -1;
    int list_first_register = -1;
    int list_value_count = 0; // -1 means symbolic multret tail
    int list_start_index = -1;
    std::vector<std::set<ValueOriginContract>> list_fixed_values;
    int list_open_origin_kind = -1;
    int list_open_origin_instruction = -1;
    int list_open_origin_base = -1;
    int raw_a = 0, raw_b = 0, raw_c = 0, raw_bx = 0;
    uint32_t raw_aux = 0;
    bool operator<(const TableOperationContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (instruction != other.instruction) return instruction < other.instruction;
        if (block != other.block) return block < other.block;
        if (effect_order != other.effect_order) return effect_order < other.effect_order;
        if (kind != other.kind) return (int)kind < (int)other.kind;
        if (table_register != other.table_register) return table_register < other.table_register;
        if (table_origins != other.table_origins) return table_origins < other.table_origins;
        if (value_register != other.value_register) return value_register < other.value_register;
        if (value_origins != other.value_origins) return value_origins < other.value_origins;
        if (key_register != other.key_register) return key_register < other.key_register;
        if (key_origins != other.key_origins) return key_origins < other.key_origins;
        if (field_name != other.field_name) return field_name < other.field_name;
        if (numeric_key != other.numeric_key) return numeric_key < other.numeric_key;
        if (list_first_register != other.list_first_register)
            return list_first_register < other.list_first_register;
        if (list_value_count != other.list_value_count)
            return list_value_count < other.list_value_count;
        if (list_start_index != other.list_start_index)
            return list_start_index < other.list_start_index;
        if (list_fixed_values != other.list_fixed_values)
            return list_fixed_values < other.list_fixed_values;
        if (list_open_origin_kind != other.list_open_origin_kind)
            return list_open_origin_kind < other.list_open_origin_kind;
        if (list_open_origin_instruction != other.list_open_origin_instruction)
            return list_open_origin_instruction < other.list_open_origin_instruction;
        if (list_open_origin_base != other.list_open_origin_base)
            return list_open_origin_base < other.list_open_origin_base;
        if (raw_a != other.raw_a) return raw_a < other.raw_a;
        if (raw_b != other.raw_b) return raw_b < other.raw_b;
        if (raw_c != other.raw_c) return raw_c < other.raw_c;
        if (raw_bx != other.raw_bx) return raw_bx < other.raw_bx;
        return raw_aux < other.raw_aux;
    }
    bool operator==(const TableOperationContract& other) const {
        return !(*this < other) && !(other < *this);
    }
};

struct CaptureContract {
    CaptureId capture;
    PrototypeId owner;
    PrototypeId target;
    int closure_instruction = -1;
    int slot = -1;
    CaptureMode mode = CaptureMode::Value;
    int source = -1;
    // VAL copies these reaching values. REF shares the cell identified by the
    // source register and these possible cell births. UPVAL names a parent slot.
    std::set<ValueOriginContract> source_origins;
    int reference_cell_register = -1;
    int parent_upvalue_slot = -1;
    bool operator<(const CaptureContract& other) const {
        if (capture != other.capture) return capture < other.capture;
        if (owner != other.owner) return owner < other.owner;
        if (target != other.target) return target < other.target;
        if (closure_instruction != other.closure_instruction)
            return closure_instruction < other.closure_instruction;
        if (slot != other.slot) return slot < other.slot;
        if (mode != other.mode) return (int)mode < (int)other.mode;
        if (source != other.source) return source < other.source;
        if (source_origins != other.source_origins)
            return source_origins < other.source_origins;
        if (reference_cell_register != other.reference_cell_register)
            return reference_cell_register < other.reference_cell_register;
        return parent_upvalue_slot < other.parent_upvalue_slot;
    }
    bool operator==(const CaptureContract& other) const {
        return capture == other.capture && owner == other.owner && target == other.target
            && closure_instruction == other.closure_instruction && slot == other.slot
            && mode == other.mode && source == other.source
            && source_origins == other.source_origins
            && reference_cell_register == other.reference_cell_register
            && parent_upvalue_slot == other.parent_upvalue_slot;
    }
};

struct ScopeCloseContract {
    PrototypeId owner;
    BlockId block;
    int instruction = -1;
    int first_register = -1; // closes every open captured local at or above A
    bool operator<(const ScopeCloseContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (instruction != other.instruction) return instruction < other.instruction;
        if (block != other.block) return block < other.block;
        return first_register < other.first_register;
    }
    bool operator==(const ScopeCloseContract& other) const {
        return owner == other.owner && block == other.block
            && instruction == other.instruction
            && first_register == other.first_register;
    }
};

struct LocalUseSite {
    BlockId block;
    int instruction = -1;
    bool operator<(const LocalUseSite& other) const {
        if (instruction != other.instruction) return instruction < other.instruction;
        return block < other.block;
    }
    bool operator==(const LocalUseSite& other) const {
        return block == other.block && instruction == other.instruction;
    }
};

struct LocalBlockLifetime {
    BlockId block;
    int first_instruction = -1;
    int last_instruction = -1;
    bool live_in = false;
    bool live_out = false;
    bool operator<(const LocalBlockLifetime& other) const {
        if (block != other.block) return block < other.block;
        if (first_instruction != other.first_instruction)
            return first_instruction < other.first_instruction;
        if (last_instruction != other.last_instruction)
            return last_instruction < other.last_instruction;
        if (live_in != other.live_in) return live_in < other.live_in;
        return live_out < other.live_out;
    }
    bool operator==(const LocalBlockLifetime& other) const {
        return block == other.block && first_instruction == other.first_instruction
            && last_instruction == other.last_instruction && live_in == other.live_in
            && live_out == other.live_out;
    }
};

struct LocalValueContract {
    PrototypeId owner;
    ValueOriginContract identity;
    BlockId definition_block;
    BlockId declaration_block;
    bool parameter = false;
    std::set<LocalUseSite> uses;
    std::set<LocalBlockLifetime> lifetimes;
    std::set<CaptureId> copied_by_captures;
    std::set<CaptureId> shared_by_captures;
    bool operator<(const LocalValueContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (!(identity == other.identity)) return identity < other.identity;
        if (definition_block != other.definition_block)
            return definition_block < other.definition_block;
        if (declaration_block != other.declaration_block)
            return declaration_block < other.declaration_block;
        if (parameter != other.parameter) return parameter < other.parameter;
        if (uses != other.uses) return uses < other.uses;
        if (lifetimes != other.lifetimes) return lifetimes < other.lifetimes;
        if (copied_by_captures != other.copied_by_captures)
            return copied_by_captures < other.copied_by_captures;
        return shared_by_captures < other.shared_by_captures;
    }
    bool operator==(const LocalValueContract& other) const {
        return !(*this < other) && !(other < *this);
    }
};

enum class ValueMergeKind {
    Conditional = 0, LoopCarried = 1, ConditionalLoop = 2, Preserved = 3
};

struct ValueMergeContract {
    PrototypeId owner;
    int web_id = -1;
    LocalUseSite use;
    int reg = -1;
    std::set<ValueOriginContract> origins;
    ValueMergeKind kind = ValueMergeKind::Preserved;
    BlockId conditional_source;
    LoopId loop;
    bool operator<(const ValueMergeContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (!(use == other.use)) return use < other.use;
        if (reg != other.reg) return reg < other.reg;
        if (web_id != other.web_id) return web_id < other.web_id;
        if (origins != other.origins) return origins < other.origins;
        if (kind != other.kind) return (int)kind < (int)other.kind;
        if (conditional_source != other.conditional_source)
            return conditional_source < other.conditional_source;
        return loop < other.loop;
    }
    bool operator==(const ValueMergeContract& other) const {
        return !(*this < other) && !(other < *this);
    }
};

struct ValueWebContract {
    PrototypeId owner;
    int id = -1;
    int reg = -1;
    BlockId declaration_block;
    std::set<ValueOriginContract> members;
    std::set<LocalUseSite> uses;
    std::set<LocalUseSite> merge_uses;
    bool operator<(const ValueWebContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (id != other.id) return id < other.id;
        if (reg != other.reg) return reg < other.reg;
        if (declaration_block != other.declaration_block)
            return declaration_block < other.declaration_block;
        if (members != other.members) return members < other.members;
        if (uses != other.uses) return uses < other.uses;
        return merge_uses < other.merge_uses;
    }
    bool operator==(const ValueWebContract& other) const {
        return !(*this < other) && !(other < *this);
    }
};

enum class ExpressionKind {
    Number = 0, Constant, Nil, Boolean, Move, UpvalueRead, GlobalRead,
    ImportRead, FieldRead, IndexRead, NumberIndexRead, NewTable,
    DuplicateTable, ClosureValue, VarargResult, Unary, Concatenate, Binary,
    MethodFunction, MethodReceiver, CallResult, NumericLoopState,
    GenericLoopResult, Preserved
};

struct ExpressionDefinitionContract {
    PrototypeId owner;
    BlockId block;
    ValueOriginContract identity;
    ExpressionKind kind = ExpressionKind::Preserved;
    std::string opcode;
    std::string operator_text;
    std::vector<std::set<ValueOriginContract>> operands;
    int result_slot = 0;
    bool open_result = false;
    bool open_operands = false;
    int constant_index = -1;
    int constant_kind = -1;
    std::string constant_text;
    std::string name;
    int upvalue_slot = -1;
    int closure_target = -1;
    bool compiler_scaffolding = false;
    int raw_a = 0, raw_b = 0, raw_c = 0, raw_bx = 0;
    uint32_t raw_aux = 0;
    bool operator<(const ExpressionDefinitionContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (!(identity == other.identity)) return identity < other.identity;
        if (block != other.block) return block < other.block;
        if (kind != other.kind) return (int)kind < (int)other.kind;
        if (opcode != other.opcode) return opcode < other.opcode;
        if (operator_text != other.operator_text) return operator_text < other.operator_text;
        if (operands != other.operands) return operands < other.operands;
        if (result_slot != other.result_slot) return result_slot < other.result_slot;
        if (open_result != other.open_result) return open_result < other.open_result;
        if (open_operands != other.open_operands) return open_operands < other.open_operands;
        if (constant_index != other.constant_index) return constant_index < other.constant_index;
        if (constant_kind != other.constant_kind) return constant_kind < other.constant_kind;
        if (constant_text != other.constant_text) return constant_text < other.constant_text;
        if (name != other.name) return name < other.name;
        if (upvalue_slot != other.upvalue_slot) return upvalue_slot < other.upvalue_slot;
        if (closure_target != other.closure_target) return closure_target < other.closure_target;
        if (compiler_scaffolding != other.compiler_scaffolding)
            return compiler_scaffolding < other.compiler_scaffolding;
        if (raw_a != other.raw_a) return raw_a < other.raw_a;
        if (raw_b != other.raw_b) return raw_b < other.raw_b;
        if (raw_c != other.raw_c) return raw_c < other.raw_c;
        if (raw_bx != other.raw_bx) return raw_bx < other.raw_bx;
        return raw_aux < other.raw_aux;
    }
    bool operator==(const ExpressionDefinitionContract& other) const {
        return !(*this < other) && !(other < *this);
    }
};

enum class EmissionDisposition {
    ExplicitStatement = 0, InlineLiteral = 1, StructuralScaffolding = 2
};

struct DefinitionEmissionContract {
    PrototypeId owner;
    ValueOriginContract identity;
    EmissionDisposition disposition = EmissionDisposition::ExplicitStatement;
    ValueOriginContract group_leader;
    bool emits_statement = false;
    LocalUseSite inline_use;
    int web_id = -1;
    bool single_use = false;
    bool single_origin_at_use = false;
    bool dominance_proven = false;
    bool capture_free = false;
    bool operator<(const DefinitionEmissionContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (!(identity == other.identity)) return identity < other.identity;
        if (disposition != other.disposition)
            return (int)disposition < (int)other.disposition;
        if (!(group_leader == other.group_leader))
            return group_leader < other.group_leader;
        if (emits_statement != other.emits_statement)
            return emits_statement < other.emits_statement;
        if (!(inline_use == other.inline_use)) return inline_use < other.inline_use;
        if (web_id != other.web_id) return web_id < other.web_id;
        if (single_use != other.single_use) return single_use < other.single_use;
        if (single_origin_at_use != other.single_origin_at_use)
            return single_origin_at_use < other.single_origin_at_use;
        if (dominance_proven != other.dominance_proven)
            return dominance_proven < other.dominance_proven;
        return capture_free < other.capture_free;
    }
    bool operator==(const DefinitionEmissionContract& other) const {
        return !(*this < other) && !(other < *this);
    }
};

struct ClosureContract {
    PrototypeId owner;
    PrototypeId target;
    int instruction = -1;
    int destination_register = -1;
    int expected_capture_count = 0;
    std::vector<CaptureContract> captures;
    bool operator<(const ClosureContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (instruction != other.instruction) return instruction < other.instruction;
        if (target != other.target) return target < other.target;
        if (destination_register != other.destination_register)
            return destination_register < other.destination_register;
        if (expected_capture_count != other.expected_capture_count)
            return expected_capture_count < other.expected_capture_count;
        return captures < other.captures;
    }
    bool operator==(const ClosureContract& other) const {
        return owner == other.owner && target == other.target
            && instruction == other.instruction
            && destination_register == other.destination_register
            && expected_capture_count == other.expected_capture_count
            && captures == other.captures;
    }
};

struct BranchContract {
    BlockId source;
    BlockId true_target;
    BlockId false_target;
    BlockId join;
    bool virtual_exit_join = false;
    BlockId chain_next;
    BlockId chain_shared_target;
    bool true_escapes_region = false;
    bool false_escapes_region = false;
    bool true_has_terminal = false;
    bool false_has_terminal = false;
    BranchRole role = BranchRole::Unresolved;
    LoopId loop;
    std::set<BlockId> true_blocks;
    std::set<BlockId> false_blocks;
    bool operator<(const BranchContract& other) const {
        if (source != other.source) return source < other.source;
        if (true_target != other.true_target) return true_target < other.true_target;
        if (false_target != other.false_target) return false_target < other.false_target;
        if (join != other.join) return join < other.join;
        if (virtual_exit_join != other.virtual_exit_join)
            return virtual_exit_join < other.virtual_exit_join;
        if (chain_next != other.chain_next) return chain_next < other.chain_next;
        if (chain_shared_target != other.chain_shared_target)
            return chain_shared_target < other.chain_shared_target;
        if (true_escapes_region != other.true_escapes_region)
            return true_escapes_region < other.true_escapes_region;
        if (false_escapes_region != other.false_escapes_region)
            return false_escapes_region < other.false_escapes_region;
        if (true_has_terminal != other.true_has_terminal)
            return true_has_terminal < other.true_has_terminal;
        if (false_has_terminal != other.false_has_terminal)
            return false_has_terminal < other.false_has_terminal;
        if (role != other.role) return (int)role < (int)other.role;
        if (loop != other.loop) return loop < other.loop;
        if (true_blocks != other.true_blocks) return true_blocks < other.true_blocks;
        return false_blocks < other.false_blocks;
    }
    bool operator==(const BranchContract& other) const {
        return source == other.source && true_target == other.true_target
            && false_target == other.false_target && join == other.join
            && virtual_exit_join == other.virtual_exit_join
            && chain_next == other.chain_next
            && chain_shared_target == other.chain_shared_target
            && true_escapes_region == other.true_escapes_region
            && false_escapes_region == other.false_escapes_region
            && true_has_terminal == other.true_has_terminal
            && false_has_terminal == other.false_has_terminal
            && role == other.role && loop == other.loop
            && true_blocks == other.true_blocks && false_blocks == other.false_blocks;
    }
};

enum class PredicateTestKind {
    Truthy = 0, Falsey, Equal, NotEqual, Less, LessEqual,
    NumericForExhausted, NumericForAdvance, GenericForAdvance, Preserved
};

struct PredicateTestContract {
    PrototypeId owner;
    BlockId block;
    int instruction = -1;
    PredicateTestKind kind = PredicateTestKind::Preserved;
    std::string opcode;
    std::vector<std::set<ValueOriginContract>> operands;
    int constant_index = -1;
    int constant_kind = -1;
    std::string constant_text;
    bool branch_on_true = true;
    int raw_a = 0;
    uint32_t raw_aux = 0;
    bool operator<(const PredicateTestContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (instruction != other.instruction) return instruction < other.instruction;
        if (block != other.block) return block < other.block;
        if (kind != other.kind) return (int)kind < (int)other.kind;
        if (opcode != other.opcode) return opcode < other.opcode;
        if (operands != other.operands) return operands < other.operands;
        if (constant_index != other.constant_index)
            return constant_index < other.constant_index;
        if (constant_kind != other.constant_kind)
            return constant_kind < other.constant_kind;
        if (constant_text != other.constant_text)
            return constant_text < other.constant_text;
        if (branch_on_true != other.branch_on_true)
            return branch_on_true < other.branch_on_true;
        if (raw_a != other.raw_a) return raw_a < other.raw_a;
        return raw_aux < other.raw_aux;
    }
    bool operator==(const PredicateTestContract& other) const {
        return !(*this < other) && !(other < *this);
    }
};

// Exact branch-taken boolean expression for one structured CFG block.  The
// structurer can collapse several bytecode tests into one block; retaining only
// the block's final test silently changes `a or b` into `b`.  Nodes are stored
// in deterministic post-order and refer to earlier children by index.
enum class PredicateExpressionKind { Test = 0, Not, And, Or };

struct PredicateExpressionNodeContract {
    PredicateExpressionKind kind = PredicateExpressionKind::Test;
    int left = -1;
    int right = -1;
    PredicateTestContract test;
    bool operator<(const PredicateExpressionNodeContract& other) const {
        if (kind != other.kind) return (int)kind < (int)other.kind;
        if (left != other.left) return left < other.left;
        if (right != other.right) return right < other.right;
        return test < other.test;
    }
    bool operator==(const PredicateExpressionNodeContract& other) const {
        return !(*this < other) && !(other < *this);
    }
};

struct PredicateExpressionContract {
    PrototypeId owner;
    BlockId block;
    std::vector<PredicateExpressionNodeContract> nodes;
    int root = -1;
    bool operator<(const PredicateExpressionContract& other) const {
        if (owner != other.owner) return owner < other.owner;
        if (block != other.block) return block < other.block;
        if (root != other.root) return root < other.root;
        return nodes < other.nodes;
    }
    bool operator==(const PredicateExpressionContract& other) const {
        return !(*this < other) && !(other < *this);
    }
};

struct Node {
    NodeId id;
    NodeId parent;
    NodeKind kind = NodeKind::Statement;
    std::vector<NodeId> children; // semantic execution order
    std::set<BlockId> blocks;     // blocks owned directly by this node
    std::vector<EffectId> effects; // effects owned directly, in execution order
    BlockId control_source;
    std::set<Edge> control_edges;
    int control_instruction = -1;
    std::string control_opcode;
    int control_target_predecessor_count = 0;
    bool control_source_dominates_target = false;
    LoopId control_loop;
    BlockId branch_true_target;
    BlockId branch_false_target;
    BlockId branch_join;
    bool branch_virtual_exit_join = false;
    BlockId branch_chain_next;
    BlockId branch_chain_shared_target;
    bool branch_true_escapes_region = false;
    bool branch_false_escapes_region = false;
    bool branch_true_has_terminal = false;
    bool branch_false_has_terminal = false;
    BranchRole branch_role = BranchRole::Unresolved;
    std::set<BlockId> branch_true_blocks;
    std::set<BlockId> branch_false_blocks;
    LoopId loop;
    LoopId loop_parent;
    std::set<LoopId> loop_children;
    std::set<BlockId> loop_body;
    std::set<BlockId> loop_latches;
    BlockId loop_canonical_latch;
    std::set<Exit> loop_exits;
    PrototypeId prototype;
    PrototypeId closure_prototype;
    int maximum_register_count = 0;
    int upvalue_count = 0;
    int closure_instruction = -1;
    int closure_destination_register = -1;
    int target_upvalue_count = 0;
    std::vector<CaptureContract> captures;
    int parameter_count = 0;
    bool accepts_varargs = false;
    int fixed_result_count = 0;
    bool returns_multiple = false;
    std::set<LocalValueContract> local_values;
    std::set<ValueWebContract> value_webs;
    std::set<ValueMergeContract> value_merges;
    std::set<ExpressionDefinitionContract> expressions;
    std::set<DefinitionEmissionContract> definition_emissions;
    bool has_predicate_test = false;
    PredicateTestContract predicate_test;
    bool has_predicate_expression = false;
    PredicateExpressionContract predicate_expression;
    BlockId call_block;
    int call_instruction = -1;
    int call_effect_order = -1;
    int call_base_register = -1;
    bool call_is_method = false;
    int call_namecall_instruction = -1;
    int call_receiver_register = -1;
    int call_argument_first = -1;
    int call_argument_count = 0;
    int call_explicit_argument_first = -1;
    int call_explicit_argument_count = 0;
    int call_result_first = -1;
    int call_result_count = 0;
    std::set<ValueOriginContract> call_callee_origins;
    std::set<ValueOriginContract> call_receiver_origins;
    std::vector<std::set<ValueOriginContract>> call_fixed_argument_origins;
    int call_open_argument_origin_kind = -1;
    int call_open_argument_origin_instruction = -1;
    int call_open_argument_origin_base = -1;
    BlockId return_block;
    int return_instruction = -1;
    int return_effect_order = -1;
    int return_first_register = -1;
    int return_value_count = 0;
    std::vector<std::set<ValueOriginContract>> return_fixed_values;
    int return_open_origin_kind = -1;
    int return_open_origin_instruction = -1;
    int return_open_origin_base = -1;
    bool has_table_operation = false;
    TableOperationContract table_operation;
    bool has_store_operation = false;
    StoreOperationContract store_operation;
    bool has_scope_close = false;
    ScopeCloseContract scope_close;
    std::string preserved_opcode;
};

struct Model {
    PrototypeId prototype;
    NodeId root;
    std::map<NodeId, Node> nodes;
    std::set<BlockId> reachable_blocks;
    std::map<int, std::pair<int, int>> block_instruction_ranges;
    std::map<int, std::set<int>> block_dominators;
    std::set<BlockId> compiler_scaffolding;
    std::set<EffectId> observable_effects;
    std::vector<EffectId> authoritative_effect_order;
    std::vector<EffectId> semantic_effect_order;
    std::map<LoopId, AuthoritativeLoop> authoritative_loops;
    std::set<Edge> cfg_edges;
    std::set<PrototypeId> authoritative_prototypes;
    int authoritative_upvalue_count = 0;
    std::set<ClosureContract> authoritative_closures;
    std::set<BranchContract> authoritative_branches;
    std::set<CaptureContract> authoritative_captures;
    std::set<CallContract> authoritative_calls;
    std::set<ReturnContract> authoritative_returns;
    std::set<TableOperationContract> authoritative_table_operations;
    std::set<StoreOperationContract> authoritative_store_operations;
    std::set<ScopeCloseContract> authoritative_scope_closes;
    std::set<LocalValueContract> authoritative_local_values;
    std::set<ValueWebContract> authoritative_value_webs;
    std::set<ValueMergeContract> authoritative_value_merges;
    std::set<ExpressionDefinitionContract> authoritative_expressions;
    std::set<DefinitionEmissionContract> authoritative_definition_emissions;
    std::set<PredicateTestContract> authoritative_predicate_tests;
    std::set<PredicateExpressionContract> authoritative_predicate_expressions;
    std::vector<std::string> ownership_conflicts;
    bool renderer_ready = false;
};

inline const char* node_kind_name(NodeKind kind) {
    switch (kind) {
        case NodeKind::Module: return "Module"; case NodeKind::Function: return "Function";
        case NodeKind::Sequence: return "Sequence"; case NodeKind::Statement: return "Statement";
        case NodeKind::If: return "If"; case NodeKind::IfElse: return "IfElse";
        case NodeKind::While: return "While"; case NodeKind::Repeat: return "Repeat";
        case NodeKind::NumericFor: return "NumericFor"; case NodeKind::GenericFor: return "GenericFor";
        case NodeKind::Break: return "Break"; case NodeKind::Continue: return "Continue";
        case NodeKind::Return: return "Return"; case NodeKind::Call: return "Call";
        case NodeKind::Assignment: return "Assignment";
        case NodeKind::TableConstructor: return "TableConstructor";
        case NodeKind::Closure: return "Closure";
        case NodeKind::ScopeClose: return "ScopeClose";
        case NodeKind::UnknownPreservedOperation: return "UnknownPreservedOperation";
        case NodeKind::Fallthrough: return "Fallthrough";
        case NodeKind::LoopEntry: return "LoopEntry";
        case NodeKind::BooleanSkipTransfer: return "BooleanSkipTransfer";
        case NodeKind::LinearTransfer: return "LinearTransfer";
        case NodeKind::JoinTransfer: return "JoinTransfer";
        case NodeKind::LoopCondition: return "LoopCondition";
        case NodeKind::LoopLatch: return "LoopLatch";
        case NodeKind::LoopExitTransfer: return "LoopExitTransfer";
        case NodeKind::RedundantPredicate: return "RedundantPredicate";
        case NodeKind::BooleanShortCircuit: return "BooleanShortCircuit";
        case NodeKind::ConditionalBreak: return "ConditionalBreak";
        case NodeKind::ConditionalContinue: return "ConditionalContinue";
        case NodeKind::ConditionalBreakContinue: return "ConditionalBreakContinue";
        case NodeKind::PreservedCyclicBranch: return "PreservedCyclicBranch";
        case NodeKind::PreservedSharedBranch: return "PreservedSharedBranch";
        case NodeKind::PreservedEscapingBranch: return "PreservedEscapingBranch";
        case NodeKind::UnresolvedBranch: return "UnresolvedBranch";
        case NodeKind::UnresolvedControl: return "UnresolvedControl";
    }
    return "Invalid";
}

} // namespace sir
