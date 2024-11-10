{ config, lib, ... }:
{

  imports = [
    ./system
    ./desktopEnvironment
    ./nixvim
  ];

  modules.system.enable = lib.mkDefault true;
  modules.desktopEnvironment.enable = lib.mkDefault true;
  modules.term.nixvim.enable = lib.mkDefault true;

}
