{ config, lib, ... }:
let
  cfg = config.modules.hyprland;
  enable = cfg.enable;
in {

  options.modules.hyprland.enable = lib.mkEnableOption "hyprland";

  imports = [
    ./hyprland.nix
    ./hyprpaper.nix
    ./waybar.nix
  ];

  config = lib.mkIf enable {
    modules.hyprland.wm.enable = lib.mkDefault true;
    modules.hyprland.hyprpaper.enable = lib.mkDefault true;
    modules.hyprland.waybar.enable = lib.mkDefault true;
  };

}
