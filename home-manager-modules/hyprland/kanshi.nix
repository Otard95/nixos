{ config, lib, ... }:
let
  cfg = config.modules.hyprland.kanshi;
  enable = cfg.enable;
in {
  options.modules.hyprland.kanshi.enable =
    lib.mkEnableOption "kanshi";

  config = lib.mkIf enable {
    services.kanshi = {
      enable = true;

      systemdTarget = "hyprland-session.target";

      settings = [
        {
          profile = {
            name = "undocked";
            exec = [
              "${./scripts/kanshi-undocked.sh}"
              "pkill hyprpaper ; sleep 0.5 && hyprpaper &"
            ];
            outputs = [
              { criteria = "eDP-1"; mode = "2560x1600"; scale = 1.0; }
            ];
          };
        }
        {
          profile = {
            name = "docked";
            exec = [
              "${./scripts/kanshi-docked.sh}"
              "pkill hyprpaper ; sleep 0.5 && hyprpaper &"
            ];
            outputs = [
              { criteria = "eDP-1"; mode = "2560x1600"; position = "4000,1920"; scale = 1.0; }
              { criteria = "DP-3"; mode = "2560x1440"; position = "4000,480"; }
              { criteria = "DP-4"; mode = "2560x1440"; position = "2560,0"; transform = "270"; }
              { criteria = "DP-5"; mode = "2560x1440"; position = "0,485"; }
            ];
          };
        }
      ];

    };
  };
}
