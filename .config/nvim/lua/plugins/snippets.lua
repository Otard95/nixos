local function SetupSnippets()
  local ls = require 'luasnip'

  vim.keymap.set({ 'i', 's' }, '<C-S-n>', function() ls.jump(1) end, { silent = true })
  vim.keymap.set({ 'i', 's' }, '<C-S-p>', function()
    print('jumping back')
    ls.jump(-1)
  end, { silent = true })

  require("luasnip.loaders.from_snipmate").lazy_load()
end

return {
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = 'make install_jsregexp',
    config = SetupSnippets,
  }
}
