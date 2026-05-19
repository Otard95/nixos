{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktopEnvironment.hyprland;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.hyprland = {
    enable = lib.mkEnableOption "hyprland WM";
  };

  config = lib.mkIf enable {

    programs = {
      hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };
      hyprlock.enable = true;
    };

    # To manage displays with GUI
    environment.systemPackages = [ pkgs.wdisplays ];

    environment.sessionVariables = {
      # If cursor becomes invisible
      # WLR_NO_HARDWARE_CURSORS = "1";
      # Hint electron apps to use wayland
      NIXOS_OZONE_WL = "1";
    };

    # TODO: Move to own module???
    security = {
      rtkit.enable = true;
      polkit.enable = true;
    };

    # TODO: Move to home??? Or own module???
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      configPackages = with pkgs; [
        hyprland
        xdg-desktop-portal-gtk
      ];
      config.hyprland = {
        default = [ "hyprland" "gtk" ];
      };
    };

    # TODO: Make option in sound module?
    services.pipewire.wireplumber.enable = true;

    systemd.user.services.hyprpolkitagent = {
      description = "hyprpolkitagent";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

  };

}
