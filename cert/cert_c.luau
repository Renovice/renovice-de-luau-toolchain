function OnInit()
    local function t(three, four, seven)   -- 3,4,7
        local s = three + four
        if s ~= seven then error("C_ADDNE") end
        error("C_ADDOK")            -- C_ADDOK => ADD + params + compare all correct (few args)
    end
    t(3, 4, 7)
end
