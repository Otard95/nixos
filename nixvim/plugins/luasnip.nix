{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.luasnip;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.luasnip.enable =
    lib.mkEnableOption "luasnip plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      keymaps =  map (m: {
        mode = builtins.elemAt m 0;
        key = builtins.elemAt m 1;
        action = builtins.elemAt m 2;
        options = { silent = true; } // builtins.elemAt m 3;
      }) [
        [ "s" "<C-S-n>" (nixvim.mkRaw "function() require('luasnip').jump(1) end") {} ]
        [ "i" "<C-S-n>" (nixvim.mkRaw "function() require('luasnip').jump(1) end") {} ]
        [ "s" "<C-S-p>" (nixvim.mkRaw "function() require('luasnip').jump(-1) end") {} ]
        [ "i" "<C-S-p>" (nixvim.mkRaw "function() require('luasnip').jump(-1) end") {} ]
      ];

      plugins.luasnip = {
        enable = true;

        fromSnipmate = [
          { lazyLoad = true; paths = ../snippets; }
        ];
      };
    };
  };
}
