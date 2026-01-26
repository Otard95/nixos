{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.redis-insight;
  enable = cfg.enable;
in {
  options.modules.packages.apps.redis-insight.enable =
    lib.mkEnableOption "redis-insight";

  config = lib.mkIf enable {
    environment.systemPackages = [
      pkgs.redisinsight
    ];
  };
}
