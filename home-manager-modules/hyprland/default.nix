{ config, lib, ... }:
let
  cfg = config.modules.hyprland;
  enable = cfg.enable;
in {

  options.modules.hyprland.enable = lib.mkEnableOption "hyprland";

  imports = [
    ./hypridle.nix
    ./hyprland.nix
    ./hyprpaper.nix
    ./hyprlock.nix
    ./kanshi.nix
    ./swww.nix
    ./waybar.nix
  ];

  config = lib.mkIf enable {
    modules.hyprland = {
      wm.enable = lib.mkDefault true;
      hypridle.enable = lib.mkDefault true;
      hyprpaper.enable = lib.mkDefault true;
      hyprlock.enable = lib.mkDefault true;
      kanshi.enable = lib.mkDefault true;
      # swww.enable = lib.mkDefault true;
      waybar.enable = lib.mkDefault true;
    };
  };

}
