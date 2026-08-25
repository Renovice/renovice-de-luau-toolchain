// semantic_ir/lowering_oracle.h -- executable source-lowering semantics gate.
#pragma once
#include "source_renderer.h"
#include <sstream>

namespace sir::oracle {

struct Result {
    int assertions = 0;
    int passed = 0;
    int failed = 0;
    int runtime_exit = -1;
    std::vector<std::string> failures;
    std::string runtime_output;
};

inline std::string indent_source(const std::string& source, const std::string& prefix) {
    std::istringstream lines(source);
    std::ostringstream out;
    std::string line;
    while (std::getline(lines, line)) out << prefix << line << '\n';
    return out.str();
}

inline Result run_open_tail_oracle() {
    const std::string prefix_lowering = source::open_setlist_lowering_source(
        "target", 1, {"fixed"}, "producer()", "oracle_index_prefix",
        "oracle_values_prefix");
    const std::string tail_lowering = source::open_setlist_lowering_source(
        "target", 1, {}, "producer()", "oracle_index_tail",
        "oracle_values_tail");
    const std::string return_lowering = source::return_lowering_source(
        {"fixed"}, "producer()");
    const std::string vararg_return_lowering = source::return_lowering_source(
        {"\"fixed\""}, "...");

    std::ostringstream source;
    source << R"LUAU(local assertions = 0
local failures = 0
local function check(name, condition, detail)
    assertions += 1
    if condition then
        print("PASS " .. name)
    else
        failures += 1
        print("FAIL " .. name .. " " .. tostring(detail or ""))
    end
end

check("table_pack_available", type(table.pack) == "function", type(table.pack))
local primitive = table.pack(nil, "middle", nil)
check("table_pack_exact_nil_count",
    primitive.n == 3 and primitive[1] == nil
        and primitive[2] == "middle" and primitive[3] == nil,
    primitive.n)

local function lower_prefix(target, fixed, producer)
)LUAU";
    source << indent_source(prefix_lowering, "    ");
    source << R"LUAU(end

local function lower_tail(target, producer)
)LUAU";
    source << indent_source(tail_lowering, "    ");
    source << R"LUAU(end

-- The producer must run once and before every SETLIST mutation. Existing
-- sentinels make interior/trailing nil writes observable as slot removal.
local calls = 0
local saw_prefix
local target = {[2] = "sentinel2", [3] = "sentinel3", [4] = "sentinel4",
                [5] = "after"}
lower_prefix(target, "fixed", function()
    calls += 1
    saw_prefix = target[1]
    return nil, "middle", nil
end)
check("setlist_producer_once", calls == 1, calls)
check("setlist_producer_before_prefix_write", saw_prefix == nil, saw_prefix)
check("setlist_fixed_prefix", target[1] == "fixed", target[1])
check("setlist_interior_and_trailing_nil",
    target[2] == nil and target[3] == "middle" and target[4] == nil,
    tostring(target[2]) .. "/" .. tostring(target[3]) .. "/" .. tostring(target[4]))
check("setlist_exact_tail_extent", target[5] == "after", target[5])

