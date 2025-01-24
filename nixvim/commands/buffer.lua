local function buf_only()
  local buf = vim.api.nvim_get_current_buf()
  local bufs = vim.api.nvim_list_bufs()
  for _, b in ipairs(bufs) do
    if b ~= buf then
      vim.api.nvim_buf_delete(b, { force = true })
    end
  end
  print('Deleted '.. #bufs - 1 .. ' buffers')
end
return buf_only
