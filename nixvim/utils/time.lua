local M = {}

---@class Offset
---@field year integer|nil
---@field month integer|nil
---@field day integer|nil
---@field hour integer|nil
---@field minute integer|nil
---@field second integer|nil

---@param offset Offset
---@return integer
function M.get_offset_time(offset)
  local now  = M.osdate()
  return os.time({
    year = now.year + (offset.year or 0),
    month = now.month + (offset.month or 0),
    day = now.day + (offset.day or 0),
    hour = now.hour + (offset.hour or 0),
    min = now.min + (offset.minute or 0),
    sec = now.sec + (offset.second or 0),
  })
end

---@return osdate
function M.osdate()
---@diagnostic disable-next-line: return-type-mismatch
  return os.date('*t')
end

---@param day integer
---@return boolean
function M.is_day_of_week(day)
  return os.date('%u', os.time()) == tostring(day)
end

return M
