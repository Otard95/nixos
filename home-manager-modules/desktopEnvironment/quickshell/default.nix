{ config, lib, pkgs, helpers, ... }:
let
  cfg = config.modules.desktopEnvironment.quickshell;
  enable = cfg.enable;
in {
  options.modules.desktopEnvironment.quickshell = {
    enable = lib.mkEnableOption "quickshell";

    notifications.backend = (helpers.mkOption.enum
      "The backend to enable"
      ["native" "mako"]) // { default = "native"; };
  };

  config = lib.mkIf enable {
    home.packages = with pkgs; [ brightnessctl ];

    services.poweralertd.enable = true;

    programs.quickshell = {
      enable = true;
      systemd.enable = true;

      configs = {
        default = ./v2;
        # bar = ./bar;
      };
    };

    systemd.user.services.quickshell.Service.Environment = [ "QS_NOTIFICATION_BACKEND=${cfg.notifications.backend}" ];
  };
}
