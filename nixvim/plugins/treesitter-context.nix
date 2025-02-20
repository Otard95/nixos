{ config, lib, ... }:
let
  cfg = config.modules.nixvim.plugins.treesitter-context;
  enable = cfg.enable;
in {
  options.modules.nixvim.plugins.treesitter-context.enable =
    lib.mkEnableOption "treesitter-context plugin";

  config = lib.mkIf enable {
    programs.nixvim.plugins.treesitter-context = {

      enable = true;

      settings = {
        multiline_threshold = 1;
        mode = "topline";
      };

    };
  };
}
