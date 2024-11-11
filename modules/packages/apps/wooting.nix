{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.wooting;
  enable = cfg.enable;
in {
  options.modules.packages.apps.wooting.enable = lib.mkEnableOption "wooting";

  config = lib.mkIf enable {
    hardware.wooting.enable = true;
    users.users.otard.extraGroups = [ "input" ];

    environment.systemPackages = with pkgs; [ wootility ];
  };
}
