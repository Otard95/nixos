{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.cmp;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.cmp.enable =
    lib.mkEnableOption "cmp plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.cmp = {
      enable = true;

      settings = {
        completion.completeopt = "menu,menuone,noinsert";
        preselect = nixvim.mkRaw "cmp.PreselectMode.None";
        mapping = {
          "<Tab>" = "cmp.mapping.confirm({ select = true })";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-u>" = "cmp.mapping.scroll_docs(-4)";
          "<C-d>" = "cmp.mapping.scroll_docs(4)";
        };
        sources = [
          { name = "path"; }
          { name = "nvim_lsp"; }
          { name = "nvim_lua"; }
          { name = "luasnip"; }
          { name = "buffer"; }
        ];
        snippet.expand = nixvim.mkRaw ''
          function(args) require('luasnip').lsp_expand(args.body) end
        '';
      };
    };
  };
}
