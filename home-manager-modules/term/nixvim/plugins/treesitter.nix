{ pkgs, ... }:
{
  programs.nixvim.plugins.treesitter = {
    enable = true;

    folding = true;

    settings = {
      indent.enable = true;
      highlight.enable = true;
    };

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
}
