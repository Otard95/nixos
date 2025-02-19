{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim;
  enable = cfg.enable;
in {

  options.modules.nixvim.enable = lib.mkEnableOption "nixvim configuration";

  imports = [
    ./opts.nix
    ./ft-opts.nix
    ./keymap.nix
    ./todo.nix
    ./utils.nix
    ./commands.nix
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

      # Enable lazy loading provider
      # plugins.lz-n.enable = true;

      viAlias = true;
      vimAlias = true;

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

      extraConfigLuaPre = ''
        pcall(require, 'local-plugins')
      '';

    };

    modules.nixvim = {
      plugins.enable = lib.mkDefault true;
      ft-opts = {
        c = { commentstring = "//%s"; };
        cpp = { commentstring = "//%s"; };
        php = { shiftwidth = 4; tabstop = 4; };
        json = { formatprg = "jq"; };
        go = { expandtab = false; };
      };
    };
  };
}
