{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.grimblast;
  enable = cfg.enable;
in {
  options.modules.packages.apps.grimblast.enable = lib.mkEnableOption "grimblast";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ grimblast ];
  };
}
