{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.matrix;
  enable = cfg.enable;
in {
  options.modules.packages.apps.matrix.enable = lib.mkEnableOption "matrix";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ element-desktop ];
  };
}
