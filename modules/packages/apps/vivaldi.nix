{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.vivaldi;
  enable = cfg.enable;
in {
  options.modules.packages.apps.vivaldi.enable = lib.mkEnableOption "vivaldi";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ vivaldi ];
  };
}
