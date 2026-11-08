local function f(list, key)
  for _, e in ipairs(list) do
    for _, tag in ipairs(e) do
      if tag == key then
        while Busy() do
          Sleep(1)
        end
        break
      end
    end
  end
  Done()
end
return f
