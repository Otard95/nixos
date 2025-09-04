local M = {}

function M.create_branch()
  local branch = vim.fn.input('Branch name: ')
  if branch == '' or branch == nil then
    print('Aborting branch creation.')
    return
  end
  vim.cmd('Git checkout -b ' .. branch)
end

function M.reload_branch_list()
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_delete(0, { force = true })
  vim.cmd('Git branch')
  vim.api.nvim_win_set_cursor(0, pos)
end

function M.delete_branch_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local branch = string.gsub(line, '^%s?[%*%+]%*?%s*(.-)%s*$', '%1')
  vim.cmd('Git branch -d ' .. branch)
end

function M.merge_branch_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local branch = string.gsub(line, '^%s?[%*%+]%*?%s*(.-)%s*$', '%1')
  vim.cmd('Git merge ' .. branch)
end

return M
