{ config, lib, theme, ... }:
let
  cfg = config.modules.theme.qt;
  enable = cfg.enable;
in {

  options.modules.theme.qt.enable = lib.mkEnableOption "qt";

  config = lib.mkIf enable {

    catppuccin.kvantum = {
      enable = true;
      flavor = theme.flavor;
      accent = theme.accent;
    };

    qt = {
      enable = true;
      style.name = "kvantum";
      platformTheme = {
        name = "kvantum";
        # package = with pkgs; [ libsForQt5.qt5ct qt6Packages.qt6ct ];
      };
    };

  };

}
