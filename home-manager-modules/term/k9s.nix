{ config, lib, theme, ... }:
let
  cfg = config.modules.term.k9s;
  enable = cfg.enable;
in {
  options.modules.term.k9s.enable =
    lib.mkEnableOption "k9s";

  config = lib.mkIf enable {
    programs.k9s = {
      enable = true;

      catppuccin = {
        enable = true;
        flavor = theme.flavor;
        transparent = true;
      };
    };
  };
}
