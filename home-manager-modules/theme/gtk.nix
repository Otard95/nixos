{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.theme.gtk;
  enable = cfg.enable;

  gtkThemePackage = pkgs.catppuccin-gtk.override {
    inherit (theme) size tweaks;
    variant = theme.flavor;
    accents = [ theme.accent ];
  };
  gtkThemeName = "catppuccin-${theme.flavor}-${theme.accent}-${theme.size}";
in {

  options.modules.theme.gtk.enable = lib.mkEnableOption "gtk";

  config = lib.mkIf enable {
    gtk = {
      enable = true;
      theme = {
        name = gtkThemeName;
        package = gtkThemePackage;
      };
      iconTheme =
      let
        # use the light icon theme for latte
        polarity = if theme.flavor == "latte" then "Light" else "Dark";
      in
      {
        name = "Papirus-${polarity}";
        package = pkgs.catppuccin-papirus-folders.override { inherit (theme) accent flavor; };
      };
      font = {
        name = theme.font.regular.default;
        size = 10;
      };
      cursorTheme = {
        name = "BreezeX-RosePine-Linux";
        package = pkgs.rose-pine-cursor;
        size = 24;
      };
    };
    xdg.configFile = let
      gtk4Dir = "${gtkThemePackage}/share/themes/${gtkThemeName}/gtk-4.0";
    in {
      "gtk-4.0/assets".source = "${gtk4Dir}/assets";
      "gtk-4.0/gtk.css".source = "${gtk4Dir}/gtk.css";
      "gtk-4.0/gtk-dark.css".source = "${gtk4Dir}/gtk-dark.css";
    };
  };

}
