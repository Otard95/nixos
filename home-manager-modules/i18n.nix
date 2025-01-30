{ config, lib, theme, ... }:
let
  cfg = config.modules.i18n;
  enable = cfg.enable;
in {
  options.modules.i18n.enable =
    lib.mkEnableOption "i18n";

  config = lib.mkIf enable {

    catppuccin.fcitx5 = {
      enable = true;
      apply = true;
      flavor = theme.flavor;
      accent = theme.accent;
    };

    i18n.inputMethod.enabled = "fcitx5";

  };
}
