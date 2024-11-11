{ config, lib, ... }:
let
  cfg = config.modules.desktopEnvironment;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.enable = lib.mkEnableOption "Desktop Environment";
  options.modules.desktopEnvironment.windowManager = lib.mkOption {
    default = "hyprland";
    description = "Select a WM to use";
    type = lib.types.enum [
      "hyprland"
    ];
  };
  options.modules.desktopEnvironment.displayManager = lib.mkOption {
    default = "sddm";
    description = "Select a DM to use";
    type = lib.types.enum [
      "sddm"
    ];
  };

  imports = [
    ./hyprland.nix
    ./sddm.nix
  ];

  config = lib.mkIf enable {
    modules.desktopEnvironment.hyprland.enable =
      lib.mkDefault (cfg.windowManager == "hyprland");

    modules.desktopEnvironment.sddm.enable =
      lib.mkDefault (cfg.displayManager == "sddm");

    modules.system.graphics.enable = lib.mkDefault true;
    modules.system.sound.enable = lib.mkDefault true;

    modules.packages.notification.enable = lib.mkDefault true;
  };
}
