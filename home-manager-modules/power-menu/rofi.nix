{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.power-menu.rofi;
  enable = cfg.enable;
in {

  options.modules.power-menu.rofi = {
    enable = lib.mkEnableOption "rofi";
    splash-image = {
      path = lib.mkOption {
        description = "The splash-image to use";
        default = ./splash-images/lynnette_space_suit_20240205_04_by_kai_artworks_dgu3229-pre.jpg;
        type = lib.types.path;
      };
      scale = lib.mkOption {
        description = "The scaling logic for the image, where scale is: none, both, width, height";
        default = "height";
        type = lib.types.enum [
          "height"
          "width"
          "both"
          "none"
        ];
      };
    };
  };

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      rofi-wayland
    ];

    xdg.configFile = let
      themeTempl = builtins.readFile ./theme.rasi;

      themeFile = builtins.replaceStrings
        [ "TEXT_FONT"        "TEXT_ICONS"     "SPLASH_SCALE" ]
        [ theme.font.regular theme.font.icons cfg.splash-image.scale ]
        themeTempl;
    in {
      "rofi/power-menu/theme.rasi".text = themeFile;
      "rofi/power-menu/splash.jpg".source = cfg.splash-image.path;
      "power-menu.sh".source = ./start.sh;
    };
  };

}
