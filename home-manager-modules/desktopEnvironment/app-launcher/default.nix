{ config, lib, helpers, ... }:
let
  cfg = config.modules.desktopEnvironment.app-launcher;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.app-launcher = {
    enable = lib.mkEnableOption "app launcher";
    launcher = lib.mkOption {
      default = "rofi";
      description = "Select a launcher to use";
      type = lib.types.enum [
        "rofi"
        "vicinae"
      ];
    };

    splash-image = helpers.mkOption.image "splash";
  };

  imports = [
    ./rofi.nix
    ./vicinae.nix
  ];

  config = lib.mkIf enable (lib.mkMerge [

    (lib.mkIf (cfg.launcher == "rofi") {
      modules.desktopEnvironment = {
        app-launcher.rofi = {
          enable = lib.mkDefault true;
          splash-image.path = cfg.splash-image;
        };

        keybinds = [
          { key = "d"; mods = [ "main" ];
            exec = "uwsm app -- rofi -show combi";
          }
          { key = "tab"; mods = [ "alt" ];
            exec = "uwsm app -- rofi -show window";
          }
          { key = "e"; mods = [ "ctrl" "shift" ];
            exec = "uwsm app -- rofi -show emoji";
          }
        ];
      };
    })

    (lib.mkIf (cfg.launcher == "vicinae") {
      modules.desktopEnvironment = {
        app-launcher.vicinae = {
          enable = lib.mkDefault true;
          splash-image.path = cfg.splash-image;
        };

        keybinds = [
          { key = "d"; mods = [ "main" ];
            exec = "uwsm app -- vicinae toggle";
          }
          # { key = "tab"; mods = [ "alt" ];
          #   exec = "uwsm app -- rofi -show window";
          # }
          # { key = "e"; mods = [ "ctrl" "shift" ];
          #   exec = "uwsm app -- rofi -show emoji";
          # }
        ];
      };
    })

  ]);

}
