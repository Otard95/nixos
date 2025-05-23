local wezterm = require 'wezterm'

local M = {}

function M.map(tbl, f)
  local t = {}
  for k, v in pairs(tbl) do
    t[k] = f(v)
  end
  return t
end

function M.merge(...)
  local out = {}
  for _, tbl in ipairs({ ... }) do
    for k, v in ipairs(tbl) do
      out[k] = v
    end
  end
  return out
end

function M.concat(...)
  local out = {}
  for _, tbl in ipairs({ ... }) do
    for _, v in ipairs(tbl) do
      table.insert(out, v)
    end
  end
  return out
end

---If `predicate` is a function:
---  Returns true if `predicate` returns true for any element of `tbl`, otherwise false.
---If `predicate` is not a function:
---  Returns true if `predicate` is equal to any element in the table, otherwise false.
---@param tbl table
---@param predicate (fun(value: any): boolean)|any
---@return boolean
function M.has(tbl, predicate)
  local match = type(predicate) == 'function' and predicate or function(val)
    return val == predicate
  end
  for _, value in ipairs(tbl) do
    if match(value) then
      return true
    end
  end
  return false
end

---Returns the first element of `tbl`, for which `predicate` returns true
---@param tbl table
---@param predicate fun(value: any): boolean
function M.find(tbl, predicate)
  for _, value in ipairs(tbl) do
    if predicate(value) then
      return value
    end
  end
end

return M
