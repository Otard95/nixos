{ config, lib, ... }:
let
  cfg = config.modules.hyprland.kanshi;
  enable = cfg.enable;
in {
  options.modules.hyprland.kanshi.enable =
    lib.mkEnableOption "kanshi";

  config = lib.mkIf enable (lib.mkMerge [
    {
      services.kanshi = {
        enable = true;

        systemdTarget = "wayland-session@Hyprland.target";

        settings = [
          {
            profile = {
              name = "undocked";
              exec = [ "${./scripts/kanshi-undocked.sh}" ];
              outputs = [
                { criteria = "eDP-1"; status = "enable"; position = "0,0"; mode = "2560x1600"; scale = 1.0; }
              ];
            };
          }
          {
            profile = {
              name = "docked";
              exec = [ "${./scripts/kanshi-docked.sh}" ];
              outputs = [
                { criteria = "eDP-1"; status = "disable"; } #  mode = "2560x1600"; position = "5440,960"; scale = 1.0;
                { criteria = "DP-3"; mode = "2560x1440"; position = "4000,0"; transform = "270"; }
                { criteria = "DP-4"; mode = "2560x1440"; position = "2560,0"; transform = "90"; }
                { criteria = "DP-5"; mode = "2560x1440"; position = "0,485"; }
              ];
            };
          }
        ];

      };

    }
    (lib.mkIf config.modules.hyprland.wm.enable {

      wayland.windowManager.hyprland.settings.bindl = [
        "$mod+SHIFT, F5, exec, systemctl --user restart kanshi.service"
      ];

    })
  ]);
}
