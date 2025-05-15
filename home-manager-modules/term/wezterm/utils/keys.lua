local M = {}

---@class KeyMap
---@field [1] string
---@field [2] string
---@field [3] KeyAssignment

---@param map KeyMap
---@return Key
function M.map(map)
  ---@type Key
  local key = {
    key = map[1],
    mods = map[2],
    action = map[3],
  }
  return key
end

return M
