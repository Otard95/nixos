local M = {}

---@param str string
function M.contains(str, sub)
  return str:find(sub, 1, true) ~= nil
end

---@param str string
function M.starts_with(str, start)
  return str:sub(1, #start) == start
end

---@param str string
function M.ends_with(str, ending)
  return ending == "" or str:sub(- #ending) == ending
end

---@param str string
function M.replace(str, old, new)
  local s = str
  local search_start_idx = 1

  while true do
    local start_idx, end_idx = s:find(old, search_start_idx, true)
    if (not start_idx) then
      break
    end

    local postfix = s:sub(end_idx + 1)
    s = s:sub(1, (start_idx - 1)) .. new .. postfix

    search_start_idx = -1 * postfix:len()
  end

  return s
end

---@param str string
function M.insert(str, pos, text)
  return str:sub(1, pos - 1) .. text .. str:sub(pos)
end

---Split string into a table of strings using a separator.
---@param input_string string The string to split.
---@param sep string The separator to use.
---@return table table A table of strings.
M.split = function(input_string, sep)
  local fields = {}

  if sep == nil then
    sep = "%s" -- any whitespace
  end

  local pattern = string.format("([^%s]+)", sep)
  local _ = string.gsub(input_string, pattern, function(c)
    fields[#fields + 1] = c
  end)

  return fields
end

return M
