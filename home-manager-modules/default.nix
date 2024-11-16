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

  modules.hyprland.enable = lib.mkDefault true;
  modules.app-launcher.enable = lib.mkDefault true;
  modules.term.enable = lib.mkDefault true;
  modules.nixvim.enable = lib.mkDefault true;
  modules.mako.enable = lib.mkDefault true;
  modules.gtk.enable = lib.mkDefault true;
  modules.qt.enable = lib.mkDefault true;
}
