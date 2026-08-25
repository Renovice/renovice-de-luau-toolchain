-- rich sample to exercise the parser: nested closures, tables, imports, loops, varied consts
local Big = 123456789012
local Pi = 3.14159
local names = { "alpha", "beta", "gamma" }

local function add(a, b)
    return a + b
end

local function make(mult)
    return function(x)
        return x * mult + Big
    end
end

local total = 0
for i = 1, #names do
    total = add(total, i)
    print(names[i], total, Pi)
end

local twice = make(2)
print(twice(total))
return total
