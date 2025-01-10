{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.term.k9s;
  enable = cfg.enable;
in {
  options.modules.term.k9s.enable =
    lib.mkEnableOption "k9s";

  config = lib.mkIf enable {

    modules.term.aws.enable = lib.mkDefault true;

    catppuccin.k9s = {
      enable = true;
      flavor = theme.flavor;
      transparent = true;
    };

    programs.k9s.enable = true;

    home.packages = with pkgs; [ aws-mfa ];

  };
}
