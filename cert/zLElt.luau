function OnInit()
    local function t(a, b) if a <= b then error("zLElt_T") else error("zLElt_F") end end
    t(3, 5)
end
