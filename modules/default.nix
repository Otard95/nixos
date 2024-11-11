{ lib, ... }:
{

  imports = [
    ./system
    ./desktopEnvironment
    ./packages
    ./nixvim
  ];

  modules.system.enable = lib.mkDefault true;
  modules.desktopEnvironment.enable = lib.mkDefault true;
  modules.term.nixvim.enable = lib.mkDefault true;
  modules.packages.enable = lib.mkDefault true;

}
