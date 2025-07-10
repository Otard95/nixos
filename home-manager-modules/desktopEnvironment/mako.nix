{ config, lib, theme, ... }:
let
  cfg = config.modules.desktopEnvironment.mako;
  enable = cfg.enable;
in {

  options.modules.desktopEnvironment.mako.enable = lib.mkEnableOption "mako";

  config = lib.mkIf enable {

    catppuccin.mako = {
      enable = true;
      flavor = theme.flavor;
      accent = theme.accent;
    };

    services.mako = {
      enable = true;

      settings = {
        sort = "+time";
        width = 400;
        border-size = 2;
        border-radius = 10;
        max-icon-size = 32;
        background-color = lib.mkForce "#303446aa";
      };

      extraConfig = ''
        []
        on-button-middle=dismiss-all

        [mode=do-not-disturb]
        invisible=1
      '';
    };

  };

}
