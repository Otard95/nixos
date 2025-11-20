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
          ", ${cfg.bg-image.horizontal}"
          "HDMI-A-1, ${cfg.bg-image.horizontal}"
        ]
          ++ lib.optionals (cfg.bg-image.vertical != null) [
            "DP-7, ${cfg.bg-image.vertical}"
            "DP-9, ${cfg.bg-image.vertical}"
          ]
          ++ lib.optionals (cfg.bg-image.vertical == null) [
            "DP-7, ${cfg.bg-image.horizontal}"
            "DP-9, ${cfg.bg-image.horizontal}"
          ];
      };
    };
  };

}
