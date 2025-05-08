{ config, lib, pkgs, ... }:
let
  cfg = config.modules.hyprland.wm;
  enable = cfg.enable;
in {

  options.modules.hyprland.wm = {
    enable = lib.mkEnableOption "hyprland configuration";
    disable-sync = lib.mkOption {
      description = "Disable explicit_sync. Games may require this";
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      hyprcursor
    ];

    modules.term.wezterm.enable = lib.mkDefault true;

    catppuccin.hyprland.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;

      settings = {
        "$mod" = "SUPER";
        bind = [
          "$mod, RETURN, exec, uwsm app -- wezterm"
          "$mod+SHIFT, Q, killactive"
          "$mod+SHIFT+CTRL, M, exec, uwsm stop"
          "$mod+SHIFT, P,   exec, uwsm app -- ~/.config/power-menu.sh"
          "$mod,       D,   exec, uwsm app -- rofi -show combi"
          "ALT,        TAB, exec, uwsm app -- rofi -show window"
          "CTRL+SHIFT, E,   exec, uwsm app -- rofi -show emoji"
          "$mod+SHIFT, SPACE, togglefloating"
          "$mod, SPACE, cyclenext, floating"
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
          "$mod+SHIFT, S, exec, uwsm app -- grimblast edit area"
          "$mod+ALT, S, exec, uwsm app -- grimblast edit active"
          "$mod+CTRL, S, exec, uwsm app -- grimblast edit output"
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

          ", switch:Lid Switch, exec, uwsm app -- hyprlock"
        ];

        env = [
        ];

        windowrule = [
          # Rofi
          "float,       class:(Rofi)"
          "stayfocused, class:(Rofi)"
          # Zen Browser
          "float,               class:(zen), title:(Extension)"
          "float,               initialTitle:(^Picture-in-Picture$)"
          "size 944 530,        initialTitle:(^Picture-in-Picture$)"
          "float,               initialTitle:(^File Operation Progress$)"
          "size 500 200,        initialTitle:(^File Operation Progress$)"
          "opacity 0.95 0.95 1, class:(zen)"
          # Vivaldi Browser
          "opacity 0.95, class:(vivaldi-stable)"
          "float,        initialTitle:(^$), initialClass:(^$)"
          "move 50% 10,   initialTitle:(^$), initialClass:(^$)"
          "pin,          initialTitle:(^$), initialClass:(^$)"
          # Wine
          "move 50% 20, initialTitle:(Wine System Tray)"
          "pin,         initialTitle:(Wine System Tray)"
          # Gnome Clocks
          "float, class:(org.gnome.clocks)"
        ];

        exec-once = [
          # https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580#editing-the-configuration-file
          "uwsm app -- dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "uwsm app -- hyprpaper"
          "uwsm app -- kanshi"
          "[workspace 1 silent] uwsm app -- zen"
          "[workspace 2 silent] uwsm app -- wezterm"
        ];

        exec = [ "pkill waybar; sleep 0.5 && uwsm app -- waybar" ];

        general = {
          gaps_in = 5;
          gaps_out = 15;
          border_size = 0;
        };

        render = lib.mkIf cfg.disable-sync {
          explicit_sync = 0;
          explicit_sync_kms = 0;
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
            noise = 0;
            size = 2;
            passes = 3;
            ignore_opacity = true;
          };
        };

        group = {
          groupbar = {
            "col.active" = "0xbb51576d";
            "col.inactive" = "0xbb232634";
            "col.locked_active" = "0xbbaa576d";
            "col.locked_inactive" = "0xbb992634";
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
          repeat_rate = 50;
          repeat_delay = 160;
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
      }
      '';
    };

    xdg.configFile."hypr/xdph.conf".text = ''
      screencopy {
        allow_token_by_default = true
      }
    '';
    xdg.configFile."uwsm/env".text = ''
      export LIBVA_DRIVER_NAME=nvidia
      export XDG_SESSION_TYPE=wayland
      export GBM_BACKEND=nvidia-drm
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export SLURP_ARGS=-d -b 16897a44 -c 04d6c8 -B 0e999e22
      export GRIMBLAST_EDITOR=pinta
    '';
    # xdg.configFile."uwsm/env-hyprland".text = ''
    #   export AQ_DRM_DEVICES=/dev/dri/card0:/dev/dri/card1
    # '';

  };
}
