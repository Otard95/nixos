function SetupHarpoon()
  local harpoon = require 'harpoon'

  harpoon:setup()

  vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end)
  -- vim.keymap.set('n', '<leader>he', toggle_quick_menu)
  vim.keymap.set('n', '<leader>e', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

  vim.keymap.set('n', '<leader>h', function() harpoon:list():select(1) end)
  vim.keymap.set('n', '<leader>j', function() harpoon:list():select(2) end)
  vim.keymap.set('n', '<leader>k', function() harpoon:list():select(3) end)
  vim.keymap.set('n', '<leader>l', function() harpoon:list():select(4) end)
  vim.keymap.set('n', '<leader>;', function() harpoon:list():select(5) end)
  vim.keymap.set('n', '<leader>\'', function() harpoon:list():select(6) end)

  -- Toggle previous & next buffers stored within Harpoon list
  vim.keymap.set('n', '<leader>p', function() harpoon:list():prev() end)
  vim.keymap.set('n', '<leader>n', function() harpoon:list():next() end)
end

return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    config = SetupHarpoon,
    dependencies = { 'nvim-lua/plenary.nvim' }
  }
}
