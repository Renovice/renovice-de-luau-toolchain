function OnInit()
    local function t(a,b,c) if a / b == c then error("div32_OK") else error("div32_BAD") end end
    t(20,4,5)
end
