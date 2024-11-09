{ config, pkgs, theme, capFirst, ...}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  gtkThemePackage = pkgs.catppuccin-gtk.override {
    inherit (theme) size tweaks;
    variant = theme.flavor;
    accents = [ theme.accent ];
  };
  gtkThemeName = "catppuccin-${theme.flavor}-${theme.accent}-${theme.size}";
in
{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = "otard";
  home.homeDirectory = "/home/otard";

  imports = [ ./modules ];

  catppuccin = {
    enable = true;
    inherit (theme) flavor accent;
    pointerCursor.enable = true;
  };
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
      name = "MesloLGM Nerd Font";
      size = 10;
    };
  };
  xdg.configFile = let
    gtk4Dir = "${gtkThemePackage}/share/themes/${gtkThemeName}/gtk-4.0";
  in {
    "gtk-4.0/assets".source = "${gtk4Dir}/assets";
    "gtk-4.0/gtk.css".source = "${gtk4Dir}/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${gtk4Dir}/gtk-dark.css";

    nvim.source = mkOutOfStoreSymlink "/etc/nixos/.config/nvim";
  };

  home.packages = with pkgs; [
  ];

  programs = {
    neovim = (import ./nvim.nix { inherit pkgs; });
  };
}
