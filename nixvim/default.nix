{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim;
  enable = cfg.enable;
in {

  options.modules.nixvim = {
    enable = lib.mkEnableOption "nixvim configuration";

    defaultTerminal = lib.mkOption {
      description = ''
        Set the your default terminal.
        This determines which terminal your window manager will start,
        which tmux and nvim integrations are enabled by default, etc.
      '';
      type = lib.types.enum [ "kitty" "wezterm" ];
      default = "wezterm";
    };
  };

  imports = [
    ./opts.nix
    ./ft-opts.nix
    ./keymap.nix
    ./todo.nix
    ./utils.nix
    ./commands.nix
    ./wezterm-move.nix
    ./plugins
  ];

  config = lib.mkIf enable {
    programs.nixvim = {

      enable = true;
      # package = pkgs.neovim-unwrapped.overrideAttrs  (_: {
      #   pname = "neovim-unwrapped";
      #   version = "0.11.0";

      #   src = pkgs.fetchFromGitHub {
      #     owner = "neovim";
      #     repo = "neovim";
      #     rev = "refs/tags/v0.11.0";
      #     hash = "sha256-UVMRHqyq3AP9sV79EkPUZnVkj0FpbS+XDPPOppp2yFE=";
      #   };
      # });

      nixpkgs.config.allowUnfree = true;

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

      extraPackages = with pkgs; [ kalker ];

      extraConfigLuaPre = ''
        pcall(require, 'local-plugins')
      '';

    };

    modules.nixvim = {
      plugins.enable = lib.mkDefault true;
      wezterm-move.enable = lib.mkDefault (config.modules.nixvim.defaultTerminal == "wezterm"); # (config.modules.term.defaultTerminal == "wezterm")
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
