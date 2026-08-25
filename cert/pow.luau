function OnInit()
    local function t(a,b,c) if a ^ b == c then error("pow_OK") else error("pow_BAD") end end
    t(2,10,1024)
end
