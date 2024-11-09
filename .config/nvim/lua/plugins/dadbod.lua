local function db_completion()
  local cmp = require "cmp"
  cmp.setup.buffer {
    sources = cmp.config.sources({
      { name = "vim-dadbod-completion" },
      { name = 'luasnip' },
    }, {
      { name = 'buffer' },
    })
  }
end

function SetupDadbod()
  vim.g.db_ui_save_location = vim.fn.stdpath "config" .. require("plenary.path").path.sep .. "db_ui"

  vim.api.nvim_create_autocmd("FileType", {
    pattern = {
      "sql",
    },
    command = [[setlocal omnifunc=vim_dadbod_completion#omni]],
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = {
      "sql",
      "mysql",
      "plsql",
    },
    callback = function()
      vim.schedule(db_completion)
    end,
  })
end

return {
  {
    'tpope/vim-dadbod',
    dependencies = {
      'kristijanhusak/vim-dadbod-ui',
      'kristijanhusak/vim-dadbod-completion',
    },
    config = SetupDadbod,
  }
}
