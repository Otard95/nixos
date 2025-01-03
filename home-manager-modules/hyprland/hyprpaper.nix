{ config, lib, sources, ... }:
let
  cfg = config.modules.hyprland.hyprpaper;
  enable = cfg.enable;
in {

  options.modules.hyprland.hyprpaper = {
    enable = lib.mkEnableOption "hyprpaper configuration";
    bg-image = lib.mkOption {
      description = "Path to the backround image to use";
      default = sources.images.backround.falling-into-infinity;
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
