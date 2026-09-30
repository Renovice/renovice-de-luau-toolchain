-- UNFIXED repro (2026-09-30): numeric-for body parts emitted in region-id order; print(i) runs before the inner loop.
local function Track()
    for i = 1, 3 do
      while IsNull(gGameRules) do Sleep(1) end
      print(i)
    end
end
