function OnInit()
    local function t(a,b,c) if a % b == c then error("mod24_OK") else error("mod24_BAD") end end
    t(17,5,2)
end
