{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.gimp;
  enable = cfg.enable;
in {
  options.modules.packages.apps.gimp.enable = lib.mkEnableOption "gimp";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ gimp3 ];
  };
}
