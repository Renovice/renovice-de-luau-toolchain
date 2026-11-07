local function f(key, t)
  for k, v in pairs(t) do
    if v == key then
      X()
      break
    end
  end
  while true do
    Sleep(1)
  end
end
return f
