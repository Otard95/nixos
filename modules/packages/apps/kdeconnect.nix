{ config, lib, ... }:
let
  cfg = config.modules.programs.apps.kdeconnect;
  enable = cfg.enable;
in {
  options.modules.programs.apps.kdeconnect.enable =
    lib.mkEnableOption "kdeconnect";

  config = lib.mkIf enable {
    programs.kdeconnect.enable = true;
  };
}
