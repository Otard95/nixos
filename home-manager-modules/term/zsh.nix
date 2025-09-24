{ config, lib, pkgs, ... }:
let
  cfg = config.modules.term.zsh;
  enable = cfg.enable;
in {
  options.modules.term.zsh.enable =
    lib.mkEnableOption "zsh";

  config = lib.mkIf enable {
    programs.zsh = {
      enable = true;

      defaultKeymap = "viins";
      history.ignoreAllDups = true;

      shellAliases = {
        ls = "${pkgs.eza}/bin/eza";
        ll = "${pkgs.eza}/bin/eza -lah --git --icons";
        ".." = "cd ..";
      };

      initContent = ''
        bindkey -v '^?' backward-delete-char
        bindkey -r '^H'
        bindkey -r '^J'
        bindkey -r '^K'
        bindkey -r '^L'
      '';
    };
  };
}
