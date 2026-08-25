function OnInit()
    local function t(a, b) if a ~= b then error("Q3a_then") else error("Q3a_else") end end
    t(5, 5)
end
