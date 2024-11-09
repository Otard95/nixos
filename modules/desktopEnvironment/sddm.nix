{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktopEnvironment.sddm;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.sddm = {
    enable = lib.mkEnableOption "sddm";
  };

  config = lib.mkIf enable {
    services.displayManager.sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;
      wayland.enable = true;
    };
  };
}
