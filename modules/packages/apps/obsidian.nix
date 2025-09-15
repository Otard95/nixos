# TODO: Use home-manager module when available
{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.obsidian;
  enable = cfg.enable;
in {
  options.modules.packages.apps.obsidian.enable =
    lib.mkEnableOption "obsidian";

  config = lib.mkIf enable {
    environment.systemPackages = [ pkgs.obsidian ];
  };
}
