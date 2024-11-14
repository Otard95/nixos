{ lib, ... }:
{

  imports = [
    ./hyprland
    ./app-launcher
    ./term
    ./gtk.nix
    ./qt.nix
  ];

  modules.hyprland.enable = lib.mkDefault true;
  modules.app-launcher.enable = lib.mkDefault true;
  modules.term.enable = lib.mkDefault true;
  modules.gtk.enable = lib.mkDefault true;
  modules.qt.enable = lib.mkDefault true;
}
