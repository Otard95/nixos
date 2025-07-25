{ config, lib, theme, sources, ... }:
let
  cfg = config.modules.desktopEnvironment.hyprland.hyprlock;
  enable = cfg.enable;
in {
  options.modules.desktopEnvironment.hyprland.hyprlock = {
    enable = lib.mkEnableOption "hyprlock";

    bg-image = lib.mkOption {
      description = "Path to the background image to use";
      default = sources.images.background.falling-into-infinity;
      type = lib.types.path;
    };
  };

  config = lib.mkIf enable {
    catppuccin.hyprlock.enable = false;

    programs.hyprlock = {
      enable = true;

      settings = {
        background = [
          {
            path = "${cfg.bg-image}";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        input-field = [
          {
            size = "300, 45";
            position = "0, -80";
            dots_center = true;
            dots_fade_time = 80;
            fade_on_empty = false;
            font_color = "rgb(198, 208, 245)";
            inner_color = "rgb(65, 69, 89)";
            outer_color = "rgb(129, 200, 190)";
            check_color = "rgb(186, 187, 241)"; # color accent when waiting for the authentication result
            fail_color = "rgb(234, 153, 156)";
            capslock_color = "rgb(229, 200, 144)";
            outline_thickness = 3;
            placeholder_text = ''<span foreground="##c6d0f5"><i>󰌾 Logged in as </i><span foreground="##81c8be">$USER</span></span>'';
            shadow_passes = 2;
            shadow_color = "rgb(48, 52, 70)";
          }
        ];

        label = [
          {
            font_family = theme.font.regular.default;
            font_size = 64;
            halign = "center";
            valign = "center";
            position = "0, 100";
            text = "$TIME";
          }
          {
            font_family = theme.font.regular.default;
            font_size = 12;
            color = "rgb(165, 173, 206)";
            halign = "center";
            valign = "center";
            position = "0, 35";
            text = "cmd[update:99999] date '+%A %d. %B'";
          }
          {
            font_family = theme.font.regular.default;
            font_size = 8;
            color = "rgb(165, 173, 206)";
            halign = "center";
            valign = "center";
            position = "0, -135";
            text = "  $LAYOUT";
          }
        ];
      };
    };
  };
}
