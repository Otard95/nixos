{ config, ... }:
let
  nixvim = config.lib.nixvim;
in {
  programs.nixvim = {
    keymaps =  map (m: {
      mode = builtins.elemAt m 0;
      key = builtins.elemAt m 1;
      action = builtins.elemAt m 2;
      options = { noremap = true; silent = true; } // builtins.elemAt m 3;
    }) [
      [ "n" "<leader>gm" ":Gdiffsplit!<CR>" {} ]
      [ "n" "<leader>gj" ":diffget //3<CR>" {} ]
      [ "n" "<leader>gf" ":diffget //2<CR>" {} ]
      [ "n" "<leader>gn" "]c"               {} ]
      [ "n" "<leader>gp" "[c"               {} ]
      [ "n" "<leader>gs" ":Git<CR>"         {} ]
      [ "n" "<leader>gl" ":Git log<CR>"     {} ]
    ];

    # autoCmd = [
    #   {
    #     event = "FileType";
    #     pattern = "fugitive";
    #     callback = nixvim.mkRaw ''
    #       function(e)
    #         local opts = { buffer = e.buf, silent = true }

    #         vim.keymap.set('n', '<leader>gp', ':Git push<CR>', opts)
    #         vim.keymap.set('n', '<leader>gP', ':Git push -u origin HEAD<CR>', opts)
    #         vim.keymap.set('n', '<leader>gu', ':Git pull<CR>', opts)
    #         vim.keymap.set('n', '<leader>gb', ':Git branch<CR>', opts)

    #         # TODO: fix branch creation
    #         # vim.keymap.set('n', '<leader>ba', create_branch, opts)
    #       end
    #     '';
    #   }
    #   # TODO: Port this
    #   # vim.api.nvim_create_autocmd('FileType', {
    #   #   pattern = 'git',
    #   #   callback = function(e)
    #   #     local opts = { buffer = e.buf, silent = true }

    #   #     vim.keymap.set('n', '<C-r>', reload_branch_list, opts)
    #   #     vim.keymap.set('n', '<leader>a', fn.flow(create_branch, reload_branch_list), opts)
    #   #     vim.keymap.set('n', '<leader>dd', fn.flow(delete_branch_under_cursor, reload_branch_list), opts)
    #   #     vim.keymap.set('n', '<leader>mm', merge_branch_under_cursor, opts)
    #   #   end,
    #   # })
    # ];

    plugins = {
      fugitive.enable = true; # TODO: Should we just assume git is installed?

      gitsigns = {
        enable = true;

        settings = {
          current_line_blame = true;
          current_line_blame_opts = {
            delay = 500;
          };
          current_line_blame_formatter = "<author>, <author_time:%R> - <summary>";
          on_attach = ''
            function(bufnr)
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
            end
          '';
        };
      };
    };
  };
}
