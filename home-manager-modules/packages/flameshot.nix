{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.flameshot;
  enable = cfg.enable;
in {
  options.modules.packages.flameshot = {
    enable = lib.mkEnableOption "flameshot";
    package = lib.mkPackageOption pkgs "flameshot" {} // {
      default = pkgs.flameshot.override { enableWlrSupport = true; };
    };
  };

  config = lib.mkIf enable {
    services.flameshot = {
      enable = true;
      package = cfg.package;

      settings = {
        General = {
          disabledGrimWarning = true;
          useGrimAdapter = true;
        };
      };
    };

    modules.desktopEnvironment.keybinds = let
      # Flameshot doesn't work properly:
      #   GitHub Issue: https://github.com/flameshot-org/flameshot/issues/2978#issuecomment-2283569630
      flameshot-wrapper = pkgs.writeShellScript "flameshot-wrapper" ''
        if command -v hyprctl &>/dev/null; then
          read -r monitor move_x move_y width height < <(
            hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '
              map(. + {
                eff_w: (if .transform % 2 != 0 then .height else .width end),
                eff_h: (if .transform % 2 != 0 then .width else .height end)
              })
              | (map(.x) | min) as $min_x
              | (map(.y) | min) as $min_y
              | (map(.x + .eff_w) | max) as $max_x
              | (map(.y + .eff_h) | max) as $max_y
              | (sort_by(.x, .y) | first) as $anchor
              | "\($anchor.name) \($min_x - $anchor.x) \($min_y - $anchor.y) \($max_x - $min_x) \($max_y - $min_y)"
            '
          )
          hyprctl --batch "
            keyword windowrule[flameshot]:monitor $monitor;
            keyword windowrule[flameshot]:move $move_x $move_y;
            keyword windowrule[flameshot]:size $width $height;
            keyword windowrule[flameshot]:match:initial_title flameshot;
            keyword windowrule[flameshot]:pin on;
            keyword windowrule[flameshot]:float on;
            keyword windowrule[flameshot]:rounding 0;
            keyword windowrule[flameshot]:border_size 0;
            keyword windowrule[flameshot]:stay_focused on;
            keyword windowrule[flameshot]:suppress_event fullscreen
          "
        fi
        ${cfg.package}/bin/flameshot "$@"
      '';
    in [
      { key = "s"; mods = [ "main" "shift" ];
        # exec = "uwsm app -- ${flameshot-wrapper} gui -r | ${pkgs.wl-clipboard}/bin/wl-copy";
        exec = "uwsm app -- ${flameshot-wrapper} gui";
        # exec = "uwsm app -- flameshot gui -r | ${pkgs.wl-clipboard}/bin/wl-copy";
      }
    ];
  };
}