-- Metamethod trace makes the required producer -> fixed -> tail order explicit.
local events = {}
target = setmetatable({}, {__newindex = function(t, k, v)
    events[#events + 1] = "W" .. tostring(k) .. "=" .. tostring(v)
    rawset(t, k, v)
end})
lower_prefix(target, "F", function()
    events[#events + 1] = "P"
    return "A", "B"
end)
check("setlist_effect_order",
    table.concat(events, ",") == "P,W1=F,W2=A,W3=B",
    table.concat(events, ","))

-- An error in the producer occurs before SETLIST, so no table slot may change.
calls = 0
target = {}
local error_ok, error_value = pcall(function()
    lower_prefix(target, "fixed", function()
        calls += 1
        error("producer_boom")
    end)
end)
check("setlist_error_propagates", not error_ok
    and string.find(tostring(error_value), "producer_boom", 1, true) ~= nil,
    error_value)
check("setlist_error_producer_once", calls == 1, calls)
check("setlist_error_before_all_writes", next(target) == nil, target[1])

-- Zero open results perform zero tail writes but still commit the fixed prefix
-- after the successful producer call.
calls = 0
local zero_saw_prefix
target = {[2] = "keep"}
lower_prefix(target, "fixed", function()
    calls += 1
    zero_saw_prefix = target[1]
end)
check("setlist_zero_result_once", calls == 1, calls)
check("setlist_zero_result_order", zero_saw_prefix == nil and target[1] == "fixed",
    zero_saw_prefix)
check("setlist_zero_result_no_tail_write", target[2] == "keep", target[2])

-- No-prefix SETLIST starts the exact tail at its declared list index.
target = {[4] = "after"}
lower_tail(target, function() return "A", nil, "C" end)
check("setlist_no_prefix_exact",
    target[1] == "A" and target[2] == nil and target[3] == "C"
        and target[4] == "after", target[4])

-- Lua's terminal expression expansion is the production open-RETURN lowering.
local return_calls = 0
local function return_open(producer)
    local fixed = "fixed"
)LUAU";
    source << "    " << return_lowering << "\nend\n";
    source << R"LUAU(local returned = table.pack(return_open(function()
    return_calls += 1
    return nil, "middle", nil
end))
check("return_open_exact_count", returned.n == 4, returned.n)
check("return_open_exact_values",
    returned[1] == "fixed" and returned[2] == nil
        and returned[3] == "middle" and returned[4] == nil,
    returned[3])
check("return_open_producer_once", return_calls == 1, return_calls)

)LUAU";
    source << "local function return_vararg(...)\n    "
           << vararg_return_lowering << "\nend\n";
    source << R"LUAU(local vararg = table.pack(return_vararg(nil, "middle", nil))
check("return_vararg_exact_count", vararg.n == 4, vararg.n)
check("return_vararg_exact_values",
    vararg[1] == "fixed" and vararg[2] == nil
        and vararg[3] == "middle" and vararg[4] == nil,
    vararg[3])

return_calls = 0
local return_error_ok, return_error = pcall(function()
    return_open(function()
        return_calls += 1
        error("return_boom")
    end)
end)
check("return_open_error_propagates", not return_error_ok
    and string.find(tostring(return_error), "return_boom", 1, true) ~= nil,
    return_error)
check("return_open_error_once", return_calls == 1, return_calls)

print("SUMMARY assertions=" .. assertions .. " passed="
    .. (assertions - failures) .. " failed=" .. failures)
if failures > 0 then error("semantic lowering oracle failed") end
)LUAU";

    Result result;
    const std::string stem = "_sir_lowering_oracle_"
        + std::to_string((long long)GetCurrentProcessId());
    const std::string source_path = stem + ".luau";
    const std::string output_path = stem + ".out";
    const std::string error_path = stem + ".err";
    if (!write_file(source_path, source.str())) {
        result.failures.push_back("LOWERING_ORACLE_SOURCE_WRITE_FAILED");
        result.failed = 1;
        return result;
    }
    const std::string inner = "\"" + exe_dir() + "\\luau.exe\" \""
        + source_path + "\" > \"" + output_path + "\" 2> \""
        + error_path + "\"";
    result.runtime_exit = std::system(("\"" + inner + "\"").c_str());
    result.runtime_output = read_file(output_path) + read_file(error_path);
    std::remove(source_path.c_str());
    std::remove(output_path.c_str());
    std::remove(error_path.c_str());

    std::istringstream lines(result.runtime_output);
    std::string line;
    while (std::getline(lines, line)) {
        if (line.rfind("PASS ", 0) == 0) {
            ++result.assertions; ++result.passed;
        } else if (line.rfind("FAIL ", 0) == 0) {
            ++result.assertions; ++result.failed;
            result.failures.push_back(line.substr(5));
        }
    }
    constexpr int expected_assertions = 22;
    if (result.runtime_exit != 0) {
        ++result.failed;
        result.failures.push_back("LOWERING_ORACLE_RUNTIME_FAILED");
    }
    if (result.assertions != expected_assertions) {
        ++result.failed;
        result.failures.push_back("LOWERING_ORACLE_ASSERTION_COUNT expected="
            + std::to_string(expected_assertions) + " actual="
            + std::to_string(result.assertions));
    }
    return result;
}

} // namespace sir::oracle
