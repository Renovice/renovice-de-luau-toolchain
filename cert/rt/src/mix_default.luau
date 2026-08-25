-- ground-truth case: mix_default
function f(opts)
  opts = opts or {}
  local n = opts.n or 10
  local name = opts.name or "anon"
  return n, name
end
