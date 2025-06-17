{ config, lib, ... }:
let
  cfg = config.modules.term.pay-respects;
  enable = cfg.enable;
in {
  options.modules.term.pay-respects.enable =
    lib.mkEnableOption "pay-respects";

  config = lib.mkIf enable {

    programs.pay-respects = {
      enable = true;
      enableBashIntegration = true;
    };

  };
}
