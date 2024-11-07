{ config, lib, ... }:
{

  imports = [
    ./system
  ];

  modules.system.enable = lib.mkDefault true;

}
