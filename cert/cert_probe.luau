function OnInit()
    local function t(one, two)   -- 1, 2 : 1<2 is unambiguously TRUE
        if one < two then error("PROBE_LT_TRUE") else error("PROBE_LT_FALSE") end
    end
    t(1, 2)
end
