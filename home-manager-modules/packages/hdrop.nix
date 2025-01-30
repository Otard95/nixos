{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.hdrop;
  enable = cfg.enable;
in {
  options.modules.packages.hdrop = {
    enable = lib.mkEnableOption "hdrop";
  };

  config = lib.mkIf enable (lib.mkMerge [
    {
      assertions = [
        { assertion = config.modules.hyprland.wm.enable;
          message = "hdrop only work in a hyprland session";
        }
      ];
      # home.packages = with pkgs; [ hdrop ];
      # TODO: Make PR? Remake in go? Use pixels?
      home.file."scripts/hdrop" = {
        executable = true;
        source = ./hdrop.sh;
      };
      home.shellAliases.hdrop = "/home/otard/scripts/hdrop";
    }

    (lib.mkIf config.modules.term.kitty.enable {
      wayland.windowManager.hyprland.settings.bind = [
        "ALT, Q, exec, uwsm app -- /home/otard/scripts/hdrop -f -w 99 -g 61 -c kitty_hdrop 'kitty --class kitty_hdrop'"
      ];
      wayland.windowManager.hyprland.settings.exec-once = [
        "uwsm app -- /home/otard/scripts/hdrop -b -f -c kitty_hdrop 'kitty --class kitty_hdrop'"
      ];
      wayland.windowManager.hyprland.settings.windowrulev2 = [
        "float, class:(kitty_hdrop)"
      ];
    })
  ]);
}
