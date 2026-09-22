{ config, lib, ... }:
let
  cfg = config.modules.packages.apps.localsend;
  enable = cfg.enable;
in {
  options.modules.packages.apps.localsend.enable =
    lib.mkEnableOption "localsend";

  config = lib.mkIf enable {
    programs.localsend.enable = true;
  };
}
