{ config, lib, pkgs, ... }:
{

  imports = [
    ./hyprland
    ./app-launcher
    ./term
  ];

  modules.hyprland.enable = lib.mkDefault true;
  modules.app-launcher.enable = lib.mkDefault true;
  modules.term.enable = lib.mkDefault true;
}
