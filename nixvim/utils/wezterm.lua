local M = {}

local wezterm_directions = { h = "Left", j = "Down", k = "Up", l = "Right" }

local function wezterm_exec(cmd)
  local command = vim.deepcopy(cmd)
  table.insert(command, 1, "wezterm")
  table.insert(command, 2, "cli")
  return vim.fn.system(command)
end

---@param direction string (h, j, k, l)
local function send_key_to_wezterm(direction)
  wezterm_exec({ "activate-pane-direction", wezterm_directions[direction] })
end

---@param direction string (h, j, k, l)
---@return function
M.move = function(direction)
  return function()
    local winnr = vim.fn.winnr()
    vim.cmd("wincmd " .. direction)
    local is_same_win = winnr == vim.fn.winnr()

    if is_same_win then
      send_key_to_wezterm(direction)
    end
  end
end

return M
