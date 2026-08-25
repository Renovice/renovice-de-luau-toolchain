function OnInit()
  local function f1(a,b) while a < b do a = a + 1 end return a end
  local function f2(a,b) repeat a = a + 1 until a < b return a end
  local function f3(a,b) if not (a < b) then return 1 end return 2 end
  local function f4(a,b) return a < b end
  local function f5(a,b) local x = a < b if x then return 1 end return 2 end
  return f1,f2,f3,f4,f5
end
