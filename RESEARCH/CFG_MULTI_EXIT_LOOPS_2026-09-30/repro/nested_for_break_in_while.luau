-- FIXED 2026-09-30 (DEFECTS #44/#46/#47, 54cab5a8; fixture nested_for_break). Was UNFIXED: `idx = i; break` inside a numeric for nested in `while true` loses its break.
local function F(t, o)
  while true do
      local idx = nil
      for i = 1, #t do
        local s = t[i]
        if not IsNull(s) and s == o then idx = i; break end
      end
      if IsNull(idx) then table.insert(t, o) end
    Sleep(0)
  end
end
