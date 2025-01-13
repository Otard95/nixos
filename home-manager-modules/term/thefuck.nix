{ config, lib, ... }:
let
  cfg = config.modules.term.thefuck;
  enable = cfg.enable;
in {
  options.modules.term.thefuck.enable =
    lib.mkEnableOption "thefuck";

  config = lib.mkIf enable {
    programs.thefuck = {
      enable = true;
    };
  };
}
