function SetupDap()
  local dap = require 'dap'

  require 'mason-nvim-dap'.setup {
    ensure_installed = {
      'js',
      'php',
      'delve',
    },
  }

  -- Mappings
  vim.keymap.set('n', '<leader>db', function () dap.toggle_breakpoint() end)
  vim.keymap.set('n', '<leader>dcb', function ()
    -- Get user input
    local input = vim.fn.input('Condition: ')
    if not input or input == '' then return end

    dap.set_breakpoint(input)
  end)
  vim.keymap.set('n', '<leader>dr', function () dap.continue() end)
  vim.keymap.set('n', '<leader>dq', function () dap.terminate() end)
  vim.keymap.set('n', '<leader>dn', function () dap.step_over() end)
  vim.keymap.set('n', '<leader>di', function () dap.step_into() end)
  vim.keymap.set('n', '<leader>du', function () dap.step_out() end)
  vim.keymap.set('n', '<leader>dl', function () dap.run_to_cursor() end)
  vim.keymap.set('n', '<leader>dk', function () require("dap.ui.widgets").hover() end)

  -- Highlight groups
  vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939', bg = '#31353f' })
  vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { ctermbg = 0, fg = '#d8b113', bg = '#31353f' })
  vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#61afef', bg = '#31353f' })
  vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379', bg = '#31353f' })

  -- Signs
  vim.fn.sign_define('DapBreakpoint', {text='⬤', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint'})
  vim.fn.sign_define('DapBreakpointCondition', {text='', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint'})
  -- vim.fn.sign_define('DapBreakpointRejected', {text='', texthl='DapBreakpointRejected', linehl='DapBreakpointRejected', numhl='DapBreakpointRejected'})
  vim.fn.sign_define('DapBreakpointRejected', {text='', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint'})
  vim.fn.sign_define('DapBreakpointRejected', {text='', texthl='DapBreakpointRejected', linehl='DapBreakpointRejected', numhl='DapBreakpointRejected'})
  vim.fn.sign_define('DapLogPoint', {text='', texthl='DapLogPoint', linehl='DapLogPoint', numhl='DapLogPoint'})
  vim.fn.sign_define('DapStopped', {text='', texthl='DapStopped', linehl='DapStopped', numhl='DapStopped'})

  -- Add vscode configurations
  require 'dap.ext.vscode'.load_launchjs('.vscode/launch.json', {
    node = { 'typescript', 'javascript' },
    ['pwa-node'] = { 'typescript', 'javascript' },
    php = { 'php' },
  })

  -- NodeJS adapter
  local node_dap_adapter = {
    type = 'server',
    host = '::1',
    port = 8123,
    executable = {
      command = 'js-debug-adapter',
      args = { '8123' },
      -- cwd = vim.fn.getcwd(),
    },
    options = {
      max_retries = 40,
    },
    enrich_config = function(conf, on_config)
      if not vim.startswith(conf.type, "pwa-") then
        local config = vim.deepcopy(conf)
        config.type = "pwa-" .. config.type
        on_config(config)
      else
        on_config(conf)
      end
    end,
  }
  dap.adapters["node"] = node_dap_adapter
  dap.adapters["pwa-node"] = node_dap_adapter

  -- PHP adapter
  dap.adapters.php = {
    type = 'executable',
    command = 'php-debug-adapter',
    enrich_config = function(conf, on_config)
      if not conf.localSourceRoot then
        local config = vim.deepcopy(conf)
        config.pathMappings = {
          ['/var/www/html/'] = vim.fn.getcwd().."/",
        }
        on_config(config)
      else
        on_config(conf)
      end
    end,
  }

  dap.adapters.delve = {
    type = 'server',
    port = '${port}',
    executable = {
      command = 'dlv',
      args = {'dap', '-l', '127.0.0.1:${port}'},
    }
  }
  -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
  dap.configurations.go = {
    {
      type = "delve",
      name = "Debug",
      request = "launch",
      program = "${file}"
    },
    {
      type = "delve",
      name = "Debug test", -- configuration for debugging test files
      request = "launch",
      mode = "test",
      program = "${file}"
    },
    -- works with go.mod packages and sub packages 
    {
      type = "delve",
      name = "Debug test (go.mod)",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}"
    }
  }

  -- vim.g.nvim_dap_vscode_launch_debug = 0
  -- require 'utils.dap.vscode-launch' (dap)
end

function SetupDapUI()
  local dap, dapui = require 'dap', require 'dapui'

  dapui.setup()

  dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated['dapui_config'] = function()
    dapui.close()
  end
  dap.listeners.after.disconnect['dapui_config'] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited['dapui_config'] = function()
    dapui.close()
  end
end

return {
  {
    'rcarriga/nvim-dap-ui',
    event = 'VeryLazy',
    dependencies = {
      { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' }
    },
    config = SetupDapUI,
  },
  {
    'mfussenegger/nvim-dap',
    config = SetupDap,
    dependencies = {
      {
        'theHamsta/nvim-dap-virtual-text',
        config = true,
        dependencies = {
          { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
        },
      },
      {
        'jay-babu/mason-nvim-dap.nvim',
        dependencies = {
          { 'williamboman/mason.nvim', opts = {} },
        },
      },
    },
  },
}
