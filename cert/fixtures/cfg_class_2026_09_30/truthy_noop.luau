-- Gate fixture (2026-09-30, cfg-identity S3): stock keeps the final truthiness test of an
-- empty-bodied `if a and IsNull(b) then end`; both successors are the same node, so the test is
-- unobservable (truthiness runs no metamethod) and the decompiler prints only the operand calls.
local polls = 0
local function Ready()
    polls = polls + 1
    print("ready?", polls)
    return polls % 2 == 1
end
local function IsNull(value)
    print("isnull", value)
    return value == nil
end
local target = nil

local function Launch(value)
    if Ready() and IsNull(target) then
    end
    if Ready() then
        print("launch", value)
        return value
    end
    print("skip", value)
    return nil
end

print("result", Launch(1))
print("result", Launch(2))
