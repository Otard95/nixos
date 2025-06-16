{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.fabric;
  enable = cfg.enable;
in {
  options.modules.packages.fabric.enable =
    lib.mkEnableOption "fabric";

  config = lib.mkIf enable {
    environment.systemPackages = [
      pkgs.fabric-ai
    ];
  };
}
