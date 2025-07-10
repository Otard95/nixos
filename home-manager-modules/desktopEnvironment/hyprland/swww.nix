{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktopEnvironment.hyprland.swww;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.hyprland.swww.enable = lib.mkEnableOption "swww configuration";

  config = lib.mkIf enable {
    xdg.configFile."hypr/background-images".source = ./background-images;

    home.packages = with pkgs; [
      swww
    ];

    wayland.windowManager.hyprland.settings.exec-once = [
      "swww-daemon"
      "swww img ~/.config/hypr/background-images/falling_into_infinity.png"
    ];
  };

}
