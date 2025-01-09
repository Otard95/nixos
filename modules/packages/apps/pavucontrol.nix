{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.pavucontrol;
  enable = cfg.enable;
in {
  options.modules.packages.apps.pavucontrol.enable = lib.mkEnableOption "pavucontrol";

  config = lib.mkIf enable {
    environment.systemPackages = [ pkgs.pavucontrol ];
  };
}
