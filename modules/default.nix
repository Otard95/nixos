{ config, lib, ... }:
{

  imports = [
    ./system
    ./desktopEnvironment
  ];

  modules.system.enable = lib.mkDefault true;
  modules.desktopEnvironment.enable = lib.mkDefault true;

}
