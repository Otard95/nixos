{ config, lib, helpers, ... }:
let
  cfg = config.modules.desktopEnvironment.power-menu;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.power-menu = {
    enable = lib.mkEnableOption "power menu";
    launcher = lib.mkOption {
      default = "rofi";
      description = "Select a power menu to use";
      type = lib.types.enum [
        "rofi"
      ];
    };

    splash-image = helpers.mkOption.image "splash";
  };

  imports = [
    ./rofi.nix
  ];

  config = lib.mkIf enable (lib.mkMerge [

    (lib.mkIf (cfg.launcher == "rofi") {
      modules.desktopEnvironment = {
        power-menu.rofi = {
          enable = lib.mkDefault true;
          splash-image.path = cfg.splash-image;
        };

        keybinds = [
          { key = "p"; mods = [ "super" "shift" ];
            exec = "uwsm app -- ~/.config/power-menu.sh";
          }
        ];
      };
    })

  ]);

}
