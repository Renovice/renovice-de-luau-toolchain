function OnInit()
    local function t(a, b) if a ~= b then error("Q41_then") else error("Q41_else") end end
    t(5, 5)
end
