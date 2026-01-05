{ config, lib, sources, helpers, ... }:
let
  cfg = config.modules.desktopEnvironment.hyprland.hyprpaper;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.hyprland.hyprpaper = {
    enable = lib.mkEnableOption "hyprpaper configuration";
    bg-image = helpers.mkOption.monitorBackground sources.images.background.falling-into-infinity;
  };

  config = lib.mkIf enable {
    services.hyprpaper = {
      enable = true;

      settings = {
        ipc = true;

        preload = [
          "${cfg.bg-image.horizontal}"
        ] ++ lib.optional (cfg.bg-image.vertical != null) "${cfg.bg-image.vertical}";

        wallpaper = [
          { path = "${cfg.bg-image.horizontal}"; }
          { monitor = "HDMI-A-1"; path = "${cfg.bg-image.horizontal}"; }
        ]
          ++ lib.optionals (cfg.bg-image.vertical != null) [
            { monitor = "DP-7"; path = "${cfg.bg-image.vertical}"; }
            { monitor = "DP-9"; path = "${cfg.bg-image.vertical}"; }
          ]
          ++ lib.optionals (cfg.bg-image.vertical == null) [
            { monitor = "DP-7"; path = "${cfg.bg-image.horizontal}"; }
            { monitor = "DP-9"; path = "${cfg.bg-image.horizontal}"; }
          ];
      };
    };
  };

}
