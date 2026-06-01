{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.git;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.git.enable =
    lib.mkEnableOption "git plugins";

  config = lib.mkIf enable {
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

      autoCmd = [
        {
          event = "FileType";
          pattern = "fugitive";
          callback = nixvim.mkRaw ''
            function(e)
              local opts = { buffer = e.buf, silent = true }

              vim.keymap.set('n', '<leader>gp', ':Git push<CR>', opts)
              vim.keymap.set('n', '<leader>gP', ':Git push -u origin HEAD<CR>', opts)
              vim.keymap.set('n', '<leader>gu', ':Git pull<CR>', opts)
              vim.keymap.set('n', '<leader>gb', ':Git branch<CR>', opts)

              vim.keymap.set('n', '<leader>ba', require('utils.git').create_branch, opts)
            end
          '';
        }
        {
          event = "FileType";
          pattern = "git";
          callback = nixvim.mkRaw ''
            function(e)
              local git = require 'utils.git'
              local fn = require 'utils.fn'
              local opts = { buffer = e.buf, silent = true }

              vim.keymap.set('n', '<C-r>', git.reload_branch_list, opts)
              vim.keymap.set('n', '<leader>a', fn.flow(git.create_branch, git.reload_branch_list), opts)
              vim.keymap.set('n', '<leader>dd', fn.flow(git.delete_branch_under_cursor, git.reload_branch_list), opts)
              vim.keymap.set('n', '<leader>mm', git.merge_branch_under_cursor, opts)
            end
          '';
        }
      ];

      colorschemes.catppuccin.settings.integrations.gitsigns = true;
      plugins = {
        fugitive.enable = true;

        diffview = {
          enable = true;
          package = pkgs.vimUtils.buildVimPlugin {
            name = "diffview-nvim-test";
            src = pkgs.fetchFromGitHub {
                owner = "dlyongemallo";
                repo = "diffview.nvim";
                rev = "d52621fe8a0b865e0971389bc36dd9220260cbc3";
                hash = "sha256-1DwfCbOl+Tfj4QtW/nbgNkFg9CQU21N8E4p63sDPl20=";
            };
            doCheck = false;
          };
        };

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
  };
}
