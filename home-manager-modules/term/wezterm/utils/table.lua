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

---comment
---@param tbl table
---@param predicate function|any a predicate function taking individual elements of tbl or a value to match
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

return M
