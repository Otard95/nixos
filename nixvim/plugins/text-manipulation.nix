{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.text-manipulation;
  enable = cfg.enable;

  nixvim = config.lib.nixvim;
in {
  options.modules.nixvim.plugins.text-manipulation.enable =
    lib.mkEnableOption "text-manipulation plugins";

  config = lib.mkIf enable {
    programs.nixvim = {

      plugins = {
        commentary.enable = true;
        vim-surround.enable = true;
        visual-multi.enable = true;
        mini = {
          luaConfig.pre = "local spec_treesitter = require('mini.ai').gen_spec.treesitter";
          modules = {
            ai = {
              custom_textobjects = {
                F = nixvim.mkRaw "spec_treesitter({ a = '@function.outer', i = '@function.inner' })";
                c = nixvim.mkRaw "spec_treesitter({ a = '@class.outer', i = '@class.inner' })";
                a = nixvim.mkRaw "spec_treesitter({ a = '@parameter.outer', i = '@parameter.inner' })";
                o = nixvim.mkRaw ''
                  spec_treesitter({
                    a = { '@conditional.outer', '@loop.outer' },
                    i = { '@conditional.inner', '@loop.inner' },
                  })
                '';
              };
              mappings = {
                goto_left = "[[";
                goto_right = "]]";
              };
              n_lines = 500;
            };
            align.enable = true;
          };
        };
      };

      extraPlugins = with pkgs.vimPlugins; [ vim-abolish nvim-treesitter-textobjects ];

    };
  };
}
