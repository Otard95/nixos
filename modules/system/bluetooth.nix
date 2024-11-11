{ config, lib, ... }:
let
  cfg = config.modules.system.bluetooth;
  enable = cfg.enable;
in {

  options.modules.system.bluetooth.enable = lib.mkEnableOption "bluetooth";

  config = lib.mkIf enable {
    hardware.bluetooth.enable = true;
  };
}
