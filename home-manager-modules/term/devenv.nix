{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.devenv;
  enable = cfg.enable;
in {
  options.modules.term.devenv.enable =
    lib.mkEnableOption "devenv";

  config = lib.mkIf enable {

    home.packages = [
      pkgs.devenv
    ];

    programs.bash.bashrcExtra = ''
      eval "$(devenv hook bash)"
    '';

  };
}
