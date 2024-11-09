local M = {}

local movement_fold_method = {
  ['{'] = { foldclosed = vim.fn.foldclosed, backwards = true, },
  ['}'] = { foldclosed = vim.fn.foldclosedend, },
}

--- Do a movement like { or } but skip closed folds
--- @param movement string
M.skipping_folds = function (movement)
  if movement_fold_method[movement] == nil then
    vim.notify("Unknown movement passed to 'skipping_folds()': "..movement, vim.log.level.ERROR)
    return
  end

  local flags = 'Wn'
  if movement_fold_method[movement].backwards then
    flags = 'b' .. flags
  end

  local move_to = movement_fold_method[movement].foldclosed(vim.fn.search('^$', flags))
  if move_to == -1 then
    vim.cmd('normal! '..movement)
  else
    vim.fn.cursor(move_to, 0)
  end
end

return M
