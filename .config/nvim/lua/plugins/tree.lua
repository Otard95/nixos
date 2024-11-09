function SetupTree()
  local api = require 'nvim-tree.api'

  vim.keymap.set('n', "<leader>\\", api.tree.toggle, {
    noremap = true,
    silent = true
  })

  require 'nvim-tree'.setup {
    view = {
      width = 40,
    },
    renderer = {
      icons = {
        glyphs = {
          bookmark = '',
        },
      },
    },
    update_focused_file = {
      enable = true,
      update_root = true,
    },
    filters = {
      git_ignored = false,
      dotfiles = false,
    },
    on_attach = function(bufnr)

      -- Setup default mappings
      api.config.mappings.default_on_attach(bufnr)

      vim.keymap.set('n', 'l', api.node.open.edit, { buffer = bufnr })
      vim.keymap.set('n', 'h', function()
        local node = api.tree.get_node_under_cursor()

        if not node then
          return
        end

        if node.type ~= 'directory' then
          -- If the node is not a directory, navigate to the parent
          api.node.navigate.parent()
        elseif node.open then
          -- If the directory is open, collapse it
          api.node.open.edit() -- collapse the node
        else
          -- If the directory is closed, navigate to the parent
          api.node.navigate.parent()
        end
      end, { buffer = bufnr })
    end,
  }
end

function tree_init()
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
end

return {
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      {
        'nvim-tree/nvim-web-devicons',
        opts = {
          override_by_extension = {
            ['txt'] = {
              icon = "",
              color = "#89e051",
              cterm_color = "113",
              name = "Txt",
            }
          },
          override_by_filename = {
            [".dockerignore"] = {
              icon = "",
              color = "#458ee6",
              cterm_color = "68",
              name = "Dockerfile",
            },
            ["dockerfile"] = {
              icon = "",
              color = "#458ee6",
              cterm_color = "68",
              name = "Dockerfile",
            },
            ["docker-compose.yaml"] = {
              icon = "",
              color = "#458ee6",
              cterm_color = "68",
              name = "Dockerfile",
            },
            ["docker-compose.yml"] = {
              icon = "",
              color = "#458ee6",
              cterm_color = "68",
              name = "Dockerfile",
            },
          }
        }
      }
    },
    init = tree_init,
    config = SetupTree,
  }
}
