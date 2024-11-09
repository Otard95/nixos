function NeorgSetup()
  require'neorg'.setup {
    load = {
      ["core.defaults"] = {}, -- Loads default behaviour
      ["core.journal"] = {
        config = {
          journal_folder = 'dailes',
          strategy = 'nested',
          template_name = 'daily_template.norg',
          use_template = true,
          workspace = 'work',
        }
      },
      ["core.concealer"] = {
        config = {
          icons = {
            todo = {
              done = {
                icon = ''
              },
              pending = {
                icon = ''
              },
            },
          },
        },
      }, -- Adds pretty icons to your documents
      ["core.dirman"] = { -- Manages Neorg workspaces
        config = {
          workspaces = {
            work = "~/dev/smb/neorg/work",
          },
          default_workspace = "work",
        },
      },
      ["core.export"] = {},
      ["core.export.markdown"] = {},
    },
  }
end


function neorg_init()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'norg',
    callback = function()
      vim.opt_local.conceallevel = 2
    end
  })
end

return {
  {
    'nvim-neorg/neorg',
    init = neorg_init,
    build = function () vim.cmd 'Neorg sync-parsers' end,
    config = NeorgSetup,
    dependencies = {'nvim-lua/plenary.nvim'}
  }
}
