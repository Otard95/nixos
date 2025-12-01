{ config, lib, ... }:
let
  cfg = config.modules.system.hardware;
  enable = cfg.enable;
in {
  options.modules.system.hardware = {
    enable = lib.mkEnableOption "hardware";
    logitech.enable = lib.mkEnableOption "logitech";
  };

  config = lib.mkIf enable {
    hardware.logitech.wireless.enable = cfg.logitech.enable;
  };
}
