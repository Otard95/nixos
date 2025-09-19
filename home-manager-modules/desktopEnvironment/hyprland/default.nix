{ config, lib, helpers, ... }:
let
  cfg = config.modules.desktopEnvironment.hyprland;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.hyprland = {
    enable = lib.mkEnableOption "hyprland";

    background-image = helpers.mkOption.image "background";
  };

  imports = [
    ./hypridle.nix
    ./hyprland.nix
    ./hyprpaper.nix
    ./hyprlock.nix
    ./waybar.nix
  ];

  config = lib.mkIf enable {
    modules.desktopEnvironment.hyprland = {
      wm.enable = lib.mkDefault true;
      hypridle.enable = lib.mkDefault true;
      hyprpaper = {
        enable = lib.mkDefault true;
        bg-image = cfg.background-image;
      };
      hyprlock = {
        enable = lib.mkDefault true;
        bg-image = cfg.background-image;
      };
      waybar.enable = lib.mkDefault true;
    };
  };

}
