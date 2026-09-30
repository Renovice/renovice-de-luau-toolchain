-- UNFIXED repro (2026-09-30): `idx = i; break` inside a numeric for nested in `while true` loses its break.
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
