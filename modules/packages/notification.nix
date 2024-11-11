{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.notification;
  enable = cfg.enable;
in {

  options.modules.packages.notification.enable = lib.mkEnableOption "notification packages";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [
      dunst
      libnotify
    ];
  };
}
