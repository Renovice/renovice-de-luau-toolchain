-- Dataflow-identity control (2026-10-09): capture mode. `value` is assigned twice BEFORE the closure
-- is created, so the compiler captures it by reference (CAPTURE REF) although nothing writes it
-- while the closure can read it. The EQUIVALENT variant copies the final value into a local that is
-- assigned once (CAPTURE VAL): dataflow-identity must PASS it (a REF capture with no write while open
-- is a VAL capture). The LATE_WRITE mutant performs the second assignment AFTER the closure was
-- created and called: the first call reads the earlier value, which dataflow-identity must report
-- (CFG-ID cannot: the operations and their order are unchanged). Own code.
local function Base(n) return n * 10 end
local function Scale(n) return n + 1 end
local function Make(n)
    local value = Base(n)
    local scaled = Scale(value)
    value = scaled
    local reader = function()
        return value
    end
    print("made", n, reader())
    return reader
end
local first, second = Make(1), Make(2)
print("read", first(), second())
