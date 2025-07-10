{ config, lib, sources, ... }:
let
  cfg = config.modules.desktopEnvironment.hyprland.hyprpaper;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.hyprland.hyprpaper = {
    enable = lib.mkEnableOption "hyprpaper configuration";
    bg-image = lib.mkOption {
      description = "Path to the background image to use";
      default = sources.images.background.falling-into-infinity;
      type = lib.types.path;
    };
  };

  config = lib.mkIf enable {
    services.hyprpaper = {
      enable = true;

      settings = {
        ipc = false;

        preload = "${cfg.bg-image}";

        wallpaper = lib.concatStrings [
          ", " "${cfg.bg-image}"
        ];
      };
    };
  };

}
