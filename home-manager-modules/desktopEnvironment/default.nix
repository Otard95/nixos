{ config, lib, ... }:
let
  cfg = config.modules.desktopEnvironment;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment = let
    imageOption = name: lib.mkOption {
      description = "Path to the ${name} image to use";
      type = lib.types.path;
    };
  in {
    enable = lib.mkEnableOption "Desktop Environment";

    windowManager = lib.mkOption {
      default = "hyprland";
      description = "Select a WM to use";
      type = lib.types.enum [
        "hyprland"
      ];
    };

    background-image = imageOption "background";
    splash-image = imageOption "splash";
  };

  imports = [
    ./app-launcher
    ./hyprland
    ./power-menu
    ./theme
    ./mako.nix
  ];

  config = lib.mkIf enable {
    modules.desktopEnvironment = lib.mkMerge [
      {
        app-launcher = {
          enable = lib.mkDefault true;
          splash-image = cfg.splash-image;
        };
        power-menu = {
          enable = lib.mkDefault true;
          splash-image = cfg.splash-image;
        };
        theme.enable = lib.mkDefault true;
        mako.enable = lib.mkDefault true;
      }
      (lib.mkIf (cfg.windowManager == "hyprland") {
        hyprland = {
          enable = lib.mkDefault true;
          background-image = cfg.background-image;
        };
      })
    ];
  };
}
