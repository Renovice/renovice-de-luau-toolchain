-- NATIVE const-compares: JUMPXEQKN 0x20 (number), JUMPXEQKS 0x41 (string), JUMPXEQKB 0x34 (boolean).
-- These are the ops the tag audit says dispatch BY CONSTANT TYPE. 0x34 is the one whose meaning
-- I corrected today (boolean IMMEDIATE in aux, not a const index) — this is its first real test.
-- Both polarities, and a non-matching case each, so a stuck-always/never branch is visible.
function OnInit()
  local function t(n, s, b)
    local r = ""
    r = r .. "n_eq="   .. tostring(n == 7)      -- 7 == 7      -> true
    r = r .. " n_ne="  .. tostring(n ~= 7)      --             -> false
    r = r .. " n_no="  .. tostring(n == 99)     -- 7 == 99     -> false
    r = r .. " s_eq="  .. tostring(s == "hi")   -- "hi"=="hi"  -> true
    r = r .. " s_no="  .. tostring(s == "xx")   --             -> false
    r = r .. " b_eq="  .. tostring(b == true)   -- true==true  -> true
    r = r .. " b_no="  .. tostring(b == false)  --             -> false
    error("V12_CMPK " .. r)
  end
  t(7, "hi", true)
end
