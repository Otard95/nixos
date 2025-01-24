local function uuid()
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '^V' then
    vim.cmd 'normal! d'
  end
  local u = vim.fn.system('cat /proc/sys/kernel/random/uuid')
  vim.api.nvim_put({ u }, 'c', true, true)
  vim.cmd 'normal! x'
end
return uuid
