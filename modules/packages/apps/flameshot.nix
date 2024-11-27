{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.flameshot;
  enable = cfg.enable;
in {
  options.modules.packages.apps.flameshot.enable = lib.mkEnableOption "flameshot";

  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [
      (flameshot.override { enableWlrSupport = true; })
    ];
  };
}
