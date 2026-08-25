function OnInit()
    local function t(a, b) if a == b then error("N20_EQ") else error("N20_NE") end end
    t(5, 3)
end
