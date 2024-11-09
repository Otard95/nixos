{ pkgs, ... }:
{
  enable = true;
  catppuccin.enable = false;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
  plugins = [
    (pkgs.vimPlugins.nvim-treesitter.withPlugins (gram: [
      gram.c
      gram.go
      gram.gomod
      gram.graphql
      gram.html
      gram.http
      gram.javascript
      gram.json
      gram.json5
      gram.jsonc
      gram.lua
      gram.markdown
      gram.markdown_inline
      gram.php
      gram.phpdoc
      gram.python
      gram.rust
      gram.terraform
      gram.tsx
      gram.typescript
      gram.vim
      gram.vimdoc
    ]))
  ];
}
