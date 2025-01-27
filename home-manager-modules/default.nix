{ lib, ... }:
{

  imports = [
    ./hyprland
    ./packages
    ./app-launcher
    ./power-menu
    ./term
    ./mako.nix
    ./gtk.nix
    ./qt.nix
  ];

  modules = {
    hyprland.enable     = lib.mkDefault true;
    packages.enable     = lib.mkDefault true;
    app-launcher.enable = lib.mkDefault true;
    power-menu.enable   = lib.mkDefault true;
    term.enable         = lib.mkDefault true;
    nixvim.enable       = lib.mkDefault true;
    mako.enable         = lib.mkDefault true;
    gtk.enable          = lib.mkDefault true;
    qt.enable           = lib.mkDefault true;
  };
}
