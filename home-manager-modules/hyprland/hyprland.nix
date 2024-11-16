{ config, lib, pkgs, ... }:
let
  cfg = config.modules.hyprland.wm;
  enable = cfg.enable;
in {

  options.modules.hyprland.wm.enable = lib.mkEnableOption "hyprland configuration";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      hyprcursor
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      catppuccin.enable = true;

      settings = {
        "$mod" = "SUPER";
        bind = [
          "$mod, RETURN, exec, kitty"
          "$mod+SHIFT, Q, killactive"
          "$mod, M, exit"
          "$mod, D, exec, rofi -show drun"
          "ALT, TAB, exec, rofi -show window"
          "$mod, F, togglefloating"
          "$mod, E, togglesplit"
          "$mod, W, togglegroup"
          "$mod+ALT, E, changegroupactive, f"
          "$mod+ALT, W, changegroupactive, f"
          "$mod, L, movefocus, r"
          "$mod, H, movefocus, l"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
        ] ++ (
          builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
               builtins.toString(x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString(x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString(x + 1)}"
            ]
          )
          10)
        );

        monitor = [
          "DP-4, 2560x1440, 0x0, 1"
          "DP-2, 2560x1440, 2560x0, 1"
        ];

        workspace = [
          "1, monitor:DP-4"
          "2, monitor:DP-2"
        ];

        windowrulev2 = [
          "float, class:(Rofi)"
          "stayfocused, class:(Rofi)"
        ];

        exec-once = [
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP" # https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580#editing-the-configuration-file
          "hyprpaper"
          "[workspace 1 silent] zen"
          "[workspace 2 silent] kitty"
        ];

        exec = [ "pkill waybar; sleep 0.5 && waybar" ];

        general = {
          gaps_in = 5;
          gaps_out = 15;
          border_size = 0;
        };

        decoration = {
          rounding = 10;

          drop_shadow = true;
          shadow_range = 8;
          shadow_render_power = 3;
          "col.shadow" = "$accent";
          "col.shadow_inactive" = "0xff$baseAlpha";

          blur = {
            noise = 0;
            size = 2;
            passes = 3;
          };
        };

        layerrule = [
          "blur, rofi"
          "blur, notifications"
          "ignorezero, notifications"
        ];

        animations = {
          enabled = true;

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

          animation = [
            "windows, 1, 4, myBezier"
            "windowsOut, 1, 4, default"
            "border, 1, 5, default"
            "fade, 1, 4, default"
            "workspaces, 1, 3, default"
          ];
        };

        input = {
          kb_layout = "us,no";
          kb_options = "grp:alt_space_toggle";
          repeat_rate = 45;
          repeat_delay = 180;
        };
      };

      # Nvidia
      extraConfig = ''
      env = LIBVA_DRIVER_NAME,nvidia
      env = XDG_SESSION_TYPE,wayland
      env = GBM_BACKEND,nvidia-drm
      env = __GLX_VENDOR_LIBRARY_NAME,nvidia

      cursor {
        no_hardware_cursors = true
        # allow_dumb_copy = true
      }
      '';
    };
  };
}
