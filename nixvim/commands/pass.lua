---@param len number?
---@return nil
local function pass(len)
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '^V' then
    vim.cmd 'normal! d'
  end
  local p = vim.fn.system( "cat /dev/urandom | tr -dc '[:alnum:]!@#$%^~+*.,\"?;:-' | head -c" .. (len or 20))
  vim.api.nvim_put({ p }, 'c', true, true)
  vim.cmd 'normal! x'
end

return pass
