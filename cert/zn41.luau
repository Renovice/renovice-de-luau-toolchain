function OnInit()
    local function t(a, b) if a == b then error("N41_EQ") else error("N41_NE") end end
    t(5, 3)
end
