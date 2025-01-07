{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nixvim.plugins.dadbod;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.dadbod.enable =
    lib.mkEnableOption "dadbod plugin";

  config = lib.mkIf enable {
    programs.nixvim = {
      extraPackages = with pkgs; [
        mariadb
      ];
      plugins = {
        vim-dadbod.enable = true;
        vim-dadbod-completion.enable = true;
        vim-dadbod-ui.enable = true;
      };
    };
  };
}
