function OnInit()
  local function make(start, inc)
    local acc = start
    local function bump() acc = acc + inc return acc end
    return bump
  end
  local b = make(0, 1)
  b()
  local r = b()
  if r > 1 then else error("CAP_nil_or_low") end
  if r < 3 then else error("CAP_hi") end
  error("CAP_OK")
end
