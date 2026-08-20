{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.logitech.openlogi;
  enable = cfg.enable;
in {
  options.modules.packages.apps.logitech.openlogi = {
    enable = lib.mkEnableOption "openlogi";
  };

  config = lib.mkIf enable {
    environment.systemPackages = [ pkgs.openlogi ];
  };
}
