{ lib, ... }:
{

  imports = [
    ./theme.nix
    ./system
    ./desktopEnvironment
    ./packages
  ];

  modules.system.enable = lib.mkDefault true;
  modules.desktopEnvironment.enable = lib.mkDefault true;
  modules.packages.enable = lib.mkDefault true;

}
