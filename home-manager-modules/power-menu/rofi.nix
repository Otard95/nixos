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
      "power-menu.sh".source = ./start.sh;
    };
  };

}
