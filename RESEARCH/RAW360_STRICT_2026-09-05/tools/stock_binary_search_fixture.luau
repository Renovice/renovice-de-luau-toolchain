-- Retained decompiler output for LotusUtilities BinarySearch and three dependencies.
-- This is a recovered-source regression fixture, not an original-source identity claim.
local v100, v101, v102, v103
  v100 = function(c207v0)
    do return c207v0 end
  end
  v101 = function(c208v0, c208v1)
    local c208v2
    if c208v1 <= c208v0 then
      c208v2 = false
      do return c208v2 end
    end
    c208v2 = true
    do return c208v2 end
  end
  v102 = function(c209v0, c209v1)
    local c209v2
    if c209v0 <= c209v1 then
      c209v2 = false
      do return c209v2 end
    end
    c209v2 = true
    do return c209v2 end
  end
  v103 = function(c210v0, c210v1, c210v2, c210v3)
    local c210v4, c210v5, c210v6, c210v7, c210v8, c210v9, c210v10, c210v11, c210v12
    local __renovice_state_0 = 0
    c210v4 = c210v2
    if c210v4 then
      __renovice_state_0 = 2
    else
      __renovice_state_0 = 1
    end
    if __renovice_state_0 == 1 then
      c210v4 = v100
      __renovice_state_0 = 2
    end
    if __renovice_state_0 == 2 then
      c210v2 = c210v4
      if not c210v3 then
        __renovice_state_0 = 4
      else
        __renovice_state_0 = 3
      end
    end
    if __renovice_state_0 == 3 then
      c210v4 = v102
      if c210v4 then
        __renovice_state_0 = 5
      else
        __renovice_state_0 = 4
      end
    end
    if __renovice_state_0 == 4 then
      c210v4 = v101
      __renovice_state_0 = 5
    end
    if __renovice_state_0 == 5 then
      c210v5 = 1
      c210v6 = #c210v0
      c210v7 = 0
      __renovice_state_0 = 6
    end
    while ((((__renovice_state_0 == 6 or __renovice_state_0 == 7) or __renovice_state_0 == 15) or __renovice_state_0 == 16) or __renovice_state_0 == 17) or __renovice_state_0 == 18 do
      if __renovice_state_0 == 6 then
        if c210v6 < c210v5 then
          __renovice_state_0 = 19
        else
          __renovice_state_0 = 7
        end
      end
      if __renovice_state_0 == 7 then
        c210v10 = c210v5 + c210v6
        c210v9 = c210v10 / 2
        c210v8 = math.floor
        c210v7 = c210v8(c210v9)
        c210v9 = c210v0[c210v7]
        c210v8 = c210v2(c210v9)
        if c210v1 ~= c210v8 then
          __renovice_state_0 = 15
        else
          __renovice_state_0 = 8
        end
      end
      if __renovice_state_0 == 15 then
        c210v9 = c210v4(c210v1, c210v8)
        if not c210v9 then
          __renovice_state_0 = 17
        else
          __renovice_state_0 = 16
        end
      end
      if __renovice_state_0 == 16 then
        c210v6 = c210v7 - 1
        __renovice_state_0 = 18
      end
      if __renovice_state_0 == 17 then
        c210v5 = c210v7 + 1
        __renovice_state_0 = 18
      end
      if __renovice_state_0 ~= 18 then
        continue
      end
      __renovice_state_0 = 6
    end
    if __renovice_state_0 == 8 then
      c210v9 = {c210v7, c210v7}
      c210v10 = c210v7 - 1
      __renovice_state_0 = 9
    end
    while __renovice_state_0 == 9 or __renovice_state_0 == 10 do
      if __renovice_state_0 == 9 then
        c210v12 = c210v0[c210v10]
        c210v11 = c210v2(c210v12)
        if c210v1 ~= c210v11 then
          __renovice_state_0 = 11
        else
          __renovice_state_0 = 10
        end
      end
      if __renovice_state_0 ~= 10 then
        continue
      end
      c210v11 = c210v10 - 1
      c210v9[1] = c210v10
      c210v10 = c210v11
      __renovice_state_0 = 9
    end
    if __renovice_state_0 == 11 then
      c210v10 = c210v7 + 1
      __renovice_state_0 = 12
    end
    while __renovice_state_0 == 12 or __renovice_state_0 == 13 do
      if __renovice_state_0 == 12 then
        c210v12 = c210v0[c210v10]
        c210v11 = c210v2(c210v12)
        if c210v1 ~= c210v11 then
          __renovice_state_0 = 14
        else
          __renovice_state_0 = 13
        end
      end
      if __renovice_state_0 ~= 13 then
        continue
      end
      c210v11 = c210v10 + 1
      c210v9[2] = c210v10
      c210v10 = c210v11
      __renovice_state_0 = 12
    end
    if __renovice_state_0 == 14 then
      do return c210v9 end
    elseif __renovice_state_0 == 19 then
      do return end
    end
    do return end
  end
local assertions = 0
local function check(values, key, descending, low, high)
    local result = v103(values, key, nil, descending)
    assert((result == nil) == (low == nil), "presence")
    assert((result and result[1]) == low, "lower bound")
    assert((result and result[2]) == high, "upper bound")
    assertions = assertions + 3
end
check({}, 3, false, nil, nil)
check({3}, 3, false, 1, 1)
check({3}, 2, false, nil, nil)
check({3}, 4, false, nil, nil)
check({1, 2, 2, 2, 4}, 2, false, 2, 4)
check({1, 2, 2, 2, 4}, 1, false, 1, 1)
check({1, 2, 2, 2, 4}, 4, false, 5, 5)
check({1, 2, 2, 2, 4}, 3, false, nil, nil)
check({4, 2, 2, 2, 1}, 2, true, 2, 4)
check({4, 2, 2, 2, 1}, 4, true, 1, 1)
check({4, 2, 2, 2, 1}, 1, true, 5, 5)
check({4, 2, 2, 2, 1}, 3, true, nil, nil)
print("stock binary search fixture: " .. assertions .. " assertions passed")
