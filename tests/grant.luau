local function grant(a, b)
    local s = a + b
    if a then
        return s
    end
    return 0
end
return grant(10, 20)
