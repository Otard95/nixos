{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.slack;
  enable = cfg.enable;
in {
  options.modules.packages.apps.slack.enable =
    lib.mkEnableOption "slack";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ slack ];
  };
}
