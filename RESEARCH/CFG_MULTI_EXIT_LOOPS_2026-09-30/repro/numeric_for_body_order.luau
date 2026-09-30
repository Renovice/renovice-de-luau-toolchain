-- FIXED 2026-09-30 (DEFECTS #45, 54cab5a8; fixture cert/fixtures/cfg_class_2026_09_30/for_body_order). Was UNFIXED: numeric-for body parts emitted in region-id order; print(i) runs before the inner loop.
local function Track()
    for i = 1, 3 do
      while IsNull(gGameRules) do Sleep(1) end
      print(i)
    end
end
