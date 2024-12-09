{ config, lib, ... }:
let
  cfg = config.modules.hyprland;
  enable = cfg.enable;
in {

  options.modules.hyprland.enable = lib.mkEnableOption "hyprland";

  imports = [
    ./hyprland.nix
    ./hyprpaper.nix
    ./hyprlock.nix
    ./swww.nix
    ./waybar.nix
  ];

  config = lib.mkIf enable {
    modules.hyprland = {
      wm.enable = lib.mkDefault true;
      hyprpaper.enable = lib.mkDefault true;
      hyprlock.enable = lib.mkDefault true;
      # swww.enable = lib.mkDefault true;
      waybar.enable = lib.mkDefault true;
    };
  };

}
