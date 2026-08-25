function OnInit()
    local function t(a, b) if a ~= b then error("Q34_then") else error("Q34_else") end end
    t(5, 5)
end
