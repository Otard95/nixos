{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.power-menu.rofi;
  enable = cfg.enable;
in {

  options.modules.power-menu.rofi.enable = lib.mkEnableOption "rofi";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      rofi-wayland
    ];

    xdg.configFile = let
      themeTempl = builtins.readFile ./theme.rasi;

      themeFile = builtins.replaceStrings
        [ "TEXT_FONT"        "TEXT_ICONS" ]
        [ theme.font.regular theme.font.icons ]
        themeTempl;
    in {
      "rofi/power-menu/theme.rasi".text = themeFile;
      "rofi/power-menu/splash.jpg".source =
        ./splash-images/lynnette_space_suit_20240205_04_by_kai_artworks_dgu3229-pre.jpg;
      "power-menu.sh".source = ./start.sh;
    };
  };

}
