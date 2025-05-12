local M = {}

---@enum Underline
M.Underline = {
  None = "None",
  Single = "Single",
  Double = "Double",
  Curly = "Curly",
  Dotted = "Dotted",
  Dashed = "Dashed",
}
---@enum Intensity
M.Intensity = {
  Normal = "Normal",
  Bold = "Bold",
  Half = "Half",
}

---@class Ansi
---@field AnsiColor string

---@class Color
---@field Color string

---@param c string|Color|Ansi
---@return Color|Ansi
function M.color(c)
  if type(c) == 'string' then
    return { Color = c }
  end
  return c
end

---@class TextFormat
---@field bg string|Color|Ansi|nil
---@field fg string|Color|Ansi|nil
---@field underline Underline|nil
---@field intensity Intensity|nil
---@field italic boolean|nil

---@param text string
---@param format TextFormat|nil
---@return table
function M.text_format(text, format)
  local out = {}
  if format then
    if format.underline ~= nil then
      table.insert(out, { Attribute = { Underline = format.underline } })
    end
    if format.intensity ~= nil then
      table.insert(out, { Attribute = { Intensity = format.intensity } })
    end
    if format.italic ~= nil then
      table.insert(out, { Attribute = { Italic = format.italic } })
    end
    if format.bg ~= nil then
      table.insert(out, { Background = M.color(format.bg) })
    end
    if format.fg ~= nil then
      table.insert(out, { Foreground = M.color(format.fg) })
    end
  end

  table.insert(out, { Text = text })
  return out
end

return M
