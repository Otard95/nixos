{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.indent-blankline;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.indent-blankline.enable =
    lib.mkEnableOption "indent-blankline plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.indent-blankline = {

      enable = true;

    };
  };
}
