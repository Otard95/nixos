{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktopEnvironment.hyprland.wm;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.hyprland.wm = {
    enable = lib.mkEnableOption "hyprland configuration";
  };

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      hyprcursor
    ];

    catppuccin.hyprland.enable = true;

    modules.desktopEnvironment.uwsm = {
      enable = true;

      envs = [
        { name = "WLR_NO_HARDWARE_CURSORS"; value = "1"; }
        { name = "SLURP_ARGS";              value = "-d -b 16897a44 -c 04d6c8 -B 0e999e22"; }
        { name = "GRIMBLAST_EDITOR";        value = "pinta"; }
      ];
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;

      settings = {
        "$mod" = "SUPER";
        bind = [
          "$mod, RETURN, exec, uwsm app -- ${config.modules.term.defaultTerminal}"
          "$mod+SHIFT, Q, killactive"
          "$mod+SHIFT+CTRL, M, exec, uwsm stop"
          "$mod+SHIFT, SPACE, togglefloating"
          "$mod, SPACE, cyclenext, floating"
          "$mod, BACKSPACE, cyclenext, tiled"
          "$mod+SHIFT, F, fullscreen, 0"
          "$mod, E, togglesplit"
          "$mod, W, togglegroup"
          "$mod+ALT, E, changegroupactive, f"
          "$mod+ALT, W, changegroupactive, f"
          "$mod, L, movefocus, r"
          "$mod, H, movefocus, l"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod+ALT, L, changegroupactive, f"
          "$mod+ALT, H, changegroupactive, b"
          "$mod+SHIFT, L, movewindoworgroup, r"
          "$mod+SHIFT, H, movewindoworgroup, l"
          "$mod+SHIFT, K, movewindoworgroup, u"
          "$mod+SHIFT, J, movewindoworgroup, d"
          "$mod+ALT+SHIFT, L, movegroupwindow, f"
          "$mod+ALT+SHIFT, H, movegroupwindow, b"
          # Screenshot
          # "$mod+SHIFT, S, exec, uwsm app -- grimblast edit area"
          # "$mod+ALT, S, exec, uwsm app -- grimblast edit active"
          # "$mod+CTRL, S, exec, uwsm app -- grimblast edit output"
          # Convert unix timestamp
          "$mod+CTRL, D, exec, ${pkgs.wl-clipboard}/bin/wl-paste --primary | xargs -I {} date -d @{} | xargs -I {} notify-send '{}'; ${pkgs.wl-clipboard}/bin/wl-paste | xargs -I {} date -d @{} | xargs -I {} notify-send '{}'"
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
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        bindel = [
          ", XF86AudioRaiseVolume, exec, uwsm app -- wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, uwsm app -- wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ];
        bindl = [
          ", XF86AudioMute, exec, uwsm app -- wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioPlay, exec, uwsm app -- playerctl play-pause"
          ", XF86AudioPrev, exec, uwsm app -- playerctl previous"
          ", XF86AudioNext, exec, uwsm app -- playerctl next"

          # ", switch:Lid Switch, exec, uwsm app -- hyprlock"
        ];

        #   TODO: Port this to some equivalent to `modules.desktopEnvironment.keybinds`
        windowrule = [
          # TEMP: ed-discovery
          "match:initial_title ed-expedition, float on"
          # Rofi
          "match:class Rofi, float on"
          "match:class Rofi, stay_focused on"
          # Zen Browser
          "match:class zen, match:title Extension, float on"
          "match:initial_title ^Picture-in-Picture$, float on"
          "match:initial_title ^Picture-in-Picture$, size 944 530"
          "match:initial_title ^File Operation Progress$, float on"
          "match:initial_title ^File Operation Progress$, size 500 200"
          # "match:class zen, opacity 0.95 0.95 1"
          # Wine
          "match:initial_title Wine System Tray, move 50% 20"
          "match:initial_title Wine System Tray, pin on"
          # Gnome Clocks
          "match:class org.gnome.clocks, float on"
          # Flameshot
          "match:initial_title Upload image, float on"
          "match:initial_title Configuration, float on"
          "match:initial_title Capture Launcher, float on"
          "match:initial_title Save screenshot, float on"
        ];

        #   TODO: Port this to some equivalent to `modules.desktopEnvironment.keybinds`
        exec-once = [
          # https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580#editing-the-configuration-file
          "uwsm app -- dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          # "uwsm app -- hyprpaper"
          "uwsm app -- kanshi"
          "[workspace 1 silent] uwsm app -- zen"
          "[workspace 2 silent] uwsm app -- ${config.modules.term.defaultTerminal}"
        ];

        #   TODO: Port this to some equivalent to `modules.desktopEnvironment.keybinds`
        exec = [ "pkill waybar; sleep 0.5 && uwsm app -- waybar" ];

        general = {
          gaps_in = 5;
          gaps_out = 15;
          border_size = 0;
        };

        decoration = {
          rounding = 10;

          shadow =  {
            enabled = true;
            range = 8;
            render_power = 3;
            color = "$accent";
            color_inactive = "0xff$mantleAlpha";
          };

          blur = {
            enabled = false;
            noise = 0;
            size = 2;
            passes = 3;
            ignore_opacity = true;
          };
        };

        opengl = {
          nvidia_anti_flicker = false;
        };

        group = {
          groupbar = {
            "col.active" = "0xbb51576d";
            "col.inactive" = "0xbb232634";
            "col.locked_active" = "0xbbaa576d";
            "col.locked_inactive" = "0xbb992634";
          };
        };

        # layerrule = [
        #   "blur, rofi"
        #   "blur, notifications"
        #   "ignorezero, notifications"
        # ];

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
          repeat_rate = 50;
          repeat_delay = 160;
        };

        misc = {
          # https://github.com/hyprwm/Hyprland/discussions/11616
          # https://github.com/hyprwm/Hyprland/issues/9452
          # https://github.com/hyprwm/Hyprland/issues/10514
          enable_anr_dialog = false;
          middle_click_paste = false;
        };
      };

      extraConfig = ''
      # Notification binds
      bindr = $mod, N, submap, notifications
      submap = notifications

      bindr = $mod, C, exec, uwsm app -- makoctl dismiss
      bindr = $mod, A, exec, uwsm app -- makoctl invoke && makoctl dismiss
      bindr = $mod, H, exec, uwsm app -- makoctl restore

      # Exit notification submap
      bindr = $mod, N, submap, reset
      bindr = , catchall, submap, reset
      submap = reset

      cursor {
        no_hardware_cursors = true
        # allow_dumb_copy = true
        # sync_gsettings_theme = false
      }
      '';
    };

    xdg.configFile."hypr/xdph.conf".text = ''
      screencopy {
        allow_token_by_default = true
      }
    '';

  };
}
