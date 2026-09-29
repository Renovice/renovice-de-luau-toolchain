-- Synthetic tests for a returned else followed by an empty continuation.
local log = ""
local function mark(text) log ..= text end
local function guarded(active, expired)
    if active then
        if expired then mark("clear")
        else mark("display") return true end
    end
    do return end
end
local function effectAfter(active, expired)
    if active then
        if expired then mark("clear")
        else mark("display") return true end
    end
    mark("tail")
    do return end
end
local function loopBoundary(active, expired)
    for i = 1, 2 do
        if active then
            if expired then mark("clear")
            else mark("display") return true end
        end
    end
    do return end
end
local assertions = 0
local cases = {
    {false, false, false, "", "tail", ""},
    {false, true, false, "", "tail", ""},
    {true, false, true, "display", "display", "display"},
    {true, true, false, "clear", "cleartail", "clearclear"},
}
for _, case in ipairs(cases) do
    for index, fn in ipairs({guarded, effectAfter, loopBoundary}) do
        log = ""
        local packed = table.pack(fn(case[1], case[2]))
        assert(log == case[3 + index])
        if case[3] then
            assert(packed.n == 1 and packed[1] == true)
        else
            assert(packed.n == 0)
        end
        assertions += 2
    end
end
assert(assertions == 24)
print("return continuation fixture: 24 assertions passed")
