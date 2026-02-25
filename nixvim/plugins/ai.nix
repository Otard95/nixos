{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.ai;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.ai.enable =
    lib.mkEnableOption "ai";

  config = lib.mkIf enable {
    programs.nixvim = {
      extraPackages = [ pkgs.lsof ];
      extraPlugins = [ pkgs.vimPlugins.opencode-nvim ];
      opts.autoread = true;
      globals.opencode_opts = {
        provider = {
          enabled = "${config.modules.term.defaultTerminal}";
          wezterm = { };
        };
      };
      keymaps = [
        {
          mode = [ "n" "x" ];
          key = "<leader>ot";
          action = nixvim.mkRaw "function() require('opencode').ask('@this: ', { submit = true }) end";
          options = { desc = "Ask opencode"; };
        }
        {
          mode = "n";
          key = "<leader>ob";
          action = nixvim.mkRaw "function() require('opencode').ask('@buffer: ', { submit = true }) end";
          options = { desc = "Ask opencode"; };
        }
        {
          mode = [ "n" "x" ];
          key = "<leader>os";
          action = nixvim.mkRaw "function() require('opencode').select() end";
          options = { desc = "Execute opencode action…"; };
        }
        {
          mode = [ "n" "x" ];
          key = "<leader>ogt";
          action = nixvim.mkRaw "function() return require('opencode').operator('@this ') end";
          options = { expr = true; desc = "Add range to opencode"; };
        }
        {
          mode = [ "n" ];
          key = "<leader>ogb";
          action = nixvim.mkRaw "function() return require('opencode').operator('@buffer ') end";
          options = { expr = true; desc = "Add range to opencode"; };
        }
      ];

      plugins = {
        snacks = {
          enable = true;

          settings = { input.enabled = true; picker.enabled = true; terminal.enabled = true; };
        };
      };
    };
  };
}
