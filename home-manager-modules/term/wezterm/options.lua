local M = {}

function M.apply_to_config(config)
  config.enable_wayland = true
  config.window_close_confirmation = 'NeverPrompt'
end

return M
