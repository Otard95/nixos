function commentary_init()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'typescript',
    callback = function()
      vim.bo.commentstring = '// %s'
    end,
  })
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'php',
    callback = function()
      vim.bo.commentstring = '// %s'
    end,
  })
end

function visual_multi_init(plugins)
  table.insert(plugins, { 'mg979/vim-visual-multi', { branch = 'master'} })
end

return {
  { 'RRethy/nvim-align' },
  {
    'tpope/vim-commentary',
    init = commentary_init,
  },
  { 'tpope/vim-surround' },
  { 'mg979/vim-visual-multi', branch = 'master' },
  { 'tpope/vim-abolish' }
}
