{ config, lib, ... }:
let
  cfg = config.modules.desktopEnvironment.hyprland.kanshi;
  enable = cfg.enable;
in {
  options.modules.desktopEnvironment.hyprland.kanshi.enable =
    lib.mkEnableOption "kanshi";

  config = lib.mkIf enable {
    services.kanshi = {
      enable = true;

      systemdTarget = "wayland-session@Hyprland.target";

      settings = [
        {
          profile = {
            name = "undocked";
            exec = [ "${./scripts/kanshi-undocked.sh}" ];
            outputs = [
              { criteria = "eDP-1"; status = "enable"; position = "0,0"; scale = 1.0; } # mode = "1920x1200"; mode = "2560x1600";
            ];
          };
        }
        {
          profile = {
            name = "docked-phobos";
            exec = [ "${./scripts/kanshi-docked-phobos.sh}" ];
            outputs = [
              { criteria = "eDP-1"; status = "disable"; } #  mode = "2560x1600"; position = "5440,960"; scale = 1.0;
              { criteria = "DP-3"; mode = "2560x1440"; position = "4000,0"; transform = "270"; }
              { criteria = "DP-4"; mode = "2560x1440"; position = "2560,0"; transform = "90"; }
              { criteria = "DP-5"; mode = "2560x1440"; position = "0,485"; }
            ];
          };
        }
        {
          profile = {
            name = "docked-deimos";
            exec = [ "${./scripts/kanshi-docked-deimos.sh}" ];
            outputs = [
              { criteria = "eDP-1"; status = "disable"; } #  mode = "2560x1600"; position = "5440,960"; scale = 1.0;
              { criteria = "DP-7"; mode = "2560x1440"; position = "4000,0"; transform = "270"; }
              { criteria = "DP-9"; mode = "2560x1440"; position = "2560,0"; transform = "90"; }
              { criteria = "HDMI-A-1"; mode = "2560x1440"; position = "0,485"; }
            ];
          };
        }
      ];

    };

    modules.desktopEnvironment.keybinds = [
      {
        key = "F5";
        mods = [ "super" "shift" ];
        inLock = true;
        exec = "systemctl --user restart kanshi.service";
      }
    ];

  };
}
