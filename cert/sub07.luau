function OnInit()
    local function t(a,b,c) if a - b == c then error("sub07_OK") else error("sub07_BAD") end end
    t(10,3,7)
end
