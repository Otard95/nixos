{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.term.btop;
  enable = cfg.enable;
in {

  options.modules.term.btop.enable = lib.mkEnableOption "btop configuration";

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      btop
    ];

    programs.btop = {

      enable = true;

      catppuccin = {
        enable = true;
        flavor = theme.flavor;
      };

      settings = {
        vim_keys = true;
        proc_sorting = "memory";
        proc_tree = true;
        proc_gradient = false;
        theme_background = false;
      };

    };
  };

}
