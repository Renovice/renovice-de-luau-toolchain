-- Isolate GETVARARGS (0x4c)
function OnInit()
  local function va1(...) local a = ... return a end
  local function va2(...) local a, b = ... return b end
  local function va3(...) return select("#", ...) end
  if va1(7) == 7 then else error("V_ONE") end
  if va2(7, 9) == 9 then else error("V_TWO") end
  if va3(7, 9) == 2 then else error("V_COUNT") end
  error("V9_VA_OK")
end
