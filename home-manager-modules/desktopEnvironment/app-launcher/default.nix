{ config, lib, ... }:
let
  cfg = config.modules.desktopEnvironment.app-launcher;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.app-launcher = let
    imageOption = name: lib.mkOption {
      description = "Path to the ${name} image to use";
      type = lib.types.path;
    };
  in {
    enable = lib.mkEnableOption "app launcher";
    launcher = lib.mkOption {
      default = "rofi";
      description = "Select a launcher to use";
      type = lib.types.enum [
        "rofi"
      ];
    };

    splash-image = imageOption "splash";
  };

  imports = [
    ./rofi.nix
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

  ]);

}
