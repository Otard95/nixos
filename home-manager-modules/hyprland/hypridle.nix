{ config, lib, pkgs, ... }:
let
  cfg = config.modules.hyprland.hypridle;
  enable = cfg.enable;
in {
  options.modules.hyprland.hypridle.enable =
    lib.mkEnableOption "name";

  config = lib.mkIf enable {
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";      # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session";   # lock before suspend.
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };

        listener = [
          { # brightness/warn idle
            timeout = 90; # 1.5min
            on-timeout = builtins.concatStringsSep " ; " [
              "${pkgs.brightnessctl}/bin/brightnessctl -s set 10"
              "${pkgs.libnotify}/bin/notify-send -pu critical 'You are idle' 'Locking in 1min' > /var/tmp/idle-notification"
            ];
            on-resume = builtins.concatStringsSep " ; " [
              "${pkgs.brightnessctl}/bin/brightnessctl -r"
              "${pkgs.libnotify}/bin/notify-send -t 3000 --replace-id $(cat /var/tmp/idle-notification) 'You are now active'"
            ];
          }

          # { # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
          #   timeout = 150;                                              # 2.5min.
          #   on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd rgb:kbd_backlight set 0";   # turn off keyboard backlight.
          #   on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd rgb:kbd_backlight";          # turn on keyboard backlight.
          # }

          {
            timeout = 150; # 2.5min
            on-timeout = "loginctl lock-session";
          }

          { # screen off/on on timeout/reset
            timeout = 180; # 3min
            on-timeout = "hyprctl dispatch dpms off"; 
            on-resume = "hyprctl dispatch dpms on && ${pkgs.brightnessctl}/bin/brightnessctl -r";
          }

          {
            timeout = 960; # 15min
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
