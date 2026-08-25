function OnInit()
    local function t(a,b,c) if a % b == c then error("mod55_OK") else error("mod55_BAD") end end
    t(17,5,2)
end
