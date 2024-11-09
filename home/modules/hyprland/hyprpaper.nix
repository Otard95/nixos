{ config, lib, pkgs, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;

  cfg = config.modules.hyprland.hyprpaper;
  enable = cfg.enable;
in {

  options.modules.hyprland.hyprpaper.enable = lib.mkEnableOption "hyprpaper configuration";

  config = lib.mkIf enable {
    xdg.configFile."hypr/background-images".source =
      mkOutOfStoreSymlink "/etc/nixos/home/modules/hyprland/background-images";

    home.packages = with pkgs; [
      hyprpaper
    ];

    services.hyprpaper = {
      enable = true;

      settings = {
        preload = "~/.config/hypr/background-images/falling_into_infinity.png";

        wallpaper = ", ~/.config/hypr/background-images/falling_into_infinity.png";
      };
    };
  };

}
