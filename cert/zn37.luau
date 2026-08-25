function OnInit()
    local function t(a, b) if a == b then error("N37_EQ") else error("N37_NE") end end
    t(5, 3)
end
