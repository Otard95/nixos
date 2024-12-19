{ config, lib, pkgs, ... }:
let
  cfg = config.modules.hyprland.hyprpaper;
  enable = cfg.enable;
in {

  options.modules.hyprland.hyprpaper = {
    enable = lib.mkEnableOption "hyprpaper configuration";
    bg-image = lib.mkOption {
      description = "Path to the backround image to use";
      default = "~/.config/hypr/background-images/falling_into_infinity.png";
      type = lib.types.string;
    };
  };

  config = lib.mkIf enable {
    xdg.configFile."hypr/background-images".source = ./background-images;

    home.packages = with pkgs; [
      hyprpaper
    ];

    services.hyprpaper = {
      enable = true;

      settings = {
        ipc = false;

        preload = cfg.bg-image;

        wallpaper = lib.concatStrings [
          ", " cfg.bg-image
        ];
      };
    };
  };

}
