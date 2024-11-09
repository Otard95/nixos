local M = {}

function M.flow(...)
  local args = {...}
  return function()
    for _, v in ipairs(args) do
      if type(v) == "function" then
        v()
      end
    end
  end
end

function M.partial(fn, ...)
  local left_args = {...}
  return function(...)
    local right_args = {...}
    fn(unpack(left_args), unpack(right_args))
  end
end

return M
