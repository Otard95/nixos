local fn = require 'utils.fn'

local present_mode_on = false
local original_cursor = vim.opt.guicursor._value
local options = {
  relativenumber = { original = vim.opt.relativenumber, present = false },
  number = { original = vim.opt.number, present = false },
  showmode = { original = vim.opt.showmode, present = false },
  showcmd = { original = vim.opt.showcmd, present = false },
  cmdheight = { original = vim.opt.cmdheight, present = 1 },
  hidden = { original = vim.opt.hidden, present = true },
  laststatus = { original = vim.opt.laststatus, present = 0 },
  statusline = { original = vim.opt.statusline, present = '' },
  ruler = { original = vim.opt.ruler, present = false },
  guicursor = { original = vim.opt.guicursor._value, present = 'a:hor1' },
  scrolloff = { original = vim.opt.scrolloff, present = 0 }
}

local function print_presentation_progression()
  local current = vim.fn.bufnr()
  local total_count = vim.fn.bufnr('$') - 1
  local progression = (current - 1) / (total_count - 1)
  local width = vim.api.nvim_win_get_width(0)

  local progression_text = ' ' .. current .. '/' .. total_count

  local padding = 4
  local bar_width = width - 2 - string.len(progression_text) - padding * 2
  local bar_progress_count = math.floor(bar_width * progression)
  local bar = string.rep(' ', padding) ..
      '[' ..
      string.rep('🬋', bar_progress_count) ..
      string.rep(' ', bar_width - bar_progress_count) ..
      ']' ..
      progression_text

  vim.print(bar)
end

local function present_mode(on)
  present_mode_on = on

  for opt, value in pairs(options) do
    vim.opt[opt] = value[on and 'present' or 'original']
  end

  require('lualine').hide({ unhide = not on })
  require('barbecue.ui').toggle(not on)

  local opts = { buffer = vim.fn.bufnr(), silent = true }
  -- Navigate
  vim.keymap.set('n', '<Right>', ':n<CR>', opts)
  vim.keymap.set('n', '<Left>', ':N<CR>', opts)
  -- Reset
  vim.keymap.set('n', 'r', print_presentation_progression, opts)
  -- Ascii
  vim.keymap.set('n', '<leader>H', ':.!toilet -w 200 -f pagga-clean<CR>', opts)
  vim.keymap.set('n', '<leader>h', ':.!toilet -w 200 -f future<CR>', opts)
  vim.keymap.set('n', '<leader>b', ':.!toilet -w 200 -f term -F border<CR>', opts)
  -- Quit
  vim.keymap.set('n', 'q', ':q!<CR>', opts)
end

vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function() vim.opt.guicursor = original_cursor end
})
vim.api.nvim_create_autocmd({ 'CmdlineLeave', 'BufEnter' }, {
  pattern = '*.vpm',
  callback = print_presentation_progression,
})

vim.api.nvim_create_user_command('PresentToggle', function()
  present_mode(not present_mode_on)
end, {})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*.vpm',
  callback = fn.partial(present_mode, true),
})
