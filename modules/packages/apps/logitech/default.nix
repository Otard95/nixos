{ config, lib, ... }:
let
  cfg = config.modules.packages.apps.logitech;
  enable = cfg.enable;
in {
  options.modules.packages.apps.logitech = {
    enable = lib.mkEnableOption "logitech apps";

    solaar.enable = lib.mkEnableOption "solaar" // { default = true; };
  };

  imports = [
    ./logiops.nix
  ];

  config = lib.mkIf enable {
    modules.system.hardware.logitech.enable = true;

    hardware.logitech.wireless.enableGraphical = cfg.solaar.enable;
  };
}
