{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.treesitter;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.treesitter.enable =
    lib.mkEnableOption "treesitter plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      plugins.treesitter = {
        enable = true;

        folding.enable = true;
        indent.enable = true;
        highlight.enable = true;

        languageRegister = {
          bash = "redis";
          php_only = "php";
        };

        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          diff
          http

          html
          css
          svelte
          tsx
          typescript
          javascript
          graphql
          php
          php_only
          phpdoc

          c
          go
          gomod
          zig

          json
          json5
          yaml
          # jsonc

          markdown
          markdown_inline

          lua
          nix
          vim
          vimdoc

          terraform
        ];
      };
    };
  };
}
