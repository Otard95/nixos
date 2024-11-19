{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.luasnip;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.luasnip.enable =
    lib.mkEnableOption "luasnip plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.luasnip = {
      enable = true;

      fromSnipmate = [
        { lazyLoad = true; paths = ../snippets; }
      ];
    };
  };
}
