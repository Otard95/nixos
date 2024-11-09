local max_filesize = 100 * 1024 -- 100 KB

local function large_file_disable(bufnr)
  print('Large file! Disabling some features')

  vim.opt_local.syntax = 'off'
  vim.opt_local.swapfile = false
  vim.opt_local.undofile = false
  vim.opt_local.foldmethod = 'manual'

  vim.diagnostic.disable(bufnr)

  vim.cmd('NoMatchParen')
end

vim.api.nvim_create_autocmd({ "BufReadPre", "FileReadPre" }, {
  pattern = "*",
  callback = function(event)
    local filesize = vim.fn.getfsize(vim.fn.expand('%:p'))
    local filepath = vim.fn.expand('%:p')
    local is_nvim_docs = filepath:find('/usr/share/nvim/runtime/doc', 1, true) == 1
    if filesize > max_filesize and not is_nvim_docs then
      large_file_disable(event.buf)
    end
  end
})
