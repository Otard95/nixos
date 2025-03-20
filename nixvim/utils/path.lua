local M = {}

---The file system path separator for the current platform.
M.path_separator = "/"
M.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win32unix") == 1
if M.is_windows == true then
  M.path_separator = "\\"
end

---@alias PathType 'abs' | 'home' | 'rel'

---@class Path
---@field type PathType
---@field parts string[]

---Parses a string path into a path class
---@param string_path any
---@return Path
M.parse = function(string_path)
  local type = M.type(string_path)

  local prefix = M.type_prefix(type)
  if string.sub(string_path, 1, #prefix) == prefix then
    string_path = string.sub(string_path, #prefix, #string_path)
  end

  return {
    type = type,
    parts = M.split(string_path, M.path_separator),
  }
end

---Takes a Path class and returns it as a string representation
---@param path Path
---@return string
M.to_string = function(path)
  local out = M.type_prefix(path.type)
  for _, value in pairs(path.parts) do
    out = out .. value .. '/'
  end
  return string.sub(out, 1, #out - 1)
end

---Split string into a table of strings using a separator.
---@param input_string string The string to split.
---@param sep string The separator to use.
---@return table table A table of strings.
M.split = function(input_string, sep)
  local fields = {}

  local pattern = string.format("([^%s]+)", sep)
  local _ = string.gsub(input_string, pattern, function(c)
    fields[#fields + 1] = c
  end)

  return fields
end

---Gets the dirname of the given path (removes the last element)
---@param path_or_string string|Path
---@return string
M.dirname = function(path_or_string)
  ---@type Path
  local path = type(path_or_string) == 'string' and M.parse(path_or_string) or path_or_string
  table.remove(path.parts, #path.parts)
  return M.to_string(path)
end

---Joins arbitrary number of paths together.
---@param ... string The paths to join.
---@return string
M.path_join = function(...)
  local args = { ... }
  if #args == 0 then
    return ""
  end

  local all_parts = {}
  if type(args[1]) == "string" and args[1]:sub(1, 1) == M.path_separator then
    all_parts[1] = ""
  end

  for _, arg in ipairs(args) do
    local arg_parts = M.split(arg, M.path_separator)
    vim.list_extend(all_parts, arg_parts)
  end
  return table.concat(all_parts, M.path_separator)
end

---Joins ans resolves an arbitrary number of path segments together
---@param ... (string|Path)
---@return string
M.resolve = function(...)
  local out = ''

  for _, v in pairs({ ... }) do
    ---@type Path
    local path = type(v) == 'string' and M.parse(v) or v
    if path.type == 'abs' or path.type == 'home' then
      out = M.to_string(path)
    else
      local p = M.to_string(path)
      out = out .. (string.sub(p, 2, #p))
    end
  end

  return vim.fn.resolve(out)
end

--device aliases are file names that are found _in any directory_.
local dev_aliases = {
  CON = 1,
  PRN = 1,
  AUX = 1,
  NUL = 1,
  COM1 = 1,
  COM2 = 1,
  COM3 = 1,
  COM4 = 1,
  COM5 = 1,
  COM6 = 1,
  COM7 = 1,
  COM8 = 1,
  COM9 = 1,
  LPT1 = 1,
  LPT2 = 1,
  LPT3 = 1,
  LPT4 = 1,
  LPT5 = 1,
  LPT6 = 1,
  LPT7 = 1,
  LPT8 = 1,
  LPT9 = 1,
}

--check if a path refers to a device alias and return that alias.
function M.dev_alias(s)
  s = s:match '[^\\/]+$'      --basename (dev aliases are present in all dirs)
  s = s and s:match '^[^%.]+' --strip extension (they can have any extension)
  s = s and s:upper()         --they're case-insensitive
  return s and dev_aliases[s] and s
end

---Returns the type of the path
---@param s string
---@return PathType
function M.type(s)
  if M.is_windows then
    if s:find '^\\\\' then
      if s:find '^\\\\%?\\' then
        if s:find '^\\\\%?\\%a:\\' then
          return 'abs_long'
        elseif s:find '^\\\\%?\\[uU][nN][cC]\\' then
          return 'unc_long'
        else
          return 'global'
        end
      elseif s:find '^\\\\%.\\' then
        return 'dev'
      else
        return 'unc'
      end
    elseif M.dev_alias(s) then
      return 'dev_alias'
    elseif s:find '^%a:' then
      return s:find '^..[\\/]' and 'abs' or 'rel_drive'
    else
      return s:find '^[\\/]' and 'abs_nodrive' or 'rel'
    end
  else
    if string.sub(s, 1, 1) == '/' then
      return 'abs'
    end
    if string.sub(s, 1, 2) == '~/' then
      return 'home'
    end
    return 'rel'
  end
end

---Returns the relevant path prefix for the type
---@param type PathType
---@return string
M.type_prefix = function(type)
  if M.is_windows then
    error('Not implemented')
  else
    return ({ abs = '/', home = '~/', rel = './', })[type]
  end
end

---Checks if the given path is a absolute path
---@param path string
---@return boolean
M.is_absolute = function(path)
  if path == '' then
    return false
  end

  local type = M.type(path)
  if type == 'rel' or type == 'rel_drive' or type == 'dev_alias' or type == 'home' then
    return false
  else
    return true
  end
end

---Checks if the given path is a relative path
---@param path string
---@return boolean
M.is_relative = function(path)
  if path == '' then
    return false
  end

  local type = M.type(path)
  if type == 'rel' or type == 'rel_drive' or type == 'dev_alias' then
    return true
  else
    return false
  end
end

return M
