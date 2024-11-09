function markdown_preview_init()
  vim.cmd [[
    function! MarkdownPreviewOpenBrowser(url)
      call system('/opt/firefox/firefox -P markdown-preview ' . a:url . ' &')
    endfunction
  ]]

  vim.g.mkdp_auto_close = 0
  vim.g.mkdp_browserfunc = 'MarkdownPreviewOpenBrowser'
  vim.g.mkdp_page_title = '「${name}」 - Markdown Preview'
end

return {
  -- {
  --   'iamcco/markdown-preview.nvim',
  --   build = 'yarn install',
  --   init = markdown_preview_init,
  -- },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    opts = {
      checkbox = {
        unchecked = {
          icon = '󰄱',
        },
        checked = {
          icon = '󰱒',
        },
        custom = {
          todo = { raw = '[-]', rendered = '󰥔', highlight = 'RenderMarkdownTodo' },
          follow_up = { raw = '[>]', rendered = '󰬪', highlight = 'WarningMsg' },
          canceled = { raw = '[~]', rendered = '󰅙', highlight = 'ErrorMsg' },
        },
      },
      code = {
        -- Width of the code block background:
        --  block: width of the code block
        --  full:  full width of the window
        width = 'block',
        -- Amount of padding to add to the left of code blocks
        left_pad = 2,
        -- Amount of padding to add to the right of code blocks when width is 'block'
        right_pad = 1,
        -- Minimum width to use for code blocks when width is 'block'
        min_width = 80,
      },
    },
  }
}
