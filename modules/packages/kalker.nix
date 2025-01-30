{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.kalker;
  enable = cfg.enable;
in {
  options.modules.packages.kalker.enable =
    lib.mkEnableOption "kalker";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ kalker ];
  };
}
