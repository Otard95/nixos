{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.treesitter;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.treesitter.enable =
    lib.mkEnableOption "treesitter plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      # [[BUG] Colorschema off since my last flake update · Issue #4152 · nix-community/nixvim](https://github.com/nix-community/nixvim/issues/4152)
      extraFiles = {
        "queries/ecma/highlights.scm".source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/master/queries/ecma/highlights.scm";
          sha256 = "sha256-N4NFR+uqnBYMrYfqvTg4fUcisbQNRLq1TY5x0f7/m54=";
        };
        "queries/typescript/highlights.scm".source =
          "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/typescript/highlights.scm";
        "queries/typescript/folds.scm".source =
          "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/typescript/folds.scm";
        "queries/typescript/indents.scm".source =
          "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/typescript/indents.scm";
        "queries/typescript/injections.scm".source =
          "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/typescript/injections.scm";
        "queries/typescript/locals.scm".source =
          "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/typescript/locals.scm";
        "queries/tsx/highlights.scm".source =
          "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/tsx/highlights.scm";
        "queries/tsx/folds.scm".source =
          "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/tsx/folds.scm";
        "queries/tsx/indents.scm".source =
          "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/tsx/indents.scm";
        "queries/tsx/injections.scm".source =
          "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/tsx/injections.scm";
        "queries/tsx/locals.scm".source =
          "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/tsx/locals.scm";
      };
      extraConfigLua = ''
        -- nvim-treesitter-grammars uses is-not? in js/jsx queries but the
        -- installed nvim-treesitter plugin version doesn't register that predicate.
        vim.treesitter.query.add_predicate('is-not?', function() return true end, { force = true })
      '';


      plugins.treesitter = {
        enable = true;

        folding.enable = true;
        # indent.enable = true;
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
