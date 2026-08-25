function OnInit()
    local function t(a, b) if a <= b then error("zLEeq_T") else error("zLEeq_F") end end
    t(5, 5)
end
