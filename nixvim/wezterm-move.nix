{ config, lib, ... }:
let
  cfg = config.modules.nixvim.wezterm-move;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.wezterm-move.enable =
    lib.mkEnableOption "wezterm-move";

  config = lib.mkIf enable {

    modules.nixvim.plugins.tmux-navigator.enable = false;

    programs.nixvim.keymaps = [
      {
        mode = "n";
        key = "<C-h>";
        action = nixvim.mkRaw "function() require 'utils.wezterm'.move 'h' end";
        options = { silent = true; };
      }
      {
        mode = "n";
        key = "<C-j>";
        action = nixvim.mkRaw "function() require 'utils.wezterm'.move 'j' end";
        options = { silent = true; };
      }
      {
        mode = "n";
        key = "<C-k>";
        action = nixvim.mkRaw "function() require 'utils.wezterm'.move 'k' end";
        options = { silent = true; };
      }
      {
        mode = "n";
        key = "<C-l>";
        action = nixvim.mkRaw "function() require 'utils.wezterm'.move 'l' end";
        options = { silent = true; };
      }
    ];

  };
}
