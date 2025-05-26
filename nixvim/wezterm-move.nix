{ config, lib, ... }:
let
  cfg = config.modules.nixvim.wezterm-move;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.wezterm-move.enable =
    lib.mkEnableOption "wezterm-move";

  config = lib.mkIf enable {

    programs.nixvim.keymaps = [
      {
        mode = "n";
        key = "<C-h>";
        action = nixvim.mkRaw "require 'utils.wezterm'.move 'h'";
        options = { silent = true; };
      }
      {
        mode = "n";
        key = "<C-j>";
        action = nixvim.mkRaw "require 'utils.wezterm'.move 'j'";
        options = { silent = true; };
      }
      {
        mode = "n";
        key = "<C-k>";
        action = nixvim.mkRaw "require 'utils.wezterm'.move 'k'";
        options = { silent = true; };
      }
      {
        mode = "n";
        key = "<C-l>";
        action = nixvim.mkRaw "require 'utils.wezterm'.move 'l'";
        options = { silent = true; };
      }
    ];

  };
}
