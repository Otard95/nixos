{ config, lib, pkgs, ... }:
let
  cfg = config.modules.packages.apps.firefox;
  enable = cfg.enable;
in {
  options.modules.packages.apps.firefox.enable = lib.mkEnableOption "firefox";

  config = lib.mkIf enable {
    environment = {
      systemPackages = with pkgs; [ firefox ];
      sessionVariables.MOZ_USE_XINPUT2 = "1";
    };
  };
}
