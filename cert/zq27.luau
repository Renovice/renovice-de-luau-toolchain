function OnInit()
    local function t(a, b) if a ~= b then error("Q27_then") else error("Q27_else") end end
    t(5, 5)
end
