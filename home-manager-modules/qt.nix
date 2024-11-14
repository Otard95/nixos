{ config, lib, theme, ... }:
let
  cfg = config.modules.qt;
  enable = cfg.enable;
in {

  options.modules.qt.enable = lib.mkEnableOption "qt";

  config = lib.mkIf enable {
    qt = {
      enable = true;
      style.name = "kvantum";
      platformTheme.name = "kvantum";
      style.catppuccin = {
        enable = true;
        flavor = theme.flavor;
        accent = theme.accent;
      };
    };
  };

}
