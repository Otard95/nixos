{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.guess-indent;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.guess-indent.enable =
    lib.mkEnableOption "guess-indent plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.guess-indent = {
      enable = true;
    };
  };
}
