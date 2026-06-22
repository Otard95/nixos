{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.devenv;
  enable = cfg.enable;
in {
  options.modules.term.devenv.enable =
    lib.mkEnableOption "devenv";

  config = lib.mkIf enable {

    environment.systemPackages = [
      pkgs.devenv
    ];

  };
}
