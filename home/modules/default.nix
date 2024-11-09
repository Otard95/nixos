{ config, lib, pkgs, ... }:
{

  imports = [
    ./hyprland
  ];

  modules.hyprland.enable = lib.mkDefault true;
}
