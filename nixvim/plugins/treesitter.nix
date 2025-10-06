{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.treesitter;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.treesitter.enable =
    lib.mkEnableOption "treesitter plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      colorschemes.catppuccin.settings.integrations.nvimtree = true;
      plugins.treesitter = {
        enable = true;

        folding = true;

        settings = {
          indent.enable = true;
          highlight.enable = true;
        };

        languageRegister = { bash = "redis"; };

        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          c
          go
          gomod
          graphql
          html
          http
          javascript
          json
          json5
          jsonc
          lua
          markdown
          markdown_inline
          nix
          php
          phpdoc
          terraform
          tsx
          typescript
          vim
          vimdoc
          yaml
        ];
      };
    };
  };
}
