function TelescopeSetup()
  local telescope = require('telescope')
  local builtin = require('telescope.builtin')
  local actions = require('telescope.actions')

  telescope.setup {
    defaults = {
      layout_strategy = 'vertical',
      mappings = {
        n = {
          ['<M-o>'] = actions.send_selected_to_qflist + actions.open_qflist,
          ['<C-o>'] = actions.send_to_qflist + actions.open_qflist,
        },
        i = {
          ['<C-o>'] = actions.send_to_qflist + actions.open_qflist,
        },
      },
      -- vimgrep_arguments = ripgrep_argsuments,
      preview = {
        filesize_limit = 0.5,
        filetype_hook = function (filepath)
          return not (
            filepath:find('services%.json')
            or filepath:find('%.env')
          )
        end,
      },
    },
    extensions = {
      ['ui-select'] = {
        require("telescope.themes").get_dropdown {
          layout_config = {
            width = 0.8,
          },
        },
      },
    },
  }

  telescope.load_extension("ui-select")

  local is_inside_work_tree = {}
  local function project_files()
    local opts = {} -- define here if you want to define something

    local cwd = vim.fn.getcwd()
    if is_inside_work_tree[cwd] == nil then
      vim.fn.system("git rev-parse --is-inside-work-tree")
      is_inside_work_tree[cwd] = vim.v.shell_error == 0
    end

    if is_inside_work_tree[cwd] then
      builtin.git_files(opts)
    else
      builtin.find_files(opts)
    end
  end

  -- vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
  vim.keymap.set('n', '<leader>ff', project_files, {})
  vim.keymap.set('n', '<leader>fr', function() builtin.live_grep  {} end, {})
  vim.keymap.set('n', '<leader>fb',  function() builtin.buffers   {} end, {})
  vim.keymap.set('n', '<leader>FF', function() builtin.find_files {
    hidden = true,
    no_ignore = true,
    no_ignore_parent = true
  } end, {})
  vim.keymap.set('n', '<leader>FR', function() builtin.live_grep  {
    -- vimgrep_arguments = ripgrep_all_arguments
    additional_args = { '--hidden', '-u' }
  } end, {})
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
end

return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    config = TelescopeSetup,
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
  }
}
