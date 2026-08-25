function OnInit()
    local function t(a,b,c) if a * b == c then error("mul22_OK") else error("mul22_BAD") end end
    t(6,7,42)
end
