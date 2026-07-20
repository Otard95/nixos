{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.term.fzf;
  enable = cfg.enable;
in {

  options.modules.term.fzf.enable = lib.mkEnableOption "fzf configuration";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      fzf
    ];

    catppuccin.fzf = {
      # Until it supports `accent` again
      enable = false;
      flavor = theme.flavor;
      # accent = theme.accent;
    };

    programs.fzf = {
      enable = true;
      tmux.enableShellIntegration = true;
      # Until `catppuccin.fzf` supports `accent` again
      colors = {
        bg         = "#303446";
        "bg+"      = "#414559";
        "selected-bg" = "#51576d";
        fg         = "#c6d0f5";
        "fg+"      = "#c6d0f5";
        hl         = "#81c8be";
        "hl+"      = "#81c8be";
        header     = "#81c8be";
        info       = "#ca9ee6";
        prompt     = "#ca9ee6";
        pointer    = "#f2d5cf";
        spinner    = "#f2d5cf";
        marker     = "#babbf1";
        border     = "#737994";
        label      = "#c6d0f5";
      };
    };
  };

}
