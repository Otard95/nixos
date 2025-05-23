local wezterm = require 'wezterm' --[[@as Wezterm]]
local tbl = require 'utils.table'

local M = {}

function M.apply_to_config(config)
  config.enable_wayland = true
  config.window_close_confirmation = 'NeverPrompt'

  config.front_end = 'WebGpu'
  config.webgpu_preferred_adapter = tbl.find(
    wezterm.gui.enumerate_gpus(),
    function(value) return value.device_type == 'DiscreteGpu' end
  )
end

return M
