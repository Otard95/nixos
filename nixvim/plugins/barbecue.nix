{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.barbecue;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.barbecue.enable =
    lib.mkEnableOption "barbecue plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.barbecue.enable = true;
  };
}
