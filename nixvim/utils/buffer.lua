local M = {}

function M.replace_visual_text(text)
  local selected = M.get_selected()
  if selected == nil then
    return
  end

  -- Replace only the selected text with provided
  if #selected.lines > 1 then
    vim.api.nvim_buf_set_text(0, selected.start_pos[2] - 1, selected.start_pos[3] - 1, selected.end_pos[2] - 1,
      selected.end_pos[3], vim.split(text, "\n"))
  else
    vim.api.nvim_buf_set_text(0, selected.start_pos[2] - 1, selected.start_pos[3] - 1, selected.start_pos[2] - 1,
      selected.end_pos[3], { text })
  end
end

function M.insert_text(text)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { text })
end

function M.get_selected()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  if #lines == 0 then return end

  -- Handle multi-line selections
  if #lines > 1 then
    lines[1] = lines[1]:sub(start_pos[3])
    lines[#lines] = lines[#lines]:sub(1, end_pos[3])
  else
    lines[1] = lines[1]:sub(start_pos[3], end_pos[3])
  end

  return { start_pos = start_pos, end_pos = end_pos, lines = lines }
end

function M.has_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  -- Check if start and end positions are different
  if start_pos[2] ~= end_pos[2] or start_pos[3] ~= end_pos[3] then
    return true
  end

  return false
end

return M
