local wezterm = require 'wezterm' --[[@as Wezterm]]
local str = require 'utils.string'

local M = {}

---@param pane Pane
---@return boolean
function M.is_vim(pane)
  local process_info = pane:get_foreground_process_info()

  if process_info == nil then
    local user_vars = pane:get_user_vars()
    wezterm.log_info('[is_vim()] is mux pane', { pane = pane, user_vars = user_vars })
    return user_vars and user_vars.WEZTERM_PROG and str.starts_with(user_vars.WEZTERM_PROG, 'vi')
  end

  local process_name = process_info and process_info.name
  wezterm.log_info('[is_vim()] normal pane', { pane = pane, process_info = process_info })
  return process_name == "nvim" or process_name == "vim"
end

return M
