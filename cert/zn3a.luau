function OnInit()
    local function t(a, b) if a == b then error("N3a_EQ") else error("N3a_NE") end end
    t(5, 3)
end
