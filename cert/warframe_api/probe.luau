local function result_text(values)
    local parts = {}
    for index = 2, values.n do parts[#parts + 1] = __wf_value(values[index]) end
    return table.concat(parts, ",")
end

print("LOAD|" .. __wf_take_trace())

local callbacks = {
    {"EvaluateAbility", function(fn) return fn(__wf.ability, __wf.avatar, __wf.enemy) end},
    {"NpcEvaluateAbility", function(fn) return fn(__wf.ability, __wf.agent, __wf.enemy) end},
    {"ActivateAbility", function(fn) return fn(__wf.ability, __wf.avatar, 3, __wf.enemy) end},
    {"Update", function(fn) return fn(__wf.ability, __wf.avatar, 0.25, __wf.enemy) end},
    {"OnDamaged", function(fn) return fn(__wf.avatar, __wf.damage, __wf.enemy) end},
    {"OnKilled", function(fn) return fn(__wf.avatar, __wf.enemy, __wf.ability) end},
    {"DeactivateAbility", function(fn) return fn(__wf.ability, __wf.avatar, __wf.spawn) end},
}

for _, callback in ipairs(callbacks) do
    local name, invoke = callback[1], callback[2]
    local fn = getfenv(1)[name]
    if type(fn) == "function" then
        local values = table.pack(pcall(invoke, fn))
        local status = values[1] and "OK" or "ERR"
        if not values[1] then
            values[2] = tostring(values[2]):gsub("^.-:%d+: ", "")
            values.n = 2
        end
        print(name .. "|" .. status .. "|" .. result_text(values)
            .. "|TRACE=" .. __wf_take_trace())
    end
end
