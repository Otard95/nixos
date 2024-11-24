{ config, lib, pkgs, ... }:
let
  cfg = config.modules.hyprland.hyprpaper;
  enable = cfg.enable;
in {

  options.modules.hyprland.hyprpaper.enable = lib.mkEnableOption "hyprpaper configuration";

  config = lib.mkIf enable {
    xdg.configFile."hypr/background-images".source = ./background-images;

    home.packages = with pkgs; [
      hyprpaper
    ];

    services.hyprpaper = {
      enable = true;

      settings = {
        ipc = false;

        preload = "~/.config/hypr/background-images/falling_into_infinity.png";

        wallpaper = ", ~/.config/hypr/background-images/falling_into_infinity.png";
      };
    };
  };

}
