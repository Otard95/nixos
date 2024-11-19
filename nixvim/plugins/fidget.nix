{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.fidget;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.fidget.enable =
    lib.mkEnableOption "fidget plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.fidget = {
      enable = true;
    };
  };
}
