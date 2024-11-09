local function create_branch()
  local branch = vim.fn.input('Branch name: ')
  if branch == '' or branch == nil then
    print('Aborting branch creation.')
    return
  end
  vim.cmd('Git checkout -b ' .. branch)
end
local function reload_branch_list()
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_delete(0, { force = true })
  vim.cmd('Git branch')
  vim.api.nvim_win_set_cursor(0, pos)
end
local function delete_branch_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local branch = string.gsub(line, '^%s?[%*%+]%*?%s*(.-)%s*$', '%1')
  vim.cmd('Git branch -d ' .. branch)
end
local function merge_branch_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local branch = string.gsub(line, '^%s?[%*%+]%*?%s*(.-)%s*$', '%1')
  vim.cmd('Git merge ' .. branch)
end

function SetupFugitive()
  local fn = require 'utils.fn'

  -- Merge conflict resolution
  local opts = { noremap = true, silent = true }
  vim.keymap.set('n', '<leader>gm', ':Gdiffsplit!<CR>', opts)
  vim.keymap.set('n', '<leader>gj', ':diffget //3<CR>', opts)
  vim.keymap.set('n', '<leader>gf', ':diffget //2<CR>', opts)
  vim.keymap.set('n', '<leader>gn', ']c', opts)
  vim.keymap.set('n', '<leader>gp', '[c', opts)
  vim.keymap.set('n', '<leader>gs', ':Git<CR>', opts)
  vim.keymap.set('n', '<leader>gl', ':Git log<CR>', opts)

  -- Keybinds in status window
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'fugitive',
    callback = function(e)
      local opts = { buffer = e.buf, silent = true }

      vim.keymap.set('n', '<leader>gp', ':Git push<CR>', opts)
      vim.keymap.set('n', '<leader>gP', ':Git push -u origin HEAD<CR>', opts)
      vim.keymap.set('n', '<leader>gu', ':Git pull<CR>', opts)
      vim.keymap.set('n', '<leader>gb', ':Git branch<CR>', opts)

      vim.keymap.set('n', '<leader>ba', create_branch, opts)
    end,
  })
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'git',
    callback = function(e)
      local opts = { buffer = e.buf, silent = true }

      vim.keymap.set('n', '<C-r>', reload_branch_list, opts)
      vim.keymap.set('n', '<leader>a', fn.flow(create_branch, reload_branch_list), opts)
      vim.keymap.set('n', '<leader>dd', fn.flow(delete_branch_under_cursor, reload_branch_list), opts)
      vim.keymap.set('n', '<leader>mm', merge_branch_under_cursor, opts)
    end,
  })
end

return {
  {
    'tpope/vim-fugitive',
    init = SetupFugitive,
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
      },
      current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local opts = { buffer = bufnr }

        -- Navigation
        vim.keymap.set('n', '<leader>ghn', gs.next_hunk, opts)
        vim.keymap.set('n', '<leader>ghp', gs.prev_hunk, opts)

        -- Actions
        vim.keymap.set('n', '<leader>ghs', gs.stage_hunk, opts)
        vim.keymap.set('n', '<leader>ghr', gs.reset_hunk, opts)
        vim.keymap.set('v', '<leader>ghs', function()
          gs.stage_hunk {
            vim.fn.line('.'),
            vim.fn.line('v')
          }
        end, opts)
        vim.keymap.set('v', '<leader>ghr', function()
          gs.reset_hunk {
            vim.fn.line('.'),
            vim.fn.line('v')
          }
        end, opts)
        vim.keymap.set('n', '<leader>ghi', gs.preview_hunk, opts)
      end,
    },
  }
}
