function OnInit()
    local function t(a, b) if a == b then error("N27_EQ") else error("N27_NE") end end
    t(5, 3)
end
