{ config, lib, pkgs, ... }:
{

  imports = [
    ./hyprland
    ./app-launcher
  ];

  modules.hyprland.enable = lib.mkDefault true;
  modules.app-launcher.enable = lib.mkDefault true;
}
