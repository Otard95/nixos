{ config, lib, pkgs, theme, ... }:
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

    i18n.inputMethod = {
      enabled = "fcitx5";
      # fcitx5 = {
      #   waylandFrontend = true;
      #   addons = with pkgs; [
      #     fcitx5-mozc
      #     fcitx5-gtk
      #     fcitx5-configtool
      #   ];
      # };
    };

  };
}
