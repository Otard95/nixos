local wezterm = require 'wezterm'
local str = require 'utils.string'

local M = {}

function M.is_vim(pane)
  local process_info = pane:get_foreground_process_info()
  local process_name = ''
  if process_info == nil then
    local user_vars = pane:get_user_vars()
    process_name = user_vars and user_vars.WEZTERM_PROG
    wezterm.log_info('[is_vim()] is mux pane', { pane = pane, user_vars = user_vars })
  else
    process_name = process_info and process_info.name
    wezterm.log_info('[is_vim()] normal pane', { pane = pane, process_info = process_info })
  end

  return process_name == "nvim" or process_name == "vim" or (str and str.starts_with(process_name, 'vi'))
end

return M
