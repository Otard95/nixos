function SetupLualine()
  local lualine = require 'lualine'
  local auto = require 'lualine.themes.auto'
  local palette = require 'catppuccin.palettes.frappe'

  local inactive_colors = { fg = palette.blue, bg = palette.surface0 }
  auto.inactive.a = inactive_colors
  auto.inactive.b = inactive_colors
  auto.inactive.c = inactive_colors

  lualine.setup {
    options = {
      theme = auto,
      component_separators = '|',
      section_separators = { left = '', right = '' },
    },
    sections = {
      lualine_a = {
        { 'mode', separator = { left = '' }, right_padding = 2 },
      },
      lualine_b = { 'filename', 'branch' },
      lualine_c = { 'fileformat' },
      lualine_x = { 'rest' },
      lualine_y = { 'filetype', 'progress' },
      lualine_z = {
        { 'location', separator = { right = '' }, left_padding = 2 },
      },
    },
    inactive_sections = {
      lualine_a = { 'filename' },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { 'location' },
    },
    tabline = {},
    extensions = {},
  }
end

return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', lazy = true },
      { 'catppuccin/nvim' },
    },
    config = SetupLualine,
  }
}
