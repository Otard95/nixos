{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.signal;
  enable = cfg.enable;
in {
  options.modules.packages.apps.signal.enable = lib.mkEnableOption "signal";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [ signal-desktop ];
  };
}
