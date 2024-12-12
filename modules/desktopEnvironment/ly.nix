{ config, lib, ... }:
let
  cfg = config.modules.desktopEnvironment.ly;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.ly = {
    enable = lib.mkEnableOption "ly";
  };

  config = lib.mkIf enable {
    services.displayManager.ly = {
      enable = true;
    };
  };
}
