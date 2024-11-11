{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.fzf;
  enable = cfg.enable;
in {

  options.modules.term.fzf.enable = lib.mkEnableOption "fzf configuration";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      fzf
    ];

    programs.fzf = {
      enable = true;
      tmux.enableShellIntegration = true;
    };
  };

}
