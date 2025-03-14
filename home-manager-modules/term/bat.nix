{ config, lib, theme, ... }:
let
  cfg = config.modules.term.bat;
  enable = cfg.enable;
in {

  options.modules.term.bat.enable = lib.mkEnableOption "bat configuration";

  config = lib.mkIf enable {

    catppuccin.bat = {
      enable = true;
      flavor = theme.flavor;
    };

    programs.bat.enable = true;

  };

}
