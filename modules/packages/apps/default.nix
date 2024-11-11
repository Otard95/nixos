{ config, lib, ... }:
let
  cfg = config.modules.packages.apps;
  enable = cfg.enable;
in {

  options.modules.packages.apps.enable = lib.mkEnableOption "apps";

  imports = [
    ./firefox.nix
    ./zen-browser.nix
    ./pavucontrol.nix
  ];

  config = lib.mkIf enable {
    modules.packages.apps.zen-browser.enable = lib.mkDefault true;
    modules.packages.apps.pavucontrol.enable = lib.mkDefault true;
  };
}
