{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.discord;
  enable = cfg.enable;
in {
  options.modules.packages.apps.discord.enable = lib.mkEnableOption "discord";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ discord ];
  };
}
