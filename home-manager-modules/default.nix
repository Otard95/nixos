{ lib, ... }:
{

  imports = [
    ./hyprland
    ./packages
    ./app-launcher
    ./power-menu
    ./term
    ./theme
    ./i18n.nix
    ./mako.nix
  ];

  modules = {
    hyprland.enable     = lib.mkDefault true;
    packages.enable     = lib.mkDefault true;
    app-launcher.enable = lib.mkDefault true;
    power-menu.enable   = lib.mkDefault true;
    term.enable         = lib.mkDefault true;
    nixvim.enable       = lib.mkDefault true;
    # i18n.enable         = lib.mkDefault true;
    mako.enable         = lib.mkDefault true;
    theme.enable        = lib.mkDefault true;
  };
}
