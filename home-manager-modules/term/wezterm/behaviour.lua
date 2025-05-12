local M = {}

function M.apply_to_config(config)
  config.window_close_confirmation = 'NeverPrompt'
end

return M
