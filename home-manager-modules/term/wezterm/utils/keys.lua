local M = {}

---@class KeyMapFull
---@field [1] string
---@field [2] string
---@field [3] KeyAssignment
---@class KeyMapKeyOnly
---@field [1] string
---@field [2] KeyAssignment
---@alias KeyMap KeyMapFull|KeyMapKeyOnly

---@param map KeyMap
---@return Key
function M.map(map)
  if #map == 2 then
    return {
      key = map[1],
      action = map[2],
    }
  end
  return {
    key = map[1],
    mods = map[2],
    action = map[3],
  }
end

return M
