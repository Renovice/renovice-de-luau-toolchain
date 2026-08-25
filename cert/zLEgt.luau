function OnInit()
    local function t(a, b) if a <= b then error("zLEgt_T") else error("zLEgt_F") end end
    t(5, 3)
end
