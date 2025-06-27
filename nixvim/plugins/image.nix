{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.image;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.image.enable =
    lib.mkEnableOption "image plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.image = {
      enable = true;
    };
  };
}
