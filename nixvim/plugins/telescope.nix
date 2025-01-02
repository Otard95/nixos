{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.telescope;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.telescope.enable =
    lib.mkEnableOption "telescope plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      extraPackages = with pkgs; [
        ripgrep
      ];

      keymaps = [
        {
          mode = "n";
          key = "<leader>FF";
          action = nixvim.mkRaw ''
            function()
              require('telescope.builtin').find_files {
                hidden = true,
                no_ignore = true,
                no_ignore_parent = true
              }
            end
          '';
          options = { silent = true; };
        }
        {
          mode = "n";
          key = "<leader>FR";
          action = nixvim.mkRaw ''
            function()
              require('telescope.builtin').live_grep  {
                additional_args = { '--hidden', '-u' }
              }
            end
          '';
          options = { silent = true; };
        }
      ];

      plugins.telescope = {
      enable = true;

      extensions.ui-select = {
        enable = true;
        settings = {
          layout_config = {
            width = 0.8;
          };
        };
      };

      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fr" = "live_grep";
        "<leader>fg" = "git_files";
        "<leader>fb" = "buffers";
        "<leader>fh" = "help_tags";
      };

      settings = {
        defaults = {
          layout_strategy = "vertical";
          mappings = {
            n = {
              "<M-o>" = nixvim.mkRaw (lib.concatStrings [
                "require('telescope.actions').send_selected_to_qflist"
                "+"
                "require('telescope.actions').open_qflist"
              ]);
              "<C-o>" = nixvim.mkRaw (lib.concatStrings [
                "require('telescope.actions').send_to_qflist"
                "+"
                "require('telescope.actions').open_qflist"
              ]);
              "dd" = nixvim.mkRaw "require('telescope.actions').delete_buffer";
            };
            i = {
              "<C-o>" = nixvim.mkRaw (lib.concatStrings [
                "require('telescope.actions').send_to_qflist"
                "+"
                "require('telescope.actions').open_qflist"
              ]);
            };
          };
            # vimgrep_arguments = ripgrep_argsuments;
          preview = {
            filesize_limit = 0.5;
            filetype_hook = nixvim.mkRaw ''
              function (filepath)
                return not (
                  filepath:find("services%.json")
                  or filepath:find("%.env")
                )
              end
            '';
            };
          };
        };
      };
    };
  };
}
