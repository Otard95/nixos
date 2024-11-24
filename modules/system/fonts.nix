{ config, lib, pkgs, theme, ... }:
let
  cfg = config.modules.system.fonts;
  enable = cfg.enable;
in {

  options.modules.system.fonts.enable = lib.mkEnableOption "fonts";

  config = lib.mkIf enable {
    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;
      packages = with pkgs; [
        meslo-lg
        (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      ];

      fontconfig = {
        defaultFonts = {
          serif = [ theme.font.regular theme.font.icons ];
          sansSerif = [ theme.font.regular theme.font.icons ];
          monospace = [ theme.font.mono theme.font.icons ];
        };
      };
    };
  };
}
