{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.colorize;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.colorize.enable =
    lib.mkEnableOption "colorize plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.colorizer = {
      enable = true;

      settings.filetypes.markdown.names = false;
    };
  };
}
