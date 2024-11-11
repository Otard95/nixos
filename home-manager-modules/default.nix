{ lib, ... }:
{

  imports = [
    ./hyprland
    ./app-launcher
    ./term
    ./gtk.nix
  ];

  modules.hyprland.enable = lib.mkDefault true;
  modules.app-launcher.enable = lib.mkDefault true;
  modules.term.enable = lib.mkDefault true;
  modules.gtk.enable = lib.mkDefault true;
}
