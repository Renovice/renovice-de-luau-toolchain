function OnInit()
    local function t(a,b,c) if a - b == c then error("sub06_OK") else error("sub06_BAD") end end
    t(10,3,7)
end
