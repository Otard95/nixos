function SetupRest()
  local rest = require 'rest-nvim'
  local telescope = require 'telescope'

  rest.setup { }

  telescope.load_extension('rest')

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'http', 'rest' },
    callback = function(ev)
      vim.opt_local.splitright = true

      local opts = { buffer = ev.buf }
      vim.keymap.set({ 'n' }, '<leader>rr', '<cmd>Rest run<CR>', opts)
      vim.keymap.set({ 'n' }, '<leader>rl', '<cmd>Rest run last<CR>', opts)
      vim.keymap.set({ 'n' }, '<leader>re', telescope.extensions.rest.select_env, opts)
    end
  })
end

return {
  {
    'rest-nvim/rest.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
    },
    tag = 'v3.8.3',
    ft = { 'http', 'rest' },
    config = SetupRest,
  }
}
