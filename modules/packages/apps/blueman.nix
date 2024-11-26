{ config, lib, ... }:
let
  cfg = config.modules.packages.apps.blueman;
  enable = cfg.enable && config.modules.system.bluetooth.enable;
in {
  options.modules.packages.apps.blueman.enable = lib.mkEnableOption "blueman";

  config = lib.mkIf enable {
    services.blueman.enable = true;
  };
}
