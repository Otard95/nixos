{ config, lib, pkgs, theme, ... }:
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

    # Fix color scheme :D
    # https://github.com/NixOS/nixpkgs/issues/355602#issuecomment-2495539792
    xdg.configFile."kdeglobals" = {
      enable = true;
      text =
        ''
          [UiSettings]
          ColorScheme=*
        ''
        + (builtins.readFile "${
          pkgs.catppuccin-kde.override {
            flavour = [ theme.flavor ];
            accents = [ theme.accent ];
          }
        }/share/color-schemes/CatppuccinFrappeTeal.colors");
    };

  };

}
