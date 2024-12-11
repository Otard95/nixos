{ config, lib, ... }:
let
  cfg = config.modules.packages.apps.appgate;
  enable = cfg.enable;
in {
  options.modules.packages.apps.appgate.enable =
    lib.mkEnableOption "appgate";

  config = lib.mkIf enable {
    programs.appgate-sdp.enable = true;
  };
}
