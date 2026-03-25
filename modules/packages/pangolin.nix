{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.pangolin;
  enable = cfg.enable;
in {
  options.modules.packages.pangolin.enable =
    lib.mkEnableOption "pangolin cli";

  config = lib.mkIf enable {
    environment.systemPackages = [
      pkgs.pangolin-cli
    ];
  };
}
