{ lib, ... }:
{

  imports = [
    ./hyprland
    ./app-launcher
    ./term
    ./mako.nix
    ./gtk.nix
    ./qt.nix
  ];

  modules = {
    hyprland.enable = lib.mkDefault true;
    app-launcher.enable = lib.mkDefault true;
    term.enable = lib.mkDefault true;
    nixvim.enable = lib.mkDefault true;
    mako.enable = lib.mkDefault true;
    gtk.enable = lib.mkDefault true;
    qt.enable = lib.mkDefault true;
  };
}
