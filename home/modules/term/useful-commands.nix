{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.useful-commands;
  enable = cfg.enable;
in {

  options.modules.term.useful-commands.enable = lib.mkEnableOption "generally useful-commands configuration";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      jq
      ripgrep
      unzip
    ];
  };

}
