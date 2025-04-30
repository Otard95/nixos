{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.clocks;
  enable = cfg.enable;
in {
  options.modules.packages.apps.clocks.enable =
    lib.mkEnableOption "clocks";

  config = lib.mkIf enable {
    environment.systemPackages = [
      pkgs.gnome-clocks
    ];
  };
}
