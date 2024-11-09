function SetupTheme()
  require 'tokyonight'.setup {
    transparent = true,
    styles = {
      sidebars = 'transparent',
    }
  }

  require 'catppuccin'.setup {
    flavour = 'frappe',
    transparent_background = true,
  }

  vim.cmd.colorscheme 'catppuccin'
  -- vim.cmd.colorscheme 'tokyonight-moon'

  local palette = require 'catppuccin.palettes.frappe'
  -- Overrides
  vim.api.nvim_set_hl(0, 'LineNr', { fg = palette.blue })
end

return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    -- config = SetupTheme,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = SetupTheme,
  }
}
