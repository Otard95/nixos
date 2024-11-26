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
    programs.nixvim = {
      enable = true;
      package = pkgs.neovim-unwrapped.overrideAttrs  (_: {
        pname = "neovim-unwrapped";
        version = "0.10.1";

        src = pkgs.fetchFromGitHub {
          owner = "neovim";
          repo = "neovim";
          rev = "refs/tags/v0.10.1";
          hash = "sha256-OsHIacgorYnB/dPbzl1b6rYUzQdhTtsJYLsFLJxregk=";
        };
      });

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
