{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.term.aven;
  enable = cfg.enable;
in {
  options.modules.term.aven.enable =
    lib.mkEnableOption "aven";

  config = lib.mkIf enable {

    home.packages = [ inputs.aven.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  };
}
