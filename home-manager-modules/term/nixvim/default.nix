{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim;
  enable = cfg.enable;
in {

  options.modules.nixvim.enable = lib.mkEnableOption "nixvim configuration";

  imports = [
    ./opts.nix
    ./keymap.nix
    ./todo.nix
    ./plugins
  ];

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      wl-clipboard
    ];

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      colorschemes.catppuccin = {
        enable = true;

        settings = {
          flavour = "frappe";
          transparent_background = true;
          term_colors = true;
        };
      };

      clipboard = {
        register = "unnamedplus";
        providers.wl-copy.enable = true;
      };
    };

    modules.nixvim.plugins.enable = lib.mkDefault true;
  };

}
