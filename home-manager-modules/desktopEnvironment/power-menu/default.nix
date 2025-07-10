{ config, lib, ... }:
let
  cfg = config.modules.desktopEnvironment.power-menu;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.power-menu = let
    imageOption = name: lib.mkOption {
      description = "Path to the ${name} image to use";
      type = lib.types.path;
    };
  in {
    enable = lib.mkEnableOption "power menu";
    launcher = lib.mkOption {
      default = "rofi";
      description = "Select a power menu to use";
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
      modules.desktopEnvironment.power-menu.rofi = {
        enable = lib.mkDefault true;
        splash-image.path = cfg.splash-image;
      };
    })
  ]);

}
