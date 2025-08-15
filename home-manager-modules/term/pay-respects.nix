{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.pay-respects;
  enable = cfg.enable;
in {
  options.modules.term.pay-respects.enable =
    lib.mkEnableOption "pay-respects";

  config = lib.mkIf enable {

    home.packages = [ pkgs.nix-index ];

    programs.pay-respects = {
      enable = true;
      enableBashIntegration = true;
    };

  };
}
