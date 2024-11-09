function copilot_init()
  vim.api.nvim_set_keymap("i", "<C-j>", "copilot#Accept('<CR>')", {
    silent = true,
    expr = true,
    noremap = true
  })
  vim.g.copilot_no_tab_map = true
  vim.g.copilot_assume_mapped = true
end

return {
  {
    'github/copilot.vim',
    init = copilot_init,
  }
}
