{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.tmux-navigator;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.tmux-navigator.enable =
    lib.mkEnableOption "tmux-navigator plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.tmux-navigator.enable = true;
  };
}
