{ config, lib, theme, ... }:
let
  cfg = config.modules.mako;
  enable = cfg.enable;
in {

  options.modules.mako.enable = lib.mkEnableOption "mako";

  config = lib.mkIf enable {
    services.mako = {
      enable = true;
      catppuccin.enable = true;
      catppuccin.flavor = theme.flavor;
      catppuccin.accent = theme.accent;

      width = 400;
      borderSize = 2;
      borderRadius = 10;
      maxIconSize = 32;
      backgroundColor = lib.mkForce "#303446aa";

      extraConfig = ''
        []
        on-button-middle=dismiss-all

        [mode=do-not-disturb]
        invisible=1
      '';
    };
  };
}
