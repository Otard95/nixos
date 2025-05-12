local M = {}

function M.apply_to_config(config)
  -- Unix Domains: https://wezterm.org/multiplexing.html?h=#unix-domains
  config.unix_domains = {
    {
      name = 'unix',
    },
  }
  config.default_gui_startup_args = { 'connect', 'unix' }
end

return M
