{ lib, ... }:
{

  imports = [
    ./desktopEnvironment
    ./packages
    ./term
    ./i18n.nix
  ];

  modules = {
    desktopEnvironment.enable = lib.mkDefault true;
    packages.enable           = lib.mkDefault true;
    term.enable               = lib.mkDefault true;
    nixvim.enable             = lib.mkDefault true;
    # i18n.enable               = lib.mkDefault true;
  };
}
