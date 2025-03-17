{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktopEnvironment.sddm;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.sddm = {
    enable = lib.mkEnableOption "sddm";

    background = lib.mkOption {
      description = "The background for the login screen";
      type = with lib.types; either str path;
      default = "";
    };
  };

  config = lib.mkIf enable {

    environment.systemPackages = [
      (pkgs.sddm-astronaut.override {
        themeConfig = if (cfg.background != "") then {
          Background = "${cfg.background}";
        } else null;
        # embeddedTheme = "pixel_sakura";
      })
    ];

    catppuccin.sddm = {
      enable = false;
      assertQt6Sddm = true;
    };

    services.displayManager.sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;
      wayland.enable = true;
      theme = "sddm-astronaut-theme";
      extraPackages = with pkgs.kdePackages; [
        qtmultimedia
        qtsvg
        qtvirtualkeyboard
      ];
    };

  };
}
