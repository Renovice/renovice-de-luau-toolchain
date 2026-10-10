-- RENOVICE fixture (2026-10-10, agent spill). Own code; runs under luau.exe.
-- A key that lives in a register (assigned, so never a compile-time constant) compiles to
-- `LOADN R, k; GETTABLE`. Folding the scratch pair into `u[k]` makes Luau emit GETTABLEN/SETTABLEN.
local rows = { "a", "b", "c", [0] = "zero", [300] = "far" }
local function Read(which)
    local base, key, value
    base = rows
    key = 2
    value = base[key]
    return value .. which
end
local function Write(text)
    local base, key
    base = rows
    key = 3
    base[key] = text
end
local function ReadZero()
    local base, key, value
    base = rows
    key = 0
    value = base[key]
    return value
end
print(Read("!"), ReadZero())
Write("C")
print(rows[3], rows[300])
