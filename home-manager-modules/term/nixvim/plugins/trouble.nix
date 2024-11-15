{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.trouble;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.trouble.enable =
    lib.mkEnableOption "trouble plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.trouble.enable = true;
  };
}
