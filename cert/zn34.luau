function OnInit()
    local function t(a, b) if a == b then error("N34_EQ") else error("N34_NE") end end
    t(5, 3)
end
