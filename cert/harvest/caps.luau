-- Which library globals actually resolve inside the injected sandbox?
-- Reports a bitmask via error() (error+tostring are known-good).
function OnInit()
  local s = ""
  s = s .. (type(print)        == "function" and "print,"        or "")
  s = s .. (type(pairs)        == "function" and "pairs,"        or "")
  s = s .. (type(next)         == "function" and "next,"         or "")
  s = s .. (type(getmetatable) == "function" and "getmetatable," or "")
  s = s .. (type(pcall)        == "function" and "pcall,"        or "")
  s = s .. (type(table)        == "table"    and "table,"        or "")
  s = s .. (type(string)       == "table"    and "string,"       or "")
  s = s .. (type(math)         == "table"    and "math,"         or "")
  s = s .. (type(_G)           == "table"    and "_G,"           or "")
  s = s .. (type(Engine)       ~= "nil"      and "Engine,"       or "")
  s = s .. (type(rawget)       == "function" and "rawget,"       or "")
  s = s .. (type(select)       == "function" and "select,"       or "")
  error("CAPS=" .. s)
end
