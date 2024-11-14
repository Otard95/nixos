{ config, lib, ... }:
let
  cfg = config.modules.desktopEnvironment.hyprland;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.hyprland = {
    enable = lib.mkEnableOption "hyprland WM";
  };

  config = lib.mkIf enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    environment.sessionVariables = {
      # If cursor becomes invisible
      # WLR_NO_HARDWARE_CURSORS = "1";
      # Hint electron apps to use wayland
      NIXOS_OZONE_WL = "1";
    };
    security = {
      rtkit.enable = true;
      polkit.enable = true;
    };
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config = {
        common.default = ["hyprland"];
        hyprland.default = ["hyprland"];
      };
    };
  };
}
