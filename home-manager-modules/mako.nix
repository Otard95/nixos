{ config, lib, theme, ... }:
let
  cfg = config.modules.mako;
  enable = cfg.enable;
in {

  options.modules.mako.enable = lib.mkEnableOption "mako";

  config = lib.mkIf enable {

    catppuccin.mako = {
      enable = true;
      flavor = theme.flavor;
      accent = theme.accent;
    };

    services.mako = {
      enable = true;

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
