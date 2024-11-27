{ config, lib, ... }:
let
  cfg = config.modules.packages.apps.kdeconnect;
  enable = cfg.enable;
in {
  options.modules.packages.apps.kdeconnect.enable =
    lib.mkEnableOption "kdeconnect";

  config = lib.mkIf enable {
    programs.kdeconnect.enable = true;
  };
}
