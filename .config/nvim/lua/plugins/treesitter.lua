function TSSetup()
  local max_filesize = 100 * 1024 -- 100 KB

  require 'nvim-treesitter.configs'.setup {
    -- One of 'all', 'maintained' (parsers with maintainers), or a list of languages
    ensure_installed = {{
      'c',
      'go',
      'gomod',
      'graphql',
      'html',
      'http',
      'javascript',
      'json',
      'json5',
      'jsonc',
      'lua',
      'markdown',
      'markdown_inline',
      'php',
      'phpdoc',
      'python',
      'rust',
      'terraform',
      'tsx',
      'typescript',
      'vim',
      'vimdoc',
    }},
    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,
    enable = true
    indent = {
    },
    highlight = {
      -- `false` will disable the whole extension
      enable = true,

      -- -- list of language that will be disabled
      -- disable = { 'c', 'rust' },
      -- -- Disable for large files
      disable = function (_lang, buf)
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
      end,

      -- -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false,
    },
    -- rainbow = {
    --   enable = true,
    --   -- List of bright contrasting colors for syntax highlighting
    --   colors = { '#FF4444', '#00FF00', '#8888FF', '#FFFF00', '#00FFFF', '#FF00FF' },
    -- },
  }
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- tag = 'v0.9.2',
    build=':TSUpdate',
    config=TSSetup,
  }
}
