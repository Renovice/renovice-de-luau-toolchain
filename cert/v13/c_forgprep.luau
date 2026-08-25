-- NATIVE generic FORGPREP 0x0b (decode name was literally "FORGPREP?" until today).
-- Uses a CUSTOM iterator triple, which is what forces the generic prep rather than the
-- pairs/ipairs specialisations. The iterator has a HARD call cap so that a mis-decoded
-- prep cannot spin the game thread — an infinite loop in OnInit would hang the client.
function OnInit()
  local function t()
    local calls = 0
    local function iter(s, i)
      calls = calls + 1
      if calls > 50 then return nil end        -- hard stop regardless of loop behaviour
      i = i + 1
      if i <= 3 then return i, i * 10 end
    end
    local sum, count = 0, 0
    for i, v in iter, nil, 0 do sum = sum + v; count = count + 1 end
    -- expect sum = 10+20+30 = 60, count = 3, calls = 4 (three yields + the terminating nil)
    error("V13_FORGPREP sum=" .. tostring(sum) .. " count=" .. tostring(count) .. " calls=" .. tostring(calls))
  end
  t()
end
