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
              "hyprctl keyword workspace 1,monitor:eDP-1"
              "hyprctl keyword workspace 2,monitor:eDP-1"
              "hyprctl keyword workspace 3,monitor:eDP-1"
              "hyprctl keyword workspace 4,monitor:eDP-1"
              "hyprctl keyword workspace 5,monitor:eDP-1"
              "hyprctl keyword workspace 6,monitor:eDP-1"
              "hyprctl keyword workspace 7,monitor:eDP-1"
              "hyprctl keyword workspace 8,monitor:eDP-1"
              "hyprctl keyword workspace 9,monitor:eDP-1"
              "hyprctl keyword workspace 10,monitor:eDP-1"
              "hyprctl dispatch moveworkspacetomonitor 1 eDP-1"
              "hyprctl dispatch moveworkspacetomonitor 2 eDP-1"
              "hyprctl dispatch moveworkspacetomonitor 3 eDP-1"
              "hyprctl dispatch moveworkspacetomonitor 4 eDP-1"
              "hyprctl dispatch moveworkspacetomonitor 5 eDP-1"
              "hyprctl dispatch moveworkspacetomonitor 6 eDP-1"
              "hyprctl dispatch moveworkspacetomonitor 7 eDP-1"
              "hyprctl dispatch moveworkspacetomonitor 8 eDP-1"
              "hyprctl dispatch moveworkspacetomonitor 9 eDP-1"
              "hyprctl dispatch moveworkspacetomonitor 10 eDP-1"
              "pkill hyprpaper ; sleep 0.5 && nohup hyprpaper &> /dev/null &"
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
              "hyprctl keyword workspace 1,monitor:DP-5"
              "hyprctl keyword workspace 2,monitor:DP-4"
              "hyprctl keyword workspace 3,monitor:DP-3"
              "hyprctl keyword workspace 4,monitor:DP-5"
              "hyprctl keyword workspace 5,monitor:DP-4"
              "hyprctl keyword workspace 6,monitor:DP-3"
              "hyprctl keyword workspace 7,monitor:DP-5"
              "hyprctl keyword workspace 8,monitor:DP-4"
              "hyprctl keyword workspace 9,monitor:DP-3"
              "hyprctl keyword workspace 10,monitor:eDP-1"
              "hyprctl dispatch moveworkspacetomonitor 1 DP-5"
              "hyprctl dispatch moveworkspacetomonitor 2 DP-4"
              "hyprctl dispatch moveworkspacetomonitor 3 DP-3"
              "hyprctl dispatch moveworkspacetomonitor 4 DP-5"
              "hyprctl dispatch moveworkspacetomonitor 5 DP-4"
              "hyprctl dispatch moveworkspacetomonitor 6 DP-3"
              "hyprctl dispatch moveworkspacetomonitor 7 DP-5"
              "hyprctl dispatch moveworkspacetomonitor 8 DP-4"
              "hyprctl dispatch moveworkspacetomonitor 9 DP-3"
              "hyprctl dispatch moveworkspacetomonitor 10 eDP-1"
              "pkill hyprpaper ; sleep 0.5 && nohup hyprpaper &> /dev/null &"
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
