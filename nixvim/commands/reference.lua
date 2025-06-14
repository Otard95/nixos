local function get_lines(from, to)
  local lines = {}
  for line = from, to do
    table.insert(lines, vim.fn.getline(line))
  end
  return lines
end

local function reference(opts)
  local full_file_path = vim.fn.expand("%:p")
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local local_path = full_file_path:gsub(vim.fn.getcwd():gsub("%p", "%%%1"), '')
  local path = project_name .. local_path

  local line_start = opts.line1 or vim.fn.line(".")
  local line_end = opts.line2 or line_start

  local selected = get_lines(line_start, line_end)
  vim.cmd([[normal! \<Esc>]])

  local text = '`' .. path .. ':' .. line_start
  if line_start ~= line_end then
    text = text .. '-' .. line_end
  end
  text = text .. '`\n```\n' .. table.concat(selected, '\n') .. '\n```'

  vim.fn.system("wl-copy", text)
  print("Copied to clipboard")
end
return reference
