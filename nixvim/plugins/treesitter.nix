{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.treesitter;
  enable = cfg.enable;

  # [Issue #4152 · nix-community/nixvim](https://github.com/nix-community/nixvim/issues/4152)
  # nvim-treesitter puts queries under runtime/queries/ which is not on the rtp.
  # This copies them into the nvim config dir so they are found at queries/{grammar}/*.scm.
  mkGrammarFix = grammars:
    lib.concatMapAttrs (grammar: features:
      lib.listToAttrs (map (feature: {
        name = "queries/${grammar}/${feature}.scm";
        value.source = "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/${grammar}/${feature}.scm";
      }) features)
    ) grammars;

in {
  options.modules.nixvim.plugins.treesitter.enable =
    lib.mkEnableOption "treesitter plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      extraFiles = {
        "queries/ecma/highlights.scm".source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/master/queries/ecma/highlights.scm";
          sha256 = "sha256-N4NFR+uqnBYMrYfqvTg4fUcisbQNRLq1TY5x0f7/m54=";
        };
      } // mkGrammarFix {
        typescript = [ "highlights" "folds" "indents" "injections" "locals" ];
        tsx        = [ "highlights" "folds" "indents" "injections" "locals" ];
        php        = [ "highlights" "folds" "indents" "injections" "locals" ];
        php_only   = [ "highlights" "folds" "indents" "injections" "locals" ];
        phpdoc     = [ "highlights" ];
        terraform  = [ "highlights" "folds" "indents" "injections" ];
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

