{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.text-manipulation;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.text-manipulation.enable =
    lib.mkEnableOption "text-manipulation plugins";

  config = lib.mkIf enable {
    programs.nixvim = {
      plugins = {
        commentary.enable = true;
        vim-surround.enable = true;
        visual-multi.enable = true;
        mini.modules = {
          align.enable = true;
        };
      };
      extraPlugins = with pkgs.vimPlugins; [ vim-abolish ];
    };
  };
}
