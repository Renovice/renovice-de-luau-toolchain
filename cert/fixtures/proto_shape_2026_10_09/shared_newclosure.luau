-- Shared prototype through -O2 inlining (NEWCLOSURE): Register is inlined into Setup twice, so the
-- callback literal's prototype is referenced from Register and twice from Setup.
local count = 0
local list = {}
local function Register(name)
    list[#list + 1] = function(x)
        count = count + x
        return name .. x
    end
end
local function Setup()
    Register("a")
    print("between")
    Register("b")
end
Setup()
print(#list, list[1](1), list[2](2), count)
