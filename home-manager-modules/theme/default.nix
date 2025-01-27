{ config, lib, theme, ... }:
let
  cfg = config.modules.theme;
  enable = cfg.enable;
in {
  options.modules.theme.enable =
    lib.mkEnableOption "theme";

  imports = [
    ./gtk.nix
    ./qt.nix
  ];

  config = lib.mkIf enable {

    modules.theme = {
      gtk.enable = lib.mkDefault true;
      qt.enable  = lib.mkDefault true;
    };

    catppuccin = {
      enable = true;
      inherit (theme) flavor accent;
      cursors.enable = true;
    };
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      hyprcursor.enable = true;
      size = 16;
    };
    home.sessionVariables.HYPRCURSOR_SIZE = lib.mkForce 24;

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
