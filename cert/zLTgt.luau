function OnInit()
    local function t(a, b) if a < b then error("zLTgt_T") else error("zLTgt_F") end end
    t(5, 3)
end
