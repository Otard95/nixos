{ config, lib, helpers, sources, ... }:
let
  cfg = config.modules.desktopEnvironment.hyprland;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.hyprland = {
    enable = lib.mkEnableOption "hyprland";

    background-image = helpers.mkOption.monitorBackground sources.images.background.falling-into-infinity;
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
        bg-image = {
          horizontal = lib.mkDefault cfg.background-image.horizontal;
          vertical = lib.mkDefault cfg.background-image.vertical;
        };
      };
      hyprlock = {
        enable = lib.mkDefault true;
        bg-image = cfg.background-image.horizontal;
      };
      waybar.enable = lib.mkDefault true;
    };
  };

}
