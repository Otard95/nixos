{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.term.workmux;
  enable = cfg.enable;
in {
  options.modules.term.workmux.enable =
    lib.mkEnableOption "workmux";

  config = lib.mkIf enable {

    home.packages = [ inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  };
}
