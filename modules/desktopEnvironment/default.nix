{ config, lib, ... }:
let
  cfg = config.modules.desktopEnvironment;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.enable = lib.mkEnableOption "desktop environment";

  imports = [
    ./hyprland.nix
  ];

  config = lib.mkIf enable {
    modules.desktopEnvironment.hyprland.enable = lib.mkDefault true;
  };
}
