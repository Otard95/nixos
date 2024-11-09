local function get_lines(from, to)
  local lines = {}
  for line = from, to do
    table.insert(lines, vim.fn.getline(line))
  end
  return lines
end

local function reference(opts)
  local local_path = vim.fn.expand("%")
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local path = project_name .. '/' .. local_path

  local line_start = opts.line1 or vim.fn.line(".")
  local line_end = opts.line2 or line_start

  local selected = get_lines(line_start, line_end)
  vim.cmd([[normal! \<Esc>]])

  local text = '`' .. path .. ':' .. line_start
  if line_start ~= line_end then
    text = text .. '-' .. line_end
  end
  text = text .. '`\n```\n' .. table.concat(selected, '\n') .. '\n```'

  vim.fn.system("xclip -selection clipboard", text)
  print("Copied to clipboard")
end
return reference
