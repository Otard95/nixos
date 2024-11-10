{ config, lib, ... }:
let
  cfg = config.modules.term.nixvim;
  enable = cfg.enable;
in {

  options.modules.term.nixvim.enable = lib.mkEnableOption "nixvim configuration";

  imports = [
    ./opts.nix
    ./keymap.nix
    ./todo.nix
    ./plugins
  ];

  config = lib.mkIf enable {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      colorschemes.catppuccin = {
        enable = true;

        settings = {
          flavour = "frappe";
          transparent_background = true;
          integrations = {
            # cmp = true;
            gitsigns = true;
            # notify = false;
            nvimtree = true;
            treesitter = true;
          };
          term_colors = true;
        };
      };
    };
  };

}
