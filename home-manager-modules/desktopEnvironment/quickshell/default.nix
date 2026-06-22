{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktopEnvironment.quickshell;
  enable = cfg.enable;
in {
  options.modules.desktopEnvironment.quickshell.enable =
    lib.mkEnableOption "quickshell";

  config = lib.mkIf enable {
    home.packages = with pkgs; [ brightnessctl ];

    services.poweralertd.enable = true;

    programs.quickshell = {
      enable = true;
      systemd.enable = true;

      configs = {
        default = ./bar;
        bar = ./bar;
      };
    };
  };
}
