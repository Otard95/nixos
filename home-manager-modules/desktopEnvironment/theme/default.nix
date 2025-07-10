{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.desktopEnvironment.theme;
  enable = cfg.enable;
in {
  options.modules.desktopEnvironment.theme.enable =
    lib.mkEnableOption "theme";

  imports = [
    ./gtk.nix
    ./qt.nix
  ];

  config = lib.mkIf enable {

    modules.desktopEnvironment.theme = {
      gtk.enable = lib.mkDefault true;
      qt.enable  = lib.mkDefault true;
    };

    catppuccin = {
      enable = true;
      inherit (theme) flavor accent;
      cursors.enable = false;
    };
    home.pointerCursor = {
      name = "rose-pine-hyprcursor";
      package = pkgs.rose-pine-hyprcursor;
      size = 24;
      # gtk.enable = true;
      x11.enable = true;
      hyprcursor.enable = true;
    };

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ theme.font.regular.default theme.font.icons ] ++
          theme.font.regular.extra;
        sansSerif = [ theme.font.regular.default theme.font.icons ] ++
          theme.font.regular.extra;
        monospace = [ theme.font.mono.default theme.font.icons ];
      };
    };

  };
}
