{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.mpv;
  enable = cfg.enable;
in {
  options.modules.packages.apps.mpv.enable =
    lib.mkEnableOption "mpv - image viewer";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ mpv ];
  };
}
